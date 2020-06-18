/obj/machinery/computer/system_map
	name = "system map console"
	desc = "system map here"
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/security
	light_color = LIGHT_COLOR_RED
	ui_x = 870
	ui_y = 708

	var/datum/weakref/linked_bluespace_drive

	//A list of all the icons used on the starmap
	var/static/list/starmap_icons_cache
	var/shuttle_id

/obj/machinery/computer/system_map/exploration
	shuttle_id = "exploration"

/obj/machinery/computer/system_map/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	//Locate the shuttle ID we are attatched to (if we are attatched)
	if(!shuttle_id)
		var/turf/our_turf = get_turf(src)
		for(var/obj/docking_port/mobile/M as anything in SSbluespace_exploration.tracked_ships)
			if(M.z != z)
				continue
			if(our_turf in M.return_turfs())
				shuttle_id = M.id
				break
	//Locate the bluespace drive
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttle_id)
	if(M)
		for(var/obj/machinery/bluespace_drive/BSD as anything in GLOB.bluespace_drives)
			if(BSD in M.return_turfs())
				linked_bluespace_drive = WEAKREF(BSD)
				break
	//expertly copypasted from pill_press, with some minor altercations to make use of staticness
	starmap_icons_cache = list()
	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/starmap)
	for(var/key in assets.assets)
		var/list/asset = list()
		asset["id"] = key
		asset["class_name"] = assets.icon_class_name(key)
		starmap_icons_cache += list(asset)

/obj/machinery/computer/system_map/ui_base_html(html)
	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/starmap)
	. = replacetext(html, "<!--customheadhtml-->", assets.css_tag())

/obj/machinery/computer/system_map/ui_interact(\
		mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
		datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	if(!shuttle_id)
		to_chat(usr, "<span class='warning'>Console not attatched to a bluespace capable shuttle.</span>")
		return
	// Update UI
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		//Send assets
		var/datum/asset/assets = get_asset_datum(/datum/asset/spritesheet/simple/starmap)
		assets.send(user)
		// Open UI
		ui = new(user, src, ui_key, "SystemMap", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/computer/system_map/ui_act(action, params)
	switch(action)
		if("jump")
			return

/obj/machinery/computer/system_map/ui_data(mob/user)
	var/list/data = list()
	data["jump_locations"] = list()
	for(var/datum/star_system/star as anything in SSbluespace_exploration.current_system)
		data["jump_locations"] += list(
			"name" = star.name,
			"id" = star.unique_id,
		)
	return data

/obj/machinery/computer/system_map/ui_static_data(mob/user)
	var/list/data = list()
	data["icon_cache"] = starmap_icons_cache
	data["stars"] = list()
	data["links"] = list()
	data["jump_state"] = linked_bluespace_drive ? TRUE : FALSE
	for(var/datum/star_system/star as anything in SSbluespace_exploration.star_systems)
		var/list/formatted_star = list(
			"name" = star.name,
			"x" = star.map_x,
			"y" = star.map_y,
			"orbitting" = SSbluespace_exploration.current_system == star,
			"can_jump" = SSbluespace_exploration.current_system ? (star in SSbluespace_exploration.current_system.linked_stars) : FALSE,
		)
		data["stars"] += list(formatted_star)
	for(var/datum/star_link/link as anything in SSbluespace_exploration.star_links)
		var/list/formatted_link = list(
			"x1" = link.x1,
			"y1" = link.y1,
			"x2" = link.x2,
			"y2" = link.y2
		)
		data["links"] += list(formatted_link)
	return data
