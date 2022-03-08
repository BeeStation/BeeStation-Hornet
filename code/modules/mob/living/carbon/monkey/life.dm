/mob/living/carbon/monkey

/mob/living/carbon/monkey/handle_mutations_and_radiation()
	if(radiation)
		if(radiation > RAD_MOB_KNOCKDOWN && prob(RAD_MOB_KNOCKDOWN_PROB))
			if(!IsParalyzed())
				emote("collapse")
			Paralyze(RAD_MOB_KNOCKDOWN_AMOUNT)
			to_chat(src, "<span class='danger'>You feel weak.</span>")
		if(radiation > RAD_MOB_MUTATE)
			if(prob(2))
				to_chat(src, "<span class='danger'>You mutate!</span>")
				easy_randmut(NEGATIVE+MINOR_NEGATIVE)
				emote("gasp")
				domutcheck()

				if(radiation > RAD_MOB_MUTATE * 1.5)
					switch(rand(1, 3))
						if(1)
							gorillize()
						if(2)
							humanize(TR_KEEPITEMS | TR_KEEPVIRUS | TR_DEFAULTMSG | TR_KEEPDAMAGE | TR_KEEPORGANS)
						if(3)
							var/obj/item/bodypart/BP = pick(bodyparts)
							if(BP.body_part != HEAD && BP.body_part != CHEST)
								if(BP.dismemberable)
									BP.dismember()
							take_bodypart_damage(100, 0, 0)
					return
		if(radiation > RAD_MOB_VOMIT && prob(RAD_MOB_VOMIT_PROB))
			vomit(10, TRUE)
	return ..()

/mob/living/carbon/monkey/handle_breath_temperature(datum/gas_mixture/breath)
	if(abs(dna.species.bodytemp_normal - breath.return_temperature()) > 50)
		switch(breath.return_temperature())
			if(-INFINITY to 120)
				adjustFireLoss(3)
			if(120 to 200)
				adjustFireLoss(1.5)
			if(200 to 260)
				adjustFireLoss(0.5)
			if(360 to 400)
				adjustFireLoss(2)
			if(400 to 1000)
				adjustFireLoss(3)
			if(1000 to INFINITY)
				adjustFireLoss(8)


/mob/living/carbon/monkey/calculate_affecting_pressure(pressure)
	if (head && isclothing(head))
		var/obj/item/clothing/CH = head
		if (CH.clothing_flags & STOPSPRESSUREDAMAGE)
			return ONE_ATMOSPHERE
	return pressure

/mob/living/carbon/monkey/handle_random_events()
	if (prob(1) && prob(2))
		emote("scratch")

/mob/living/carbon/monkey/has_smoke_protection()
	if(wear_mask)
		if(wear_mask.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
			return 1

/mob/living/carbon/monkey/handle_fire()
	. = ..()
	if(.) //if the mob isn't on fire anymore
		return

	//the fire tries to damage the exposed clothes and items
	var/list/burning_items = list()
	//HEAD//
	var/obscured = check_obscured_slots(TRUE)
	if(wear_mask && !(obscured & ITEM_SLOT_MASK))
		burning_items += wear_mask
	if(wear_neck && !(obscured & ITEM_SLOT_NECK))
		burning_items += wear_neck
	if(head)
		burning_items += head

	if(back)
		burning_items += back

	for(var/obj/item/I as() in burning_items)
		I.fire_act((fire_stacks * 50)) //damage taken is reduced to 2% of this value by fire_act()

	if(!head?.max_heat_protection_temperature || head.max_heat_protection_temperature < FIRE_IMMUNITY_MAX_TEMP_PROTECT)
		adjust_bodytemperature(HUMAN_BODYTEMP_HEATING_MAX)
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "on_fire", /datum/mood_event/on_fire)
