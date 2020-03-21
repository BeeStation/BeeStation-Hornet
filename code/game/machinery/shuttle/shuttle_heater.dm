#define AIR_CONTENTS	((25*ONE_ATMOSPHERE)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature))
//-----------------------------------------------
//--------------Engine Heaters-------------------
//This uses atmospherics, much like a thermomachine,
//but instead of changing temp, it stores plasma and uses
//it for the engine
//-----------------------------------------------
/obj/machinery/atmospherics/components/unary/shuttle/heater
	name = "engine heater"
	desc = "Directs energy into compressed particles in order to power an attached thruster."
	icon_state = "heater"
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

/obj/machinery/atmospherics/components/unary/shuttle/heater/SetInitDirections()
	initialize_directions = angle2dir((dir2angle(dir) + 180) % 360)

/obj/machinery/atmospherics/components/unary/shuttle/heater/New()
	..()
	updateGasStats()

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
