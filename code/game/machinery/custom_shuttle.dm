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
	var/icon_state_closed = "burst_plasma"
	var/icon_state_open = "burst_plasma_open"
	var/thrust = 1000
	var/fuel_use = 0
	var/bluespace_capable = TRUE
	var/cooldown = 0
	var/setup = FALSE

//Call this when:
// - The shuttle it's attached to gets 'Calculate Stats' called
// - A heater next to this object gets wrenched into place
// - A heat next to this gets wrenched out of place
// - This gets wrenched into place
/obj/machinery/shuttle/engine/proc/setup()


/obj/machinery/shuttle/engine/plasma
	name = "plasma thruster"
	desc = "A thruster that burns plasma stored in an adjacent plasma thruster heater."
	icon_state = "burst_plasma"
	idle_power_usage = 0
	thrust = 25
	fuel_use = 0.04
	bluespace_capable = FALSE
	cooldown = 45

/obj/machinery/shuttle/engine/heater
	name = "engine heater"
	desc = "Directs energy into compressed particles in order to power an attached thruster."
	icon_state = "heater"
	icon_state_closed = "heater"
	icon_state_open = "heater_open"
	idle_power_usage = 200

/obj/machinery/shuttle/engine/attackby(obj/item/I, mob/living/user, params)
	if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_closed, I))
		return
	if(default_pry_open(I))
		return
	if(default_unfasten_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()
