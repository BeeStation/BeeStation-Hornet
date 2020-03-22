//-----------------------------------------------
//-------------Engine Thrusters------------------
//-----------------------------------------------

#define ENGINE_HEAT_TARGET 600

/obj/machinery/shuttle/engine
	name = "shuttle thruster"
	desc = "A thruster for shuttles."
	density = TRUE
	obj_integrity = 250
	max_integrity = 250
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "burst_plasma"
	idle_power_usage = 150
	circuit = /obj/item/circuitboard/machine/shuttle/engine
	var/thrust = 0
	var/fuel_use = 0
	var/bluespace_capable = TRUE
	var/cooldown = 0
	var/thruster_active = FALSE
	var/obj/machinery/atmospherics/components/unary/shuttle/heater/attached_heater

/obj/machinery/shuttle/engine/plasma
	name = "plasma thruster"
	desc = "A thruster that burns plasma stored in an adjacent plasma thruster heater."
	icon_state = "burst_plasma"
	icon_state_off = "burst_plasma_off"

	idle_power_usage = 0
	circuit = /obj/item/circuitboard/machine/shuttle/engine/plasma
	thrust = 25
	fuel_use = 0.09
	bluespace_capable = FALSE
	cooldown = 45

/obj/machinery/shuttle/engine/void
	name = "void thruster"
	desc = "A thruster using technology to breach voidspace for propulsion."
	icon_state = "burst_void"
	icon_state_off = "burst_void"
	icon_state_closed = "burst_void"
	icon_state_open = "burst_void_open"
	idle_power_usage = 0
	circuit = /obj/item/circuitboard/machine/shuttle/engine/void
	thrust = 400
	fuel_use = 0
	bluespace_capable = TRUE
	cooldown = 90

/obj/machinery/shuttle/engine/check_setup(var/affectSurrounding = TRUE)
	var/heater_turf
	switch(dir)
		if(NORTH)
			heater_turf = get_offset_target_turf(src, 0, 1)
		if(SOUTH)
			heater_turf = get_offset_target_turf(src, 0, -1)
		if(EAST)
			heater_turf = get_offset_target_turf(src, 1, 0)
		if(WEST)
			heater_turf = get_offset_target_turf(src, -1, 0)
	if(!heater_turf)
		attached_heater = null
		update_engine()
		return ..()
	attached_heater = null
	for(var/atom/thing in heater_turf)
		if(!istype(thing, /obj/machinery/atmospherics/components/unary/shuttle/heater))
			continue
		if(thing.dir != dir)
			continue
		var/obj/machinery/atmospherics/components/unary/shuttle/heater/as_heater = thing
		if(as_heater.panel_open)
			continue
		if(!as_heater.anchored)
			continue
		attached_heater = as_heater
		break
	update_engine()
	return ..()

/obj/machinery/shuttle/engine/proc/update_engine()
	if(panel_open)
		thruster_active = FALSE
		return
	if(!attached_heater)
		icon_state = icon_state_off
		thruster_active = FALSE
		return
	if(attached_heater.hasFuel(1))
		icon_state = icon_state_closed
		thruster_active = TRUE
		return
	thruster_active = FALSE
	icon_state = icon_state_off
	return

/obj/machinery/shuttle/engine/void/proc/update_engine()
	if(panel_open)
		thruster_active = FALSE
		return
	thruster_active = TRUE
	icon_state = icon_state_closed
	return

//Thanks to spaceheater.dm for inspiration :)
/obj/machinery/shuttle/engine/proc/fireEngine()
	var/turf/heatTurf = loc
	if(!heatTurf)
		return
	var/datum/gas_mixture/env = heatTurf.return_air()
	var/heat_cap = env.heat_capacity()
	var/req_power = abs(env.temperature - ENGINE_HEAT_TARGET) * heat_cap
	req_power = min(req_power, 500000)
	var/deltaTemperature = req_power / heat_cap
	if(deltaTemperature < 0)
		return
	env.temperature += deltaTemperature
	air_update_turf()
