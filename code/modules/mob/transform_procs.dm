#define TRANSFORMATION_DURATION 22

/mob/living/carbon/proc/monkeyize(tr_flags = (TR_KEEPITEMS | TR_KEEPVIRUS | TR_DEFAULTMSG | TR_KEEPAI), skip_animation = FALSE, keep_original_species = FALSE)
	if (notransform || transformation_timer)
		return

	var/list/missing_bodyparts_zones = get_missing_limbs()
	var/list/original_organs = list()
	var/obj/item/cavity_object

	var/obj/item/bodypart/chest/CH = get_bodypart(BODY_ZONE_CHEST)
	if(CH.cavity_item)
		cavity_object = CH.cavity_item
		CH.cavity_item = null

	if(tr_flags & TR_KEEPITEMS)
		unequip_everything()

	//Make mob invisible and spawn animation
	notransform = TRUE
	Paralyze(TRANSFORMATION_DURATION, ignore_canstun = TRUE)
	icon = null
	cut_overlays()
	invisibility = INVISIBILITY_MAXIMUM

	if(!skip_animation)
		new /obj/effect/temp_visual/monkeyify(loc)

		transformation_timer = TRUE
		sleep(TRANSFORMATION_DURATION)
		transformation_timer = FALSE

	var/mob/living/carbon/monkey/new_monkey = new /mob/living/carbon/monkey( loc )

	// Make it be able to be turned back into a human with mutadone
	new_monkey.natural = FALSE
	new_monkey.check_if_natural()
	// hash the original name?
	if(tr_flags & TR_HASHNAME)
		new_monkey.name = "monkey ([copytext_char(rustg_hash_string(RUSTG_HASH_MD5, real_name), 2, 6)])"
		new_monkey.real_name = "monkey ([copytext_char(rustg_hash_string(RUSTG_HASH_MD5, real_name), 2, 6)])"

	//handle DNA and other attributes
	dna.transfer_identity(new_monkey, tr_flags & TR_KEEPSE)
	new_monkey.set_species(/datum/species/monkey)
	new_monkey.dna.set_se(TRUE, GET_INITIALIZED_MUTATION(RACEMUT))
	new_monkey.updateappearance(icon_update=0)

	//store original species
	if(keep_original_species)
		for(var/datum/mutation/race/M in new_monkey.dna.mutations)
			if(!isnull(dna.species))
				M.original_species = dna.species.type
			break //Can't be more than one monkified in a DNA set so, no need to continue the loop

	if(suiciding)
		new_monkey.set_suicide(suiciding)
	new_monkey.a_intent = INTENT_HARM

	//keep viruses?
	if (tr_flags & TR_KEEPVIRUS)
		new_monkey.diseases = diseases
		diseases = list()
		for(var/thing in new_monkey.diseases)
			var/datum/disease/D = thing
			D.affected_mob = new_monkey

	//keep damage?
	if (tr_flags & TR_KEEPDAMAGE)
		new_monkey.setToxLoss(getToxLoss(), 0)
		new_monkey.adjustBruteLoss(getBruteLoss(), 0)
		new_monkey.setOxyLoss(getOxyLoss(), 0)
		new_monkey.setCloneLoss(getCloneLoss(), 0)
		new_monkey.adjustFireLoss(getFireLoss(), 0)
		new_monkey.setOrganLoss(ORGAN_SLOT_BRAIN, getOrganLoss(ORGAN_SLOT_BRAIN))
		new_monkey.updatehealth()
		new_monkey.radiation = radiation

	//move implants to new mob
	if(tr_flags & TR_KEEPIMPLANTS)
		for(var/obj/item/implant/IMP as anything in implants)
			IMP.transfer_implant(src, new_monkey)

	//re-add organs to new mob. this order prevents moving the mind to a brain at any point
	if(tr_flags & TR_KEEPORGANS)
		for(var/X in new_monkey.getOrgansList())
			var/obj/item/organ/I = X
			I.Remove(new_monkey, 1)

		if(mind)
			mind.transfer_to(new_monkey)
			var/datum/antagonist/changeling/changeling = new_monkey.mind.has_antag_datum(/datum/antagonist/changeling)
			if(changeling)
				var/datum/action/changeling/humanform/hf = new
				changeling.purchasedpowers += hf
				changeling.regain_powers()

		for(var/X in getOrgansList())
			var/obj/item/organ/I = X
			original_organs += I
			I.Remove(src, 1)

		for(var/X in original_organs)
			var/obj/item/organ/I = X
			I.Insert(new_monkey, 1)

	var/obj/item/bodypart/chest/torso = new_monkey.get_bodypart(BODY_ZONE_CHEST)
	if(cavity_object)
		torso.cavity_item = cavity_object //cavity item is given to the new chest
		cavity_object.forceMove(new_monkey)

	for(var/missing_zone in missing_bodyparts_zones)
		var/obj/item/bodypart/BP = new_monkey.get_bodypart(missing_zone)
		BP.drop_limb(1)
		if(!(tr_flags & TR_KEEPORGANS)) //we didn't already get rid of the organs of the newly spawned mob
			for(var/X in new_monkey.getOrgansList())
				var/obj/item/organ/G = X
				if(BP.body_zone == check_zone(G.zone))
					if(mind && mind.has_antag_datum(/datum/antagonist/changeling) && istype(G, /obj/item/organ/brain))
						continue //so headless changelings don't lose their brain when transforming
					qdel(G) //we lose the organs in the missing limbs
		qdel(BP)

	//transfer mind if we didn't yet
	if(mind)
		mind.transfer_to(new_monkey)
		var/datum/antagonist/changeling/changeling = new_monkey.mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling)
			var/datum/action/changeling/humanform/hf = new
			changeling.purchasedpowers += hf
			changeling.regain_powers()


	//if we have an AI, transfer it; if we don't, make sure the new thing doesn't either
	if(tr_flags & TR_KEEPAI)
		if(ai_controller)
			ai_controller.PossessPawn(new_monkey)
		else if(new_monkey.ai_controller)
			QDEL_NULL(new_monkey.ai_controller)

	if (tr_flags & TR_DEFAULTMSG)
		to_chat(new_monkey, "<B>You are now a monkey.</B>")
	SEND_SIGNAL(src, COMSIG_CARBON_TRANSFORMED, new_monkey)

	for(var/A in loc.vars)
		if(loc.vars[A] == src)
			loc.vars[A] = new_monkey

	new_monkey.update_sight()
	transfer_observers_to(new_monkey)

	. = new_monkey

	qdel(src)

//Mostly same as monkey but turns target into teratoma

/mob/living/carbon/proc/teratomize(tr_flags = (TR_KEEPITEMS | TR_KEEPVIRUS | TR_DEFAULTMSG))
	if (notransform || transformation_timer)
		return
	//Handle items on mob

	//first organs
	var/list/original_organs = list()
	var/list/missing_bodyparts_zones = get_missing_limbs()

	var/obj/item/cavity_object

	var/obj/item/bodypart/chest/CH = get_bodypart(BODY_ZONE_CHEST)
	if(CH.cavity_item)
		cavity_object = CH.cavity_item
		CH.cavity_item = null

	if(tr_flags & TR_KEEPITEMS)
		unequip_everything()

	//Make mob invisible and spawn animation
	notransform = TRUE
	Paralyze(TRANSFORMATION_DURATION, ignore_canstun = TRUE)
	icon = null
	cut_overlays()
	invisibility = INVISIBILITY_MAXIMUM

	new /obj/effect/temp_visual/monkeyify(loc)

	transformation_timer = TRUE
	sleep(TRANSFORMATION_DURATION)
	transformation_timer = FALSE

	var/mob/living/carbon/monkey/tumor/new_toma = new /mob/living/carbon/monkey/tumor( loc )

	// hash the original name?
	if(tr_flags & TR_HASHNAME)
		new_toma.name = "living teratoma ([copytext_char(rustg_hash_string(RUSTG_HASH_MD5, real_name), 2, 6)])"
		new_toma.real_name = "living teratoma ([copytext_char(rustg_hash_string(RUSTG_HASH_MD5, real_name), 2, 6)])"

	//handle DNA and other attributes
	dna.transfer_identity(new_toma)
	new_toma.dna.species.species_traits += NOTRANSSTING
	new_toma.updateappearance(icon_update=0)

	if(tr_flags & TR_KEEPSE)
		new_toma.dna.mutation_index = dna.mutation_index
		new_toma.dna.set_se(1, GET_INITIALIZED_MUTATION(RACEMUT))

	if(suiciding)
		new_toma.set_suicide(suiciding)
	new_toma.a_intent = INTENT_HARM

	//keep viruses?
	if (tr_flags & TR_KEEPVIRUS)
		new_toma.diseases = diseases
		diseases = list()
		for(var/thing in new_toma.diseases)
			var/datum/disease/D = thing
			D.affected_mob = new_toma

	//keep damage?
	if (tr_flags & TR_KEEPDAMAGE)
		new_toma.setToxLoss(getToxLoss(), 0)
		new_toma.adjustBruteLoss(getBruteLoss(), 0)
		new_toma.setOxyLoss(getOxyLoss(), 0)
		new_toma.setCloneLoss(getCloneLoss(), 0)
		new_toma.adjustFireLoss(getFireLoss(), 0)
		new_toma.setOrganLoss(ORGAN_SLOT_BRAIN, getOrganLoss(ORGAN_SLOT_BRAIN))
		new_toma.updatehealth()
		new_toma.radiation = radiation

	//move implants to new mob
	if(tr_flags & TR_KEEPIMPLANTS)
		for(var/obj/item/implant/IMP as anything in implants)
			IMP.transfer_implant(src, new_toma)

	//re-add organs to new mob. this order prevents moving the mind to a brain at any point
	if(tr_flags & TR_KEEPORGANS)
		for(var/X in new_toma.getOrgansList())
			var/obj/item/organ/I = X
			I.Remove(new_toma, 1)

		if(mind)
			mind.transfer_to(new_toma)
			var/datum/antagonist/changeling/changeling = new_toma.mind.has_antag_datum(/datum/antagonist/changeling)
			if(changeling)
				var/datum/action/changeling/humanform/hf = new
				changeling.purchasedpowers += hf
				changeling.regain_powers()

		for(var/X in getOrgansList())
			var/obj/item/organ/I = X
			original_organs += I
			I.Remove(src, 1)

		for(var/X in original_organs)
			var/obj/item/organ/I = X
			I.Insert(new_toma, 1)

	var/obj/item/bodypart/chest/torso = new_toma.get_bodypart(BODY_ZONE_CHEST)
	if(cavity_object)
		torso.cavity_item = cavity_object //cavity item is given to the new chest
		cavity_object.forceMove(new_toma)

	for(var/missing_zone in missing_bodyparts_zones)
		var/obj/item/bodypart/BP = new_toma.get_bodypart(missing_zone)
		BP.drop_limb(1)
		if(!(tr_flags & TR_KEEPORGANS)) //we didn't already get rid of the organs of the newly spawned mob
			for(var/X in new_toma.getOrgansList())
				var/obj/item/organ/G = X
				if(BP.body_zone == check_zone(G.zone))
					if(mind && mind.has_antag_datum(/datum/antagonist/changeling) && istype(G, /obj/item/organ/brain))
						continue //so headless changelings don't lose their brain when transforming
					qdel(G) //we lose the organs in the missing limbs
		qdel(BP)

	//transfer mind if we didn't yet
	if(mind)
		mind.transfer_to(new_toma)
		var/datum/antagonist/changeling/changeling = new_toma.mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling)
			var/datum/action/changeling/humanform/hf = new
			changeling.purchasedpowers += hf
			changeling.regain_powers()


	if (tr_flags & TR_DEFAULTMSG)
		to_chat(new_toma, "<B>You are now a living teratoma.</B>")

	SEND_SIGNAL(src, COMSIG_CARBON_TRANSFORMED, new_toma)

	for(var/A in loc.vars)
		if(loc.vars[A] == src)
			loc.vars[A] = new_toma

	transfer_observers_to(new_toma)

	. = new_toma

	qdel(src)

//////////////////////////           Humanize               //////////////////////////////
//Could probably be merged with monkeyize but other transformations got their own procs, too

/mob/living/carbon/proc/humanize(tr_flags = (TR_KEEPITEMS | TR_KEEPVIRUS | TR_DEFAULTMSG | TR_KEEPAI), keep_original_species = FALSE, var/datum/species/original_species)
	if (notransform || transformation_timer)
		return

	var/list/original_organs = list()

	var/list/missing_bodyparts_zones = get_missing_limbs()

	var/obj/item/cavity_object

	var/obj/item/bodypart/chest/CH = get_bodypart(BODY_ZONE_CHEST)
	if(CH.cavity_item)
		cavity_object = CH.cavity_item
		CH.cavity_item = null

	//now the rest
	if (tr_flags & TR_KEEPITEMS)
		unequip_everything()

	//Make mob invisible and spawn animation
	notransform = TRUE
	Paralyze(TRANSFORMATION_DURATION, ignore_canstun = TRUE)

	icon = null
	cut_overlays()
	invisibility = INVISIBILITY_MAXIMUM
	new /obj/effect/temp_visual/monkeyify/humanify(loc)

	transformation_timer = TRUE
	sleep(TRANSFORMATION_DURATION)
	transformation_timer = FALSE

	var/mob/living/carbon/human/new_human = new( loc )
	for(var/obj/item/C in new_human.loc)
		if(C.anchored)
			continue
		new_human.equip_to_appropriate_slot(C)

	dna.transfer_identity(new_human, tr_flags & TR_KEEPSE)
	new_human.dna.set_se(FALSE, GET_INITIALIZED_MUTATION(RACEMUT))
	//Reset offsets to match human settings, in-case they have been changed
	new_human.dna.species.offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,0), OFFSET_EARS = list(0,0), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,0), OFFSET_FACE = list(0,0), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0), OFFSET_RIGHT_HAND = list(0,0), OFFSET_LEFT_HAND = list(0,0))
	new_human.updateappearance(mutcolor_update=1)

	if(findtext(new_human.dna.real_name, "monkey", 1, 7)) //7 == length("monkey") + 1
		new_human.real_name = random_unique_name(new_human.gender)
		new_human.dna.generate_unique_enzymes(new_human)
	else
		new_human.real_name = new_human.dna.real_name
	new_human.name = new_human.real_name

	if(suiciding)
		new_human.set_suicide(suiciding)

	//keep viruses?
	if (tr_flags & TR_KEEPVIRUS)
		new_human.diseases = diseases
		diseases = list()
		for(var/thing in new_human.diseases)
			var/datum/disease/D = thing
			D.affected_mob = new_human
		new_human.med_hud_set_status()

	//keep damage?
	if (tr_flags & TR_KEEPDAMAGE)
		new_human.setToxLoss(getToxLoss(), 0)
		new_human.adjustBruteLoss(getBruteLoss(), 0)
		new_human.setOxyLoss(getOxyLoss(), 0)
		new_human.setCloneLoss(getCloneLoss(), 0)
		new_human.adjustFireLoss(getFireLoss(), 0)
		new_human.adjustOrganLoss(ORGAN_SLOT_BRAIN, getOrganLoss(ORGAN_SLOT_BRAIN))
		new_human.updatehealth()
		new_human.radiation = radiation

	//move implants to new mob
	if(tr_flags & TR_KEEPIMPLANTS)
		for(var/obj/item/implant/IMP as anything in implants)
			IMP.transfer_implant(src, new_human)

	if(tr_flags & TR_KEEPORGANS)
		for(var/X in new_human.getOrgansList())
			var/obj/item/organ/I = X
			I.Remove(new_human, 1)

		if(mind)
			mind.transfer_to(new_human)
			var/datum/antagonist/changeling/changeling = new_human.mind.has_antag_datum(/datum/antagonist/changeling)
			if(changeling)
				for(var/datum/action/changeling/humanform/HF in changeling.purchasedpowers)
					changeling.purchasedpowers -= HF
					changeling.regain_powers()

		for(var/X in getOrgansList())
			var/obj/item/organ/I = X
			original_organs += I
			I.Remove(src, 1)

		for(var/X in original_organs)
			var/obj/item/organ/I = X
			I.Insert(new_human, 1)


	var/obj/item/bodypart/chest/torso = get_bodypart(BODY_ZONE_CHEST)
	if(cavity_object)
		torso.cavity_item = cavity_object //cavity item is given to the new chest
		cavity_object.forceMove(new_human)

	for(var/missing_zone in missing_bodyparts_zones)
		var/obj/item/bodypart/BP = new_human.get_bodypart(missing_zone)
		BP.drop_limb(1)
		if(!(tr_flags & TR_KEEPORGANS)) //we didn't already get rid of the organs of the newly spawned mob
			for(var/X in new_human.getOrgansList())
				var/obj/item/organ/G = X
				if(BP.body_zone == check_zone(G.zone))
					if(mind && mind.has_antag_datum(/datum/antagonist/changeling) && istype(G, /obj/item/organ/brain))
						continue //so headless changelings don't lose their brain when transforming
					qdel(G) //we lose the organs in the missing limbs
		qdel(BP)

	if(mind)
		mind.transfer_to(new_human)
		var/datum/antagonist/changeling/changeling = new_human.mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling)
			for(var/datum/action/changeling/humanform/HF in changeling.purchasedpowers)
				changeling.purchasedpowers -= HF
				changeling.regain_powers()

	//if we have an AI, transfer it; if we don't, make sure the new thing doesn't either
	if(tr_flags & TR_KEEPAI)
		if(ai_controller)
			ai_controller.PossessPawn(new_human)
		else if(new_human.ai_controller)
			QDEL_NULL(new_human.ai_controller)

	if(keep_original_species && isnull(original_species))
		original_species = /datum/species/human

	if(new_human.dna.species && !istype(new_human.dna.species, /datum/species/monkey))
		if(isnull(new_human.dna.species))
			new_human.set_species(/datum/species/human)
		else
			new_human.set_species(new_human.dna.species)
	else
		if(keep_original_species)
			if(isnull(original_species) || !ispath(original_species, /datum/species))
				new_human.set_species(/datum/species/human)
			else
				new_human.set_species(original_species)
		else
			new_human.set_species(/datum/species/human)

	new_human.a_intent = INTENT_HELP
	if (tr_flags & TR_DEFAULTMSG)
		to_chat(new_human, "<B>You are now \a [new_human.dna.species]].</B>")

	SEND_SIGNAL(src, COMSIG_CARBON_TRANSFORMED, new_human)

	transfer_observers_to(new_human)

	. = new_human

	for(var/A in loc.vars)
		if(loc.vars[A] == src)
			loc.vars[A] = new_human

	qdel(src)

//A common proc to start an -ize transformation
/mob/living/carbon/proc/pre_transform(delete_items = FALSE)
	if(notransform)
		return TRUE
	notransform = TRUE
	Paralyze(1, ignore_canstun = TRUE)

	if(delete_items)
		for(var/obj/item/W in get_equipped_items(TRUE) | held_items)
			qdel(W)
	else
		unequip_everything()
	regenerate_icons()
	icon = null
	invisibility = INVISIBILITY_MAXIMUM

/mob/living/carbon/AIize(transfer_after = TRUE, client/preference_source)
	return pre_transform() ? null : ..()

/mob/proc/AIize(transfer_after = TRUE, client/preference_source)
	var/list/turf/landmark_loc = list()
	for(var/obj/effect/landmark/start/ai/sloc in GLOB.landmarks_list)
		if(locate(/mob/living/silicon/ai) in sloc.loc)
			continue
		if(sloc.primary_ai)
			LAZYCLEARLIST(landmark_loc)
			landmark_loc += sloc.loc
			break
		landmark_loc += sloc.loc
	if(!landmark_loc.len)
		to_chat(src, "Oh god sorry we can't find an unoccupied AI spawn location, so we're spawning you on top of someone.")
		for(var/obj/effect/landmark/start/ai/sloc in GLOB.landmarks_list)
			landmark_loc += sloc.loc

	if(!landmark_loc.len)
		message_admins("Could not find ai landmark for [src]. Yell at a mapper! We are spawning them at their current location.")
		landmark_loc += loc

	if(client)
		stop_sound_channel(CHANNEL_LOBBYMUSIC)

	if(!transfer_after)
		mind.active = FALSE

	. = new /mob/living/silicon/ai(pick(landmark_loc), null, src)

	if(preference_source)
		apply_pref_name(/datum/preference/name/ai, preference_source)

	qdel(src)

/mob/living/carbon/human/proc/Robotize(delete_items = 0, transfer_after = TRUE)
	if(pre_transform(delete_items))
		return

	var/mob/living/silicon/robot/R = new /mob/living/silicon/robot(loc)

	R.job = JOB_NAME_CYBORG
	R.gender = gender
	R.invisibility = 0

	if(client)
		R.updatename(client)

	if(mind)//TODO //huh?
		if(!transfer_after)
			mind.active = FALSE
		mind.transfer_to(R)
	else if(transfer_after)
		R.key = key

	if(R.mmi)
		R.mmi.transfer_identity(src)

	R.notify_ai(NEW_BORG)

	. = R
	if(R.ckey && is_banned_from(R.ckey, JOB_NAME_CYBORG))
		INVOKE_ASYNC(R, TYPE_PROC_REF(/mob/living/silicon/robot, replace_banned_cyborg))
	qdel(src)

/mob/living/silicon/robot/proc/replace_banned_cyborg()
	to_chat(src, "<span class='userdanger'>You are job banned from cyborg! Appeal your job ban if you want to avoid this in the future!</span>")
	ghostize(FALSE)

	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as [src]?", JOB_NAME_CYBORG, null, 7.5 SECONDS, src, ignore_category = FALSE)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/chosen_candidate = pick(candidates)
		message_admins("[key_name_admin(chosen_candidate)] has taken control of ([key_name_admin(src)]) to replace a jobbanned player.")
		key = chosen_candidate.key
	else
		set_playable(JOB_NAME_CYBORG)

//human -> alien
/mob/living/carbon/human/proc/Alienize()
	if(pre_transform())
		return

	var/alien_caste = pick("Hunter","Sentinel","Drone")
	var/mob/living/carbon/alien/humanoid/new_xeno
	switch(alien_caste)
		if("Hunter")
			new_xeno = new /mob/living/carbon/alien/humanoid/hunter(loc)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(loc)
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/humanoid/drone(loc)

	new_xeno.a_intent = INTENT_HARM
	new_xeno.key = key

	to_chat(new_xeno, "<B>You are now an alien.</B>")
	. = new_xeno
	qdel(src)

/mob/living/carbon/human/proc/slimeize(reproduce as num)
	if(pre_transform())
		return

	var/mob/living/simple_animal/slime/new_slime
	if(reproduce)
		var/number = pick(14;2,3,4)	//reproduce (has a small chance of producing 3 or 4 offspring)
		var/list/babies = list()
		for(var/i in 1 to number)
			var/mob/living/simple_animal/slime/M = new/mob/living/simple_animal/slime(loc)
			M.set_nutrition(round(nutrition/number))
			step_away(M,src)
			babies += M
		new_slime = pick(babies)
	else
		new_slime = new /mob/living/simple_animal/slime(loc)
	new_slime.a_intent = INTENT_HARM
	new_slime.key = key

	to_chat(new_slime, "<B>You are now a slime. Skreee!</B>")
	. = new_slime
	qdel(src)

/mob/proc/become_overmind(starting_points = 60)
	var/mob/camera/blob/B = new /mob/camera/blob(get_turf(src), starting_points)
	B.key = key
	. = B
	qdel(src)


/mob/living/carbon/proc/corgize()
	if(pre_transform())
		return

	var/mob/living/simple_animal/pet/dog/corgi/new_corgi = new /mob/living/simple_animal/pet/dog/corgi (loc)
	new_corgi.a_intent = INTENT_HARM
	new_corgi.key = key

	to_chat(new_corgi, "<B>You are now a Corgi. Yap Yap!</B>")
	. = new_corgi
	qdel(src)

/mob/living/carbon/proc/gorillize()
	if(pre_transform())
		return
	var/mob/living/simple_animal/hostile/gorilla/new_gorilla = new (get_turf(src))
	new_gorilla.a_intent = INTENT_HARM
	if(mind)
		mind.transfer_to(new_gorilla)
	else
		new_gorilla.key = key
	to_chat(new_gorilla, "<B>You are now a gorilla. Ooga ooga!</B>")
	. = new_gorilla
	qdel(src)

/mob/living/carbon/proc/junglegorillize()
	if(pre_transform())
		return
	var/mob/living/simple_animal/hostile/gorilla/rabid/new_gorilla = new (get_turf(src))
	new_gorilla.a_intent = INTENT_HARM
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.add_hud_to(new_gorilla)
	if(mind)
		mind.transfer_to(new_gorilla)
	else
		new_gorilla.key = key
	to_chat(new_gorilla, "<B>You are now a gorilla. Ooga ooga!</B>")
	. = new_gorilla
	qdel(src)

/mob/living/carbon/human/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = tgui_input_list(usr, "Which type of mob should [src] turn into?", "Choose a type", sort_list(mobtypes, GLOBAL_PROC_REF(cmp_typepaths_asc)))
	if(isnull(mobpath))
		return
	if(!mobpath)
		to_chat(usr, "<span class='danger'>Sorry but this mob type is currently unavailable.</span>")
		return

	if(pre_transform())
		return

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = INTENT_HARM

	to_chat(new_mob, "You suddenly feel more... animalistic.")
	. = new_mob
	qdel(src)

/mob/proc/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = tgui_input_list(usr, "Which type of mob should [src] turn into?", "Choose a type", sort_list(mobtypes, GLOBAL_PROC_REF(cmp_typepaths_asc)))
	if(isnull(mobpath))
		return
	if(!mobpath)
		to_chat(usr, "<span class='danger'>Sorry but this mob type is currently unavailable.</span>")
		return

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = INTENT_HARM
	to_chat(new_mob, "<span class='boldnotice'>You feel more... animalistic!</span>")

	. = new_mob
	qdel(src)

#undef TRANSFORMATION_DURATION
