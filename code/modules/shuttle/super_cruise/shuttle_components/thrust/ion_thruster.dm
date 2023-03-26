/obj/machinery/shuttle/engine/ion
	name = "ion thruster"
	desc = "A thruster that expells ions in order to generate thrust. Weak, but easy to maintain."
	icon_state = "ion_thruster"
	icon_state_open = "ion_thruster_open"
	icon_state_off = "ion_thruster_off"

	idle_power_usage = 0
	circuit = /obj/item/circuitboard/machine/shuttle/engine/ion
	thrust = 200
	fuel_use = 0
	cooldown = 45
	var/usage_rate = 15
	var/obj/machinery/power/engine_capacitor_bank/capacitor_bank

/obj/machinery/shuttle/engine/ion/consume_fuel(amount)
	if(!capacitor_bank)
		return
	capacitor_bank.stored_power = max(capacitor_bank.stored_power - usage_rate * ORBITAL_UPDATE_RATE_SECONDS, 0)

/obj/machinery/shuttle/engine/ion/update_engine()
	if(panel_open)
		set_active(FALSE)
		icon_state = icon_state_open
		return
	if(!needs_heater)
		icon_state = icon_state_closed
		set_active(TRUE)
		return
	if(capacitor_bank?.stored_power)
		icon_state = icon_state_closed
		set_active(TRUE)
	else
		set_active(FALSE)
		icon_state = icon_state_off

/obj/machinery/shuttle/engine/ion/check_setup()
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
		capacitor_bank = null
		update_engine()
		return
	register_capacitor_bank(null)
	var/obj/machinery/power/engine_capacitor_bank/as_heater = locate() in heater_turf
	if(!as_heater)
		return
	if(as_heater.dir != dir)
		return
	if(as_heater.panel_open)
		return
	if(!as_heater.anchored)
		return
	register_capacitor_bank(as_heater)
	. = ..()

/obj/machinery/shuttle/engine/ion/proc/register_capacitor_bank(new_bank)
	if(capacitor_bank)
		UnregisterSignal(capacitor_bank, COMSIG_PARENT_QDELETING)
	capacitor_bank = new_bank
	if(capacitor_bank)
		RegisterSignal(capacitor_bank, COMSIG_PARENT_QDELETING, PROC_REF(on_capacitor_deleted))
	update_engine()

/obj/machinery/shuttle/engine/ion/proc/on_capacitor_deleted(datum/source, force)
	register_capacitor_bank(null)

//=============================
// Capacitor Bank
//=============================

/obj/machinery/power/engine_capacitor_bank
	name = "thruster capacitor bank"
	desc = "A capacitor bank that stores power for high-energy ion thrusters."
	icon_state = "heater_ion"
	icon = 'icons/obj/shuttle.dmi'
	density = TRUE
	use_power = NO_POWER_USE
	circuit = /obj/item/circuitboard/machine/shuttle/capacitor_bank
	var/icon_state_closed = "heater_ion"
	var/icon_state_open = "heater_ion_open"
	var/icon_state_off = "heater_ion"
	var/stored_power = 0
	var/charge_rate = 20
	var/maximum_stored_power = 500

/obj/machinery/power/engine_capacitor_bank/Initialize(mapload)
	. = ..()
	GLOB.custom_shuttle_machines += src
	update_adjacent_engines()

/obj/machinery/power/engine_capacitor_bank/Destroy()
	GLOB.custom_shuttle_machines -= src
	. = ..()
	update_adjacent_engines()

/obj/machinery/power/engine_capacitor_bank/RefreshParts()
	maximum_stored_power = 0
	charge_rate = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		maximum_stored_power += C.rating * 200
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		charge_rate += L.rating * 20
	stored_power = min(stored_power, maximum_stored_power)

/obj/machinery/power/engine_capacitor_bank/examine(mob/user)
	. = ..()
	. += "The capacitor bank reads [stored_power]W of power stored.<br>"

/obj/machinery/power/engine_capacitor_bank/process(delta_time)
	take_power(delta_time)

/obj/machinery/power/engine_capacitor_bank/proc/take_power(delta_time)
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(!C)
		return
	var/datum/powernet/powernet = C.powernet
	if(!powernet)
		return
	//Consume power
	var/surplus = max(powernet.avail - powernet.load, 0)
	var/available_power = min(charge_rate * delta_time * 10, surplus, maximum_stored_power - stored_power)
	if(available_power)
		powernet.load += available_power
		stored_power += available_power

//Annoying copy and paste because atmos machines aren't a component so engine heaters
//can't share from the same supertype
/obj/machinery/power/engine_capacitor_bank/proc/update_adjacent_engines()
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

/obj/machinery/power/engine_capacitor_bank/attackby(obj/item/I, mob/living/user, params)
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

/obj/machinery/power/engine_capacitor_bank/emp_act(severity)
	. = ..()
	stored_power = rand(0, stored_power)

/obj/machinery/power/engine_capacitor_bank/escape_pod
	name = "emergency thruster capacitor bank"
	desc = "A single-use, non-rechargable, high-capacitor capacitor bank used for getting shuttles away from a location fast."
	//Starts with maximum power
	stored_power = 600
	//Cannot be recharged
	charge_rate = 0
	//Provides 2 minutes of thrust when using burst thrusters
	maximum_stored_power = 600

/obj/machinery/power/engine_capacitor_bank/escape_pod/emp_act(severity)
	return

/obj/machinery/power/engine_capacitor_bank/escape_pod/RefreshParts()
	return

//=============================
// Burst Thruster (For shuttles)
//=============================

/obj/machinery/shuttle/engine/ion/burst
	name = "burst ion thruster"
	desc = "A varient of the ion thruster that uses significantly more power for a burst of thrust."

	circuit = /obj/item/circuitboard/machine/shuttle/engine/ion
	//Must faster
	thrust = 300
	//Uses more than it can be charged with a basic capacitor, so cannot sustain long periods of flight
	usage_rate = 5

/obj/machinery/shuttle/engine/ion/burst/consume_fuel(amount)
	if(!capacitor_bank)
		return
	capacitor_bank.stored_power = max(capacitor_bank.stored_power - capacitor_bank.charge_rate - usage_rate * ORBITAL_UPDATE_RATE_SECONDS, 0)
