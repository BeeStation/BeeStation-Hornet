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
		initialize_directions = dir

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
// Pipenet stuff

/obj/machinery/atmospherics/components/tank/return_analyzable_air()
	return air_contents

/obj/machinery/atmospherics/components/tank/return_airs_for_reconcilation(datum/pipenet/requester)
	. = ..()
	if(!air_contents)
		return
	. += air_contents

/obj/machinery/atmospherics/components/tank/proc/toggle_side_port(new_dir)
	if(initialize_directions & new_dir)
		initialize_directions &= ~new_dir
	else
		initialize_directions |= new_dir

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

////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/atmospherics/components/tank/air
	icon_state = "grey"
	name = "pressure tank (Air)"

/obj/machinery/atmospherics/components/tank/air/New()
	..()
	var/datum/gas_mixture/air_contents = airs[1]
	SET_MOLES(/datum/gas/oxygen, air_contents, 6*ONE_ATMOSPHERE*volume/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD)
	SET_MOLES(/datum/gas/nitrogen, air_contents, 6*ONE_ATMOSPHERE*volume/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD)

/obj/machinery/atmospherics/components/tank/carbon_dioxide
	gas_type = /datum/gas/carbon_dioxide

/obj/machinery/atmospherics/components/tank/plasma
	icon_state = "orange"
	gas_type = /datum/gas/plasma

/obj/machinery/atmospherics/components/tank/oxygen
	icon_state = "blue"
	gas_type = /datum/gas/oxygen

/obj/machinery/atmospherics/components/tank/nitrogen
	icon_state = "red"
	gas_type = /datum/gas/nitrogen
