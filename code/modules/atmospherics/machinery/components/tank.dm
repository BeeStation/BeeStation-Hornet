/obj/machinery/atmospherics/components/tank
	icon = 'icons/obj/atmospherics/pipes/pressure_tank.dmi'
	icon_state = "generic"

	name = "pressure tank"
	desc = "A large vessel containing pressurized gas."

	max_integrity = 800
	density = TRUE
	layer = ABOVE_WINDOW_LAYER

	pipe_flags = PIPING_ONE_PER_TURF
	device_type = QUATERNARY
	initialize_directions = NONE
	custom_reconcilation = TRUE

	/// The open node directions of the tank, assuming that the tank is facing NORTH.
	var/open_ports = NONE
	/// The volume of the gas mixture
	var/volume = 2500 //in liters
	/// The max pressure of the gas mixture before damaging the tank
	var/max_pressure = 46000
	/// The typepath of the gas this tank should be filled with.
	var/gas_type = null

	///Reference to the gas mix inside the tank
	var/datum/gas_mixture/air_contents


/obj/machinery/atmospherics/components/tank/Initialize(mapload)
	. = ..()
	air_contents = new
	air_contents.temperature = T20C
	air_contents.volume = volume
	if(gas_type)
		fill_to_pressure(gas_type)

		name = "[name] ([GLOB.meta_gas_info[gas_type][META_GAS_NAME]])"
	set_piping_layer(piping_layer)

	// Mapped in tanks should automatically connect to adjacent pipenets in the direction set in dir
	if(mapload)
		set_portdir_relative(dir, TRUE)
		set_init_directions()

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/atmospherics/components/tank/wrench_act(mob/living/user, obj/item/item)
	. = TRUE
	var/new_dir = get_dir(src, user)

	if(new_dir in GLOB.diagonals)
		return

	item.play_tool_sound(src, 10)
	if(!item.use_tool(src, user, 3 SECONDS))
		return

	toggle_side_port(new_dir)

	item.play_tool_sound(src, 50)

/// Recalculates pressure based on the current max integrity compared to original
/obj/machinery/atmospherics/components/tank/proc/refresh_pressure_limit()
	var/max_pressure_multiplier = max_integrity / initial(max_integrity)
	max_pressure = max_pressure_multiplier * initial(max_pressure)

/// Fills the tank to the maximum safe pressure.
/// Safety margin is a multiplier for the cap for the purpose of this proc so it doesn't have to be filled completely.
/obj/machinery/atmospherics/components/tank/proc/fill_to_pressure(gastype, safety_margin = 0.5)
	var/pressure_limit = max_pressure * safety_margin

	var/moles_to_add = (pressure_limit * air_contents.volume) / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	air_contents.assert_gas(gastype)
	air_contents.gases[gastype][MOLES] += moles_to_add
	air_contents.archive()

/obj/machinery/atmospherics/components/tank/process_atmos()
	if(air_contents.react(src))
		update_parents()

	if(air_contents.return_pressure() > max_pressure)
		take_damage(0.1, BRUTE, sound_effect = FALSE)
		if(prob(40))
			playsound(src, 'sound/effects/spray3.ogg', 30, vary = TRUE)

///////////////////////////////////////////////////////////////////
// Port stuff

/**
 * Enables/Disables a port direction in var/open_ports. \
 * Use this, then call set_init_directions() instead of setting initialize_directions directly \
 * This system exists because tanks not having all initialize_directions set correctly breaks shuttle rotations
 */
/obj/machinery/atmospherics/components/tank/proc/set_portdir_relative(relative_port_dir, enable)
	ASSERT(!isnull(enable))

	// Rotate the given dir so that it's relative to north
	var/port_dir
	if(dir == NORTH) // We're already facing north, no rotation needed
		port_dir = relative_port_dir
	else
		var/offnorth_angle = dir2angle(dir)
		port_dir = turn(relative_port_dir, offnorth_angle)

	if(enable)
		open_ports |= port_dir
	else
		open_ports &= ~port_dir

/**
 * Toggles a port direction in var/open_ports \
 * Use this, then call set_init_directions() instead of setting initialize_directions directly \
 * This system exists because tanks not having all initialize_directions set correctly breaks shuttle rotations
 */
/obj/machinery/atmospherics/components/tank/proc/toggle_portdir_relative(relative_port_dir)
	var/toggle = ((initialize_directions & relative_port_dir) ? FALSE : TRUE)
	set_portdir_relative(relative_port_dir, toggle)

/obj/machinery/atmospherics/components/tank/set_init_directions()
	if(!open_ports)
		initialize_directions = NONE
		return
	//We're rotating open_ports relative to dir, and
	//setting initialize_directions to that rotated dir
	var/relative_port_dirs = NONE
	var/dir_angle = dir2angle(dir)
	for(var/cardinal in GLOB.cardinals)
		var/current_dir = cardinal & open_ports
		if(!current_dir)
			continue

		var/rotated_dir = turn(current_dir, -dir_angle)
		relative_port_dirs |= rotated_dir

	initialize_directions = relative_port_dirs

/obj/machinery/atmospherics/components/tank/proc/toggle_side_port(port_dir)
	toggle_portdir_relative(port_dir)
	set_init_directions()

	for(var/i in 1 to length(nodes))
		var/obj/machinery/atmospherics/components/node = nodes[i]
		if(!node)
			continue
		if(src in node.nodes)
			node.disconnect(src)
		nodes[i] = null
		if(parents[i])
			nullify_pipenet(parents[i])

	atmos_init()

	for(var/obj/machinery/atmospherics/components/node as anything in nodes)
		if(!node)
			continue
		node.atmos_init()
		node.add_member(src)
	SSair.add_to_rebuild_queue(src)

	update_parents()

///////////////////////////////////////////////////////////////////
// Pipenet stuff

/obj/machinery/atmospherics/components/tank/return_analyzable_air()
	return air_contents

/obj/machinery/atmospherics/components/tank/return_airs_for_reconcilation(datum/pipenet/requester)
	. = ..()
	if(!air_contents)
		return
	. += air_contents

////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/atmospherics/components/tank/air
	icon_state = "grey"
	name = "pressure tank (Air)"

/obj/machinery/atmospherics/components/tank/air/Initialize(mapload)
	. = ..()
	SET_MOLES(/datum/gas/oxygen, air_contents, 6*ONE_ATMOSPHERE*volume/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD)
	SET_MOLES(/datum/gas/nitrogen, air_contents, 6*ONE_ATMOSPHERE*volume/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD)

/obj/machinery/atmospherics/components/tank/carbon_dioxide
	gas_type = /datum/gas/carbon_dioxide

/obj/machinery/atmospherics/components/tank/nitrous_oxide
	gas_type = /datum/gas/nitrous_oxide

/obj/machinery/atmospherics/components/tank/plasma
	icon_state = "orange"
	gas_type = /datum/gas/plasma

/obj/machinery/atmospherics/components/tank/oxygen
	icon_state = "blue"
	gas_type = /datum/gas/oxygen

/obj/machinery/atmospherics/components/tank/nitrogen
	icon_state = "red"
	gas_type = /datum/gas/nitrogen
