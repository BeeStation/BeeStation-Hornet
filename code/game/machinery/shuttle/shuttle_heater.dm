//-----------------------------------------------
//--------------Engine Heaters-------------------
//This uses atmospherics, much like a thermomachine,
//but instead of changing temp, it stores plasma and uses
//it for the engine
//-----------------------------------------------
/obj/machinery/atmospherics/components/unary/shuttle/heater
	name = "engine heater"
	desc = "Directs energy into compressed particles in order to power an attached thruster."
	icon_state = "heater_pipe"
	var/icon_state_closed = "heater_pipe"
	var/icon_state_open = "heater_pipe_open"
	var/icon_state_off = "heater_pipe"
	icon = 'icons/turf/shuttle.dmi'
	idle_power_usage = 50
	circuit = /obj/item/circuitboard/machine/shuttle/heater

	density = TRUE
	max_integrity = 400
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 30)
	layer = OBJ_LAYER
	showpipe = TRUE

	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY

	var/gas_type = /datum/gas/plasma
	var/efficiency_multiplier = 1
	var/gas_capacity = 0

/obj/machinery/atmospherics/components/unary/shuttle/heater/Initialize()
	. = ..()
	SetInitDirections()
	updateGasStats()

/obj/machinery/atmospherics/components/unary/shuttle/heater/on_construction()
	..(dir, dir)
	SetInitDirections()
	check_setup()

/obj/machinery/atmospherics/components/unary/shuttle/heater/default_change_direction_wrench(mob/user, obj/item/I)
	if(!..())
		return FALSE
	SetInitDirections()
	var/obj/machinery/atmospherics/node = nodes[1]
	if(node)
		node.disconnect(src)
		nodes[1] = null
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
	efficiency_multiplier = round(((eff / 2) / 2.828) ** 2, 0.1)
	updateGasStats()

/obj/machinery/atmospherics/components/unary/shuttle/heater/examine(mob/user)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	. += "The engine heater's gas dial reads [air_contents.gases[gas_type][MOLES]] moles of gas.<br>"

/obj/machinery/atmospherics/components/unary/shuttle/heater/proc/updateGasStats()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.volume = gas_capacity
	air_contents.temperature = T20C
	if(gas_type)
		air_contents.assert_gas(gas_type)

/obj/machinery/atmospherics/components/unary/shuttle/heater/proc/hasFuel(var/required)
	var/datum/gas_mixture/air_contents = airs[1]
	var/moles = air_contents.total_moles()
	return moles >= required

/obj/machinery/atmospherics/components/unary/shuttle/heater/proc/consumeFuel(var/amount)
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.remove(amount)
	return

/obj/machinery/atmospherics/components/unary/shuttle/heater/proc/check_setup(var/affectSurrounding = TRUE)
	if(!affectSurrounding)
		return
	//Don't update if not on shuttle, to prevent lagging out the server in space
	if(!istype(get_turf(src), /area/shuttle/custom))
		return
	//Shitcode omegalul
	for(var/place in get_area(get_turf(src)))
		for(var/atom/thing in place)
			if(!istype(thing, /obj/machinery/shuttle))
				continue
			if(thing == src)
				continue
			var/obj/machinery/shuttle/shuttle_comp = thing
			shuttle_comp.check_setup(FALSE)
	return

/obj/machinery/atmospherics/components/unary/shuttle/heater/attackby(obj/item/I, mob/living/user, params)
	if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_closed, I))
		check_setup()
		return
	if(default_pry_open(I))
		check_setup()
		return
	if(panel_open)
		if(default_change_direction_wrench(user, I))
			check_setup()
			return
	if(default_deconstruction_crowbar(I))
		check_setup()
		return
	check_setup()
	return ..()
