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
	var/thrust = 1000
	var/fuel_use = 0
	var/bluespace_capable = TRUE
	var/cooldown = 0

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
	idle_power_usage = 200
