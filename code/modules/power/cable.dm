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
	icon_state = "0"
	layer = WIRE_LAYER //Above hidden pipes, GAS_PIPE_HIDDEN_LAYER
	anchored = TRUE
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	var/datum/powernet/powernet
	/// Are we a single cable that wants to be a node?
	var/has_power_node = FALSE
	/// Have we been manually given a power node and should keep it when we change?
	var/forced_power_node = FALSE
	var/obj/structure/cable/north
	var/obj/structure/cable/east
	var/obj/structure/cable/south
	var/obj/structure/cable/west
	/// Are we an omni cable?
	var/omni = FALSE

	FASTDMM_PROP(\
		pipe_type = PIPE_TYPE_CABLE,\
		pipe_interference_group = list("cable"),\
		pipe_group = "cable-[cable_color]"\
	)

	var/cable_color = "red"
	color = "#ff0000"

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
	cable_color = "white"
	color = "#ffffff"
	omni = TRUE

// the power cable object
CREATION_TEST_IGNORE_SUBTYPES(/obj/structure/cable)

/obj/structure/cable/Initialize(mapload, param_color)
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

	// Locate adjacent tiles
	reform_connections()

	pixel_x = 0
	pixel_y = 0

	GLOB.cable_list += src //add it to the global cable list

	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE)

	update_appearance(UPDATE_ICON)
	linkup_adjacent(!mapload)

/obj/structure/cable/Destroy()					// called when a cable is deleted
	// Update our neighbors
	clear_connections()
	if(powernet)
		cut_cable_from_powernet()				// update the powernets
	GLOB.cable_list -= src							//remove it from global cable list
	return ..()									// then go ahead and delete the cable

/obj/structure/cable/proc/clear_connections()
	north?.set_south(null)
	east?.set_west(null)
	south?.set_north(null)
	west?.set_east(null)

/obj/structure/cable/proc/reform_connections()
	north = get_cable(get_step(src, NORTH), cable_color, omni)
	south = get_cable(get_step(src, SOUTH), cable_color, omni)
	east = get_cable(get_step(src, EAST), cable_color, omni)
	west = get_cable(get_step(src, WEST), cable_color, omni)
	north?.south = src
	east?.west = src
	south?.north = src
	west?.east = src
	south?.update_appearance(UPDATE_ICON)
	west?.update_appearance(UPDATE_ICON)
	north?.update_appearance(UPDATE_ICON)
	east?.update_appearance(UPDATE_ICON)

/// Add a power node to this cable
/obj/structure/cable/proc/add_power_node()
	forced_power_node = TRUE
	has_power_node = TRUE
	linkup_adjacent(FALSE)
	update_appearance(UPDATE_ICON)

/obj/structure/cable/proc/set_north(new_value)
	north = new_value
	// Remove the power node if we no longer need it
	if (!forced_power_node && has_power_node && (south || east || west))
		has_power_node = FALSE
	update_appearance(UPDATE_ICON)

/obj/structure/cable/proc/set_south(new_value)
	south = new_value
	// Remove the power node if we no longer need it
	if (!forced_power_node && has_power_node && (north || east || west))
		has_power_node = FALSE
	update_appearance(UPDATE_ICON)

/obj/structure/cable/proc/set_east(new_value)
	east = new_value
	// Remove the power node if we no longer need it
	if (!forced_power_node && has_power_node && (south || north || west))
		has_power_node = FALSE
	update_appearance(UPDATE_ICON)

/obj/structure/cable/proc/set_west(new_value)
	west = new_value
	// Remove the power node if we no longer need it
	if (!forced_power_node && has_power_node && (south || east || north))
		has_power_node = FALSE
	update_appearance(UPDATE_ICON)

/obj/structure/cable/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/T = get_turf(loc)
		if(T)
			var/obj/item/stack/cable_coil/R = new /obj/item/stack/cable_coil(T, forced_power_node ? 2 : 1, cable_color, omni)
			if(QDELETED(R)) // the coil merged with something on the tile
				R = locate(/obj/item/stack/cable_coil) in T
			if(R)
				transfer_fingerprints_to(R)
	/*
		var/turf/T_below = T.below()
		if((d1 == DOWN || d2 == DOWN) && T_below)
			for(var/obj/structure/cable/C in T_below)
				if(C.d1 == UP || C.d2 == UP)
					C.deconstruct()
	*/
	..()

///////////////////////////////////
// General procedures
///////////////////////////////////

/obj/structure/cable/update_icon()
	var/list/adjacencies = list()
	if (has_power_node)
		adjacencies += "0"
	if (north)
		adjacencies += "1"
	if (south)
		adjacencies += "2"
	if (east)
		adjacencies += "4"
	if (west)
		adjacencies += "8"
	if (length(adjacencies) <= 1)
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
		var/shift_amount = 0
		switch (cable_color)
			if ("green")
				shift_amount = -4
			if ("orange")
				shift_amount = -2
			if ("yellow")
				shift_amount = 0
			if ("red")
				shift_amount = 2
			if ("pink")
				shift_amount = 4
		add_filter("displace_wire", 1, displacement_map_filter(icon('icons/obj/power_cond/cables.dmi', "displace-wire"), size=shift_amount))
		if (north && north.omni)
			add_filter("omni-connection-up", 1, displacement_map_filter(icon('icons/obj/power_cond/cables.dmi', "displace-up"), size=shift_amount))
		if (south && south.omni)
			add_filter("omni-connection-down", 1, displacement_map_filter(icon('icons/obj/power_cond/cables.dmi', "displace-down"), size=shift_amount))
		if (west && west.omni)
			add_filter("omni-connection-left", 1, displacement_map_filter(icon('icons/obj/power_cond/cables.dmi', "displace-left"), size=shift_amount))
		if (east && east.omni)
			add_filter("omni-connection-right", 1, displacement_map_filter(icon('icons/obj/power_cond/cables.dmi', "displace-right"), size=shift_amount))

/obj/structure/cable/attackby(obj/item/W, mob/user, params)
	var/turf/T = get_turf(src)
	if(T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
		return
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		//if(d1 == UP || d2 == UP)
		//	to_chat(user, "<span class='warning'>You must cut this cable from above.</span>")
		//	return
		if (shock(user, 50))
			return
		user.visible_message("[user] cuts the cable.", "<span class='notice'>You cut the cable.</span>")
		investigate_log("was cut by [key_name(usr)] in [AREACOORD(src)]", INVESTIGATE_WIRES)
		deconstruct()
		return

	else if(W.tool_behaviour == TOOL_MULTITOOL)
		to_chat(user, get_power_info())
		shock(user, 5, 0.2)

	else if (istype(W, /obj/item/stack/cable_coil))
		// Pass the click down to the turf instead
		return T.attackby(W, user, params)

	add_fingerprint(user)

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

/obj/structure/cable/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

/obj/structure/cable/proc/get_power_info()
	if(powernet && (powernet.avail > 0))		// is it powered?
		return "<span class='danger'>Total power: [display_power(powernet.avail)]\nLoad: [display_power(powernet.load)]\nExcess power: [display_power(surplus())]</span>"
	else
		return "<span class='danger'>The cable is not powered.</span>"

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
		if (north?.powernet)
			if (powernet)
				merge_powernets(powernet, north.powernet)
			else
				north.powernet.add_cable(src)
		if (south?.powernet)
			if (powernet)
				merge_powernets(powernet, south.powernet)
			else
				south.powernet.add_cable(src)
		if (east?.powernet)
			if (powernet)
				merge_powernets(powernet, east.powernet)
			else
				east.powernet.add_cable(src)
		if (west?.powernet)
			if (powernet)
				merge_powernets(powernet, west.powernet)
			else
				west.powernet.add_cable(src)
		if (!powernet)
			var/datum/powernet/newPN = new()
			newPN.add_cable(src)
	if (has_power_node)
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

//////////////////////////////////////////////
// Powernets handling helpers
//////////////////////////////////////////////

//should be called after placing a cable which extends another cable, creating a "smooth" cable that no longer terminates in the centre of a turf.
//needed as this can, unlike other placements, disconnect cables
/obj/structure/cable/proc/denode()
	var/turf/T1 = loc
	if(!T1)
		return

	CRASH("Denode is not implemented")

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
		for(var/obj/machinery/power/P in location)
			if(!P.connect_to_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_network() //remove from current network

/obj/structure/cable/beforeShuttleMove(turf/newT, rotation, move_mode, obj/docking_port/mobile/moving_dock)
	. = ..()
	cut_cable_from_powernet(FALSE)

/obj/structure/cable/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	. = ..()
	clear_connections()
	reform_connections()
	linkup_adjacent(TRUE)
