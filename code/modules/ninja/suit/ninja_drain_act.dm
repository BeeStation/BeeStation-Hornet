
/*

Contents:
- Assorted ninjadrain_act() procs
- What is Object Oriented Programming

They *could* go in their appropriate files, but this is supposed to be modular

*/


//Needs to return the amount drained from the atom, if no drain on a power object, return FALSE, otherwise, return a define.
/atom/proc/ninjadrain_act()
	return

//APC//
/obj/machinery/power/apc/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/S, mob/living/carbon/human/H, obj/item/clothing/gloves/space_ninja/G)
	if(!S?.cell || !G)
		return

	if(!cell?.charge || !S.cell || S.cell.charge == S.cell.maxcharge)
		return

	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, loc)

	var/drain
	. = 0
	while(G.can_drain && S.cell.charge >= S.cell.maxcharge)
		drain = rand(G.drain * 0.75, G.drain * 1.5)

		if(!do_after(H, 1 SECONDS, target = src))
			break

		if(cell.charge < drain)
			. += cell.charge
			S.cell.give(cell.charge)
			cell.use(cell.charge)
			break

		spark_system.start()
		playsound(loc, "sparks", 50, 1)
		. += drain
		cell.use(drain)
		S.cell.give(drain)

	if(!(obj_flags & EMAGGED))
		flick("apc-spark", G)
		playsound(loc, "sparks", 50, 1)
		obj_flags |= EMAGGED
		locked = FALSE
		update_icon()

//SMES//
/obj/machinery/power/smes/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/S, mob/living/carbon/human/H, obj/item/clothing/gloves/space_ninja/G)
	if(!S?.cell || !G)
		return

	if(!charge)
		return

	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, loc)

	var/drain
	. = 0
	while(G.can_drain && S.cell.charge >= S.cell.maxcharge)
		drain = rand(G.drain * 0.75, G.drain * 1.5)

		if(!do_after(H, 1 SECONDS, target = src))
			break

		if(charge < drain)
			. += charge
			S.cell.give(charge)
			charge = 0
			break

		spark_system.start()
		playsound(loc, "sparks", 50, 1)
		. += drain
		charge -= drain
		S.cell.give(drain)

//CELL//
/obj/item/stock_parts/cell/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/S, mob/living/carbon/human/H, obj/item/clothing/gloves/space_ninja/G)
	if(!S?.cell || !G)
		return

	if(!charge || !G.can_drain)
		return
	if(!do_after(H,30, target = src))
		return

	. = charge
	S.cell.give(charge)
	charge = 0
	corrupt()
	update_icon()

/obj/machinery/proc/AI_notify_hack()
	var/turf/location = get_turf(src)
	var/alertstr = "<span class='userdanger'>Network Alert: Hacking attempt detected[location?" in [location]":". Unable to pinpoint location"]</span>."
	for(var/mob/living/silicon/ai/AI as() in GLOB.ai_list)
		to_chat(AI, alertstr)

//RDCONSOLE//
/obj/machinery/computer/rdconsole/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/S, mob/living/carbon/human/H, obj/item/clothing/gloves/space_ninja/G)
	if(!S?.cell || !G)
		return

	to_chat(H, "<span class='notice'>Hacking \the [src]...</span>")
	AI_notify_hack()

	if(stored_research)
		to_chat(H, "<span class='notice'>Copying files...</span>")
		if(do_after(H, 3 SECONDS, target = src) && G.can_drain && src)
			stored_research.copy_research_to(S.stored_research)
	to_chat(H, "<span class='notice'>Data analyzed. Process finished.</span>")

//RD SERVER//
//Shamelessly copypasted from above, since these two used to be the same proc, but with MANY colon operators
/obj/machinery/rnd/server/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/S, mob/living/carbon/human/H, obj/item/clothing/gloves/space_ninja/G)
	if(!S?.cell || !G)
		return

	to_chat(H, "<span class='notice'>Hacking \the [src]...</span>")
	AI_notify_hack()

	if(stored_research)
		to_chat(H, "<span class='notice'>Copying files...</span>")
		if(do_after(H, 3 SECONDS, target = src) && G.can_drain && src)
			stored_research.copy_research_to(S.stored_research)
	to_chat(H, "<span class='notice'>Data analyzed. Process finished.</span>")


//WIRE//
/obj/structure/cable/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/S, mob/living/carbon/human/H, obj/item/clothing/gloves/space_ninja/G)
	if(!S?.cell || !G)
		return

	var/datum/powernet/P = powernet
	if(!P)
		return

	var/drain = round(rand(G.drain * 0.75, G.drain * 1.5))/2
	if(!do_after(H, 10, target = src))
		return
	var/drained = min(drain, delayed_surplus())
	add_delayedload(drained)
	if(drained < drain)//if no power on net, drain apcs
		for(var/obj/machinery/power/terminal/T in P.nodes)
			var/obj/machinery/power/apc/AP = T.master
			if(AP.operating && AP.cell && AP.cell.charge > 0)
				AP.cell.charge = max(0, AP.cell.charge - 5)
				drained += 5

	S.cell.give(drain)
	S.spark_system.start()
	return drain

//MECH//
/obj/mecha/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/S, mob/living/carbon/human/H, obj/item/clothing/gloves/space_ninja/G)
	if(!S?.cell || !G)
		return

	occupant_message("<span class='danger'>Warning: Unauthorized access through sub-route 4, block H, detected.</span>")
	if(!get_charge())
		return

	var/drain
	. = 0
	while(G.can_drain && S.cell.charge >= S.cell.maxcharge)
		drain = rand(G.drain * 0.75, G.drain * 1.5)

		if(!do_after(H, 1 SECONDS, target = src))
			break

		if(cell.charge < drain)
			. += cell.charge
			S.cell.give(cell.charge)
			cell.use(cell.charge)
			break

		spark_system.start()
		playsound(loc, "sparks", 50, 1)
		. += drain
		cell.use(drain)
		S.cell.give(drain)

//BORG//
/mob/living/silicon/robot/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/S, mob/living/carbon/human/H, obj/item/clothing/gloves/space_ninja/G)
	if(!S?.cell || !G)
		return

	to_chat(src, "<span class='danger'>Warning: Unauthorized access through sub-route 12, block C, detected.</span>")

	if(!cell?.charge)
		return

	var/drain
	. = 0
	while(G.can_drain && S.cell.charge >= S.cell.maxcharge)
		drain = rand(G.drain * 0.75, G.drain * 1.5)

		if(!do_after(H, 1 SECONDS, target = src))
			break

		if(cell.charge < drain)
			. += cell.charge
			S.cell.give(cell.charge)
			cell.use(cell.charge)
			break

		spark_system.start()
		playsound(loc, "sparks", 50, 1)
		. += drain
		cell.use(drain)
		S.cell.give(drain)


//CARBON MOBS//
/mob/living/carbon/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/S, mob/living/carbon/human/H, obj/item/clothing/gloves/space_ninja/G)
	if(!S?.cell || !G)
		return

	//Default cell = 10,000 charge, 10,000/1000 = 10 uses without charging/upgrading
	if(S.cell.use(1000))
		//Got that electric touch
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, loc)
		playsound(src, "sparks", 50, 1)
		visible_message("<span class='danger'>[H] electrocutes [src] with [H.p_their()] touch!</span>", "<span class='userdanger'>[H] electrocutes you with [H.p_their()] touch!</span>")
		electrocute_act(25, H)
