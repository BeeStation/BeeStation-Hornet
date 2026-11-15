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
		gates = entry?["viewGates"]
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
		return
	var/art_dir = owner.dir
	if(num_dirs == 1 || !art_dir)
		art_dir = SOUTH
	else if(num_dirs == 4 && !(art_dir in GLOB.cardinals))
		art_dir = (art_dir & EAST) ? EAST : WEST
	var/matrix/world_transform = owner.transform || matrix()
	if(!force && projected && state == last_state && art_dir == last_dir 		&& world_transform.a == last_a && world_transform.b == last_b && world_transform.c == last_c 		&& world_transform.d == last_d && world_transform.e == last_e && world_transform.f == last_f)
		return
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
		var/matrix/projection = matrix(world_transform)
		projection.Turn(-dir2angle(facing))
		layer.transform = projection
	show_layers()

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
