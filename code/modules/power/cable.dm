GLOBAL_LIST_INIT(cable_colors, list(
	"yellow" = COLOR_YELLOW,
	"green" = COLOR_DARK_LIME,
	"pink" = COLOR_LIGHT_PINK,
	"orange" = COLOR_MOSTLY_PURE_ORANGE,
	"red" = COLOR_RED,
	"white" = COLOR_WHITE,
))

/**
 * Helper proc to get a cable in a turf of a specific color
 * If cable_color is null, the first cable found is returned
 */
/proc/get_cable(turf/location, cable_color)
	for (var/obj/structure/cable/cable in location)
		if (isnull(cable_color) || cable.cable_color == cable_color)
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
	flags_1 = STAT_UNIQUE_1

	/// The powernet we are linked to
	var/datum/powernet/powernet
	/// Are we a single cable that wants to be a node?
	var/has_power_node = FALSE
	/// Have we been manually given a power node and should keep it when we change?
	var/forced_power_node = FALSE
	/// List of cables that are connected to this cable.
	var/list/connected = list()
	/// A bitfield of the directions this cable connects to.
	var/linked_dirs = NONE
	/// A bitfield of the directions that have an omni-cable connection.
	var/omni_dirs = NONE
	/// Reference to the cable that is above us.
	var/obj/structure/cable/up
	/// Reference to the cable that is below us.
	var/obj/structure/cable/down
	/// Are we an omni cable?
	var/omni = FALSE
	/// Are we a multi-z cable?
	var/multiz = FALSE
	/// Sound loop for multi-z cables
	VAR_PRIVATE/datum/looping_sound/transformer/sound_loop

	FASTDMM_PROP(\
		pipe_type = PIPE_TYPE_CABLE,\
		pipe_interference_group = list("cable"),\
		pipe_group = "cable-[cable_color]"\
	)

	var/cable_color = "red"
	color = COLOR_RED

// the power cable object
CREATION_TEST_IGNORE_SUBTYPES(/obj/structure/cable)

/obj/structure/cable/Initialize(mapload, param_color = cable_color, multiz = FALSE)
	. = ..()

// If building for CI then we will check to ensure that cables are not incorrectly overlapping.
#ifdef CIBUILDING
	for (var/obj/structure/cable/cable in get_turf(src))
		if (cable == src || cable.cable_color != cable_color || omni || cable.omni)
			continue
		stack_trace("A cable was created when one already exists at [COORD(src)].")
		return INITIALIZE_HINT_QDEL
#endif

	cable_color = param_color
	src.multiz = multiz

	// If our tile is open space, we're a multiz cable
	if(mapload && isopenspace(loc))
		multiz = TRUE

	if(multiz)
		sound_loop = new(src, start_immediately = TRUE)

	// Our pixel offsets are modified for mapping icons, let's reset them here
	pixel_x = 0
	pixel_y = 0

	GLOB.cable_list += src //add it to the global cable list

	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE)

	if(isturf(loc))
		var/turf/turf_loc = loc
		turf_loc.add_blueprints_preround(src)

	return INITIALIZE_HINT_LATELOAD

/obj/structure/cable/LateInitialize()
	reform_connections()
	update_appearance(UPDATE_ICON)

	// If we're being maploaded, SSmachines.makepowernets() will handle powernet creation
	var/should_we_make_a_powernet = SSatoms.initialized != INITIALIZATION_INNEW_MAPLOAD
	linkup_adjacent(should_we_make_a_powernet)

/obj/structure/cable/Destroy()
	// Update our neighbors
	clear_connections()
	if(powernet)
		cut_cable_from_powernet() // update the powernets
	GLOB.cable_list -= src //remove it from global cable list
	if (sound_loop)
		QDEL_NULL(sound_loop)
	return ..() // then go ahead and delete the cable

/obj/structure/cable/examine(mob/user)
	. = ..()
	if(isobserver(user))
		. += get_power_info()

/// Explicitly reject edits of managed variables
/obj/structure/cable/vv_edit_var(vname, vval)
	switch (vname)
		if (NAMEOF(src, connected))
			return FALSE
		if (NAMEOF(src, linked_dirs))
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
	for (var/obj/structure/cable/connected_cable as anything in connected)
		connected_cable.connected -= src

		var/inbetween_dir = get_dir(connected_cable, src)

		// Don't clear the cable's linked dir if there's still a cable.
		// This only matters for omni-cables
		if(connected_cable.omni)
			var/has_other_cable = FALSE
			var/reverse_dir = REVERSE_DIR(inbetween_dir)
			for(var/obj/structure/cable/other_cable in connected_cable.connected)
				if(other_cable.linked_dirs & reverse_dir)
					has_other_cable = TRUE
					break
			if(!has_other_cable)
				connected_cable.linked_dirs &= ~(inbetween_dir)
		else
			connected_cable.linked_dirs &= ~(inbetween_dir)

		connected_cable.omni_dirs &= ~(inbetween_dir)

		connected_cable.update_power_node()
		connected_cable.update_appearance(UPDATE_ICON)
	down?.set_up(null)
	up?.set_down(null)

/**
 * Searches the four cardinal directions for cables and links the compatible ones to us.
 * If we are a multi-z wire, the turfs above and below us are searched as well.
 */
/obj/structure/cable/proc/reform_connections()
	for(var/cardinal in GLOB.cardinals)
		for(var/obj/structure/cable/adjacent_cable in get_step(src, cardinal))
			if (!adjacent_cable.omni && !omni && adjacent_cable.cable_color != cable_color)
				continue

			var/reverse_cardinal = REVERSE_DIR(cardinal)

			connected |= adjacent_cable
			linked_dirs |= cardinal

			adjacent_cable.connected |= src
			adjacent_cable.linked_dirs |= reverse_cardinal

			if(adjacent_cable.omni)
				omni_dirs |= cardinal
			if(omni)
				adjacent_cable.omni_dirs |= reverse_cardinal

			adjacent_cable.update_power_node()
			adjacent_cable.update_appearance(UPDATE_ICON)

	// Linkup with multi-z cables
	if (multiz)
		var/turf/current_location = get_turf(src)
		// Omni-cables will not connect with coloured cables along the z-axis
		var/obj/structure/cable/below_cable = get_cable(GET_TURF_BELOW(current_location), cable_color)
		below_cable?.set_up(src)

		var/obj/structure/cable/above_cable = get_cable(GET_TURF_ABOVE(current_location), cable_color)
		above_cable?.set_down(src)

/**
 * Updates the has_power_node bool and connects/disconnects from machines if it changed.
 */
/obj/structure/cable/proc/update_power_node()
	if (forced_power_node)
		return

	var/previous_node_state = has_power_node
	has_power_node = FALSE

	// If we have 0 or 1 connections, we get a free power node
	if((linked_dirs & NORTH) + (linked_dirs & SOUTH) + (linked_dirs & WEST) + (linked_dirs & EAST) <= 1)
		has_power_node = TRUE

	if (previous_node_state != has_power_node)
		if (has_power_node)
			connect_to_machines()
		else
			disconnect_from_machines()

/**
 * Adds a focred power node to this cable
 */
/obj/structure/cable/proc/add_power_node()
	forced_power_node = TRUE
	has_power_node = TRUE
	linkup_adjacent(FALSE)
	update_appearance(UPDATE_ICON)

/**
 * Sets the linked cable on the z-level below us
 */
/obj/structure/cable/proc/set_down(obj/structure/cable/new_cable)
	down = new_cable
	update_appearance(UPDATE_ICON)
	if(!isnull(down))
		down.up = src
		down.update_appearance(UPDATE_ICON)

/**
 * Sets the linked cable on the z-level above us
 */
/obj/structure/cable/proc/set_up(obj/structure/cable/new_cable)
	up = new_cable
	update_appearance(UPDATE_ICON)
	if(!isnull(up))
		up.down = src
		up.update_appearance(UPDATE_ICON)

/obj/structure/cable/deconstruct(disassembled = TRUE)
	if(flags_1 & NODECONSTRUCT_1)
		return ..()
	var/atom/drop_loc = drop_location()
	if(drop_loc)
		var/amount_to_drop = forced_power_node ? 2 : 1
		var/obj/item/stack/cable_coil/dropped_cable = new(drop_loc, amount_to_drop, TRUE, null, cable_color, omni)
		if(QDELETED(dropped_cable)) // the coil merged with something on the tile
			dropped_cable = locate(/obj/item/stack/cable_coil) in drop_loc
		transfer_fingerprints_to(dropped_cable)
	if (multiz)
		up?.deconstruct()
		down?.deconstruct()
	return ..()

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

	if(down)
		underlays += mutable_appearance(icon, "32", appearance_flags = RESET_COLOR)
	if(up)
		. += mutable_appearance(icon, "16", appearance_flags = RESET_COLOR)

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
	// Icon state
	var/list/adjacencies = list()
	if (has_power_node)
		adjacencies += "0"
	if (linked_dirs & NORTH)
		adjacencies += "1"
	if (linked_dirs & SOUTH)
		adjacencies += "2"
	if (linked_dirs & EAST)
		adjacencies += "4"
	if (linked_dirs & WEST)
		adjacencies += "8"
	if (length(adjacencies) <= 1 && !has_power_node)
		adjacencies.Insert(1, "0")
	if (omni)
		adjacencies += "o"
	icon_state = jointext(adjacencies, "-")

	// Color
	if (omni)
		remove_atom_colour(FIXED_COLOUR_PRIORITY)
		return
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

/obj/structure/cable/attackby(obj/item/attacking_item, mob/user, params)
	var/turf/our_turf = get_turf(src)
	if(our_turf.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
		return FALSE

	if(istype(attacking_item, /obj/item/stack/cable_coil))
		// Pass the click down to the turf instead
		return our_turf.attackby(attacking_item, user, params)

	add_fingerprint(user)
	return ..()

/obj/structure/cable/wirecutter_act(mob/living/user, obj/item/tool)
	var/turf/our_turf = get_turf(src)
	if (our_turf.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
		return

	var/obj/structure/cable/target = resolve_ambiguous_target(user)
	if(isnull(target))
		return TOOL_ACT_SIGNAL_BLOCKING

	if (target.shock(user, 50))
		return TOOL_ACT_SIGNAL_BLOCKING

	user.visible_message("[user] cuts [target].", span_notice("You cut [target]."))
	target.investigate_log("was cut by [key_name(usr)] in [AREACOORD(target)]", INVESTIGATE_WIRES)
	target.deconstruct()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/structure/cable/multitool_act(mob/living/user, obj/item/tool)
	var/turf/our_turf = get_turf(src)
	if (our_turf.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
		return

	var/obj/structure/cable/target = resolve_ambiguous_target(user)
	if(isnull(target))
		return TOOL_ACT_SIGNAL_BLOCKING

	target.add_fingerprint(user)
	to_chat(user, target.get_power_info())
	target.shock(user, 5, 0.2)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/**
 * Called when we attempt to interact with this cable
 * If there are multiple cables in our location, display a radial menu for the user to choose a cable
 */
/obj/structure/cable/proc/resolve_ambiguous_target(mob/user)
	var/list/targets = list()
	for (var/obj/structure/cable/cable in loc)
		targets["Cable [cable.omni ? "(Omni)" : "([cable.cable_color])"]"] = cable
	if (length(targets) <= 1)
		return src
	var/result = show_radial_menu(user, user, targets, tooltips = TRUE)
	if (isnull(result))
		return
	return targets[result]

/// shock the user with probability prb
/obj/structure/cable/proc/shock(mob/user, prb, siemens_coeff = 1)
	if(!prob(prb))
		return FALSE
	if (electrocute_mob(user, powernet, src, siemens_coeff))
		do_sparks(5, TRUE, src)
		return TRUE
	return FALSE

/obj/structure/cable/singularity_pull(obj/anomaly/singularity/singularity, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

/obj/structure/cable/proc/get_power_info()
	if(powernet?.avail > 0)
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
	powernet?.newavail += amount

/obj/structure/cable/proc/add_load(amount)
	powernet?.load += amount

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
	powernet?.delayedload += amount

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
/obj/structure/cable/proc/linkup_adjacent(link_powernets = FALSE)
	if (link_powernets)
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
			var/datum/powernet/new_powernet = new()
			new_powernet.add_cable(src)
	if (has_power_node)
		connect_to_machines()

/**
 * Connects power machinery to our powernet.
 *
 * Called when has_power_node is set to TRUE.
 */
/obj/structure/cable/proc/connect_to_machines()
	for (var/obj/machinery/power/power_machine in get_turf(src))
		if(istype(power_machine, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/apc = power_machine
			if (isnull(apc.terminal) || apc.terminal.powernet == powernet)
				continue
			if(!apc.terminal.connect_to_network())
				apc.terminal.disconnect_from_network()
			continue

		if (power_machine.powernet == powernet)
			continue
		if(!power_machine.connect_to_network())
			power_machine.disconnect_from_network()

/obj/structure/cable/proc/disconnect_from_machines()
	for(var/obj/machinery/power/power_machine in get_turf(src))
		if(!power_machine.connect_to_network()) //can't find a node cable on a the turf to connect to
			power_machine.disconnect_from_network() //remove from current network

//////////////////////////////////////////////
// Powernets handling helpers
//////////////////////////////////////////////

// cut the cable's powernet at this cable and updates the powergrid
/obj/structure/cable/proc/cut_cable_from_powernet(remove = TRUE)
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
	color = COLOR_YELLOW
	pixel_x = 2
	pixel_y = 2

/obj/structure/cable/green
	cable_color = "green"
	color = COLOR_DARK_LIME
	pixel_x = -2
	pixel_y = -2

/obj/structure/cable/pink
	cable_color = "pink"
	color = COLOR_LIGHT_PINK
	pixel_x = -4
	pixel_y = -4

/obj/structure/cable/orange
	cable_color = "orange"
	color = COLOR_MOSTLY_PURE_ORANGE
	pixel_x = 4
	pixel_y = 4

/obj/structure/cable/omni
	icon_state = "0-o"
	cable_color = "white"
	color = COLOR_WHITE
	omni = TRUE
