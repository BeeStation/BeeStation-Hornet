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
	icon = 'icons/turf/shuttle.dmi'

/obj/machinery/atmospherics/components/unary/shuttle/heater
	name = "engine heater"
	desc = "Directs energy into compressed particles in order to power an attached thruster."
	icon_state = "heater_pipe"
	var/icon_state_closed = "heater_pipe"
	var/icon_state_open = "heater_pipe_open"
	var/icon_state_off = "heater_pipe"
	idle_power_usage = 50
	circuit = /obj/item/circuitboard/machine/shuttle/heater

	density = TRUE
	z_flags = Z_BLOCK_IN_DOWN | Z_BLOCK_IN_UP
	max_integrity = 400
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 100, ACID = 30, STAMINA = 0)
	layer = OBJ_LAYER
	showpipe = TRUE

	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY

	var/gas_type = GAS_PLASMA
	var/efficiency_multiplier = 1
	var/gas_capacity = 0

/obj/machinery/atmospherics/components/unary/shuttle/heater/New()
	. = ..()
	GLOB.custom_shuttle_machines += src
	SetInitDirections()
	update_adjacent_engines()
	updateGasStats()

/obj/machinery/atmospherics/components/unary/shuttle/heater/Destroy()
	. = ..()
	update_adjacent_engines()
	GLOB.custom_shuttle_machines -= src

/obj/machinery/atmospherics/components/unary/shuttle/heater/on_construction()
	..(dir, dir)
	SetInitDirections()
	update_adjacent_engines()

/obj/machinery/atmospherics/components/unary/shuttle/heater/default_change_direction_wrench(mob/user, obj/item/I)
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

/obj/machinery/atmospherics/components/unary/shuttle/heater/RefreshParts()
	var/cap = 0
	var/eff = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		cap += M.rating
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		eff += L.rating
	gas_capacity = 5000 * ((cap - 1) ** 2) + 1000
	efficiency_multiplier = round(((eff / 2) / 2.8) ** 2, 0.1)
	updateGasStats()

/obj/machinery/atmospherics/components/unary/shuttle/heater/examine(mob/user)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	. += "The engine heater's gas dial reads [air_contents.get_moles(gas_type)] moles of gas.<br>"

/obj/machinery/atmospherics/components/unary/shuttle/heater/proc/updateGasStats()
	var/datum/gas_mixture/air_contents = airs[1]
	if(!air_contents)
		return
	air_contents.set_volume(gas_capacity)
	air_contents.set_temperature(T20C)

/obj/machinery/atmospherics/components/unary/shuttle/heater/proc/hasFuel(var/required)
	var/datum/gas_mixture/air_contents = airs[1]
	var/moles = air_contents.total_moles()
	return moles >= required

/obj/machinery/atmospherics/components/unary/shuttle/heater/proc/consumeFuel(var/amount)
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.remove(amount)
	return

/obj/machinery/atmospherics/components/unary/shuttle/heater/attackby(obj/item/I, mob/living/user, params)
	update_adjacent_engines()
	if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_closed, I))
		return
	if(default_pry_open(I))
		return
	if(panel_open)
		if(default_change_direction_wrench(user, I))
			return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/atmospherics/components/unary/shuttle/heater/proc/update_adjacent_engines()
	var/engine_turf
	switch(dir)
		if(NORTH)
			engine_turf = get_offset_target_turf(src, 0, -1)
		if(SOUTH)
			engine_turf = get_offset_target_turf(src, 0, 1)
		if(EAST)
			engine_turf = get_offset_target_turf(src, -1, 0)
		if(WEST)
			engine_turf = get_offset_target_turf(src, 1, 0)
	if(!engine_turf)
		return
	for(var/obj/machinery/shuttle/engine/E in engine_turf)
		E.check_setup()
