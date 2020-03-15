/obj/machinery/shuttle
	name = "shuttle component"
	desc = "Something for shuttles."
	density = TRUE
	obj_integrity = 250
	max_integrity = 250
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "burst_plasma"
	idle_power_usage = 150
	circuit = /obj/item/circuitboard/machine/shuttle/engine
	var/icon_state_closed = "burst_plasma"
	var/icon_state_open = "burst_plasma_open"

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
	var/attached_heater

//Call this when:
// - The shuttle it's attached to gets 'Calculate Stats' called
// - A heater next to this object gets wrenched into place
// - A heat next to this gets wrenched out of place
// - This gets wrenched into place
/obj/machinery/shuttle/proc/check_setup(var/atom/A, var/affectSurrounding = TRUE)
	if(!affectSurrounding)
		return
	for(var/turf in get_area_turfs(get_turf(A)))
		for(var/obj/machinery/shuttle/thing in turf)
			thing.check_setup(thing, FALSE)
	return

/obj/machinery/shuttle/engine/plasma/check_setup(var/atom/A, var/affectSurrounding = TRUE)
	var/heater_turf
	switch(dir)
		if(NORTH)
			heater_turf = get_offset_target_turf(A, 0, 1)
		if(SOUTH)
			heater_turf = get_offset_target_turf(A, 0, -1)
		if(EAST)
			heater_turf = get_offset_target_turf(A, 1, 0)
		if(WEST)
			heater_turf = get_offset_target_turf(A, -1, 0)
	if(!heater_turf)
		attached_heater = null
		return ..()
	for(var/obj/machinery/shuttle/engine/thing in heater_turf)
		if(thing.dir != dir)
			attached_heater = null
			return ..()
		attached_heater = thing
	return ..()

/obj/machinery/shuttle/engine/plasma
	name = "plasma thruster"
	desc = "A thruster that burns plasma stored in an adjacent plasma thruster heater."
	icon_state = "burst_plasma"
	idle_power_usage = 0
	thrust = 25
	fuel_use = 0.04
	bluespace_capable = FALSE
	cooldown = 45

/obj/machinery/shuttle/heater
	name = "engine heater"
	desc = "Directs energy into compressed particles in order to power an attached thruster."
	icon_state = "heater"
	icon_state_closed = "heater"
	icon_state_open = "heater_open"
	idle_power_usage = 200

/obj/machinery/shuttle/engine/attackby(obj/item/I, mob/living/user, params)
	check_setup(.)
	if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_closed, I))
		return
	if(default_pry_open(I))
		return
	if(state_open)
		if(default_change_direction_wrench(user, I))
			return
	if(default_unfasten_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()
