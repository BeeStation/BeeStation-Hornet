/*
	This covers demir / rmd compat & mapping tools.

	reference https://github.com/exdal/rmd/blob/master/examples/profiles/tgstation.dm
*/

#if defined(__DEMIR_BAKE__) || defined(CIBUILDING)

#define DEMIR_GROUP_CABLES (1<<0)
#define DEMIR_GROUP_PIPES (1<<1)
#define DEMIR_GROUP_DISPOSALS (1<<2)
#define DEMIR_GROUP_LIGHTS (1<<3)
#define DEMIR_GROUP_CAMERAS (1<<4)
#define DEMIR_GROUP_POWER (1<<5)
#define DEMIR_GROUP_UNDERFLOOR (DEMIR_GROUP_CABLES | DEMIR_GROUP_PIPES | DEMIR_GROUP_DISPOSALS)

#define DEMIR_NODE_BLOCKERS list(/turf/closed, /obj/effect/spawner/structure/window)

/*
	Stand-ins for the subsystems the smoothing and icon code reads.
*/

/datum/controller/subsystem/icon_smooth/demir_preview/New()
	SSicon_smooth = src

/datum/controller/subsystem/mapping/demir_preview/New()
	SSmapping = src

/datum/controller/subsystem/mapping/demir_preview/level_trait(z, trait)
	return null

/datum/controller/subsystem/overlays/demir_preview/New()
	SSoverlays = src
	stats = list()

/datum/controller/subsystem/atoms/demir_preview/New()
	SSatoms = src
	initialized = INITIALIZATION_INSSATOMS

/datum/controller/subsystem/machines/demir_preview/New()
	SSmachines = src

// Overlay lights register with grid cells so mobs can count the light they stand in.
/datum/controller/subsystem/spatial_grid/demir_preview/New()
	SSspatial_grid = src

/datum/controller/subsystem/spatial_grid/demir_preview/get_cells_in_range(atom/center, range)
	return list()

/datum/controller/configuration/demir_preview/New()
	config = src

/datum/controller/configuration/demir_preview/Get(entry_type)
	var/datum/config_entry/entry = entry_type
	return initial(entry.default)

/datum/controller/global_vars/demir_preview/New()
	GLOB = src
	if(!SSmapping)
		SSmapping = new /datum/controller/subsystem/mapping/demir_preview
	if(!SSatoms)
		SSatoms = new /datum/controller/subsystem/atoms/demir_preview
	if(!config)
		config = new /datum/controller/configuration/demir_preview
	if(!SSoverlays)
		SSoverlays = new /datum/controller/subsystem/overlays/demir_preview
	if(!SSmachines)
		SSmachines = new /datum/controller/subsystem/machines/demir_preview
	if(!SSspatial_grid)
		SSspatial_grid = new /datum/controller/subsystem/spatial_grid/demir_preview
	if(!SSicon_smooth)
		SSicon_smooth = new /datum/controller/subsystem/icon_smooth/demir_preview
	bitflag_lists = list()
	gvars_datum_init_order = list()
	cardinals = list(NORTH, EAST, SOUTH, WEST)

/*
	Profile datum
*/

/datum/demir/hornet
	default = TRUE
// Generic setings
	var/smooth = TRUE
	var/lighting = TRUE
	var/show_cables = TRUE
	var/show_pipes = TRUE
	var/show_disposals = TRUE
	var/fade_underfloor = FALSE
	var/show_camera_ranges = FALSE
	var/power_all = TRUE
// Lighting settings
	// Are moveable lights enabled? These are pretty obnoxious in the mapper
	var/moveable_lights = FALSE

/datum/demir/hornet/New()
	..()
	if(!GLOB)
		GLOB = new /datum/controller/global_vars/demir_preview

	// Groups include subtypes, so the /visible pipes are in DEMIR_GROUP_PIPES too. Rebaking
	// them changes nothing.
	demir_define_group(DEMIR_GROUP_CABLES, /obj/structure/cable)
	demir_define_group(DEMIR_GROUP_CABLES, /obj/machinery/power/terminal)
	demir_define_group(DEMIR_GROUP_PIPES, /obj/machinery/atmospherics/pipe)
	demir_define_group(DEMIR_GROUP_PIPES, /obj/machinery/duct)
	demir_define_group(DEMIR_GROUP_DISPOSALS, /obj/structure/disposalpipe)
	demir_define_group(DEMIR_GROUP_DISPOSALS, /obj/structure/disposalconstruct)
	demir_define_group(DEMIR_GROUP_LIGHTS, /obj/machinery/light)
	demir_define_group(DEMIR_GROUP_CAMERAS, /obj/machinery/camera)
	demir_define_group(DEMIR_GROUP_POWER, /obj/machinery)
	demir_define_group(DEMIR_GROUP_POWER, /turf/open/floor/circuit)
	demir_define_group(DEMIR_GROUP_POWER, /obj/item/radio/intercom)

	// Node routes avoid closed turfs. Pipes connect only on the same layer and color, so
	// supply, scrubber and stacked pipes stay separate.
	demir_node_group(/obj/structure/cable, /turf/closed, null, "cable_layer")
	demir_node_group(/obj/machinery/atmospherics/pipe/smart, DEMIR_NODE_BLOCKERS, null, list("piping_layer", "pipe_color"))
	demir_node_group(/obj/machinery/duct, DEMIR_NODE_BLOCKERS, null, list("duct_layer", "duct_color"))
	demir_node_group(/obj/structure/disposalpipe, DEMIR_NODE_BLOCKERS, /obj/structure/disposalpipe/segment)
	demir_node_group(/obj/structure/disposalconstruct, DEMIR_NODE_BLOCKERS)
	register_disposal_node_orientations()

	demir_rotatable(/obj/machinery/atmospherics, GLOB.cardinals)

// ui() writes are rolled back unless the viewer changed something that frame, so panel state
// lives in the profile's vars.
/datum/demir/hornet/ui(atom/target)
	if(!imgui_begin("hornet"))
		imgui_end()
		return

	imgui_separator("Baking")
	var/smoothed = imgui_checkbox("Smoothing", src.smooth)
	if(smoothed != src.smooth)
		src.smooth = smoothed
		// Smoothing is set on too many unrelated types to group.
		demir_rebake(DEMIR_BAKE_APPEARANCE)

	var/lit = imgui_checkbox("Lighting", src.lighting)
	if(lit != src.lighting)
		src.lighting = lit
		// Every area reads the toggle, so this rebakes all lighting.
		demir_rebake(DEMIR_BAKE_LIGHT)
		demir_rebake(DEMIR_BAKE_APPEARANCE, DEMIR_GROUP_LIGHTS)

	imgui_separator("Lighting")
	var/moveable_lights = imgui_checkbox("Moveable Lights", src.moveable_lights)
	if(moveable_lights != src.moveable_lights)
		src.moveable_lights = moveable_lights
		// Smoothing is set on too many unrelated types to group.
		demir_rebake(DEMIR_BAKE_APPEARANCE)

	imgui_separator("Under-floor")
	var/cables = imgui_checkbox("Cables", src.show_cables)
	if(cables != src.show_cables)
		src.show_cables = cables
		demir_rebake(DEMIR_BAKE_APPEARANCE, DEMIR_GROUP_CABLES)

	var/pipes = imgui_checkbox("Pipes", src.show_pipes)
	if(pipes != src.show_pipes)
		src.show_pipes = pipes
		demir_rebake(DEMIR_BAKE_APPEARANCE, DEMIR_GROUP_PIPES)

	var/disposals = imgui_checkbox("Disposals", src.show_disposals)
	if(disposals != src.show_disposals)
		src.show_disposals = disposals
		demir_rebake(DEMIR_BAKE_APPEARANCE, DEMIR_GROUP_DISPOSALS)

	var/fade = imgui_checkbox("Semitransparent", src.fade_underfloor)
	if(fade != src.fade_underfloor)
		src.fade_underfloor = fade
		demir_rebake(DEMIR_BAKE_APPEARANCE, DEMIR_GROUP_UNDERFLOOR)

	imgui_separator("Cameras")
	var/camera_ranges = imgui_checkbox("Show all ranges", src.show_camera_ranges)
	if(camera_ranges != src.show_camera_ranges)
		src.show_camera_ranges = camera_ranges
		demir_rebake(DEMIR_BAKE_HIGHLIGHT, DEMIR_GROUP_CAMERAS)

	imgui_separator("Power")
	var/powered_all = imgui_checkbox("All areas powered", src.power_all)
	if(powered_all != src.power_all)
		src.power_all = powered_all
		demir_rebake(DEMIR_BAKE_LIGHT, DEMIR_GROUP_POWER)
		demir_rebake(DEMIR_BAKE_APPEARANCE, DEMIR_GROUP_POWER)

	imgui_separator("Modular maps")
	var/previewed = imgui_checkbox("Preview modules", demir_modular_preview())
	if(previewed != demir_modular_preview())
		demir_set_modular_preview(previewed)

	imgui_end()

/datum/demir/hornet/bake(atom/target)
	target.demir_bake_appearance()
	target.demir_finish_appearance()

/datum/demir/hornet/prepare(atom/target)
	target.demir_prepare_state()

/datum/demir/hornet/light(atom/target)
	target.demir_apply_light()


/datum/demir/hornet/highlights(atom/target)
	return target.demir_highlights()

// Same DISP_DIR_* rule as the pipe's Initialize().
/datum/demir/hornet/proc/register_disposal_node_orientations()
	for(var/type_path in typesof(/obj/structure/disposalpipe))
		var/obj/structure/disposalpipe/pipe_type = type_path
		var/extra = initial(pipe_type.initialize_dirs)
		for(var/direction in GLOB.cardinals)
			var/openings = 0
			if(extra != DISP_DIR_NONE)
				openings = direction
				if(extra & DISP_DIR_LEFT)
					openings |= turn(direction, 90)
				if(extra & DISP_DIR_RIGHT)
					openings |= turn(direction, -90)
				if(extra & DISP_DIR_FLIP)
					openings |= REVERSE_DIR(direction)
			demir_node_orientation(type_path, direction, openings)
		for(var/direction in GLOB.diagonals)
			demir_node_orientation(type_path, direction, extra == DISP_DIR_NONE ? 0 : direction)

/*
	Atom implementations for the demir shit
*/

/atom/proc/demir_bake_appearance()
	demir_bake_smoothing()

/atom/proc/demir_bake_smoothing()
	var/datum/demir/hornet/profile = demir_profile()
	if(!profile.smooth || !(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK)))
		return
	demir_smooth_icon()

/atom/proc/demir_smooth_icon()
	smooth_icon()

/atom/proc/demir_prepare_state()
	demir_prepare_smoothing()

/atom/proc/demir_prepare_smoothing()
	if(length(canSmoothWith))
		SET_BITFLAG_LIST(canSmoothWith)
	if(length(smoothing_groups))
		SET_BITFLAG_LIST(smoothing_groups)
	if(uses_integrity)
		atom_integrity = max_integrity

/atom/proc/demir_highlights()
	return null

/atom/proc/demir_apply_light()
	//if(light_system != COMPLEX_LIGHT || !light_on || !light_range || !light_power)
	//	return
	demir_light_range = light_range//max(light_range, MINIMUM_USEFUL_LIGHT_RANGE)
	demir_light_power = light_power
	demir_light_color = light_color
	demir_light_dir = dir
	demir_light_height = light_height

/atom/proc/demir_finish_appearance()
	return

/atom/movable/demir_finish_appearance()
	demir_add_overlay_light()
	demir_apply_underfloor()

/proc/demir_area_powered(area/A, chan)
	var/datum/demir/hornet/profile = demir_profile()
	if(profile.power_all)
		return TRUE
	// When unchecked, only areas that need no power are powered.
	return A && !A.requires_power && A.powered(chan)

// Same light_system switch as the end of /atom/movable/Initialize().
/atom/movable/proc/demir_add_overlay_light()
	var/datum/demir/hornet/profile = demir_profile()
	switch(light_system)
		if(MOVABLE_LIGHT)
			if(profile.moveable_lights)
				AddComponent(/datum/component/overlay_lighting)
		if(MOVABLE_LIGHT_DIRECTIONAL)
				AddComponent(/datum/component/overlay_lighting, is_directional = TRUE)
		if(MOVABLE_LIGHT_BEAM)
				AddComponent(/datum/component/overlay_lighting, is_directional = TRUE, is_beam = TRUE)

/obj/machinery/proc/demir_power_change()
	power_change()
	// Subtypes set their light after calling ..() in update_appearance(), so this still runs it.
	update_appearance()

// /datum/element/undertile hides cables and pipes on COMSIG_OBJ_HIDE. Signals do not run in a
// bake, so this reads the turf's underfloor_accessibility instead. Null means the element never
// applies to the type.
/atom/movable/proc/demir_underfloor_shown()
	return null

/atom/movable/proc/demir_apply_underfloor()
	var/shown = demir_underfloor_shown()
	if(isnull(shown))
		return

	var/turf/our_turf = loc
	if(!isturf(our_turf) || our_turf.underfloor_accessibility >= UNDERFLOOR_VISIBLE)
		return

	if(!shown)
		alpha = 0
		return

	var/datum/demir/hornet/profile = demir_profile()
	if(profile.fade_underfloor)
		// ALPHA_UNDERTILE is undefined at the end of undertile.dm.
		alpha = 128

	// The element moves what it leaves visible to FLOOR_PLANE, so pipes draw under the machines on
	// their tile. Cables already there keep the layer offsets they sort by. SET_PLANE_IMPLICIT is
	// skipped because the bake has no multi-z plane offsets. A pipe inside a wall keeps its plane,
	// or the wall would cover it.
	if(plane != FLOOR_PLANE && !isclosedturf(our_turf))
		plane = FLOOR_PLANE

/*
	Highlights
*/

// Cameras, show where they're looking
/obj/machinery/camera/demir_highlights()
	var/turf/origin = get_turf(src)
	if(!origin)
		return null

	var/list/visible = list()
	if(can_use())
		for(var/turf/T in can_see())
			visible[T] = TRUE

	var/list/seen = list()
	var/list/blind = list()
	for(var/turf/T as anything in block(origin.x - view_range, origin.y - view_range, origin.z, origin.x + view_range, origin.y + view_range))
		if(visible[T])
			seen += list(list(T.x - origin.x, T.y - origin.y))
		else
			blind += list(list(T.x - origin.x, T.y - origin.y))

	var/datum/demir/hornet/profile = demir_profile()
	var/when = DEMIR_HIGHLIGHT_SELECTED | DEMIR_HIGHLIGHT_HOVERED
	// Only seen tiles stay on, or the blind tiles of nearby cameras would cover them.
	var/seen_when = profile.show_camera_ranges ? when | DEMIR_HIGHLIGHT_ALWAYS : when
	return list(
		list("tiles" = seen, "color" = "#40c040", "fill" = 0.25, "when" = seen_when),
		list("tiles" = blind, "color" = "#e04040", "fill" = 0.25, "when" = when),
		list("x" = 0, "y" = 0, "width" = 1, "height" = 1, "fill" = 0, "outline" = 0, "when" = when, "label" = jointext(network, ", ")),
	)

// Docking ports, show the docking area
/obj/docking_port/demir_highlights()
	var/list/highlight = demir_highlight()
	return highlight ? list(highlight) : null


/obj/docking_port/proc/demir_highlight()
	if(width < 1 || height < 1)
		return null

	// return_coords() gives two opposite corners in no particular order.
	var/list/corners = return_coords(0, 0)
	return list(
		"x" = min(corners[1], corners[3]),
		"y" = min(corners[2], corners[4]),
		"width" = abs(corners[3] - corners[1]) + 1,
		"height" = abs(corners[4] - corners[2]) + 1,
		"color" = "#ff8000",
		"when" = DEMIR_HIGHLIGHT_SELECTED | DEMIR_HIGHLIGHT_HOVERED,
		"label" = name || "docking port",
	)

/obj/docking_port/mobile/demir_highlight()
	if(!(width && height))
		var/datum/map_template/shuttle/demir_preview/template = new
		template.port_x_offset = x
		template.port_y_offset = y
		//calculate_docking_port_information(template)
	return ..()

/*
	underfloor
*/

/obj/structure/cable/demir_underfloor_shown()
	var/datum/demir/hornet/profile = demir_profile()
	return profile.show_cables

/obj/machinery/power/terminal/demir_underfloor_shown()
	var/datum/demir/hornet/profile = demir_profile()
	return profile.show_cables

// setup_hiding() runs only when hide is set, so the /visible subtypes never take the element.
/obj/machinery/atmospherics/pipe/demir_underfloor_shown()
	var/datum/demir/hornet/profile = demir_profile()
	return hide ? profile.show_pipes : null

/obj/machinery/duct/demir_underfloor_shown()
	var/datum/demir/hornet/profile = demir_profile()
	return profile.show_pipes

/obj/structure/disposalpipe/demir_underfloor_shown()
	var/datum/demir/hornet/profile = demir_profile()
	return profile.show_disposals

/obj/structure/disposalconstruct/demir_underfloor_shown()
	var/datum/demir/hornet/profile = demir_profile()
	return profile.show_disposals

/*
	Lighting tweaks
*/

// The light hook replaces /datum/light_source, so set_light() only stores its values on the
// atom.
/atom/update_light()
	return

/obj/machinery/light/demir_apply_light() //Rewrote this to make it work. It's not accurate to TG - Racc
	setDir(dir)
	demir_light_range = max(brightness, MINIMUM_USEFUL_LIGHT_RANGE)
	demir_light_power = bulb_power
	demir_light_color = bulb_colour
	demir_light_height = light_height

// A border object blocks only one side, but lighting corners only check whether the whole tile
// is blocked. IS_OPAQUE_TURF needs ALL_CARDINALS.
/atom/movable/demir_apply_light()
	if(opacity && (flags_1 & ON_BORDER_1))
		demir_blocks_light = 0
	return ..()

/obj/machinery/demir_apply_light()
	demir_calculating_light = TRUE
	demir_power_change()
	demir_calculating_light = FALSE
	return ..()

/turf/open/floor/circuit/demir_apply_light()
	if(!always_off && demir_area_powered(get_area(src), AREA_USAGE_LIGHT))
		on = TRUE
		set_light_color(initial(light_color))
		set_light(2, 1.5)
	else
		on = FALSE
		set_light(0)
	return ..()

// Same as the lava's Initialize(). Only lava next to another turf type casts light.
/turf/open/lava/demir_apply_light()
	refresh_light()
	// The preview has no plane offsets, so refresh_light() never checks the levels above and below.
	if(!light_on)
		for(var/turf/around as anything in block(x - 1, y - 1, z - 1, x + 1, y + 1, z + 1))
			if(!islava(around))
				set_light(l_on = TRUE)
				break
	return ..()

/area/demir_apply_light()
	// Turning lighting off makes the whole map fullbright instead of dark.
	var/datum/demir/hornet/profile = demir_profile()
	demir_fullbright = !profile.lighting || !static_lighting
	demir_ambient_color = base_lighting_color
	demir_ambient_power = base_lighting_alpha / 255

/*
	Smoothing tweaks
	Changes made to atoms to make them smooth in the editor, some are kinda hacky
*/

// Tables - We add a a flag here to hack the smoothing helpers. Otherwise shit don't work
/obj/structure/table/demir_prepare_state()
	smoothing_flags |=  SMOOTH_OBJ
	return ..()

// Lattice
/obj/structure/lattice/demir_prepare_state()
	smoothing_flags |=  SMOOTH_OBJ
	return ..()

// Atmospherics / Pipes
/obj/machinery/atmospherics/demir_prepare_state()
	..()
	if(pipe_flags & PIPING_CARDINAL_AUTONORMALIZE)
		normalize_cardinal_directions()
	set_init_directions(initialize_directions)

/obj/machinery/atmospherics/demir_bake_appearance()
	// GAGS icons are built at runtime, so keep the mapped icon_state.
	var/preview_state = icon_state
	var/gags = greyscale_config
	greyscale_config = null
	nodes = list()
	nodes.len = device_type
	atmos_init()
	if(gags)
		icon_state = preview_state

/*
	General appearance tweaks
*/

/turf/open/floor/light/demir_prepare_state()
	..()
	update_appearance()

// Same as the switch's Initialize(). Its icon and light read the area it controls.
/obj/machinery/light_switch/demir_prepare_state()
	..()
	if(istext(area))
		area = text2path(area)

	if(ispath(area))
		area = GLOB.areas_by_type[area]

	if(!area)
		area = get_area(src)

/obj/machinery/light/demir_bake_appearance()
	var/datum/demir/hornet/profile = demir_profile()
	if(profile.lighting)
		update_appearance(UPDATE_ICON)
	return demir_bake_smoothing()

#undef DEMIR_NODE_BLOCKERS
#undef DEMIR_GROUP_CABLES
#undef DEMIR_GROUP_PIPES
#undef DEMIR_GROUP_DISPOSALS
#undef DEMIR_GROUP_LIGHTS
#undef DEMIR_GROUP_CAMERAS
#undef DEMIR_GROUP_POWER
#undef DEMIR_GROUP_UNDERFLOOR

#endif
