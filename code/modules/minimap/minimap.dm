/**
 * One pixel per turf via icon.DrawBox(), cropped and scaled up. Rendered areas also decompose
 * into rectangles for overlays. One pass, lazy, cached for the round.
 */

/// Assoc list of z-levels to /datum/minimap instances.
GLOBAL_ALIST_EMPTY(minimaps)

/**
 * Carries rendered minimaps to clients through tgui's asset pipeline.
 *
 * Has to be a real asset datum. tgui sends ui_assets() during window open and blocks on the
 * flush. Go around it and the interface gets a URL for a resource the client never got.
 */
/datum/asset/minimap
	/// Assoc of asset filename to /datum/asset_cache_item, one per rendered z-level.
	var/list/rendered = list()

/datum/asset/minimap/proc/add_map(asset_name, icon/rendered_map)
	rendered[asset_name] = SSassets.transport.register_asset(asset_name, rendered_map)

/datum/asset/minimap/send(client)
	if(!length(rendered))
		return
	return SSassets.transport.send_assets(client, rendered)

/datum/asset/minimap/get_url_mappings()
	. = list()
	for(var/asset_name in rendered)
		.[asset_name] = SSassets.transport.get_asset_url(asset_name, rendered[asset_name])

/datum/asset/minimap/unregister()
	for(var/asset_name in rendered)
		SSassets.transport.unregister_asset(asset_name)
	rendered = list()

/datum/minimap
	VAR_FINAL/z
	var/icon/base_map
	/// Name the rendered base map is registered under with the asset transport.
	var/asset_name
	/// World coordinate bounds of the crop.
	var/min_x = 1
	var/min_y = 1
	var/max_x = 1
	var/max_y = 1
	/// Size of the cropped map, measured in turfs.
	var/width = 0
	var/height = 0
	/**
	 * List of rendered areas, each an assoc list of:
	 * * ref - REF() of the area, the key consumers should send live state under.
	 * * name - display name of the area.
	 * * rects - list of list(x, y, w, h) in cropped map space, top-left origin.
	 *
	 * Cropped map space matches the icon's aspect, in turfs, y already flipped to image top.
	 */
	var/list/areas = list()

/datum/minimap/Destroy()
	asset_name = null
	base_map = null
	areas = null
	return ..()

/datum/minimap/proc/load_z(z)
	. = FALSE
	if(!isnum(z) || z > length(SSmapping.z_list))
		CRASH("Tried to create minimap for invalid Z-level ([z])")

	// A transparent canvas, one pixel per turf. Crop it once we know which turfs rendered.
	base_map = icon('icons/blanks/32x32.dmi', "nothing")
	base_map.Scale(world.maxx, world.maxy)
	src.z = z

	var/min_x = world.maxx
	var/min_y = world.maxy
	var/max_x = 1
	var/max_y = 1

	// area to assoc list of "[y]" to list of x coordinates rendered on that row.
	var/list/area_rows = list()

	for(var/turf/location as anything in Z_TURFS(z))
		// Shuttles move. Their turfs would bake into the wrong place on the backdrop.
		if(location.skip_minimap_rendering || istype(location.loc, /area/shuttle))
			continue
		var/area/arealoc = location.loc
		if(arealoc.skip_minimap_rendering)
			continue
		var/x = location.x
		var/y = location.y
		min_x = min(min_x, x)
		min_y = min(min_y, y)
		max_x = max(max_x, x)
		max_y = max(max_y, y)

		var/list/rows = area_rows[arealoc]
		if(!rows)
			rows = list()
			area_rows[arealoc] = rows
		var/y_key = "[y]"
		var/list/row = rows[y_key]
		if(!row)
			row = list()
			rows[y_key] = row
		row += x

		if(location.density)
			base_map.DrawBox(location.tacmap_color, x, y)
			continue
		var/atom/movable/alttarget = (locate(/obj/machinery/door) in location) || (locate(/obj/structure/window) in location) || (locate(/obj/structure/grille) in location)
		if(alttarget)
			base_map.DrawBox(alttarget.tacmap_color, x, y)
			continue
		if(arealoc.tacmap_color)
			base_map.DrawBox(BlendRGB(location.tacmap_color, arealoc.tacmap_color, 0.5), x, y)
			continue
		base_map.DrawBox(location.tacmap_color, x, y)
		CHECK_TICK

	if(max_x < min_x || max_y < min_y)
		return FALSE

	src.min_x = min_x
	src.min_y = min_y
	src.max_x = max_x
	src.max_y = max_y
	width = max_x - min_x + 1
	height = max_y - min_y + 1

	base_map.Crop(min_x, min_y, max_x, max_y)
	base_map.Scale(base_map.Width() * MINIMAP_PIXEL_MULTIPLIER, base_map.Height() * MINIMAP_PIXEL_MULTIPLIER)

	asset_name = "minimap_[z]_[world.time].png"
	var/datum/asset/minimap/asset = get_asset_datum(/datum/asset/minimap)
	asset.add_map(asset_name, base_map)

	build_area_rects(area_rows)
	return TRUE

/datum/minimap/proc/build_area_rects(list/area_rows)
	areas = list()
	for(var/area/rendered_area as anything in area_rows)
		var/list/rects = list()
		for(var/list/bounds as anything in decompose_rows_to_rects(area_rows[rendered_area]))
			rects += list(to_map_rect(bounds[1], bounds[2], bounds[3], bounds[4]))

		areas += list(list(
			"ref" = REF(rendered_area),
			"name" = get_area_name(rendered_area, TRUE),
			"department" = rendered_area.minimap_department,
			"anchor" = rendered_area.minimap_department_anchor,
			"rects" = rects,
		))
		CHECK_TICK

/**
 * Greedily decomposes a set of occupied cells into rectangles, in world space.
 *
 * Takes "[y]" to list of x on that row, returns list(x1, y1, x2, y2) inclusive bounds. Rows
 * become horizontal runs, then runs sharing columns on adjacent rows merge vertically.
 *
 * Kept clear of turfs and areas to keep it unit testable. A mistake here misaligns the overlay
 * silently
 */
/proc/decompose_rows_to_rects(list/rows)
	// "[x1]-[x2]" -> list of y coordinates sharing that horizontal run.
	var/list/spans = list()
	for(var/y_key in rows)
		var/y = text2num(y_key)
		var/list/row = rows[y_key]
		var/list/xs = sortTim(row.Copy())
		var/run_start = xs[1]
		var/previous = xs[1]
		for(var/i in 2 to length(xs))
			var/x = xs[i]
			if(x == previous + 1)
				previous = x
				continue
			LAZYADD(spans["[run_start]-[previous]"], y)
			run_start = x
			previous = x
		LAZYADD(spans["[run_start]-[previous]"], y)

	var/list/rects = list()
	for(var/span_key in spans)
		var/list/span_bounds = splittext(span_key, "-")
		var/x1 = text2num(span_bounds[1])
		var/x2 = text2num(span_bounds[2])
		var/list/span_rows = spans[span_key]
		var/list/ys = sortTim(span_rows.Copy())
		var/run_start = ys[1]
		var/previous = ys[1]
		for(var/i in 2 to length(ys))
			var/y = ys[i]
			if(y == previous + 1)
				previous = y
				continue
			rects += list(list(x1, run_start, x2, previous))
			run_start = y
			previous = y
		rects += list(list(x1, run_start, x2, previous))
	return rects

/// World-space rect to cropped map space. Origin top left, y down, measured in turfs.
/datum/minimap/proc/to_map_rect(x1, y1, x2, y2)
	return list(
		x1 - min_x,
		max_y - y2,
		x2 - x1 + 1,
		y2 - y1 + 1,
	)

/// Generates the Z-level's /datum/minimap if it hasn't been yet.
/proc/get_minimap_for_z(z) as /datum/minimap
	var/static/generating_minimap = FALSE
	UNTIL(!generating_minimap)

	if(GLOB.minimaps[z])
		return GLOB.minimaps[z]

	generating_minimap = TRUE
	var/datum/minimap/minimap = new
	if(minimap.load_z(z))
		GLOB.minimaps[z] = minimap
		. = minimap
	generating_minimap = FALSE
