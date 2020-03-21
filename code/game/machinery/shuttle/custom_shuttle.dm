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
	if(!affectSurrounding)
		return
	for(var/place in get_area(get_turf(src)))
		for(var/atom/thing in place)
			if(!istype(thing, /obj/machinery/shuttle))
				continue
			if(thing == src)
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
	if(default_deconstruction_crowbar(I))
		check_setup()
		return
	check_setup()
	return ..()
