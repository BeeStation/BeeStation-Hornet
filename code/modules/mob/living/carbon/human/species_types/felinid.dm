//Subtype of human
/datum/species/human/felinid
	name = "\improper Felinid"
	id = SPECIES_FELINID
	bodyflag = FLAG_FELINID
	examine_limb_id = SPECIES_HUMAN

	mutant_bodyparts = list("tail_human" = "Cat", "ears" = "Cat", "wings" = "None", "body_size" = "Normal")
	forced_features = list("tail_human" = "Cat", "ears" = "Cat")

	mutantears = /obj/item/organ/ears/cat
	mutant_organs = list(/obj/item/organ/tail/cat)
	mutanttongue = /obj/item/organ/tongue/cat
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	swimming_component = /datum/component/swimming/felinid
	inert_mutation = /datum/mutation/catclaws

	species_height = SPECIES_HEIGHTS(2, 1, 0)

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
			ears.Insert(H, drop_if_replaced = FALSE, pref_load = pref_load)
		else
			mutantears = /obj/item/organ/ears
		if(H.dna.features["tail_human"] == "Cat")
			var/obj/item/organ/tail/cat/tail = new
			tail.Insert(H, drop_if_replaced = FALSE, pref_load = pref_load)
		else
			mutant_organs = list()
	return ..()

/datum/species/human/felinid/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/M)
	if(istype(chem, /datum/reagent/consumable/cocoa))
		if(prob(40))
			M.adjust_disgust(20)
		if(prob(5))
			M.visible_message(span_warning("[M] [pick("dry heaves!","coughs!","splutters!")]"))
		if(prob(10))
			var/sick_message = pick("You feel nauseous.", "You're nya't feeling so good.","You feel like your insides are melting.","You feel illsies.")
			to_chat(M, span_notice("[sick_message]"))
		if(prob(15))
			var/obj/item/organ/guts = pick(M.internal_organs)
			guts.applyOrganDamage(15)
		return FALSE
	return ..() //second part of this effect is handled elsewhere

/datum/species/human/felinid/z_impact_damage(mob/living/carbon/human/H, turf/T, levels)
	//Check to make sure legs are working
	var/obj/item/bodypart/left_leg = H.get_bodypart(BODY_ZONE_L_LEG)
	var/obj/item/bodypart/right_leg = H.get_bodypart(BODY_ZONE_R_LEG)
	if(!left_leg || !right_leg || left_leg.bodypart_disabled || right_leg.bodypart_disabled)
		return ..()
	if(levels == 1)
		//Nailed it!
		H.visible_message(span_notice("[H] lands elegantly on [H.p_their()] feet!"),
			span_warning("You fall [levels] level\s into [T], perfecting the landing!"))
		H.Stun(levels * 35)
	else
		H.visible_message(span_danger("[H] falls [levels] level\s into [T], barely landing on [H.p_their()] feet, with a sickening crunch!"))
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

/datum/species/human/felinid/prepare_human_for_preview(mob/living/carbon/human/human)
	human.hair_style = "Hime Cut"
	human.hair_color = "fcc" // pink
	human.update_hair()

	var/obj/item/organ/ears/cat/cat_ears = human.getorgan(/obj/item/organ/ears/cat)
	if (cat_ears)
		cat_ears.color = human.hair_color
		human.update_body()

/datum/species/human/felinid/get_species_description()
	return "Felinids are one of the many types of bespoke genetic \
		modifications to come of humanity's mastery of genetic science, and are \
		also one of the most common. Meow?"

/datum/species/human/felinid/get_species_lore()
	return list(
		"Bio-engineering at its felinest, Felinids are the peak example of humanity's mastery of genetic code. \
			One of many \"Animalid\" variants, Felinids are the most popular and common, as well as one of the \
			biggest points of contention in genetic-modification.",

		"Body modders were eager to splice human and feline DNA in search of the holy trifecta: ears, eyes, and tail. \
			These traits were in high demand, with the corresponding side effects of vocal and neurochemical changes being seen as a minor inconvenience.",

		"Sadly for the Felinids, they were not minor inconveniences. Shunned as subhuman and monstrous by many, Felinids (and other Animalids) \
			sought their greener pastures out in the colonies, cloistering in communities of their own kind. \
			As a result, outer Human space has a high Animalid population.",
	)

// Felinids are subtypes of humans.
// This shouldn't call parent or we'll get a buncha human related perks (though it doesn't have a reason to).
/datum/species/human/felinid/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "angle-double-down",
			SPECIES_PERK_NAME = "Always Land On Your Feet",
			SPECIES_PERK_DESC = "Felinids always land on their feet, and take reduced damage from falling.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "shoe-prints",
			SPECIES_PERK_NAME = "Laser Affinity",
			SPECIES_PERK_DESC = "Felinids can't resist the temptation of a good laser pointer, and might involuntarily chase a strong one.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "swimming-pool",
			SPECIES_PERK_NAME = "Hydrophobia",
			SPECIES_PERK_DESC = "Felinids don't like water, and hate going in the pool.",
		),
	)

	return to_add
