/obj/machinery/recharge_station
	name = "cyborg recharging station"
	desc = "This device recharges cyborgs and resupplies them with materials."
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

/obj/machinery/recharge_station/Initialize()
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
		. += "<span class='notice'>The status display reads: Recharging <b>[recharge_speed]J</b> per cycle.<span>"
		if(repairs)
			. += "<span class='notice'>[src] has been upgraded to support automatic repairs.<span>"

/obj/machinery/recharge_station/process()
	if(!is_operational())
		return

	if(occupant)
		process_occupant()
	return 1

/obj/machinery/recharge_station/relaymove(mob/user)
	if(user.stat)
		return
	open_machine()

/obj/machinery/recharge_station/emp_act(severity)
	. = ..()
	if(!(stat & (BROKEN|NOPOWER)))
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
	if(iscyborg(occupant) || isethereal(occupant))
		use_power = IDLE_POWER_USE

/obj/machinery/recharge_station/close_machine()
	. = ..()
	if(occupant)
		if(iscyborg(occupant) || isethereal(occupant))
			use_power = ACTIVE_POWER_USE
			if(isethereal(occupant))
				to_chat(occupant, "<span class='notice'><b>As you step into the cyborg recharging station, you feel your power condensing.</b></span>")
		add_fingerprint(occupant)

/obj/machinery/recharge_station/update_icon()
	if(is_operational())
		if(state_open)
			icon_state = "borgcharger0"
		else
			icon_state = (occupant ? "borgcharger1" : "borgcharger2")
	else
		icon_state = (state_open ? "borgcharger-u0" : "borgcharger-u1")

/obj/machinery/recharge_station/power_change()
	..()
	update_icon()

/obj/machinery/recharge_station/proc/process_occupant()
	if(!occupant)
		return
	if(iscyborg(occupant))
		var/mob/living/silicon/robot/R = occupant
		restock_modules()
		if(repairs)
			R.heal_bodypart_damage(repairs, repairs - 1)
		if(R.cell)
			R.cell.charge = min(R.cell.charge + recharge_speed, R.cell.maxcharge)
	if(isethereal(occupant))
		var/mob/living/carbon/human/H = occupant
		var/datum/species/ethereal/E = H.dna?.species
		if(E.ethereal_charge <= ETHEREAL_CHARGE_LOWPOWER)	
			to_chat(H, "<span class='warning'>Your charge is too low to condense into Liquid Electricity!</span>")
			return
		else
			if(H.blood_volume < BLOOD_VOLUME_NORMAL)
				E.adjust_charge(-3) //Lose charge over time, turning it into ethereal blood.
				H.blood_volume += repairs*2+5 //Scaling blood gain rate and efficiency based on Manipulator tier.
			else
				to_chat(H, "<span class='warning'>Your Liquid Electricity stores are full!")
				return


/obj/machinery/recharge_station/proc/restock_modules()
	if(occupant)
		var/mob/living/silicon/robot/R = occupant
		if(R?.module)
			var/coeff = recharge_speed * 0.025
			R.module.respawn_consumable(R, coeff)
