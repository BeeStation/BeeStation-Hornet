/obj/machinery/recharge_station
	name = "recharging station"
	desc = "This device recharges energy dependent lifeforms, like cyborgs, ethereals and MODsuit users."
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	base_icon_state = "borgcharger"
	density = FALSE
	req_access = list(ACCESS_ROBOTICS)
	state_open = TRUE
	circuit = /obj/item/circuitboard/machine/cyborgrecharger
	occupant_typecache = list(/mob/living/silicon/robot, /mob/living/carbon/human)
	var/recharge_speed
	var/repairs
	///Callback for borgs & modsuits to provide their cell to us for charging
	var/datum/callback/charge_cell

/obj/machinery/recharge_station/Initialize(mapload)
	. = ..()
	charge_cell = CALLBACK(src, PROC_REF(charge_target_cell))
	update_icon()

/obj/machinery/recharge_station/Destroy()
	charge_cell = null
	return ..()

/**
 * Mobs & borgs invoke this through a callback to recharge their cells
 * Arguments
 *
 * * obj/item/stock_parts/cell/target - the cell to charge, optional if provided else will draw power used directly
 * * seconds_per_tick - supplied from process()
 */
/obj/machinery/recharge_station/proc/charge_target_cell(obj/item/stock_parts/cell/target, seconds_per_tick)
	PRIVATE_PROC(TRUE)

	return charge_cell(recharge_speed * seconds_per_tick, target, grid_only = TRUE)

/obj/machinery/recharge_station/RefreshParts()
	. = ..()
	recharge_speed = 0
	repairs = 0
	for(var/datum/stock_part/capacitor/C in component_parts)
		recharge_speed += 5e-3 * C.tier
	for(var/datum/stock_part/manipulator/M in component_parts)
		repairs += M.tier - 1
	for(var/obj/item/stock_parts/cell/C in component_parts)
		recharge_speed *= C.maxcharge

/obj/machinery/recharge_station/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Recharging: <b>[display_power(recharge_speed)]</b>.")
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

/obj/machinery/recharge_station/open_machine(drop = TRUE, density_to_set = FALSE)
	. = ..()
	update_use_power(IDLE_POWER_USE)

/obj/machinery/recharge_station/close_machine(atom/movable/target, density_to_set = TRUE)
	. = ..()
	if(occupant)
		update_use_power(ACTIVE_POWER_USE) //It always tries to charge, even if it can't.
		add_fingerprint(occupant)

/obj/machinery/recharge_station/update_icon_state()
	if(panel_open)
		icon_state = "borgdecon2"
		return ..()
	if(!is_operational)
		icon_state = "[base_icon_state]-u[state_open ? 0 : 1]"
		return ..()
	icon_state = "[base_icon_state][state_open ? 0 : (occupant ? 1 : 2)]"
	return ..()

/obj/machinery/recharge_station/proc/process_occupant(delta_time)
	if(!occupant)
		return
	SEND_SIGNAL(occupant, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, charge_cell, delta_time, repairs)

/obj/machinery/recharge_station/proc/restock_modules()
	if(occupant)
		var/mob/living/silicon/robot/robot = occupant
		if(robot?.model)
			robot.model.respawn_consumable(robot, recharge_speed * 0.025)
