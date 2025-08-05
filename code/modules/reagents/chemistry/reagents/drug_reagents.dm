/datum/reagent/drug
	name = "Drug"
	chemical_flags = CHEMICAL_NOT_DEFINED
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "bitterness"

	/// Does this drug make you trip?
	var/trippy = TRUE

/datum/reagent/drug/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	if(trippy)
		SEND_SIGNAL(affected_mob, COMSIG_CLEAR_MOOD_EVENT, "[type]_high")

/datum/reagent/drug/space_drugs
	name = "Space drugs"
	description = "An illegal chemical compound used as drug."
	color = "#60A584" // rgb: 96, 165, 132
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST | CHEMICAL_GOAL_BARTENDER_SERVING
	overdose_threshold = 30

/datum/reagent/drug/space_drugs/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.set_drugginess(15 * REM * delta_time)
	if(isturf(affected_mob.loc) && !isspaceturf(affected_mob.loc) && !HAS_TRAIT(affected_mob, TRAIT_IMMOBILIZED) && DT_PROB(5, delta_time))
		step(affected_mob, pick(GLOB.cardinals))

	if(DT_PROB(3.5, delta_time))
		affected_mob.emote(pick("twitch", "drool", "moan", "giggle"))

/datum/reagent/drug/space_drugs/overdose_start(mob/living/carbon/affected_mob)
	to_chat(affected_mob, span_userdanger("You start tripping hard!"))
	SEND_SIGNAL(affected_mob, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/overdose, name)

/datum/reagent/drug/space_drugs/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.hallucination < volume && DT_PROB(10, delta_time))
		affected_mob.hallucination += 5

/datum/reagent/drug/nicotine
	name = "Nicotine"
	description = "Slightly reduces stun times. If overdosed it will deal toxin and oxygen damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST | CHEMICAL_GOAL_BARTENDER_SERVING
	addiction_threshold = 10
	taste_description = "smoke"
	trippy = FALSE
	overdose_threshold=15
	metabolization_rate = 0.125 * REAGENTS_METABOLISM

/datum/reagent/drug/nicotine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(0.5, delta_time))
		to_chat(affected_mob, span_notice(pick("You feel relaxed.", "You feel calmed.", "You feel alert.", "You feel rugged.")))

	SEND_SIGNAL(affected_mob, COMSIG_ADD_MOOD_EVENT, "smoked", /datum/mood_event/smoked, name)
	affected_mob.AdjustStun(-50  * REM * delta_time)
	affected_mob.AdjustKnockdown(-50 * REM * delta_time)
	affected_mob.AdjustUnconscious(-50 * REM * delta_time)
	affected_mob.AdjustParalyzed(-50 * REM * delta_time)
	affected_mob.AdjustImmobilized(-50 * REM * delta_time)
	return UPDATE_MOB_HEALTH

/datum/reagent/drug/nicotine/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjustToxLoss(0.1 * REM * delta_time, updating_health = FALSE)
	affected_mob.adjustOxyLoss(1.1 * REM * delta_time, updating_health = FALSE)
	return UPDATE_MOB_HEALTH

/datum/reagent/drug/crank
	name = "Crank"
	description = "Reduces stun times by about 200%. If overdosed or addicted it will deal significant Toxin, Brute and Brain damage."
	reagent_state = LIQUID
	color = "#FA00C8"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	overdose_threshold = 20
	addiction_threshold = 10
	metabolized_traits = list(TRAIT_NOBLOCK)

/datum/reagent/drug/crank/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(2.5, delta_time))
		to_chat(affected_mob, span_notice(pick("You feel jittery.", "You feel like you gotta go fast.", "You feel like you need to step it up.")))

	if(prob(DT_PROB(8, delta_time)))
		affected_mob.adjustBruteLoss(rand(1,4), updating_health = FALSE)
		affected_mob.Stun(5, 0)
		to_chat(affected_mob, span_notice("You stop to furiously scratch at your skin."))

	affected_mob.AdjustStun(-20 * REM * delta_time)
	affected_mob.AdjustKnockdown(-20 * REM * delta_time)
	affected_mob.AdjustUnconscious(-20 * REM * delta_time)
	affected_mob.AdjustImmobilized(-20 * REM * delta_time)
	affected_mob.AdjustParalyzed(-20 * REM * delta_time)
	affected_mob.adjustToxLoss(0.75 * REM * delta_time, updating_health = FALSE)
	affected_mob.adjustStaminaLoss(-18 * REM * delta_time, updating_health = FALSE)
	return UPDATE_MOB_HEALTH

/datum/reagent/drug/crank/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2 * REM * delta_time)
	affected_mob.adjustToxLoss(2 * REM * delta_time, updating_health = FALSE)
	affected_mob.adjustBruteLoss(2 * REM * delta_time, updating_health = FALSE, required_status = BODYTYPE_ORGANIC)
	return UPDATE_MOB_HEALTH

/datum/reagent/drug/crank/addiction_act_stage1(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5 * REM)

/datum/reagent/drug/crank/addiction_act_stage2(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.adjustToxLoss(5 * REM, updating_health = FALSE)
	return UPDATE_MOB_HEALTH

/datum/reagent/drug/crank/addiction_act_stage3(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.adjustBruteLoss(5 * REM, updating_health = FALSE)
	return UPDATE_MOB_HEALTH

/datum/reagent/drug/crank/addiction_act_stage4(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3 * REM)
	affected_mob.adjustToxLoss(5 * REM, updating_health = FALSE)
	affected_mob.adjustBruteLoss(5 * REM, updating_health = FALSE)
	return UPDATE_MOB_HEALTH

/datum/reagent/drug/krokodil
	name = "Krokodil"
	description = "Cools and calms you down. If overdosed it will deal significant Brain and Toxin damage. If addicted it will begin to deal fatal amounts of Brute damage as the subject's skin falls off."
	reagent_state = LIQUID
	color = "#0064B4"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	overdose_threshold = 20
	addiction_threshold = 15

/datum/reagent/drug/krokodil/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(2.5, delta_time))
		to_chat(affected_mob, span_notice(pick("You feel calm.", "You feel collected.", "You feel like you need to relax.")))

/datum/reagent/drug/krokodil/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.25 * REM * delta_time)
	affected_mob.adjustToxLoss(0.25 * REM * delta_time, updating_health = FALSE)
	return UPDATE_MOB_HEALTH

/datum/reagent/drug/krokodil/addiction_act_stage1(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2*REM)
	affected_mob.adjustToxLoss(2 * REM, updating_health = FALSE)
	return UPDATE_MOB_HEALTH

/datum/reagent/drug/krokodil/addiction_act_stage2(mob/living/carbon/affected_mob)
	. = ..()
	if(prob(25))
		to_chat(affected_mob, span_danger("Your skin feels loose..."))

/datum/reagent/drug/krokodil/addiction_act_stage3(mob/living/carbon/affected_mob)
	. = ..()
	if(prob(25))
		to_chat(affected_mob, span_danger("Your skin starts to peel away..."))

	affected_mob.adjustBruteLoss(3 * REM, updating_health = FALSE)
	return UPDATE_MOB_HEALTH

/datum/reagent/drug/krokodil/addiction_act_stage4(mob/living/carbon/affected_mob)
	. = ..()
	CHECK_DNA_AND_SPECIES(affected_mob)
	if(ishumanbasic(affected_mob))
		if(!istype(affected_mob.dna.species, /datum/species/human/krokodil_addict))
			to_chat(affected_mob, span_userdanger("Your skin falls off!"))
			affected_mob.adjustBruteLoss(50 * REM, updating_health = FALSE) // holy shit your skin just FELL THE FUCK OFF
			affected_mob.set_species(/datum/species/human/krokodil_addict)
		else
			affected_mob.adjustBruteLoss(5 * REM, updating_health = FALSE)
	else
		to_chat(affected_mob, span_userdanger("Your skin falls off!"))
		affected_mob.adjustBruteLoss(50 * REM, updating_health = FALSE)

	return UPDATE_MOB_HEALTH

/datum/reagent/drug/methamphetamine
	name = "Methamphetamine"
	description = "Reduces stun times by about 300%, speeds the user up, and allows the user to quickly recover stamina while dealing a small amount of Brain damage. If overdosed the subject will move randomly, laugh randomly, drop items and suffer from Toxin and Brain damage. If addicted the subject will constantly jitter and drool, before becoming dizzy and losing motor control and eventually suffer heavy toxin damage."
	reagent_state = LIQUID
	color = "#FAFAFA"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	overdose_threshold = 20
	addiction_threshold = 10
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	metabolized_traits = list(TRAIT_SLEEPIMMUNE, TRAIT_NOBLOCK)

/datum/reagent/drug/methamphetamine/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.client?.give_award(/datum/award/achievement/misc/meth, affected_mob)
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine)

/datum/reagent/drug/methamphetamine/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine)

/datum/reagent/drug/methamphetamine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(2.5, delta_time))
		to_chat(affected_mob, span_notice(pick("You feel hyper.", "You feel like you need to go faster.", "You feel like you can run the world.")))

	if(DT_PROB(2.5, delta_time))
		affected_mob.emote(pick("twitch", "shiver"))

	affected_mob.AdjustStun(-40 * REM * delta_time)
	affected_mob.AdjustKnockdown(-40 * REM * delta_time)
	affected_mob.AdjustUnconscious(-40 * REM * delta_time)
	affected_mob.AdjustParalyzed(-40 * REM * delta_time)
	affected_mob.AdjustImmobilized(-40 * REM * delta_time)
	affected_mob.adjustStaminaLoss(-40 * REM * delta_time, updating_health = FALSE)
	affected_mob.drowsyness = max(affected_mob.drowsyness - (60 * REM * delta_time), 0)
	affected_mob.Jitter(2 * REM * delta_time)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1)

	return UPDATE_MOB_HEALTH

/datum/reagent/drug/methamphetamine/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(!HAS_TRAIT(affected_mob, TRAIT_IMMOBILIZED) && !ismovable(affected_mob.loc))
		for(var/i in 1 to round(4 * REM * delta_time, 1))
			step(affected_mob, pick(GLOB.cardinals))

	if(DT_PROB(10, delta_time))
		affected_mob.emote("laugh")

	if(DT_PROB(18, delta_time))
		affected_mob.visible_message(span_danger("[affected_mob]'s hands flip out and flail everywhere!"))
		affected_mob.drop_all_held_items()

	affected_mob.adjustToxLoss(1 * REM * delta_time, updating_health = FALSE)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, (rand(5, 10) / 10) * REM * delta_time)
	return UPDATE_MOB_HEALTH

/datum/reagent/drug/methamphetamine/addiction_act_stage1(mob/living/carbon/affected_mob)
	. = ..()
	if(prob(20))
		affected_mob.emote(pick("twitch", "drool", "moan"))

	affected_mob.Jitter(5)

/datum/reagent/drug/methamphetamine/addiction_act_stage2(mob/living/carbon/affected_mob)
	. = ..()
	if(prob(30))
		affected_mob.emote(pick("twitch", "drool", "moan"))

	affected_mob.Jitter(10)
	affected_mob.Dizzy(10)

/datum/reagent/drug/methamphetamine/addiction_act_stage3(mob/living/carbon/affected_mob)
	. = ..()
	if(prob(40))
		affected_mob.emote(pick("twitch", "drool", "moan"))

	if(!HAS_TRAIT(affected_mob, TRAIT_IMMOBILIZED) && !ismovable(affected_mob.loc))
		for(var/i = 1 to 4)
			step(affected_mob, pick(GLOB.cardinals))

	affected_mob.Jitter(15)
	affected_mob.Dizzy(15)

/datum/reagent/drug/methamphetamine/addiction_act_stage4(mob/living/carbon/affected_mob)
	. = ..()
	if(prob(50))
		affected_mob.emote(pick("twitch", "drool", "moan"))

	if(!HAS_TRAIT(affected_mob, TRAIT_IMMOBILIZED) && !ismovable(affected_mob.loc))
		for(var/i = 1 to 8)
			step(affected_mob, pick(GLOB.cardinals))

	affected_mob.Jitter(20)
	affected_mob.Dizzy(20)
	affected_mob.adjustToxLoss(5, updating_health = FALSE)
	return UPDATE_MOB_HEALTH

/datum/reagent/drug/bath_salts
	name = "Bath Salts"
	description = "Makes you impervious to stuns and grants a stamina regeneration buff, but you will be a nearly uncontrollable tramp-bearded raving lunatic."
	reagent_state = LIQUID
	color = "#FAFAFA"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	overdose_threshold = 20
	addiction_threshold = 10
	taste_description = "salt" // because they're bathsalts?
	metabolized_traits = list(TRAIT_STUNIMMUNE, TRAIT_SLEEPIMMUNE, TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_NOSTAMCRIT, TRAIT_NOLIMBDISABLE, TRAIT_NOBLOCK)

	var/datum/martial_art/psychotic_brawling/brawling

/datum/reagent/drug/bath_salts/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	brawling = new(null)
	if(!brawling.teach(affected_mob, TRUE))
		QDEL_NULL(brawling)

/datum/reagent/drug/bath_salts/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	if(brawling)
		brawling.remove(affected_mob)
		QDEL_NULL(brawling)

/datum/reagent/drug/bath_salts/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(2.5, delta_time))
		to_chat(affected_mob, span_notice(pick("You feel amped up.", "You feel ready.", "You feel like you can push it to the limit.")))

	if(!HAS_TRAIT(affected_mob, TRAIT_IMMOBILIZED) && !ismovable(affected_mob.loc))
		for(var/i = 1 to 2)
			step(affected_mob, pick(GLOB.cardinals))

	affected_mob.adjustStaminaLoss(-5 * REM * delta_time, updating_health = FALSE)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 4 * REM * delta_time)
	affected_mob.hallucination += 5 * REM * delta_time
	return UPDATE_MOB_HEALTH

/datum/reagent/drug/bath_salts/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(10, delta_time))
		affected_mob.emote(pick("twitch", "drool", "moan"))

	if(!HAS_TRAIT(affected_mob, TRAIT_IMMOBILIZED) && !ismovable(affected_mob.loc))
		for(var/i = 1 to round(8 * REM * delta_time, 1))
			step(affected_mob, pick(GLOB.cardinals))

	if(DT_PROB(28, delta_time))
		affected_mob.drop_all_held_items()

	affected_mob.hallucination += 5 * REM * delta_time

/datum/reagent/drug/bath_salts/addiction_act_stage1(mob/living/carbon/affected_mob)
	. = ..()
	if(prob(20))
		affected_mob.emote(pick("twitch", "drool", "moan"))

	if(!HAS_TRAIT(affected_mob, TRAIT_IMMOBILIZED) && !ismovable(affected_mob.loc))
		for(var/i = 1 to 8)
			step(affected_mob, pick(GLOB.cardinals))

	affected_mob.hallucination += 10
	affected_mob.Jitter(5)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)

/datum/reagent/drug/bath_salts/addiction_act_stage2(mob/living/carbon/affected_mob)
	. = ..()
	if(prob(30))
		affected_mob.emote(pick("twitch", "drool", "moan"))

	if(!HAS_TRAIT(affected_mob, TRAIT_IMMOBILIZED) && !ismovable(affected_mob.loc))
		for(var/i = 1 to 8)
			step(affected_mob, pick(GLOB.cardinals))

	affected_mob.hallucination += 20
	affected_mob.Jitter(10)
	affected_mob.Dizzy(10)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)

/datum/reagent/drug/bath_salts/addiction_act_stage3(mob/living/carbon/affected_mob)
	. = ..()
	if(prob(40))
		affected_mob.emote(pick("twitch", "drool", "moan"))

	if(!HAS_TRAIT(affected_mob, TRAIT_IMMOBILIZED) && !ismovable(affected_mob.loc))
		for(var/i = 1 to 12)
			step(affected_mob, pick(GLOB.cardinals))

	affected_mob.hallucination += 30
	affected_mob.Jitter(15)
	affected_mob.Dizzy(15)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)

/datum/reagent/drug/bath_salts/addiction_act_stage4(mob/living/carbon/affected_mob)
	. = ..()
	if(prob(50))
		affected_mob.emote(pick("twitch", "drool", "moan"))

	if(!HAS_TRAIT(affected_mob, TRAIT_IMMOBILIZED) && !ismovable(affected_mob.loc))
		for(var/i = 1 to 16)
			step(affected_mob, pick(GLOB.cardinals))

	affected_mob.hallucination += 30
	affected_mob.Jitter(50)
	affected_mob.Dizzy(50)
	affected_mob.adjustToxLoss(5, updating_health = FALSE)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
	return UPDATE_MOB_HEALTH

/datum/reagent/drug/aranesp
	name = "Aranesp"
	description = "Amps you up, gets you going, and rapidly restores stamina damage. Side effects include breathlessness and toxicity."
	reagent_state = LIQUID
	color = "#78FFF0"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolized_traits = list(TRAIT_NOBLOCK)

/datum/reagent/drug/aranesp/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(2.5, delta_time))
		to_chat(affected_mob, span_notice(pick("You feel amped up.", "You feel ready.", "You feel like you can push it to the limit.")))

	if(DT_PROB(30, delta_time))
		affected_mob.losebreath++
		affected_mob.adjustOxyLoss(1, updating_health = FALSE)

	affected_mob.adjustStaminaLoss(-18 * REM * delta_time, updating_health = FALSE)
	affected_mob.adjustToxLoss(0.5 * REM * delta_time, updating_health = FALSE)
	return UPDATE_MOB_HEALTH

/datum/reagent/drug/happiness
	name = "Happiness"
	description = "Fills you with ecstasic numbness and causes minor brain damage. Highly addictive. If overdosed causes sudden mood swings."
	reagent_state = LIQUID
	color = "#FFF378"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	addiction_threshold = 10
	overdose_threshold = 20
	metabolized_traits = list(TRAIT_FEARLESS)

/datum/reagent/drug/happiness/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	SEND_SIGNAL(affected_mob, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug)

/datum/reagent/drug/happiness/on_mob_delete(mob/living/carbon/affected_mob)
	. = ..()
	SEND_SIGNAL(affected_mob, COMSIG_CLEAR_MOOD_EVENT, "happiness_drug")

/datum/reagent/drug/happiness/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.jitteriness = 0
	affected_mob.confused = 0
	affected_mob.disgust = 0
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.2 * REM * delta_time)

/datum/reagent/drug/happiness/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(16, delta_time))
		switch(rand(1, 3))
			if(1)
				affected_mob.emote("laugh")
				SEND_SIGNAL(affected_mob, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug_good_od)
			if(2)
				affected_mob.emote("frown")
				SEND_SIGNAL(affected_mob, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug_bad_od)
			if(3)
				affected_mob.emote("sway")
				affected_mob.Dizzy(25)

	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5 * REM * delta_time)

/datum/reagent/drug/happiness/addiction_act_stage1(mob/living/carbon/affected_mob)// all work and no play makes jack a dull boy
	. = ..()
	if(prob(20))
		affected_mob.emote(pick("twitch","laugh","frown"))

	var/datum/component/mood/mood = affected_mob.GetComponent(/datum/component/mood)
	mood?.setSanity(max(mood.sanity, SANITY_DISTURBED))
	affected_mob.Jitter(5)

/datum/reagent/drug/happiness/addiction_act_stage2(mob/living/carbon/affected_mob)
	. = ..()
	if(prob(30))
		affected_mob.emote(pick("twitch","laugh","frown"))

	var/datum/component/mood/mood = affected_mob.GetComponent(/datum/component/mood)
	mood?.setSanity(max(mood.sanity, SANITY_UNSTABLE))
	affected_mob.Jitter(10)

/datum/reagent/drug/happiness/addiction_act_stage3(mob/living/carbon/affected_mob)
	. = ..()
	if(prob(40))
		affected_mob.emote(pick("twitch","laugh","frown"))

	var/datum/component/mood/mood = affected_mob.GetComponent(/datum/component/mood)
	mood?.setSanity(max(mood.sanity, SANITY_CRAZY))
	affected_mob.Jitter(15)

/datum/reagent/drug/happiness/addiction_act_stage4(mob/living/carbon/affected_mob)
	. = ..()
	if(prob(50))
		affected_mob.emote(pick("twitch","laugh","frown"))

	var/datum/component/mood/mood = affected_mob.GetComponent(/datum/component/mood)
	mood?.setSanity(SANITY_INSANE)
	affected_mob.Jitter(20)

//I had to do too much research on this to make this a thing. Hopefully the FBI won't kick my door down.
/datum/reagent/drug/ketamine
	name = "Ketamine"
	description = "A heavy duty tranquilizer found to also invoke feelings of euphoria, and assist with pain. Popular at parties and amongst small frogmen who drive Honda Civics."
	reagent_state = LIQUID
	color = "#c9c9c9"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	addiction_threshold = 8
	overdose_threshold = 16
	metabolized_traits = list(TRAIT_IGNOREDAMAGESLOWDOWN)

/datum/reagent/drug/ketamine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	//Friendly Reminder: Ketamine is a tranquilizer and will sleep you.
	switch(current_cycle)
		if(10)
			to_chat(affected_mob, span_warning("You start to feel tired..."))
		if(11 to 25)
			affected_mob.drowsyness += 1 * REM * delta_time
		if(26 to INFINITY)
			affected_mob.Sleeping(60 * REM * delta_time)

	//Providing a Mood Boost
	affected_mob.confused -= 3 * REM * delta_time
	affected_mob.jitteriness -= 5 * REM * delta_time
	affected_mob.disgust -= 3 * REM * delta_time
	//Ketamine is also a dissociative anasthetic which means Hallucinations!
	affected_mob.hallucination += 5 * REM * delta_time

/datum/reagent/drug/ketamine/overdose_process(mob/living/carbon/affected_mob)
	. = ..()
	var/obj/item/organ/brain/brain = affected_mob.get_organ_by_type(/obj/item/organ/brain)
	brain?.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_SURGERY)

	affected_mob.hallucination += 10
	//Uh Oh Someone is tired
	if(prob(40))
		if(HAS_TRAIT(affected_mob, TRAIT_IGNOREDAMAGESLOWDOWN))
			REMOVE_TRAIT(affected_mob, TRAIT_IGNOREDAMAGESLOWDOWN, type)

		to_chat(affected_mob, span_warning(pick("Your limbs begin to feel heavy...", "It feels hard to move...", "You feel like you your limbs won't move...")))

		affected_mob.drop_all_held_items()
		affected_mob.Dizzy(5)

//Addiction Gradient
/datum/reagent/drug/ketamine/addiction_act_stage1(mob/living/carbon/affected_mob)
	. = ..()
	if(prob(20))
		affected_mob.drop_all_held_items()
		affected_mob.Jitter(2)

/datum/reagent/drug/ketamine/addiction_act_stage2(mob/living/carbon/affected_mob)
	. = ..()
	if(prob(30))
		affected_mob.drop_all_held_items()
		affected_mob.Jitter(3)
		affected_mob.Dizzy(3)
		affected_mob.adjustToxLoss(2 * REM, updating_health = FALSE)
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/ketamine/addiction_act_stage3(mob/living/carbon/affected_mob)
	. = ..()
	if(prob(40))
		affected_mob.drop_all_held_items()
		affected_mob.Jitter(4)
		affected_mob.Dizzy(4)
		affected_mob.adjustToxLoss(3 * REM, updating_health = FALSE)
		return UPDATE_MOB_HEALTH


/// Can bring a corpse back to life temporarily (if heart is intact)
/// Also prevents dying
/datum/reagent/drug/nooartrium
	name = "Nooartrium"
	description = "A reagent that is known to stimulate the heart in a dead patient, temporarily bringing back recently dead patients at great cost to their heart."
	overdose_threshold = 25
	color = "#280000"
	self_consuming = TRUE //No pesky liver shenanigans
	added_traits = list(TRAIT_NOCRITDAMAGE, TRAIT_NODEATH, TRAIT_NOHARDCRIT, TRAIT_NOSOFTCRIT, TRAIT_STABLEHEART, TRAIT_STUNRESISTANCE, TRAIT_NOSTAMCRIT, TRAIT_IGNOREDAMAGESLOWDOWN)

	///If we brought someone back from the dead
	var/back_from_the_dead = FALSE
	var/consequences  = FALSE // This can't be healthy?
	var/time_from_consumption = 0 // For tracking consequences


/datum/reagent/drug/nooartrium/on_mob_add(mob/living/carbon/affected_mob)
	. = ..()
	if(affected_mob.suiciding)
		return

	var/obj/item/organ/heart/heart = affected_mob.get_organ_slot(ORGAN_SLOT_HEART)
	if(!heart || heart.organ_flags & ORGAN_FAILING)
		return

	if(affected_mob.stat == DEAD)
		back_from_the_dead = TRUE

	affected_mob.set_stat(CONSCIOUS) // This doesn't touch knocked out
	affected_mob.updatehealth()
	affected_mob.update_sight()
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, list(STAT_TRAIT, CRIT_HEALTH_TRAIT, OXYLOSS_TRAIT))
	affected_mob.set_resting(FALSE) // Please get up. No one wants a death throes juggernaut lying on the floor
	affected_mob.SetAllImmobility(0)

	if(back_from_the_dead)
		affected_mob.grab_ghost(force = FALSE) //Shoves them back into their freshly reanimated corpse.
		affected_mob.emote("gasp")
		return

	to_chat(affected_mob, span_userdanger("You feel your heart start beating with incredible strength, forcing your battered body to move!"))


/datum/reagent/drug/nooartrium/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(!consequences)
		if(time_from_consumption > 180 SECONDS)
			consequences = TRUE
		else
			time_from_consumption += delta_time SECONDS

	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, list(CRIT_HEALTH_TRAIT, OXYLOSS_TRAIT))
	affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, ((affected_mob.getBruteLoss() + affected_mob.getFireLoss()) / 200 + 0.5) * delta_time / 6)

	var/obj/item/organ/heart/heart = affected_mob.get_organ_slot(ORGAN_SLOT_HEART)
	if(!heart || heart.organ_flags & ORGAN_FAILING)
		on_mob_delete(affected_mob)
	else
		heart.maxHealth -= 0.25 * delta_time / 3


/datum/reagent/drug/nooartrium/on_mob_delete(mob/living/carbon/affected_mob)
	. = ..()
	var/obj/item/organ/heart/heart = affected_mob.get_organ_slot(ORGAN_SLOT_HEART)

	to_chat(affected_mob, span_userdanger("You feel your heart grow calm."))
	affected_mob.update_sight()

	if(affected_mob.health < -300 || !heart || heart.organ_flags & ORGAN_FAILING)
		affected_mob.add_splatter_floor(get_turf(affected_mob))
		qdel(heart)
		affected_mob.visible_message(span_boldwarning("[affected_mob]'s heart explodes!"))
	else if(consequences)
		affected_mob.set_heartattack(TRUE)
	time_from_consumption = 0 // Not sure if this is needed, not gonna risk it

/datum/reagent/drug/nooartrium/overdose_start(mob/living/carbon/affected_mob)
	to_chat(affected_mob, span_userdanger("You feel your heart tearing itself apart as it tries to beat stronger!"))
	affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, 20)
	affected_mob.SetParalyzed(6 SECONDS)
	consequences = TRUE
