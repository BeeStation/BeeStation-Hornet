/mob/living/carbon/death(gibbed)
	if(stat == DEAD)
		return

	losebreath = 0

	if(!gibbed)
		INVOKE_ASYNC(src, PROC_REF(emote), "deathgasp")

	. = ..()

	for(var/T in get_traumas())
		var/datum/brain_trauma/BT = T
		BT.on_death()

/mob/living/carbon/proc/inflate_gib() // Plays an animation that makes mobs appear to inflate before finally gibbing
	addtimer(CALLBACK(src, PROC_REF(gib), null, null, TRUE, TRUE), 25)
	var/matrix/M = matrix()
	M.Scale(1.8, 1.2)
	animate(src, time = 40, transform = M, easing = SINE_EASING)

/mob/living/carbon/gib(no_brain, no_organs, no_bodyparts, safe_gib = FALSE)
	if(safe_gib) // If you want to keep all the mob's items and not have them deleted
		for(var/obj/item/W in src)
			if(dropItemToGround(W))
				if(prob(50))
					step(W, pick(GLOB.alldirs))
	var/atom/Tsec = drop_location()
	for(var/mob/M in src)
		M.forceMove(Tsec)
		visible_message(span_danger("[M] bursts out of [src]!"))
	. = ..()

/mob/living/carbon/spill_organs(no_brain, no_organs, no_bodyparts)
	var/atom/Tsec = drop_location()
	if(!no_bodyparts)
		if(no_organs)//so the organs don't get transfered inside the bodyparts we'll drop.
			for(var/organ in organs)
				if(no_brain || !istype(organ, /obj/item/organ/brain))
					qdel(organ)
		else //we're going to drop all bodyparts except chest, so the only organs that needs spilling are those inside it.
			for(var/obj/item/organ/organ as anything in organs)
				if(no_brain && istype(organ, /obj/item/organ/brain))
					qdel(organ) //so the brain isn't transfered to the head when the head drops.
					continue
				var/org_zone = check_zone(organ.zone) //both groin and chest organs.
				if(org_zone == BODY_ZONE_CHEST)
					organ.Remove(src)
					organ.forceMove(Tsec)
					organ.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1,3),5)
	else
		for(var/obj/item/organ/organ as anything in organs)
			if(no_brain && istype(organ, /obj/item/organ/brain))
				qdel(organ)
				continue
			if(no_organs && !istype(organ, /obj/item/organ/brain))
				qdel(organ)
				continue
			organ.Remove(src)
			organ.forceMove(Tsec)
			organ.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1,3),5)


/mob/living/carbon/spread_bodyparts()
	for(var/obj/item/bodypart/BP as() in bodyparts)
		BP.drop_limb()
		BP.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1,3),5)
