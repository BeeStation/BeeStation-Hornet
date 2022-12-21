//Subtype of human
/datum/species/human/vulpe
	name = "\improper Vulpe"
	id = SPECIES_VULPE
	bodyflag = FLAG_VULPE
	examine_limb_id = SPECIES_HUMAN

	mutant_bodyparts = list("ears", "tail_human")
	default_features = list("mcolor" = "FFF", "wings" = "None", "body_size" = "Normal")
	forced_features = list("tail_human" = "Fox", "ears" = "Fox")

	mutantears = /obj/item/organ/ears/fox
	mutanttail = /obj/item/organ/tail/fox
	mutanttongue = /obj/item/organ/tongue/fox
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	swimming_component = /datum/component/swimming/cat
	inert_mutation = FOXCLAWS

/datum/species/human/vulpe/qualifies_for_rank(rank, list/features)
	return TRUE

//Curiosity killed the fox's wagging tail.
/datum/species/human/vulpe/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		stop_wagging_tail(H)

/datum/species/human/vulpe/spec_stun(mob/living/carbon/human/H,amount)
	if(H)
		stop_wagging_tail(H)
	. = ..()

/datum/species/human/vulpe/can_wag_tail(mob/living/carbon/human/H)
	return ("tail_human" in mutant_bodyparts) || ("waggingtail_human" in mutant_bodyparts)

/datum/species/human/vulpe/is_wagging_tail(mob/living/carbon/human/H)
	return ("waggingtail_human" in mutant_bodyparts)

/datum/species/human/vulpe/start_wagging_tail(mob/living/carbon/human/H)
	if("tail_human" in mutant_bodyparts)
		mutant_bodyparts -= "tail_human"
		mutant_bodyparts |= "waggingtail_human"
	H.update_body()

/datum/species/human/vulpe/stop_wagging_tail(mob/living/carbon/human/H)
	if("waggingtail_human" in mutant_bodyparts)
		mutant_bodyparts -= "waggingtail_human"
		mutant_bodyparts |= "tail_human"
	H.update_body()

/datum/species/human/vulpe/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!pref_load)			//Hah! They got forcefully floof'd. Force default vulpe parts on them if they have no mutant parts in those areas!
			if(H.dna.features["tail_human"] == "None")
				H.dna.features["tail_human"] = "Fox"
			if(H.dna.features["ears"] == "None")
				H.dna.features["ears"] = "Fox"
		if(H.dna.features["ears"] == "Fox")
			var/obj/item/organ/ears/fox/ears = new
			ears.Insert(H, drop_if_replaced = FALSE)
		else
			mutantears = /obj/item/organ/ears
		if(H.dna.features["tail_human"] == "Fox")
			var/obj/item/organ/tail/fox/tail = new
			tail.Insert(H, drop_if_replaced = FALSE)
		else
			mutanttail = null
	return ..()

/datum/species/human/vulpe/on_species_loss(mob/living/carbon/H, datum/species/new_species, pref_load)
	var/obj/item/organ/ears/fox/ears = H.getorgan(/obj/item/organ/ears/fox)
	var/obj/item/organ/tail/fox/tail = H.getorgan(/obj/item/organ/tail/fox)

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
			// Roundstart fox tail overrides new_species.mutanttail, reset it here.
			new_species.mutanttail = initial(new_species.mutanttail)
			if(new_species.mutanttail)
				new_tail = new new_species.mutanttail
		if(new_tail)
			new_tail.Insert(H, drop_if_replaced = FALSE)
		else
			tail.Remove(H)

/datum/species/human/vulpe/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/M)
	if(istype(chem, /datum/reagent/consumable/cocoa))
		if(prob(40))
			M.adjust_disgust(20)
		if(prob(5))
			M.visible_message("<span class='warning'>[M] [pick("dry heaves!","coughs!","splutters!")]</span>")
		if(prob(10))
			var/sick_message = pick("You feel nauseous.", "You're aren't feeling so good.","You feel like your insides are melting.","You feel illsies.")
			to_chat(M, "<span class='notice'>[sick_message]</span>")
		if(prob(15))
			var/obj/item/organ/guts = pick(M.internal_organs)
			guts.applyOrganDamage(15)
		return FALSE
	return ..() //second part of this effect is handled elsewhere

/*
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
	if(!ishuman(H) || isfoxperson(H))
		return
	H.set_species(/datum/species/human/vulpe)

	if(!silent)
		to_chat(H, "Something is not right. UwU")
		playsound(get_turf(H), 'sound/effects/bark.ogg', 50, 1, -1)

/proc/purrbation_remove(mob/living/carbon/human/H, silent = FALSE)
	if(!ishuman(H) || !isfoxperson(H))
		return

	H.set_species(/datum/species/human)

	if(!silent)
		to_chat(H, "You are no longer a fox.")*/
