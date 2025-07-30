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
			for(var/X in internal_organs)
				if(no_brain || !istype(X, /obj/item/organ/brain))
					qdel(X)
		else //we're going to drop all bodyparts except chest, so the only organs that needs spilling are those inside it.
			var/obj/item/bodypart/chest = get_bodypart(BODY_ZONE_CHEST)
			for(var/X in chest.organ_slots)
				var/obj/item/organ/O = get_organ_slot(X)
				if (!O)
					continue
				if(no_brain && istype(O, /obj/item/organ/brain))
					qdel(O) //so the brain isn't transfered to the head when the head drops.
					continue
				O.Remove(src)
				O.forceMove(Tsec)
				O.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1,3),5)
			if (no_brain)
				var/obj/item/brain = get_organ_slot(ORGAN_SLOT_BRAIN)
				if (brain)
					qdel(brain)
	else
		for(var/X in internal_organs)
			var/obj/item/organ/I = X
			if(no_brain && istype(I, /obj/item/organ/brain))
				qdel(I)
				continue
			if(no_organs && !istype(I, /obj/item/organ/brain))
				qdel(I)
				continue
			I.Remove(src)
			I.forceMove(Tsec)
			I.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1,3),5)


/mob/living/carbon/spread_bodyparts()
	for(var/obj/item/bodypart/BP as() in bodyparts)
		BP.drop_limb()
		BP.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1,3),5)
