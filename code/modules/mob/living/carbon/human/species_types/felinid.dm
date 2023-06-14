//Subtype of human
/datum/species/human/felinid
	name = "\improper Felinid"
	id = SPECIES_FELINID
	bodyflag = FLAG_FELINID
	examine_limb_id = SPECIES_HUMAN

	mutant_bodyparts = list("ears", "tail_human")
	default_features = list("mcolor" = "FFF", "wings" = "None", "body_size" = "Normal")
	forced_features = list("tail_human" = "Cat", "ears" = "Cat")

	mutantears = /obj/item/organ/ears/cat
	mutanttail = /obj/item/organ/tail/cat
	mutanttongue = /obj/item/organ/tongue/cat
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	swimming_component = /datum/component/swimming/felinid
	inert_mutation = CATCLAWS

/datum/species/human/felinid/qualifies_for_rank(rank, list/features)
	return TRUE

//Curiosity killed the cat's wagging tail.
/datum/species/human/felinid/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		stop_wagging_tail(H)

/datum/species/human/felinid/spec_stun(mob/living/carbon/human/H,amount)
	if(H)
		stop_wagging_tail(H)
	. = ..()

/datum/species/human/felinid/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!pref_load)			//Hah! They got forcefully purrbation'd. Force default felinid parts on them if they have no mutant parts in those areas!
			if(H.dna.features["tail_human"] == "None")
				H.dna.features["tail_human"] = "Cat"
			if(H.dna.features["ears"] == "None")
				H.dna.features["ears"] = "Cat"
		if(H.dna.features["ears"] == "Cat")
			var/obj/item/organ/ears/cat/ears = new
			ears.Insert(H, drop_if_replaced = FALSE)
		else
			mutantears = /obj/item/organ/ears
		if(H.dna.features["tail_human"] == "Cat")
			var/obj/item/organ/tail/cat/tail = new
			tail.Insert(H, drop_if_replaced = FALSE)
		else
			mutanttail = null
	return ..()

/datum/species/human/felinid/on_species_loss(mob/living/carbon/H, datum/species/new_species, pref_load)
	var/obj/item/organ/ears/cat/ears = H.getorgan(/obj/item/organ/ears/cat)
	var/obj/item/organ/tail/cat/tail = H.getorgan(/obj/item/organ/tail/cat)

	if(ears)
		var/obj/item/organ/ears/new_ears
		if(new_species?.mutantears)
			// Roundstart cat ears override new_species.mutantears, reset it here.
			new_species.mutantears = initial(new_species.mutantears)
			if(new_species.mutantears)
				new_ears = new new_species.mutantears
		if(!new_ears)
			// Go with default ears
			new_ears = new /obj/item/organ/ears
		new_ears.Insert(H, drop_if_replaced = FALSE)

	if(tail)
		var/obj/item/organ/tail/new_tail
		if(new_species && new_species.mutanttail)
			// Roundstart cat tail overrides new_species.mutanttail, reset it here.
			new_species.mutanttail = initial(new_species.mutanttail)
			if(new_species.mutanttail)
				new_tail = new new_species.mutanttail
		if(new_tail)
			new_tail.Insert(H, drop_if_replaced = FALSE)
		else
			tail.Remove(H)

/datum/species/human/felinid/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/M)
	if(istype(chem, /datum/reagent/consumable/cocoa))
		if(prob(40))
			M.adjust_disgust(20)
		if(prob(5))
			M.visible_message("<span class='warning'>[M] [pick("dry heaves!","coughs!","splutters!")]</span>")
		if(prob(10))
			var/sick_message = pick("You feel nauseous.", "You're nya't feeling so good.","You feel like your insides are melting.","You feel illsies.")
			to_chat(M, "<span class='notice'>[sick_message]</span>")
		if(prob(15))
			var/obj/item/organ/guts = pick(M.internal_organs)
			guts.applyOrganDamage(15)
		return FALSE
	return ..() //second part of this effect is handled elsewhere

/datum/species/human/felinid/z_impact_damage(mob/living/carbon/human/H, turf/T, levels)
	//Check to make sure legs are working
	var/obj/item/bodypart/left_leg = H.get_bodypart(BODY_ZONE_L_LEG)
	var/obj/item/bodypart/right_leg = H.get_bodypart(BODY_ZONE_R_LEG)
	if(!left_leg || !right_leg || left_leg.disabled || right_leg.disabled)
		return ..()
	if(levels == 1)
		//Nailed it!
		H.visible_message("<span class='notice'>[H] lands elegantly on [H.p_their()] feet!</span>",
			"<span class='warning'>You fall [levels] level\s into [T], perfecting the landing!</span>")
		H.Stun(levels * 35)
	else
		H.visible_message("<span class='danger'>[H] falls [levels] level\s into [T], barely landing on [H.p_their()] feet, with a sickening crunch!</span>")
		var/amount_total = H.get_distributed_zimpact_damage(levels) * 0.5
		H.apply_damage(amount_total * 0.45, BRUTE, BODY_ZONE_L_LEG)
		H.apply_damage(amount_total * 0.45, BRUTE, BODY_ZONE_R_LEG)
		H.adjustBruteLoss(amount_total * 0.1)
		H.Stun(levels * 50)
		// SPLAT!
		// 5: 25%, 4: 16%, 3: 9%
		if(levels >= 3 && prob(min((levels ** 2), 50)))
			H.gib()
			return
		// owie
		// 5: 40%, 4: 30%, 3: 20%, 2: 10%
		if(prob(min((levels - 1) * 10, 75)))
			if(levels >= 3 && prob(25))
				for(var/selected_part in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
					var/obj/item/bodypart/bp = H.get_bodypart(selected_part)
					if(bp)
						bp.dismember()
				return
			var/selected_part = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			var/obj/item/bodypart/bp = H.get_bodypart(selected_part)
			if(bp)
				bp.dismember()
				return


/proc/mass_purrbation()
	for(var/M in GLOB.mob_list)
		if(ishumanbasic(M))
			purrbation_apply(M)
		CHECK_TICK

/proc/mass_remove_purrbation()
	for(var/M in GLOB.mob_list)
		if(ishumanbasic(M))
			purrbation_remove(M)
		CHECK_TICK

/proc/purrbation_toggle(mob/living/carbon/human/H, silent = FALSE)
	if(!ishumanbasic(H))
		return
	if(!iscatperson(H))
		purrbation_apply(H, silent)
		. = TRUE
	else
		purrbation_remove(H, silent)
		. = FALSE

/proc/purrbation_apply(mob/living/carbon/human/H, silent = FALSE)
	if(!ishuman(H) || iscatperson(H))
		return
	H.set_species(/datum/species/human/felinid)

	if(!silent)
		to_chat(H, "Something is nya~t right.")
		playsound(get_turf(H), 'sound/effects/meow1.ogg', 50, 1, -1)

/proc/purrbation_remove(mob/living/carbon/human/H, silent = FALSE)
	if(!ishuman(H) || !iscatperson(H))
		return

	H.set_species(/datum/species/human)

	if(!silent)
		to_chat(H, "You are no longer a cat.")
