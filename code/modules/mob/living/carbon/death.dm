/mob/living/carbon/death(gibbed)
	if(stat == DEAD)
		return

	silent = FALSE
	losebreath = 0

	if(!gibbed)
		INVOKE_ASYNC(src, PROC_REF(emote), "deathgasp")

	. = ..()

	for(var/T in get_traumas())
		var/datum/brain_trauma/BT = T
		BT.on_death()

	if(SSticker.mode)
		SSticker.mode.check_win() //Calls the rounds wincheck, mainly for wizard, malf, and changeling now

/mob/living/carbon/gib(no_brain, no_organs, no_bodyparts)
	var/atom/Tsec = drop_location()
	for(var/mob/M in src)
		M.forceMove(Tsec)
		visible_message(span_danger("[M] bursts out of [src]!"))
	..()

/mob/living/carbon/spill_organs(no_brain, no_organs, no_bodyparts)
	var/atom/Tsec = drop_location()
	if(!no_bodyparts)
		if(no_organs)//so the organs don't get transfered inside the bodyparts we'll drop.
			for(var/X in organs)
				if(no_brain || !istype(X, /obj/item/organ/internal/brain))
					qdel(X)
		else //we're going to drop all bodyparts except chest, so the only organs that needs spilling are those inside it.
			for(var/obj/item/organ/organs as anything in organs)
				if(no_brain && istype(organs, /obj/item/organ/internal/brain))
					qdel(organs) //so the brain isn't transfered to the head when the head drops.
					continue
				var/org_zone = check_zone(organs.zone) //both groin and chest organs.
				if(org_zone == BODY_ZONE_CHEST)
					organs.Remove(src)
					organs.forceMove(Tsec)
					organs.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1,3),5)
	else
		for(var/obj/item/organ/organs as anything in organs)
			if(no_brain && istype(organs, /obj/item/organ/internal/brain))
				qdel(organs)
				continue
			if(no_organs && !istype(organs, /obj/item/organ/internal/brain))
				qdel(organs)
				continue
			organs.Remove(src)
			organs.forceMove(Tsec)
			organs.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1,3),5)


/mob/living/carbon/spread_bodyparts()
	for(var/obj/item/bodypart/BP as() in bodyparts)
		BP.drop_limb()
		BP.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1,3),5)
