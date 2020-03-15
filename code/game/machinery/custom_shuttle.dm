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
	var/icon_state_off = "burst_plasma_off"

/obj/machinery/shuttle/Initialize()
	. = ..()
	check_setup()

//Call this when:
// - The shuttle it's attached to gets 'Calculate Stats' called
// - A heater next to this object gets wrenched into place
// - A heat next to this gets wrenched out of place
// - This gets wrenched into place
/obj/machinery/shuttle/proc/check_setup(var/affectSurrounding = TRUE)
	message_admins("Hey, I just updated the [src.name]")
	if(!affectSurrounding)
		return
	for(var/place in get_area(get_turf(src)))
		for(var/atom/thing in place)
			if(!istype(thing, /obj/machinery/shuttle))
				continue
			if(thing == src)
				message_admins("Skipping self")
				continue
			var/obj/machinery/shuttle/shuttle_comp = thing
			shuttle_comp.check_setup(FALSE)
	return

/obj/machinery/shuttle/attackby(obj/item/I, mob/living/user, params)
	if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_closed, I))
		check_setup()
		return
	if(default_pry_open(I))
		check_setup()
		return
	if(panel_open)
		if(default_unfasten_wrench(user, I))
			check_setup()
			return
	if(default_change_direction_wrench(user, I))
		check_setup()
		return
	if(default_deconstruction_crowbar(I))
		check_setup()
		return
	check_setup()
	return ..()

//-----------------------------------------------
//-------------Engine Thrusters------------------
//-----------------------------------------------

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
	var/obj/machinery/shuttle/heater/attached_heater

/obj/machinery/shuttle/engine/check_setup(var/affectSurrounding = TRUE)
	message_admins("Plasma setup called ma ni-!")
	var/heater_turf
	switch(dir)
		if(NORTH)
			heater_turf = get_offset_target_turf(src, 0, -1)
		if(SOUTH)
			heater_turf = get_offset_target_turf(src, 0, 1)
		if(EAST)
			heater_turf = get_offset_target_turf(src, 1, 0)
		if(WEST)
			heater_turf = get_offset_target_turf(src, -1, 0)
	if(!heater_turf)
		message_admins("Hey, the turf is null :(")
		attached_heater = null
		update_engine()
		return ..()
	attached_heater = null
	for(var/atom/thing in heater_turf)
		if(!istype(thing, /obj/machinery/shuttle/heater))
			continue
		message_admins("Found engine heater!")
		if(thing.dir != dir)
			continue
		var/obj/machinery/shuttle/heater/as_heater = thing
		if(as_heater.panel_open)
			continue
		if(!as_heater.anchored)
			continue
		attached_heater = as_heater
		message_admins("Found engine heater!")
		break
	update_engine()
	return ..()

/obj/machinery/shuttle/engine/plasma
	name = "plasma thruster"
	desc = "A thruster that burns plasma stored in an adjacent plasma thruster heater."
	icon_state = "burst_plasma"
	icon_state_off = "burst_plasma_off"
	idle_power_usage = 0
	circuit = /obj/item/circuitboard/machine/shuttle/engine/plasma
	thrust = 25
	fuel_use = 0.04
	bluespace_capable = FALSE
	cooldown = 45

/obj/machinery/shuttle/engine/proc/update_engine()
	if(panel_open)
		return
	if(!attached_heater)
		icon_state = icon_state_off
		return
	if(attached_heater.powering_thruster)
		icon_state = icon_state_closed
		return
	icon_state = icon_state_off
	return

//-----------------------------------------------
//--------------Engine Heaters-------------------
//-----------------------------------------------
/obj/machinery/shuttle/heater
	name = "engine heater"
	desc = "Directs energy into compressed particles in order to power an attached thruster."
	icon_state = "heater"
	icon_state_closed = "heater"
	icon_state_open = "heater_open"
	icon_state_off = "heater"
	idle_power_usage = 200
	circuit = /obj/item/circuitboard/machine/shuttle/heater
	var/powering_thruster = TRUE
