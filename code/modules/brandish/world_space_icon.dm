/// Draws a world-space transform correctly in all four native camera headings.
/// Four shared sparse DMI sheets gate the appearances; only one is visible to
/// each client. This also handles nonuniform scale (long hitscan tracers), for
/// which simply rotating the source bitmap before scaling would be incorrect.
/datum/world_space_icon
	/// Atom or an owned world overlay image (never a client.images entry).
	var/image/owner
	var/source_icon
	var/list/layers = list()
	/// Catalog lookups, resolved once per source icon rather than per refresh.
	var/resolved_icon
	var/list/gates
	var/list/state_dirs
	/// Whether the gated layers are currently shown in place of the source icon.
	var/projected = FALSE
	/// External overlay replacement invalidates the cached presentation too.
	var/layers_dirty = FALSE
	/// Last projected inputs. Compared numerically: projectiles refresh every
	/// movement step, so a formatted signature string per call is wasteful.
	var/last_state
	var/last_dir
	var/last_a
	var/last_b
	var/last_c
	var/last_d
	var/last_e
	var/last_f

/datum/world_space_icon/New(image/target)
	owner = target
	source_icon = target.icon
	return ..()

/datum/world_space_icon/Destroy()
	clear_layers()
	owner = null
	layers = null
	return ..()

/datum/world_space_icon/proc/clear_layers()
	if(isatom(owner))
		var/atom/target = owner
		target.cut_overlay(layers)
	else if(owner)
		owner.overlays -= layers

/datum/world_space_icon/proc/show_layers()
	if(isatom(owner))
		var/atom/target = owner
		target.add_overlay(layers)
	else
		owner.overlays += layers

/datum/world_space_icon/proc/refresh(force = FALSE)
	var/static/blank = 'icons/blanks/32x32.dmi'
	if(owner.icon != blank)
		source_icon = owner.icon
	if(resolved_icon != source_icon)
		resolved_icon = source_icon
		GLOB.brandish_assets.prepare()
		var/list/entry = GLOB.brandish_assets.aliases[source_icon]
		gates = entry?[BRANDISH_ASSET_VIEW_GATES]
		state_dirs = entry?["stateDirs"]
		force = TRUE
	var/state = owner.icon_state
	var/num_dirs = state_dirs?[state]
	if(!GLOB.brandish_assets.enabled || !gates || !num_dirs)
		if(projected)
			clear_layers()
			layers.Cut()
			owner.icon = source_icon
			projected = FALSE
			layers_dirty = FALSE
			return TRUE
		layers_dirty = FALSE
		return FALSE
	var/art_dir = owner.dir
	if(num_dirs == 1 || !art_dir)
		art_dir = SOUTH
	else if(num_dirs == 4 && !(art_dir in GLOB.cardinals))
		art_dir = (art_dir & EAST) ? EAST : WEST
	var/matrix/world_transform = owner.transform || matrix()
	if(!force && projected && !layers_dirty && state == last_state && art_dir == last_dir \
		&& world_transform.a == last_a && world_transform.b == last_b && world_transform.c == last_c \
		&& world_transform.d == last_d && world_transform.e == last_e && world_transform.f == last_f)
		return FALSE
	last_state = state
	last_dir = art_dir
	last_a = world_transform.a
	last_b = world_transform.b
	last_c = world_transform.c
	last_d = world_transform.d
	last_e = world_transform.e
	last_f = world_transform.f
	clear_layers()
	owner.icon = blank
	projected = TRUE
	var/index = 0
	for(var/facing in GLOB.cardinals)
		index++
		// Explicit overlay dir needs /image on BYOND (see mutable_appearance.dm).
		// Reuse four world overlays, never entries in a client's images list.
		var/image/layer
		if(index <= length(layers))
			layer = layers[index]
		else
			layer = image(dir = NORTH, layer = FLOAT_LAYER)
			layer.appearance_flags = RESET_TRANSFORM
			layers += layer
		layer.icon = gates["[facing]"]
		layer.icon_state = "[state]@[art_dir]"
		layer.transform = projection_for(facing, world_transform)
	show_layers()
	layers_dirty = FALSE
	return TRUE

/// Called only for dirty inputs, before the overlay appearance is attached.
/datum/world_space_icon/proc/projection_for(facing, matrix/world_transform)
	var/matrix/projection = matrix(world_transform)
	projection.Turn(-dir2angle(facing))
	return projection

/atom
	var/datum/world_space_icon/world_space_icon

/// Use for geometry whose angle/scale is defined in world coordinates. Sprite
/// pivot corrections stay in pixel_w/z; trajectory positions stay in pixel_x/y.
/atom/proc/set_world_transform(matrix/new_transform)
	transform = new_transform
	if(!GLOB.brandish_assets.enabled && !world_space_icon)
		return
	if(!world_space_icon)
		world_space_icon = new(src)
	world_space_icon.refresh()

/// Whole world geometry, including rectangular canvases and multi-tile bounds.
/// Keep the owner's map pixel offsets and gameplay bounds unchanged. Rotate
/// the canvas centre with the world, then undo BYOND's native bounds anchor.
/datum/world_space_icon/geometry
	var/atom/movable/bounds_owner
	var/last_bound_width
	var/last_bound_height
	var/last_bound_x
	var/last_bound_y
	var/canvas_source
	var/centre_x
	var/centre_y

/datum/world_space_icon/geometry/New(image/target, atom/movable/footprint = target)
	bounds_owner = footprint
	return ..()

/datum/world_space_icon/geometry/Destroy()
	bounds_owner = null
	return ..()

/datum/world_space_icon/geometry/refresh(force = FALSE)
	var/bounds_changed = last_bound_width != bounds_owner.bound_width || last_bound_height != bounds_owner.bound_height \
		|| last_bound_x != bounds_owner.bound_x || last_bound_y != bounds_owner.bound_y
	last_bound_width = bounds_owner.bound_width
	last_bound_height = bounds_owner.bound_height
	last_bound_x = bounds_owner.bound_x
	last_bound_y = bounds_owner.bound_y
	return ..(force || bounds_changed)

/datum/world_space_icon/geometry/projection_for(facing, matrix/world_transform)
	if(canvas_source != source_icon)
		canvas_source = source_icon
		var/list/size = get_icon_dimensions(source_icon)
		centre_x = (size["width"] - ICON_SIZE_X) / 2
		centre_y = (size["height"] - ICON_SIZE_Y) / 2
	var/list/centre = camera_world_to_screen(centre_x, centre_y, facing)
	var/dx = centre[1] - centre_x
	var/dy = centre[2] - centre_y
	APPLY_BRANDISH_BOUNDS_OFFSET(dx, dy, bounds_owner, facing)
	var/matrix/projection = ..()
	// Matrix translation preserves the half-pixel pivot of odd canvases,
	// such as the 355x76 cannon, without rounding pixel_w/z independently.
	projection.Translate(dx, dy)
	return projection

/// Snapshot an owned geometry overlay into an ordinary appearance. Its four
/// sparse children use the same footprint correction as the atom's body.
/atom/movable/proc/brandish_geometry_overlay(state, overlay_layer = FLOAT_LAYER)
	var/image/drawing = image(initial(icon), icon_state = state, layer = overlay_layer, dir = dir)
	var/datum/world_space_icon/geometry/projector = new(drawing, src)
	projector.refresh()
	var/mutable_appearance/result = new(drawing.appearance)
	qdel(projector)
	return result
