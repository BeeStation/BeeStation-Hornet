/mob/living/carbon/examine(mob/user)
	var/t_He = p_they(TRUE)
	var/t_His = p_their(TRUE)
	var/t_his = p_their()
	var/t_him = p_them()
	var/t_has = p_have()
	var/t_is = p_are()

	/*
	 * Inherent Examine
	*/
	var/list/inherent_examine = list()

	// Head
	if(head)
		inherent_examine += "[t_He] [t_is] wearing [head.get_examine_string(user)] on [t_his] head."

	// Mask
	var/obscured = check_obscured_slots()
	if(wear_mask && !(obscured & ITEM_SLOT_MASK))
		inherent_examine += "[t_He] [t_is] wearing [wear_mask.get_examine_string(user)] on [t_his] face."

	// Neck
	if(wear_neck && !(obscured & ITEM_SLOT_NECK))
		inherent_examine += "[t_He] [t_is] wearing [wear_neck.get_examine_string(user)] around [t_his] neck."

	// Back
	if(back)
		inherent_examine += "[t_He] [t_has] [back.get_examine_string(user)] on [t_his] back."

	// Hands
	for(var/obj/item/item in held_items)
		if(!(item.item_flags & ABSTRACT))
			inherent_examine += "[t_He] [t_is] holding [item.get_examine_string(user)] in [t_his] [get_held_index_name(get_held_index_of_item(item))]."

	// Handcuffs
	if(handcuffed)
		if(istype(handcuffed, /obj/item/restraints/handcuffs/cable))
			inherent_examine += span_warning("[t_He] [t_is] restrained with cable!")
		else
			inherent_examine += span_warning("[t_He] [t_is] handcuffed with [handcuffed]!")

	// Legcuffs
	if(legcuffed)
		inherent_examine += span_warning("[t_He] [t_is] legcuffed with [legcuffed]!")

	/*
	 * Damage Examine
	*/
	var/list/damage_examine = list()

	// Embedded Objects
	for(var/obj/item/bodypart/body_part as() in bodyparts)
		for(var/obj/item/I in body_part.embedded_objects)
			if(I.isEmbedHarmless())
				damage_examine += "<B>[t_He] [t_has] [icon2html(I, user)] \a [I] stuck to [t_his] [body_part.name]!</B>"
			else
				damage_examine += "<B>[t_He] [t_has] [icon2html(I, user)] \a [I] embedded in [t_his] [body_part.name]!</B>"

	// Disabled Limbs
	for(var/obj/item/bodypart/body_part as() in bodyparts)
		if(!body_part.bodypart_disabled)
			continue

		var/damage_text
		if(!(body_part.get_damage(include_stamina = FALSE) >= body_part.max_damage)) //we don't care if it's stamcritted
			damage_text = "limp and lifeless"
		else
			damage_text = (body_part.brute_dam >= body_part.burn_dam) ? body_part.heavy_brute_msg : body_part.heavy_burn_msg
		damage_examine += "<B>[capitalize(t_his)] [body_part.name] is [damage_text]!</B>"

	// Missing Limbs
	var/list/missing_limbs = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	for(var/obj/item/bodypart/body_part as() in bodyparts)
		missing_limbs -= body_part.body_zone

	for(var/t in missing_limbs)
		if(t == BODY_ZONE_HEAD)
			damage_examine += span_deadsay("[capitalize(t_his)] [parse_zone(t)] is missing!</B>")
			continue
		damage_examine += "<B>[capitalize(t_his)] [parse_zone(t)] is missing!</B>"

	// Damage
	if(!(user == src && src.hal_screwyhud == SCREWYHUD_HEALTHY))
		var/current_damage = getBruteLoss()
		if(current_damage)
			switch (current_damage)
				if(1 to 25)
					damage_examine += "[t_He] [t_has] minor bruising."
				if(25 to 50)
					damage_examine += "[t_He] [t_has] <b>moderate</b> bruising!"
				if(50 to INFINITY)
					damage_examine += "<B>[t_He] [t_has] severe bruising!</B>"

		current_damage = getFireLoss()
		if(current_damage)
			switch (current_damage)
				if(1 to 25)
					damage_examine += "[t_He] [t_has] minor burns."
				if(25 to 50)
					damage_examine += "[t_He] [t_has] <b>moderate</b> burns!"
				if(50 to INFINITY)
					damage_examine += "<B>[t_He] [t_has] severe burns!</B>"

		current_damage = getCloneLoss()
		if(current_damage)
			switch (current_damage)
				if(1 to 25)
					damage_examine += "[t_He] [t_has] slightly deformed."
				if(25 to 50)
					damage_examine += "[t_He] [t_has] <b>moderately</b> deformed!"
				if(50 to INFINITY)
					damage_examine += "<B>[t_He] [t_has] severely deformed!</B>"

	// Stupid stupid STUPID
	if(HAS_TRAIT(src, TRAIT_DUMB))
		damage_examine += "[t_He] seem[p_s()] to be clumsy and unable to think."

	// Fire stacks
	if(fire_stacks > 0)
		damage_examine += "[t_He] [t_is] covered in something flammable."
	if(fire_stacks < 0)
		damage_examine += "[t_He] look[p_s()] a little soaked."

	// Pulled
	if(pulledby?.grab_state)
		damage_examine += "[t_He] [t_is] restrained by [pulledby]'s grip."

	/*
	 * Misc Examine
	*/
	var/list/misc_examine = list()

	// Death
	if(stat == DEAD)
		if(getorgan(/obj/item/organ/brain))
			misc_examine += span_deadsay("[t_He] [t_is] limp and unresponsive, with no signs of life.")
		else if(get_bodypart(BODY_ZONE_HEAD))
			misc_examine += span_deadsay("It appears that [t_his] brain is missing.")

	// Soft crit
	if(stat == SOFT_CRIT)
		misc_examine += "[capitalize(t_His)] breathing is shallow and labored."

	// Hard crit
	if(stat == UNCONSCIOUS || stat == HARD_CRIT)
		misc_examine += "[capitalize(t_He)] [t_is]n't responding to anything around [t_him] and seems to be asleep."

	// Traits
	var/trait_exam = common_trait_examine()
	if(!isnull(trait_exam))
		misc_examine += trait_exam

	// Mood
	var/datum/component/mood/mood = src.GetComponent(/datum/component/mood)
	if(mood)
		switch(mood.shown_mood)
			if(-INFINITY to MOOD_LEVEL_SAD4)
				misc_examine += "[t_He] look[p_s()] depressed."
			if(MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
				misc_examine += "[t_He] look[p_s()] very sad."
			if(MOOD_LEVEL_SAD3 to MOOD_LEVEL_SAD2)
				misc_examine += "[t_He] look[p_s()] a bit down."
			if(MOOD_LEVEL_HAPPY2 to MOOD_LEVEL_HAPPY3)
				misc_examine += "[t_He] look[p_s()] quite happy."
			if(MOOD_LEVEL_HAPPY3 to MOOD_LEVEL_HAPPY4)
				misc_examine += "[t_He] look[p_s()] very happy."
			if(MOOD_LEVEL_HAPPY4 to INFINITY)
				misc_examine += "[t_He] look[p_s()] ecstatic."

	. = list(span_info("This is [icon2html(src, user)] \a <EM>[src]</EM>!"))
	if(length(inherent_examine))
		. += span_notice(inherent_examine.Join("\n"))
	if(length(damage_examine))
		. += span_warning(damage_examine.Join("\n"))
	if(length(misc_examine))
		. += "\n" + span_notice(misc_examine.Join("\n"))
