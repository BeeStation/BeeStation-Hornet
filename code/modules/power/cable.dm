GLOBAL_LIST_INIT(cable_colors, list(
	"yellow" = "#ffff00",
	"green" = "#00aa00",
	"pink" = "#ff3cc8",
	"orange" = "#ff8000",
	"red" = "#ff0000",
	"white" = "#ffffff"
	))

/proc/get_cable(turf/location, cable_color, omni)
	for (var/obj/structure/cable/cable in location)
		if (cable.omni || omni || cable.cable_color == cable_color)
			return cable

////////////////////////////////
// Definitions
////////////////////////////////

/obj/structure/cable
	name = "power cable"
	desc = "A flexible, superconducting insulated cable for heavy-duty power transfer."
	icon = 'icons/obj/power_cond/cables.dmi'
	icon_state = "0-1-2-4-8"
	layer = WIRE_LAYER //Above hidden pipes, GAS_PIPE_HIDDEN_LAYER
	anchored = TRUE
	obj_flags = CAN_BE_HIT
	flags_1 = STAT_UNIQUE_1
	var/datum/powernet/powernet
	/// Are we a single cable that wants to be a node?
	var/has_power_node = FALSE
	/// Have we been manually given a power node and should keep it when we change?
	var/forced_power_node = FALSE
	/// List of cables that are connected to this cable.
	var/list/connected = list()
	/// Number of cables connected to the north of this cable, can be greater than 1 for omni cables.
	var/north_count = 0
	/// Number of cables connected to the east of this cable, can be greater than 1 for omni cables.
	var/east_count = 0
	/// Number of cables connected to the south of this cable, can be greater than 1 for omni cables.
	var/south_count = 0
	/// Number of cables connected to the west of this cable, can be greater than 1 for omni cables.
	var/west_count = 0
	/// Direction flag which specifies in what direction this cable connects to omni cables.
	var/omni_dirs = NONE
	/// Reference to the cable that is above us.
	var/obj/structure/cable/up
	/// Reference to the cable that is below us.
	var/obj/structure/cable/down
	/// Are we an omni cable?
	var/omni = FALSE
	/// Are we a multi-z cable?
	var/multiz = FALSE
	// Sound loop for transformer boxes
	VAR_PRIVATE/datum/looping_sound/transformer/sound_loop = null

	FASTDMM_PROP(\
		pipe_type = PIPE_TYPE_CABLE,\
		pipe_interference_group = list("cable"),\
		pipe_group = "cable-[cable_color]"\
	)

	var/cable_color = "red"
	color = "#ff0000"

// the power cable object
CREATION_TEST_IGNORE_SUBTYPES(/obj/structure/cable)

/obj/structure/cable/Initialize(mapload, param_color, multiz = FALSE)
	. = ..()

// If building for CI then we will check to ensure that cables are not incorrectly overlapping.
#ifdef CIBUILDING
	for (var/obj/structure/cable/cable in get_turf(src))
		if (cable == src || cable.cable_color != cable_color || omni || cable.omni)
			continue
		stack_trace("A cable was created when one already exists at [COORD(src)].")
		return INITIALIZE_HINT_QDEL
#endif

	var/list/cable_colors = GLOB.cable_colors
	cable_color = param_color || cable_color || pick(cable_colors)

	// Check for multi-z status on mapload
	if (multiz || (mapload && isopenspace(loc) && !(locate(/obj/structure/lattice/catwalk) in loc)))
		var/turf/current_turf = loc
		var/obj/structure/cable/below_cable = locate(/obj/structure/cable) in GET_TURF_BELOW(current_turf)
		if (below_cable)
			down = below_cable
			below_cable.up = src
			below_cable.update_appearance(UPDATE_ICON)
			// Make sure to record this so that we can reform on multi-z shuttle movements
			src.multiz = TRUE
			below_cable.multiz = TRUE

	// Locate adjacent tiles
	reform_connections()

	pixel_x = 0
	pixel_y = 0

	GLOB.cable_list += src //add it to the global cable list

	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE)

	update_appearance(UPDATE_ICON)
	linkup_adjacent(!mapload)
	if(isturf(loc))
		var/turf/turf_loc = loc
		turf_loc.add_blueprints_preround(src)

/obj/structure/cable/Destroy()					// called when a cable is deleted
	// Update our neighbors
	clear_connections()
	if(powernet)
		cut_cable_from_powernet()				// update the powernets
	GLOB.cable_list -= src							//remove it from global cable list
	if (sound_loop)
		QDEL_NULL(sound_loop)
	return ..()									// then go ahead and delete the cable

/// Explicitly reject edits of managed variabled
/obj/structure/cable/vv_edit_var(vname, vval)
	switch (vname)
		if (NAMEOF(src, connected))
			return FALSE
		if (NAMEOF(src, north_count))
			return FALSE
		if (NAMEOF(src, east_count))
			return FALSE
		if (NAMEOF(src, south_count))
			return FALSE
		if (NAMEOF(src, west_count))
			return FALSE
		if (NAMEOF(src, omni_dirs))
			return FALSE
		if (NAMEOF(src, up))
			return FALSE
		if (NAMEOF(src, down))
			return FALSE
		if (NAMEOF(src, powernet))
			return FALSE
		if (NAMEOF(src, has_power_node))
			return FALSE
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/structure/cable/proc/clear_connections()
	for (var/obj/structure/cable/connected_cable in connected)
		connected_cable.connected -= src
		switch (get_dir(connected_cable, src))
			if (NORTH)
				connected_cable.clear_north()
			if (SOUTH)
				connected_cable.clear_south()
			if (EAST)
				connected_cable.clear_east()
			if (WEST)
				connected_cable.clear_west()
		connected_cable.omni_dirs &= ~(get_dir(connected_cable, src))
		connected_cable.update_appearance(UPDATE_ICON)
	down?.set_up(null)
	up?.set_down(null)

/obj/structure/cable/proc/reform_connections()
	for (var/obj/structure/cable/north_cable in get_step(src, NORTH))
		if (!north_cable.omni && !omni && north_cable.cable_color != cable_color)
			continue
		connected += north_cable
		north_count++
		north_cable.connected += src
		north_cable.south_count++
		if (north_cable.omni)
			omni_dirs |= NORTH
		if (omni)
			north_cable.omni_dirs |= SOUTH
		north_cable.update_power_node()
		north_cable.update_appearance(UPDATE_ICON)
	for (var/obj/structure/cable/south_cable in get_step(src, SOUTH))
		if (!south_cable.omni && !omni && south_cable.cable_color != cable_color)
			continue
		connected += south_cable
		south_count++
		south_cable.connected += src
		south_cable.north_count++
		if (south_cable.omni)
			omni_dirs |= SOUTH
		if (omni)
			south_cable.omni_dirs |= NORTH
		south_cable.update_power_node()
		south_cable.update_appearance(UPDATE_ICON)
	for (var/obj/structure/cable/east_cable in get_step(src, EAST))
		if (!east_cable.omni && !omni && east_cable.cable_color != cable_color)
			continue
		connected += east_cable
		east_count++
		east_cable.connected += src
		east_cable.west_count++
		if (east_cable.omni)
			omni_dirs |= EAST
		if (omni)
			east_cable.omni_dirs |= WEST
		east_cable.update_power_node()
		east_cable.update_appearance(UPDATE_ICON)
	for (var/obj/structure/cable/west_cable in get_step(src, WEST))
		if (!west_cable.omni && !omni && west_cable.cable_color != cable_color)
			continue
		connected += west_cable
		west_count++
		west_cable.connected += src
		west_cable.east_count++
		if (west_cable.omni)
			omni_dirs |= WEST
		if (omni)
			west_cable.omni_dirs |= EAST
		west_cable.update_power_node()
		west_cable.update_appearance(UPDATE_ICON)
	// Linkup with multi-z cables
	if (multiz)
		var/turf/current_location = get_turf(src)
		// Omni-cables will not connect with coloured cables along the z-axis
		var/obj/structure/cable/below_cable = get_cable(GET_TURF_BELOW(current_location), cable_color, FALSE)
		if (below_cable)
			below_cable.set_up(src)
		var/obj/structure/cable/above_cable = get_cable(GET_TURF_ABOVE(current_location), cable_color, FALSE)
		if (above_cable)
			above_cable.set_down(src)

/obj/structure/cable/proc/update_power_node()
	if (forced_power_node)
		return
	var/previous = has_power_node
	has_power_node = FALSE
	// If we have 0 or 1 connections, we get a free power node
	if (!!north_count + !!south_count + !!west_count + !!east_count <= 1)
		has_power_node = TRUE
	if (previous != has_power_node)
		if (has_power_node)
			connect_to_machines()
		else
			disconnect_from_machines()

/// Add a power node to this cable
/obj/structure/cable/proc/add_power_node()
	forced_power_node = TRUE
	has_power_node = TRUE
	linkup_adjacent(FALSE)
	update_appearance(UPDATE_ICON)

/obj/structure/cable/proc/clear_north(obj/structure/cable/removed)
	connected -= removed
	north_count--
	omni_dirs &= ~NORTH
	update_power_node()
	update_appearance(UPDATE_ICON)

/obj/structure/cable/proc/clear_south(obj/structure/cable/removed)
	connected -= removed
	south_count--
	omni_dirs &= ~SOUTH
	update_power_node()
	update_appearance(UPDATE_ICON)

/obj/structure/cable/proc/clear_east(obj/structure/cable/removed)
	connected -= removed
	east_count--
	omni_dirs &= ~EAST
	update_power_node()
	update_appearance(UPDATE_ICON)

/obj/structure/cable/proc/clear_west(obj/structure/cable/removed)
	connected -= removed
	west_count--
	omni_dirs &= ~WEST
	update_power_node()
	update_appearance(UPDATE_ICON)

/obj/structure/cable/proc/set_down(new_value)
	down = new_value
	down?.up = src
	update_appearance(UPDATE_ICON)
	down?.update_appearance(UPDATE_ICON)

/obj/structure/cable/proc/set_up(new_value)
	up = new_value
	up?.down = src
	update_appearance(UPDATE_ICON)
	up?.update_appearance(UPDATE_ICON)

/obj/structure/cable/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/T = get_turf(loc)
		if(T)
			var/obj/item/stack/cable_coil/R = new /obj/item/stack/cable_coil(T, forced_power_node ? 2 : 1, cable_color, omni)
			if(QDELETED(R)) // the coil merged with something on the tile
				R = locate(/obj/item/stack/cable_coil) in T
			if(R)
				transfer_fingerprints_to(R)
		if (multiz)
			if (up)
				up.down = null
				up.deconstruct()
			if (down)
				down.up = null
				down.deconstruct()
	..()

///////////////////////////////////
// General procedures
///////////////////////////////////

/obj/structure/cable/update_overlays()
	. = ..()
	underlays.Cut()
	if (multiz)
		ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)
		. += mutable_appearance(icon, "box", appearance_flags = RESET_COLOR)
		. += mutable_appearance(icon, "boxlight", appearance_flags = RESET_COLOR)
		. += emissive_appearance(icon, "boxlight", layer)
		sound_loop = new (src, TRUE)
	else if (sound_loop)
		QDEL_NULL(sound_loop)
	if (up)
		if (down)
			underlays += mutable_appearance(icon, "32", appearance_flags = RESET_COLOR)
		. += mutable_appearance(icon, "16", appearance_flags = RESET_COLOR)
	else if (down)
		underlays += mutable_appearance(icon, "32", appearance_flags = RESET_COLOR)
	var/shift_amount = get_shift_amount()
	if (shift_amount != 0)
		// Add for the sake of hitboxes
		var/mutable_appearance/ma = mutable_appearance(icon, icon_state)
		ma.alpha = 1
		ma.pixel_x = -shift_amount
		ma.pixel_y = shift_amount
		. += ma

/obj/structure/cable/update_icon_state()
	. = ..()
	var/list/adjacencies = list()
	if (has_power_node)
		adjacencies += "0"
	if (north_count)
		adjacencies += "1"
	if (south_count)
		adjacencies += "2"
	if (east_count)
		adjacencies += "4"
	if (west_count)
		adjacencies += "8"
	if (length(adjacencies) <= 1 && !has_power_node)
		adjacencies.Insert(1, "0")
	if (omni)
		adjacencies += "o"
	icon_state = jointext(adjacencies, "-")
	if (omni)
		remove_atom_colour(FIXED_COLOUR_PRIORITY)
	else
		add_atom_colour(GLOB.cable_colors[cable_color], FIXED_COLOUR_PRIORITY)
		// Calculate pixel shifts
		remove_filter(list("displace_wire", "omni-connection-up", "omni-connection-left", "omni-connection-down", "omni-connection-right"))
		var/shift_amount = get_shift_amount()
		// Shift amount not required if we are centered, reduces filter usage on main station wires
		if (shift_amount)
			layer = initial(layer)
			add_filter("displace_wire", 1, displacement_map_filter(icon('icons/obj/power_cond/cables.dmi', "displace-wire"), size=shift_amount))
			if (omni_dirs & NORTH)
				add_filter("omni-connection-up", 1, displacement_map_filter(icon('icons/obj/power_cond/cables.dmi', "displace-up"), size=shift_amount))
			if (omni_dirs & SOUTH)
				add_filter("omni-connection-down", 1, displacement_map_filter(icon('icons/obj/power_cond/cables.dmi', "displace-down"), size=shift_amount))
			if (omni_dirs & WEST)
				add_filter("omni-connection-left", 1, displacement_map_filter(icon('icons/obj/power_cond/cables.dmi', "displace-left"), size=shift_amount))
			if (omni_dirs & EAST)
				add_filter("omni-connection-right", 1, displacement_map_filter(icon('icons/obj/power_cond/cables.dmi', "displace-right"), size=shift_amount))
		else
			// Gets slightly priority over displaced cables so that shift-click functions as intended
			layer = initial(layer) + 0.001

/obj/structure/cable/proc/get_shift_amount()
	switch (cable_color)
		if ("green")
			return -4
		if ("orange")
			return -2
		if ("yellow")
			return 0
		if ("red")
			return 2
		if ("pink")
			return 4
	return 0

/obj/structure/cable/attackby(obj/item/W, mob/user, params)
	var/turf/T = get_turf(src)
	if(T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
		return FALSE
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		var/obj/structure/cable/target = resolve_ambiguous_target(user)
		if (!target)
			return TRUE
		if (target.shock(user, 50))
			return TRUE
		user.visible_message("[user] cuts the cable.", span_notice("You cut the cable."))
		target.investigate_log("was cut by [key_name(usr)] in [AREACOORD(target)]", INVESTIGATE_WIRES)
		target.deconstruct()
		return TRUE

	else if(W.tool_behaviour == TOOL_MULTITOOL)
		var/obj/structure/cable/target = resolve_ambiguous_target(user)
		if (!target)
			return TRUE
		to_chat(user, target.get_power_info())
		target.shock(user, 5, 0.2)
		return TRUE

	else if (istype(W, /obj/item/stack/cable_coil))
		// Pass the click down to the turf instead
		return T.attackby(W, user, params)

	add_fingerprint(user)
	return ..()

/obj/structure/cable/proc/resolve_ambiguous_target(mob/user)
	var/list/targets = list()
	var/list/results = list()
	for (var/obj/structure/cable/cable in loc)
		targets["Cable [cable.omni ? "(Omni)" : "([cable.cable_color])"]"] = cable.appearance
		results["Cable [cable.omni ? "(Omni)" : "([cable.cable_color])"]"] = cable
	if (length(targets) <= 1)
		return src
	var/result = show_radial_menu(user, user, targets, tooltips = TRUE)
	if (!result)
		return null
	return results[result]

/obj/structure/cable/examine(mob/user)
	. = ..()
	if(isobserver(user))
		. += get_power_info()

// shock the user with probability prb
/obj/structure/cable/proc/shock(mob/user, prb, siemens_coeff = 1)
	if(!prob(prb))
		return 0
	if (electrocute_mob(user, powernet, src, siemens_coeff))
		do_sparks(5, TRUE, src)
		return 1
	else
		return 0

/obj/structure/cable/singularity_pull(obj/anomaly/singularity/singularity, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

/obj/structure/cable/proc/get_power_info()
	if(powernet && (powernet.avail > 0))		// is it powered?
		return span_danger("Total power: [display_power_persec(powernet.avail)]\nLoad: [display_power_persec(powernet.load)]\nExcess power: [display_power_persec(surplus())]")
	else
		return span_danger("The cable is not powered.")

////////////////////////////////////////////
// Power related
///////////////////////////////////////////

// All power generation handled in add_avail()
// Machines should use add_load(), surplus(), avail()
// Non-machines should use add_delayedload(), delayed_surplus(), newavail()

/obj/structure/cable/proc/add_avail(amount)
	if(powernet)
		powernet.newavail += amount

/obj/structure/cable/proc/add_load(amount)
	if(powernet)
		powernet.load += amount

/obj/structure/cable/proc/surplus()
	if(powernet)
		return clamp(powernet.avail-powernet.load, 0, powernet.avail)
	else
		return 0

/obj/structure/cable/proc/avail(amount)
	if(powernet)
		return amount ? powernet.avail >= amount : powernet.avail
	else
		return 0

/obj/structure/cable/proc/add_delayedload(amount)
	if(powernet)
		powernet.delayedload += amount

/obj/structure/cable/proc/delayed_surplus()
	if(powernet)
		return clamp(powernet.newavail - powernet.delayedload, 0, powernet.newavail)
	else
		return 0

/obj/structure/cable/proc/newavail()
	if(powernet)
		return powernet.newavail
	else
		return 0

/////////////////////////////////////////////////
// Cable laying helpers
////////////////////////////////////////////////

/// Linkup with adjacent cables
/obj/structure/cable/proc/linkup_adjacent(consoldate_powernets)
	if (consoldate_powernets)
		// Don't linkup if they have no powernet, for example in the case of
		// shuttle moving where we get a null powernet until we land
		for (var/obj/structure/cable/connected_cable in connected)
			if (connected_cable.powernet)
				if (powernet)
					merge_powernets(powernet, connected_cable.powernet)
				else
					connected_cable.powernet.add_cable(src)
		if (up?.powernet)
			if (powernet)
				merge_powernets(powernet, up.powernet)
			else
				up.powernet.add_cable(src)
		if (down?.powernet)
			if (powernet)
				merge_powernets(powernet, down.powernet)
			else
				down.powernet.add_cable(src)
		if (!powernet)
			var/datum/powernet/newPN = new()
			newPN.add_cable(src)
	if (has_power_node)
		connect_to_machines()

/obj/structure/cable/proc/connect_to_machines()
	var/turf/location = get_turf(src)
	for (var/obj/machinery/power/apc/apc in location)
		if (apc.terminal == null || apc.terminal.powernet == powernet)
			continue
		if(!apc.terminal.connect_to_network())
			apc.terminal.disconnect_from_network()
	for (var/obj/machinery/power/power_machine in location)
		if (power_machine.powernet == powernet)
			continue
		if(!power_machine.connect_to_network())
			power_machine.disconnect_from_network()

/obj/structure/cable/proc/disconnect_from_machines()
	var/turf/location = get_turf(src)
	for(var/obj/machinery/power/P in location)
		if(!P.connect_to_network()) //can't find a node cable on a the turf to connect to
			P.disconnect_from_network() //remove from current network

//////////////////////////////////////////////
// Powernets handling helpers
//////////////////////////////////////////////

// cut the cable's powernet at this cable and updates the powergrid
/obj/structure/cable/proc/cut_cable_from_powernet(remove=TRUE)
	var/turf/location = get_turf(src)
	// remove the cut cable from its turf and powernet, so that it doesn't get count in propagate_network worklist
	if(remove)
		moveToNullspace()
	powernet.remove_cable(src) //remove the cut cable from its powernet

	if (!location)
		return

	// Disconnect machines connected to nodes
	if(has_power_node) // if we cut a node (O-X) cable
		disconnect_from_machines()

/obj/structure/cable/beforeShuttleMove(turf/newT, rotation, move_mode, obj/docking_port/mobile/moving_dock)
	. = ..()
	cut_cable_from_powernet(FALSE)

/obj/structure/cable/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	. = ..()
	clear_connections()
	reform_connections()
	linkup_adjacent(TRUE)

/obj/structure/cable/yellow
	cable_color = "yellow"
	color = "#ffff00"
	pixel_x = 2
	pixel_y = 2

/obj/structure/cable/green
	cable_color = "green"
	color = "#00aa00"
	pixel_x = -2
	pixel_y = -2

/obj/structure/cable/pink
	cable_color = "pink"
	color = "#ff3cc8"
	pixel_x = -4
	pixel_y = -4

/obj/structure/cable/orange
	cable_color = "orange"
	color = "#ff8000"
	pixel_x = 4
	pixel_y = 4

/obj/structure/cable/omni
	icon_state = "0-o"
	cable_color = "white"
	color = "#ffffff"
	omni = TRUE

/datum/looping_sound/transformer
	mid_sounds = list('sound/machines/transformer.ogg' = 1)
	mid_length = 9
	volume = 100
