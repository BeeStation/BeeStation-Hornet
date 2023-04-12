/mob/living/carbon/human/gib_animation()
	if(!dna)
		new /obj/effect/temp_visual/gib_animation(loc, "gibbed-h")
		return
	switch(dna.species.species_gibs)
		if(GIB_TYPE_HUMAN)
			new /obj/effect/temp_visual/gib_animation(loc, "gibbed-h")
		if(GIB_TYPE_ROBOTIC)
			new /obj/effect/temp_visual/gib_animation(loc, "gibbed-r")

/mob/living/carbon/human/dust(just_ash, drop_items, force)
	death(TRUE)

	if(drop_items)
		unequip_everything()

	if(buckled)
		buckled.unbuckle_mob(src, force = TRUE)

	dust_animation()
	QDEL_IN(src, 20)

/mob/living/carbon/human/dust_animation()
	// Animate them being dusted out of existence
	var/obj/effect/dusting_anim/dust_effect = new(loc, src)
	filters += filter(type = "displace", size = 256, render_source = "*snap[REF(src)]")
	animate(src, alpha = 0, time = 20, easing = (EASE_IN | SINE_EASING))

	new dna.species.remains_type(get_turf(src))
	QDEL_IN(dust_effect, 20)
	return TRUE

/mob/living/carbon/human/spawn_gibs(with_bodyparts)
	if(!dna)
		new /obj/effect/gibspawner/human(get_turf(src), src, get_static_viruses())
		return
	if(with_bodyparts)
		switch(dna.species.species_gibs)
			if(GIB_TYPE_HUMAN)
				new /obj/effect/gibspawner/human(get_turf(src), src, get_static_viruses())
			if(GIB_TYPE_ROBOTIC)
				new /obj/effect/gibspawner/robot(get_turf(src))
	else
		switch(dna.species.species_gibs)
			if(GIB_TYPE_HUMAN)
				new /obj/effect/gibspawner/human(get_turf(src), src, get_static_viruses())
			if(GIB_TYPE_ROBOTIC)
				new /obj/effect/gibspawner/robot(get_turf(src))

/mob/living/carbon/human/death(gibbed)
	if(stat == DEAD)
		return
	stop_sound_channel(CHANNEL_HEARTBEAT)
	var/obj/item/organ/heart/H = getorganslot(ORGAN_SLOT_HEART)
	if(H)
		H.beat = BEAT_NONE

	. = ..()

	dizziness = 0
	jitteriness = 0

	if(ismecha(loc))
		var/obj/mecha/M = loc
		if(M.occupant == src)
			M.go_out()

	if(!QDELETED(dna)) //The gibbed param is bit redundant here since dna won't exist at this point if they got deleted.
		dna.species.spec_death(gibbed, src)

	if(SSticker.HasRoundStarted())
		SSblackbox.ReportDeath(src)
		log_game("[key_name(src)] has died (BRUTE: [src.getBruteLoss()], BURN: [src.getFireLoss()], TOX: [src.getToxLoss()], OXY: [src.getOxyLoss()], CLONE: [src.getCloneLoss()]) ([AREACOORD(src)])")
	if(is_devil(src))
		INVOKE_ASYNC(is_devil(src), TYPE_PROC_REF(/datum/antagonist/devil, beginResurrectionCheck), src)
	if(is_hivemember(src))
		remove_hivemember(src)
	if(IS_HIVEHOST(src))
		var/datum/antagonist/hivemind/hive = mind.has_antag_datum(/datum/antagonist/hivemind)
		hive.destroy_hive()
	if(HAS_TRAIT(src, TRAIT_DROPS_ITEMS_ON_DEATH)) //if you want to add anything else, do it before this if statement
		var/list/turfs_to_throw = view(2, src)
		for(var/obj/item/I in contents)
			dropItemToGround(I, TRUE)
			if(QDELING(I))
				continue //skip it
			I.throw_at(pick(turfs_to_throw), 3, 1, spin = FALSE)
			I.pixel_x = rand(-10, 10)
			I.pixel_y = rand(-10, 10)
		//Death
		dust(TRUE)
		return

/mob/living/carbon/human/proc/makeSkeleton()
	ADD_TRAIT(src, TRAIT_DISFIGURED, TRAIT_GENERIC)
	set_species(/datum/species/skeleton)
	return TRUE


/mob/living/carbon/proc/Drain()
	become_husk(CHANGELING_DRAIN)
	ADD_TRAIT(src, TRAIT_BADDNA, CHANGELING_DRAIN)
	blood_volume = 0
	return TRUE

/mob/living/carbon/proc/makeUncloneable()
	ADD_TRAIT(src, TRAIT_BADDNA, MADE_UNCLONEABLE)
	blood_volume = 0
	return TRUE
