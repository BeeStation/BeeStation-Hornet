/mob/living/carbon/human/gib_animation()
	if(!dna)
		new /obj/effect/temp_visual/gib_animation(loc, "gibbed-h")
		return
	switch(dna.species.species_gibs)
		if(GIB_TYPE_HUMAN)
			new /obj/effect/temp_visual/gib_animation(loc, "gibbed-h")
		if(GIB_TYPE_ROBOTIC)
			new /obj/effect/temp_visual/gib_animation(loc, "gibbed-r")

/mob/living/carbon/human/dust_animation()
	if(!dna)
		new /obj/effect/temp_visual/dust_animation(loc, "dust-h")
		return
	switch(dna.species.species_gibs)
		if(GIB_TYPE_HUMAN)
			new /obj/effect/temp_visual/dust_animation(loc, "dust-h")
		if(GIB_TYPE_ROBOTIC)
			new /obj/effect/temp_visual/dust_animation(loc, "dust-r")

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

/mob/living/carbon/human/spawn_dust(just_ash = FALSE)
	if(!dna)
		new /obj/effect/decal/remains/human(loc)
		return
	if(just_ash)
		new /obj/effect/decal/cleanable/ash(loc)
	else
		switch(dna.species.species_gibs)
			if(GIB_TYPE_HUMAN)
				new /obj/effect/decal/remains/human(loc)
			if(GIB_TYPE_ROBOTIC)
				new /obj/effect/decal/remains/robot(loc)

/mob/living/carbon/human/death(gibbed)
	if(stat == DEAD)
		return
	stop_sound_channel(CHANNEL_HEARTBEAT)
	var/obj/item/organ/heart/H = get_organ_slot(ORGAN_SLOT_HEART)
	if(H)
		H.beat = BEAT_NONE

	. = ..()

	if(!QDELETED(dna)) //The gibbed param is bit redundant here since dna won't exist at this point if they got deleted.
		dna.species.spec_death(gibbed, src)

	if(SSticker.HasRoundStarted())
		SSblackbox.ReportDeath(src)
		log_game("[key_name(src)] has died (BRUTE: [src.getBruteLoss()], BURN: [src.getFireLoss()], TOX: [src.getToxLoss()], OXY: [src.getOxyLoss()], CLONE: [src.getCloneLoss()]) ([AREACOORD(src)])")
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
	if(key) // Prevents log spamming of keyless mob deaths (like xenobio monkeys)
		investigate_log("has died at [loc_name(src)].<br>\
			BRUTE: [src.getBruteLoss()] BURN: [src.getFireLoss()] TOX: [src.getToxLoss()] OXY: [src.getOxyLoss()] CLONE: [src.getCloneLoss()] STAM: [src.getStaminaLoss()]<br>\
			<b>Brain damage</b>: [src.getOrganLoss(ORGAN_SLOT_BRAIN) || "0"]<br>\
			<b>Blood volume</b>: [src.blood_volume]cl ([round((src.blood_volume / BLOOD_VOLUME_NORMAL) * 100, 0.1)]%)<br>\
			<b>Reagents</b>:<br>[reagents_readout()]", INVESTIGATE_DEATHS)
	var/death_message = CONFIG_GET(string/death_message)
	if (death_message)
		to_chat(src, death_message)

/mob/living/carbon/human/gib(no_brain, no_organs, no_bodyparts)
	dna.species.spec_gib(no_brain, no_organs, no_bodyparts, src)
	return

/mob/living/carbon/human/proc/reagents_readout()
	var/readout = "Blood:"
	for(var/datum/reagent/reagent in reagents?.reagent_list)
		readout += "<br>[round(reagent.volume, 0.001)] units of [reagent.name]"
	/*
	readout += "<br>Stomach:"
	var/obj/item/organ/stomach/belly = get_organ_slot(ORGAN_SLOT_STOMACH)
	for(var/datum/reagent/bile in belly?.reagents?.reagent_list)
		if(!belly.food_reagents[bile.type])
			readout += "<br>[round(bile.volume, 0.001)] units of [bile.name]"
	*/

	return readout

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
