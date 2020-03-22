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
	check_setup()

//Call this when:
// - The shuttle it's attached to gets 'Calculate Stats' called
// - A heater next to this object gets wrenched into place
// - A heat next to this gets wrenched out of place
// - This gets wrenched into place
/obj/machinery/shuttle/proc/check_setup(var/affectSurrounding = TRUE)
	if(!affectSurrounding)
		return
	//Don't update if not on shuttle, to prevent lagging out the server in space
	if(!istype(get_turf(src), /area/shuttle/custom))
		return
	//Check the standard machines
	for(var/machinery/shuttle/shuttle_machine in GLOB.custom_shuttle_machines)
		if(!shuttle_machine)
			continue
		if(shuttle_machine == src)
			continue
		shuttle_machine.check_setup(FALSE)
	//Check the atmospheric devices (The heaters)
	for(var/obj/machinery/atmospherics/components/unary/shuttle/atmospheric_machine in GLOB.custom_shuttle_machines)
		if(!atmospheric_machine)
			continue
		atmospheric_machine.check_setup(FALSE)
	return

/obj/machinery/shuttle/attackby(obj/item/I, mob/living/user, params)
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
