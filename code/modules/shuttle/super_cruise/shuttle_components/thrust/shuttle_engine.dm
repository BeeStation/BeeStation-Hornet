//-----------------------------------------------
//-------------Engine Thrusters------------------
//-----------------------------------------------

#define ENGINE_HEAT_TARGET 900

/obj/machinery/shuttle/engine
	name = "shuttle thruster"
	desc = "A thruster for shuttles."
	density = TRUE
	obj_integrity = 250
	max_integrity = 250
	icon = 'icons/obj/shuttle.dmi'
	icon_state = "burst_plasma"
	idle_power_usage = 1500
	circuit = /obj/item/circuitboard/machine/shuttle/engine
	var/thrust = 0
	var/fuel_use = 0
	var/cooldown = 0
	var/thruster_active = FALSE
	var/needs_heater = TRUE

/obj/machinery/shuttle/engine/Initialize(mapload)
	. = ..()
	//Check setup
	check_setup()
	//Check if we are on a shuttle
	var/area/shuttle/current_area = get_area(src)
	if(istype(current_area) && current_area.mobile_port)
		var/datum/shuttle_data/shuttle_data = SSorbits.get_shuttle_data(current_area.mobile_port.id)
		shuttle_data?.register_thruster(src)

/obj/machinery/shuttle/engine/proc/consume_fuel(amount)
	return

/obj/machinery/shuttle/engine/proc/get_fuel_amount()
	return 0

/obj/machinery/shuttle/engine/proc/check_setup()
	update_engine()

/obj/machinery/shuttle/engine/power_change()
	. = ..()
	update_engine()

/obj/machinery/shuttle/engine/proc/update_engine()
	if(panel_open)
		set_active(FALSE)
		icon_state = icon_state_open
		return
	if(!needs_heater)
		icon_state = icon_state_closed
		set_active(TRUE)
		return
	if((!idle_power_usage || !(machine_stat & NOPOWER)))
		icon_state = icon_state_closed
		set_active(TRUE)
	else
		set_active(FALSE)
		icon_state = icon_state_off

/obj/machinery/shuttle/engine/proc/set_active(new_active)
	SEND_SIGNAL(src, COMSIG_SHUTTLE_ENGINE_STATUS_CHANGE, thruster_active, new_active)
	thruster_active = new_active

//Thanks to spaceheater.dm for inspiration :)
/obj/machinery/shuttle/engine/proc/fireEngine()
	var/turf/heatTurf = loc
	if(!heatTurf)
		return
	var/datum/gas_mixture/env = heatTurf.return_air()
	//Heat up the turf to a hot temperature.
	//Do it in a more sensible manner than calculating ENGINE_HEAT_TARGET with
	//a bunch of pointless logic
	if(env.return_temperature() < ENGINE_HEAT_TARGET)
		env.set_temperature(ENGINE_HEAT_TARGET)
	air_update_turf()

/obj/machinery/shuttle/engine/attackby(obj/item/I, mob/living/user, params)
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

//========================
// Plasma Thruster
//========================

/obj/machinery/shuttle/engine/plasma
	name = "plasma thruster"
	desc = "A thruster that burns plasma stored in an adjacent plasma thruster heater."
	icon_state = "burst_plasma"
	icon_state_off = "burst_plasma_off"

	idle_power_usage = 0
	circuit = /obj/item/circuitboard/machine/shuttle/engine/plasma
	thrust = 300
	fuel_use = 0.12
	cooldown = 45
	var/datum/weakref/attached_heater
	var/cached_efficiency = -1

/obj/machinery/shuttle/engine/plasma/consume_fuel(amount)
	if(!attached_heater)
		return
	var/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/shuttle_heater = attached_heater.resolve()
	if (!shuttle_heater)
		return
	shuttle_heater.consumeFuel(amount * fuel_use)
	update_efficiency()

/obj/machinery/shuttle/engine/plasma/proc/update_efficiency()
	if(!attached_heater)
		return
	var/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/shuttle_heater = attached_heater.resolve()
	if (!shuttle_heater)
		return
	if(cached_efficiency != shuttle_heater.get_gas_multiplier())
		cached_efficiency = shuttle_heater.get_gas_multiplier()
		if(!thruster_active)
			thrust = initial(thrust) * cached_efficiency
			return
		set_active(FALSE)
		thrust = initial(thrust) * cached_efficiency
		set_active(TRUE)

/obj/machinery/shuttle/engine/plasma/get_fuel_amount()
	if(!attached_heater)
		return 0
	var/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/shuttle_heater = attached_heater.resolve()
	if (!shuttle_heater)
		return 0
	return shuttle_heater.getFuelAmount()

/obj/machinery/shuttle/engine/plasma/check_setup()
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
		return
	attached_heater = null
	var/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/as_heater = locate() in heater_turf
	if(!as_heater)
		update_engine()
		return
	if(as_heater.dir != dir)
		return
	if(as_heater.panel_open)
		return
	if(!as_heater.anchored)
		return
	attached_heater = WEAKREF(as_heater)
	. = ..()

/obj/machinery/shuttle/engine/plasma/update_engine()
	update_efficiency()
	if(panel_open)
		set_active(FALSE)
		icon_state = icon_state_open
		return
	if(!needs_heater)
		icon_state = icon_state_closed
		set_active(TRUE)
		return
	if(!attached_heater)
		icon_state = icon_state_off
		set_active(FALSE)
		return
	var/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/resolved_heater = attached_heater.resolve()
	if(resolved_heater?.hasFuel(1) && (!idle_power_usage || !(machine_stat & NOPOWER)))
		icon_state = icon_state_closed
		set_active(TRUE)
	else
		set_active(FALSE)
		icon_state = icon_state_off

//========================
// Void Thruster
//========================

/obj/machinery/shuttle/engine/void
	name = "void thruster"
	desc = "A thruster using technology to breach voidspace for propulsion."
	icon_state = "burst_void"
	icon_state_off = "burst_void"
	icon_state_closed = "burst_void"
	icon_state_open = "burst_void_open"
	circuit = /obj/item/circuitboard/machine/shuttle/engine/void
	thrust = 250
	fuel_use = 0
	needs_heater = FALSE
	cooldown = 90
