/obj/machinery/recharge_station
	name = "recharging station"
	desc = "This device recharges energy dependent lifeforms, like cyborgs, ethereals and MODsuit users."
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 1000
	req_access = list(ACCESS_ROBOTICS)
	state_open = TRUE
	circuit = /obj/item/circuitboard/machine/cyborgrecharger
	occupant_typecache = list(/mob/living/silicon/robot, /mob/living/carbon/human)
	var/recharge_speed
	var/repairs

/obj/machinery/recharge_station/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/recharge_station/RefreshParts()
	recharge_speed = 0
	repairs = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_speed += (C.rating * 100) + 66 // Starting boost, but inconsequential at t4
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		repairs += M.rating - 1
	for(var/obj/item/stock_parts/cell/C in component_parts)
		recharge_speed *= C.maxcharge / 10000

/obj/machinery/recharge_station/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Recharging <b>[recharge_speed]J</b> per cycle.")
		if(repairs)
			. += span_notice("[src] has been upgraded to support automatic repairs.")

/obj/machinery/recharge_station/process(delta_time)
	if(!is_operational)
		return
	if(occupant)
		process_occupant(delta_time)
	return 1

/obj/machinery/recharge_station/relaymove(mob/living/user, direction)
	if(user.stat)
		return
	open_machine()

/obj/machinery/recharge_station/emp_act(severity)
	. = ..()
	if(!(machine_stat & (BROKEN|NOPOWER)))
		if(occupant && !(. & EMP_PROTECT_CONTENTS))
			occupant.emp_act(severity)
		if (!(. & EMP_PROTECT_SELF))
			open_machine()

/obj/machinery/recharge_station/attackby(obj/item/P, mob/user, params)
	if(state_open)
		if(default_deconstruction_screwdriver(user, "borgdecon2", "borgcharger0", P))
			return

	if(default_pry_open(P))
		return

	if(default_deconstruction_crowbar(P))
		return
	return ..()

/obj/machinery/recharge_station/interact(mob/user)
	toggle_open()
	return TRUE

/obj/machinery/recharge_station/proc/toggle_open()
	if(state_open)
		close_machine()
	else
		open_machine()

/obj/machinery/recharge_station/open_machine()
	. = ..()
	update_use_power(IDLE_POWER_USE)

/obj/machinery/recharge_station/close_machine()
	. = ..()
	if(occupant)
		update_use_power(ACTIVE_POWER_USE) //It always tries to charge, even if it can't.
		add_fingerprint(occupant)

/obj/machinery/recharge_station/update_icon()
	if(is_operational)
		if(state_open)
			icon_state = "borgcharger0"
		else
			icon_state = (occupant ? "borgcharger1" : "borgcharger2")
	else
		icon_state = (state_open ? "borgcharger-u0" : "borgcharger-u1")

/obj/machinery/recharge_station/proc/process_occupant(delta_time)
	if(!occupant)
		return
	SEND_SIGNAL(occupant, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, recharge_speed * delta_time / 2, repairs)

/obj/machinery/recharge_station/proc/restock_modules()
	if(occupant)
		var/mob/living/silicon/robot/robot = occupant
		if(robot?.model)
			robot.model.respawn_consumable(robot, recharge_speed * 0.025)
