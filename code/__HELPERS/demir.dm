#ifdef __DEMIR_BAKE__

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
	//TODO: idk if I like this here - Racc
	cardinals = list(NORTH, EAST, SOUTH, WEST)

/*
	Profile datum
*/

/datum/demir/hornet
	default = TRUE

/datum/demir/hornet/bake(atom/target)
	target.demir_bake_appearance()

/datum/demir/hornet/prepare(atom/target)
	target.demir_prepare_state()

/datum/demir/hornet/light(atom/target)
	target.demir_apply_light()

/datum/demir/hornet/New() //TODO: make sure this works - racc
	..()
	if(!GLOB)
		GLOB = new /datum/controller/global_vars/demir_preview

/*

*/

/atom/proc/demir_bake_appearance()
	demir_bake_smoothing()

/atom/proc/demir_bake_smoothing()
	//TODO: profile checking is borked- Racc
	//var/datum/demir/hornet/profile = demir_profile()
	//if(profile)//|| !(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK)))
	//	return
	if(!(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK)))
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

/atom/proc/demir_apply_light()
	//if(light_system != COMPLEX_LIGHT || !light_on || !light_range || !light_power)
	//	return
	demir_light_range = light_range//max(light_range, MINIMUM_USEFUL_LIGHT_RANGE)
	demir_light_power = light_power
	demir_light_color = light_color
	// demir_light_angle = light_angle
	// demir_light_dir = light_dir
	/*
	TODO: doesnt exist - Racc
	var/list/light_offset = get_light_offset()
	// The game adds these offsets to the sample position, which moves the source the opposite way.
	demir_light_offset_x = -light_offset[1]
	demir_light_offset_y = -light_offset[2]
	*/
	demir_light_height = light_height

/proc/demir_area_powered(area/A, chan)
	//var/datum/demir/hornet/profile = demir_profile()
	//if(profile.power_all)
	//	return TRUE
	//TODO: Profile broken - Racc
	// When unchecked, only areas that need no power are powered.
	return A && !A.requires_power && A.powered(chan)

// Same light_system switch as the end of /atom/movable/Initialize().
/atom/movable/proc/demir_add_overlay_light()
	switch(light_system)
		if(MOVABLE_LIGHT)
			AddComponent(/datum/component/overlay_lighting)
		if(MOVABLE_LIGHT_DIRECTIONAL)
			AddComponent(/datum/component/overlay_lighting, is_directional = TRUE)
		if(MOVABLE_LIGHT_BEAM)
			AddComponent(/datum/component/overlay_lighting, is_directional = TRUE, is_beam = TRUE)

/obj/machinery/proc/demir_power_change()
	power_change()
	// Subtypes set their light after calling ..() in update_appearance(), so this still runs it.
	update_appearance()

/*
	Lighting tweaks
*/

// The light hook replaces /datum/light_source, so set_light() only stores its values on the
// atom.
/atom/update_light()
	return

// Fixtures start with `on = FALSE`. Initialize() aims the light with setDir(), and
// post_machine_initialize() turns it on from the area's lightswitch and power. power_change()
// reads the area channel directly, so the power checkbox is applied here instead.
/obj/machinery/light/demir_apply_light() //TODO: rewrote this to make it work - Racc
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
	if(!always_off) //&& demir_area_powered(get_area(src), AREA_USAGE_LIGHT)) //TODO: profiles r broken - racc
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
	//var/datum/demir/hornet/profile = demir_profile()
	//if(profile.lighting)
	//	update_appearance(UPDATE_ICON) // TODO: profile is broken - Racc
	return demir_bake_smoothing()

#endif
