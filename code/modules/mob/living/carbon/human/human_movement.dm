/mob/living/carbon/human/get_movespeed_modifiers()
	var/list/considering = ..()
	if(HAS_TRAIT(src, TRAIT_IGNORESLOWDOWN))
		. = list()
		for(var/id in considering)
			var/datum/movespeed_modifier/M = considering[id]
			if(M.flags & IGNORE_NOSLOW || M.multiplicative_slowdown < 0)
				.[id] = M
		return
	return considering

/mob/living/carbon/human/slip(knockdown_amount, obj/O, lube, paralyze, forcedrop)
	if(HAS_TRAIT(src, TRAIT_NOSLIPALL))
		return FALSE
	if(shoes && isclothing(shoes))
		var/obj/item/clothing/CS = shoes
		if ((CS.clothing_flags & NOSLIP_ALL_WALKING) && src.m_intent == MOVE_INTENT_WALK)
			return FALSE
	if (lube & GALOSHES_DONT_HELP)
		return ..()
	if(HAS_TRAIT(src, TRAIT_NOSLIPWATER))
		return FALSE
	if(shoes && isclothing(shoes))
		var/obj/item/clothing/CS = shoes
		if (CS.clothing_flags & NOSLIP)
			return FALSE
		if ((CS.clothing_flags & NOSLIP_WALKING) && src.m_intent == MOVE_INTENT_WALK)
			return FALSE
	return ..()


/mob/living/carbon/human/experience_pressure_difference(pressure_difference)
	if(pressure_difference > 100)
		playsound_local(null, 'sound/effects/space_wind_big.ogg', clamp(pressure_difference / 50, 10, 100), 1)
	else
		playsound_local(null, 'sound/effects/space_wind.ogg', clamp(pressure_difference, 10, 100), 1)
	if(shoes && isclothing(shoes))
		var/obj/item/clothing/S = shoes
		if((S.clothing_flags & NOSLIP))
			return 0
		if((S.clothing_flags & NOSLIP_WALKING) && src.m_intent == MOVE_INTENT_WALK)
			return 0
		if((S.clothing_flags & NOSLIP_ALL_WALKING) && src.m_intent == MOVE_INTENT_WALK)
			return 0
	return ..()

/mob/living/carbon/human/has_gravity(turf/T)
	return ..() || mob_negates_gravity()

/mob/living/carbon/human/mob_negates_gravity()
	return ((shoes && shoes.negates_gravity()) || (dna?.species?.negates_gravity(src)))

/mob/living/carbon/human/Move(NewLoc, direct)
	. = ..()
	if(shoes && body_position == STANDING_UP && loc == NewLoc && has_gravity(loc))
		SEND_SIGNAL(shoes, COMSIG_SHOES_STEP_ACTION)

/mob/living/carbon/human/Process_Spacemove(movement_dir = 0) //Temporary laziness thing. Will change to handles by species reee.
	if(dna.species.space_move(src))
		return TRUE
	return ..()
