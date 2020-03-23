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
	GLOB.custom_shuttle_machines += src

/obj/machinery/shuttle/Destroy()
	. = ..()
	GLOB.custom_shuttle_machines -= src

/obj/machinery/shuttle/attackby(obj/item/I, mob/living/user, params)
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
