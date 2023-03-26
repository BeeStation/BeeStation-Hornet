//-----------------------------------------------
//--------------Engine Heaters-------------------
//This uses atmospherics, much like a thermomachine,
//but instead of changing temp, it stores plasma and uses
//it for the engine.
//-----------------------------------------------
/obj/machinery/atmospherics/components/unary/shuttle
	name = "shuttle atmospherics device"
	desc = "This does something to do with shuttle atmospherics"
	icon_state = "heater"
	icon = 'icons/obj/shuttle.dmi'

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater
	name = "engine heater"
	desc = "Directs energy into compressed particles in order to power an attached thruster. While the engine can be overclocked by being flooded with tritium, this will void the warrenty."
	icon_state = "heater_pipe"
	var/icon_state_closed = "heater_pipe"
	var/icon_state_open = "heater_pipe_open"
	var/icon_state_off = "heater_pipe"
	idle_power_usage = 500
	circuit = /obj/item/circuitboard/machine/shuttle/heater

	density = TRUE
	max_integrity = 400
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 30, "stamina" = 0)
	layer = OBJ_LAYER
	showpipe = TRUE

	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY

	var/efficiency_multiplier = 1
	var/gas_capacity = 0
	var/fuel_state = FALSE

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/New()
	. = ..()
	GLOB.custom_shuttle_machines += src
	SetInitDirections()
	update_adjacent_engines()
	updateGasStats()

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/Destroy()
	GLOB.custom_shuttle_machines -= src
	. = ..()
	update_adjacent_engines()

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/process(delta_time)
	if(hasFuel(1))
		if(!fuel_state)
			fuel_state = TRUE
			update_adjacent_engines()
	else if(fuel_state)
		fuel_state = FALSE
		update_adjacent_engines()

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/on_construction()
	..(dir, dir)
	SetInitDirections()
	update_adjacent_engines()

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/default_change_direction_wrench(mob/user, obj/item/I)
	if(!..())
		return FALSE
	SetInitDirections()
	var/obj/machinery/atmospherics/node = nodes[1]
	if(node)
		node.disconnect(src)
		nodes[1] = null
	if(!parents[1])
		return
	nullifyPipenet(parents[1])

	atmosinit()
	node = nodes[1]
	if(node)
		node.atmosinit()
		node.addMember(src)
	build_network()
	return TRUE

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/RefreshParts()
	var/cap = 0
	var/eff = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		cap += M.rating
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		eff += L.rating
	gas_capacity = 5000 * ((cap - 1) ** 2) + 1000
	efficiency_multiplier = round(((eff / 2) / 2.8) ** 2, 0.1)
	updateGasStats()

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/examine(mob/user)
	. = ..()
	. += "The engine heater's gas dial reads [getFuelAmount()] moles of gas.<br>"

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/proc/updateGasStats()
	var/datum/gas_mixture/air_contents = airs[1]
	if(!air_contents)
		return
	air_contents.set_volume(gas_capacity)
	air_contents.set_temperature(T20C)

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/proc/hasFuel(var/required)
	return getFuelAmount() >= required

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/proc/consumeFuel(var/amount)
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.remove(amount / efficiency_multiplier)
	return

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/proc/getFuelAmount()
	var/datum/gas_mixture/air_contents = airs[1]
	var/moles = air_contents.get_moles(GAS_PLASMA) + air_contents.get_moles(GAS_TRITIUM)
	return moles

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/proc/get_gas_multiplier()
	//Check the gas ratio
	var/datum/gas_mixture/air_contents = airs[1]
	var/total_moles = air_contents.total_moles()
	if(!total_moles)
		return 0
	var/moles_plasma = air_contents.get_moles(GAS_PLASMA)
	var/moles_tritium = air_contents.get_moles(GAS_TRITIUM)
	return (moles_plasma / total_moles) + (3 * moles_tritium / total_moles)

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/attackby(obj/item/I, mob/living/user, params)
	if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_closed, I))
		update_adjacent_engines()
		return
	if(default_pry_open(I))
		update_adjacent_engines()
		return
	if(panel_open)
		if(default_change_direction_wrench(user, I))
			update_adjacent_engines()
			return
	if(default_deconstruction_crowbar(I))
		update_adjacent_engines()
		return
	update_adjacent_engines()
	return ..()

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/proc/update_adjacent_engines()
	var/engine_turf
	switch(dir)
		if(NORTH)
			engine_turf = get_offset_target_turf(src, 0, 1)
		if(SOUTH)
			engine_turf = get_offset_target_turf(src, 0, -1)
		if(EAST)
			engine_turf = get_offset_target_turf(src, 1, 0)
		if(WEST)
			engine_turf = get_offset_target_turf(src, -1, 0)
	if(!engine_turf)
		return
	for(var/obj/machinery/shuttle/engine/E in engine_turf)
		E.check_setup()
