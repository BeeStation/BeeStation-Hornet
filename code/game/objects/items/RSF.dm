/*
CONTAINS:
RSF

*/
/obj/item/rsf
	name = "\improper Rapid-Service-Fabricator"
	desc = "A device used to rapidly deploy service items."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	opacity = FALSE
	density = FALSE
	anchored = FALSE
	item_flags = NOBLUDGEON
	armor_type = /datum/armor/none
	var/matter = 0
	var/mode = 1
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/rsf/examine(mob/user)
	. = ..()
	. += span_notice("It currently holds [matter]/30 fabrication-units.")

/obj/item/rsf/cyborg
	matter = 30

/obj/item/rsf/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/rcd_ammo))
		if((matter + 10) > 30)
			to_chat(user, "The RSF can't hold any more matter.")
			return
		qdel(W)
		matter += 10
		playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
		to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
	else
		return ..()

/obj/item/rsf/attack_self(mob/user)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	switch(mode)
		if(5)
			mode = 1
			if(iscyborg(user))
				var/mob/living/silicon/robot/R = user
				if(R.emagged)
					mode = 6
			if (mode==1)
				to_chat(user, "Changed dispensing mode to 'Drinking Glass'")
			else
				to_chat(user, "Changed dispensing mode to 'Explosive Cigarette'")
		if(6)
			mode = 1
			to_chat(user, "Changed dispensing mode to 'Drinking Glass'")
		if(1)
			mode = 2
			to_chat(user, "Changed dispensing mode to 'Paper'")
		if(2)
			mode = 3
			to_chat(user, "Changed dispensing mode to 'Pen'")
		if(3)
			mode = 4
			to_chat(user, "Changed dispensing mode to 'Dice Pack'")
		if(4)
			mode = 5
			to_chat(user, "Changed dispensing mode to 'Cigarette'")
	// Change mode

/obj/item/rsf/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if (!(istype(A, /obj/structure/table) || isfloorturf(A)))
		return

	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell || R.cell.charge < 200)
			to_chat(user, span_warning("You do not have enough power to use [src]."))
			return
	else if (matter < 1)
		to_chat(user, span_warning("\The [src] doesn't have enough matter left."))
		return

	var/turf/T = get_turf(A)
	playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
	switch(mode)
		if(1)
			to_chat(user, "Dispensing Drinking Glass...")
			new /obj/item/reagent_containers/cup/glass/drinkingglass(T)
			use_matter(20, user)
		if(2)
			to_chat(user, "Dispensing Paper Sheet...")
			new /obj/item/paper(T)
			use_matter(10, user)
		if(3)
			to_chat(user, "Dispensing Pen...")
			new /obj/item/pen(T)
			use_matter(50, user)
		if(4)
			to_chat(user, "Dispensing Dice Pack...")
			new /obj/item/storage/pill_bottle/dice(T)
			use_matter(200, user)
		if(5)
			to_chat(user, "Dispensing Cigarette...")
			new /obj/item/clothing/mask/cigarette(T)
			use_matter(10, user)
		if(6)
			to_chat(user, "Dispensing Explosive Cigarette...")
			new /obj/item/clothing/mask/cigarette/plasma(T)
			use_matter(20, user)

/obj/item/rsf/proc/use_matter(charge, mob/user)
	if (iscyborg(user))
		var/mob/living/silicon/robot/R = user
		R.cell.charge -= charge
	else
		matter--
		to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")

/obj/item/cookiesynth
	name = "Cookie Synthesizer"
	desc = "A self-recharging device used to rapidly deploy cookies."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	emag_toggleable = TRUE
	var/matter = 10
	var/toxin = 0
	var/cooldown = 0
	var/cooldowndelay = 10
	var/safety = TRUE
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/cookiesynth/examine(mob/user)
	. = ..()
	. += span_notice("It currently holds [matter]/10 cookie-units.")

/obj/item/cookiesynth/attackby()
	return

/obj/item/cookiesynth/on_emag(mob/user)
	..()
	if(obj_flags & EMAGGED)
		to_chat(user, span_warning("You short out [src]'s reagent safety checker!"))
	else
		to_chat(user, span_warning("You reset [src]'s reagent safety checker!"))
		toxin = 0

/obj/item/cookiesynth/attack_self(mob/user)
	var/mob/living/silicon/robot/P = null
	if(iscyborg(user))
		P = user
	if((obj_flags & EMAGGED)&&!toxin)
		toxin = 1
		to_chat(user, "Cookie Synthesizer Hacked")
	else if(P.emagged&&!toxin)
		toxin = 1
		to_chat(user, "Cookie Synthesizer Hacked")
	else
		toxin = 0
		to_chat(user, "Cookie Synthesizer Reset")

/obj/item/cookiesynth/process(delta_time)
	if(matter < 10)
		matter++

/obj/item/cookiesynth/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(cooldown > world.time)
		return
	if(!proximity)
		return
	if (!(istype(A, /obj/structure/table) || isfloorturf(A)))
		return
	if(matter < 1)
		to_chat(user, span_warning("[src] doesn't have enough matter left. Wait for it to recharge!"))
		return
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell || R.cell.charge < 400)
			to_chat(user, span_warning("You do not have enough power to use [src]."))
			return
	var/turf/T = get_turf(A)
	playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
	to_chat(user, "Fabricating Cookie..")
	var/obj/item/food/cookie/S = new /obj/item/food/cookie(T)
	if(toxin)
		S.reagents.add_reagent(/datum/reagent/toxin/chloralhydrate, 10)
	if (iscyborg(user))
		var/mob/living/silicon/robot/R = user
		R.cell.charge -= 100
	else
		matter--
	cooldown = world.time + cooldowndelay
