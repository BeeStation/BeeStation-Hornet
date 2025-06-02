/datum/reagent/drug
	name = "Drug"
	chem_flags = CHEMICAL_NOT_DEFINED
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "bitterness"
	var/trippy = TRUE //Does this drug make you trip?

/datum/reagent/drug/on_mob_end_metabolize(mob/living/M)
	if(trippy)
		SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "[type]_high")

/datum/reagent/drug/space_drugs
	name = "Space drugs"
	description = "An illegal chemical compound used as drug."
	color = "#60A584" // rgb: 96, 165, 132
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST | CHEMICAL_GOAL_BARTENDER_SERVING
	overdose_threshold = 30

/datum/reagent/drug/space_drugs/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.set_drugginess(15 * REM * delta_time)
	if(isturf(M.loc) && !isspaceturf(M.loc) && !HAS_TRAIT(M, TRAIT_IMMOBILIZED) && DT_PROB(5, delta_time))
		step(M, pick(GLOB.cardinals))
	if(DT_PROB(3.5, delta_time))
		M.emote(pick("twitch","drool","moan","giggle"))
	..()

/datum/reagent/drug/space_drugs/overdose_start(mob/living/M)
	to_chat(M, span_userdanger("You start tripping hard!"))
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/overdose, name)

/datum/reagent/drug/space_drugs/overdose_process(mob/living/M, delta_time, times_fired)
	if(M.hallucination < volume && DT_PROB(10, delta_time))
		M.hallucination += 5
	..()

/datum/reagent/drug/nicotine
	name = "Nicotine"
	description = "Slightly reduces stun times. If overdosed it will deal toxin and oxygen damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST | CHEMICAL_GOAL_BARTENDER_SERVING
	addiction_threshold = 10
	taste_description = "smoke"
	trippy = FALSE
	overdose_threshold=15
	metabolization_rate = 0.125 * REAGENTS_METABOLISM

/datum/reagent/drug/nicotine/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(DT_PROB(0.5, delta_time))
		var/smoke_message = pick("You feel relaxed.", "You feel calmed.","You feel alert.","You feel rugged.")
		to_chat(M, span_notice("[smoke_message]"))
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "smoked", /datum/mood_event/smoked, name)
	M.AdjustStun(-50  * REM * delta_time)
	M.AdjustKnockdown(-50 * REM * delta_time)
	M.AdjustUnconscious(-50 * REM * delta_time)
	M.AdjustParalyzed(-50 * REM * delta_time)
	M.AdjustImmobilized(-50 * REM * delta_time)
	..()
	. = TRUE

/datum/reagent/drug/nicotine/overdose_process(mob/living/M, delta_time, times_fired)
	M.adjustToxLoss(0.1 * REM * delta_time, 0)
	M.adjustOxyLoss(1.1 * REM * delta_time, 0)
	..()
	. = TRUE

/datum/reagent/drug/crank
	name = "Crank"
	description = "Reduces stun times by about 200%. If overdosed or addicted it will deal significant Toxin, Brute and Brain damage."
	reagent_state = LIQUID
	color = "#FA00C8"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	overdose_threshold = 20
	addiction_threshold = 10

/datum/reagent/drug/crank/on_mob_metabolize(mob/living/L)
	ADD_TRAIT(L, TRAIT_NOBLOCK, type)
	..()

/datum/reagent/drug/crank/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_NOBLOCK, type)
	..()

/datum/reagent/drug/crank/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(DT_PROB(2.5, delta_time))
		var/high_message = pick("You feel jittery.", "You feel like you gotta go fast.", "You feel like you need to step it up.")
		to_chat(M, span_notice("[high_message]"))
	if(prob(8))
		M.adjustBruteLoss(rand(1,4))
		M.Stun(5, 0)
		to_chat(M, span_notice("You stop to furiously scratch at your skin."))
	M.AdjustStun(-20 * REM * delta_time)
	M.AdjustKnockdown(-20 * REM * delta_time)
	M.AdjustUnconscious(-20 * REM * delta_time)
	M.AdjustImmobilized(-20 * REM * delta_time)
	M.AdjustParalyzed(-20 * REM * delta_time)
	M.adjustToxLoss(0.75 * REM * delta_time)
	M.adjustStaminaLoss(-18 * REM * delta_time)
	..()
	. = TRUE

/datum/reagent/drug/crank/overdose_process(mob/living/M, delta_time, times_fired)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2 * REM * delta_time)
	M.adjustToxLoss(2 * REM * delta_time, 0)
	M.adjustBruteLoss(2 * REM * delta_time, FALSE, FALSE, BODYTYPE_ORGANIC)
	..()
	. = TRUE

/datum/reagent/drug/crank/addiction_act_stage1(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5*REM)
	..()

/datum/reagent/drug/crank/addiction_act_stage2(mob/living/M)
	M.adjustToxLoss(5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/crank/addiction_act_stage3(mob/living/M)
	M.adjustBruteLoss(5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/crank/addiction_act_stage4(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3*REM)
	M.adjustToxLoss(5*REM, 0)
	M.adjustBruteLoss(5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/krokodil
	name = "Krokodil"
	description = "Cools and calms you down. If overdosed it will deal significant Brain and Toxin damage. If addicted it will begin to deal fatal amounts of Brute damage as the subject's skin falls off."
	reagent_state = LIQUID
	color = "#0064B4"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	overdose_threshold = 20
	addiction_threshold = 15


/datum/reagent/drug/krokodil/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	var/high_message = pick("You feel calm.", "You feel collected.", "You feel like you need to relax.")
	if(DT_PROB(2.5, delta_time))
		to_chat(M, span_notice("[high_message]"))
	..()

/datum/reagent/drug/krokodil/overdose_process(mob/living/M, delta_time, times_fired)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.25 * REM * delta_time)
	M.adjustToxLoss(0.25 * REM * delta_time, 0)
	..()
	. = TRUE

/datum/reagent/drug/krokodil/addiction_act_stage1(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2*REM)
	M.adjustToxLoss(2*REM, 0)
	..()
	. = 1

/datum/reagent/drug/krokodil/addiction_act_stage2(mob/living/M)
	if(prob(25))
		to_chat(M, span_danger("Your skin feels loose..."))
	..()

/datum/reagent/drug/krokodil/addiction_act_stage3(mob/living/M)
	if(prob(25))
		to_chat(M, span_danger("Your skin starts to peel away..."))
	M.adjustBruteLoss(3*REM, 0)
	..()
	. = 1

/datum/reagent/drug/krokodil/addiction_act_stage4(mob/living/carbon/human/M)
	CHECK_DNA_AND_SPECIES(M)
	if(ishumanbasic(M))
		if(!istype(M.dna.species, /datum/species/human/krokodil_addict))
			to_chat(M, span_userdanger("Your skin falls off easily!"))
			M.adjustBruteLoss(50*REM, 0) // holy shit your skin just FELL THE FUCK OFF
			M.set_species(/datum/species/human/krokodil_addict)
		else
			M.adjustBruteLoss(5*REM, 0)
	else
		to_chat(M, span_danger("Your skin peels and tears!"))
		M.adjustBruteLoss(5*REM, 0) // repeats 5 times and then you get over it

	..()
	. = 1

/datum/reagent/drug/methamphetamine
	name = "Methamphetamine"
	description = "Reduces stun times by about 300%, speeds the user up, and allows the user to quickly recover stamina while dealing a small amount of Brain damage. If overdosed the subject will move randomly, laugh randomly, drop items and suffer from Toxin and Brain damage. If addicted the subject will constantly jitter and drool, before becoming dizzy and losing motor control and eventually suffer heavy toxin damage."
	reagent_state = LIQUID
	color = "#FAFAFA"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	overdose_threshold = 20
	addiction_threshold = 10
	metabolization_rate = 0.75 * REAGENTS_METABOLISM

/datum/reagent/drug/methamphetamine/on_mob_metabolize(mob/living/L)
	..()
	if(L.client)
		L.client.give_award(/datum/award/achievement/misc/meth, L)

	L.add_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine)
	ADD_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	ADD_TRAIT(L, TRAIT_NOBLOCK, type)

/datum/reagent/drug/methamphetamine/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_NOBLOCK, type)
	REMOVE_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	L.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine)
	..()

/datum/reagent/drug/methamphetamine/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	var/high_message = pick("You feel hyper.", "You feel like you need to go faster.", "You feel like you can run the world.")
	if(DT_PROB(2.5, delta_time))
		to_chat(M, span_notice("[high_message]"))
	M.AdjustStun(-40 * REM * delta_time)
	M.AdjustKnockdown(-40 * REM * delta_time)
	M.AdjustUnconscious(-40 * REM * delta_time)
	M.AdjustParalyzed(-40 * REM * delta_time)
	M.AdjustImmobilized(-40 * REM * delta_time)
	M.adjustStaminaLoss(-40 * REM * delta_time, 0)
	M.drowsyness = max(M.drowsyness - (60 * REM * delta_time), 0)
	M.Jitter(2 * REM * delta_time)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1)
	if(DT_PROB(2.5, delta_time))
		M.emote(pick("twitch", "shiver"))
	..()
	. = TRUE

/datum/reagent/drug/methamphetamine/overdose_process(mob/living/M, delta_time, times_fired)
	if(!HAS_TRAIT(M, TRAIT_IMMOBILIZED) && !ismovable(M.loc))
		for(var/i in 1 to round(4 * REM * delta_time, 1))
			step(M, pick(GLOB.cardinals))
	if(DT_PROB(10, delta_time))
		M.emote("laugh")
	if(DT_PROB(18, delta_time))
		M.visible_message(span_danger("[M]'s hands flip out and flail everywhere!"))
		M.drop_all_held_items()
	..()
	M.adjustToxLoss(1 * REM * delta_time, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, (rand(5, 10) / 10) * REM * delta_time)
	. = TRUE

/datum/reagent/drug/methamphetamine/addiction_act_stage1(mob/living/M)
	M.Jitter(5)
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/methamphetamine/addiction_act_stage2(mob/living/M)
	M.Jitter(10)
	M.Dizzy(10)
	if(prob(30))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/methamphetamine/addiction_act_stage3(mob/living/M)
	if(!HAS_TRAIT(M, TRAIT_IMMOBILIZED) && !ismovable(M.loc))
		for(var/i = 0, i < 4, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(15)
	M.Dizzy(15)
	if(prob(40))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/methamphetamine/addiction_act_stage4(mob/living/carbon/human/M)
	if(!HAS_TRAIT(M, TRAIT_IMMOBILIZED) && !ismovable(M.loc))
		for(var/i = 0, i < 8, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(20)
	M.Dizzy(20)
	M.adjustToxLoss(5, 0)
	if(prob(50))
		M.emote(pick("twitch","drool","moan"))
	..()
	. = 1

/datum/reagent/drug/bath_salts
	name = "Bath Salts"
	description = "Makes you impervious to stuns and grants a stamina regeneration buff, but you will be a nearly uncontrollable tramp-bearded raving lunatic."
	reagent_state = LIQUID
	color = "#FAFAFA"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	overdose_threshold = 20
	addiction_threshold = 10
	taste_description = "salt" // because they're bathsalts?
	var/datum/martial_art/psychotic_brawling/brawling

/datum/reagent/drug/bath_salts/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_STUNIMMUNE, type)
	ADD_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	ADD_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	ADD_TRAIT(L, TRAIT_NOSTAMCRIT, type)
	ADD_TRAIT(L, TRAIT_NOLIMBDISABLE, type)
	ADD_TRAIT(L, TRAIT_NOBLOCK, type)
	brawling = new(null)
	if(!brawling.teach(L, TRUE))
		QDEL_NULL(brawling)

/datum/reagent/drug/bath_salts/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_STUNIMMUNE, type)
	REMOVE_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	REMOVE_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	REMOVE_TRAIT(L, TRAIT_NOSTAMCRIT, type)
	REMOVE_TRAIT(L, TRAIT_NOLIMBDISABLE, type)
	REMOVE_TRAIT(L, TRAIT_NOBLOCK, type)
	if(brawling)
		brawling.remove(L)
		QDEL_NULL(brawling)
	..()

/datum/reagent/drug/bath_salts/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	var/high_message = pick("You feel amped up.", "You feel ready.", "You feel like you can push it to the limit.")
	if(DT_PROB(2.5, delta_time))
		to_chat(M, span_notice("[high_message]"))
	M.adjustStaminaLoss(-5 * REM * delta_time, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 4 * REM * delta_time)
	M.hallucination += 5 * REM * delta_time
	if(!HAS_TRAIT(M, TRAIT_IMMOBILIZED) && !ismovable(M.loc))
		step(M, pick(GLOB.cardinals))
		step(M, pick(GLOB.cardinals))
	..()
	. = TRUE

/datum/reagent/drug/bath_salts/overdose_process(mob/living/M, delta_time, times_fired)
	M.hallucination += 5 * REM * delta_time
	if(!HAS_TRAIT(M, TRAIT_IMMOBILIZED) && !ismovable(M.loc))
		for(var/i in 1 to round(8 * REM * delta_time, 1))
			step(M, pick(GLOB.cardinals))
	if(DT_PROB(10, delta_time))
		M.emote(pick("twitch","drool","moan"))
	if(DT_PROB(28, delta_time))
		M.drop_all_held_items()
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage1(mob/living/M)
	M.hallucination += 10
	if(!HAS_TRAIT(M, TRAIT_IMMOBILIZED) && !ismovable(M.loc))
		for(var/i = 0, i < 8, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(5)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage2(mob/living/M)
	M.hallucination += 20
	if(!HAS_TRAIT(M, TRAIT_IMMOBILIZED) && !ismovable(M.loc))
		for(var/i = 0, i < 8, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(10)
	M.Dizzy(10)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
	if(prob(30))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage3(mob/living/M)
	M.hallucination += 30
	if(!HAS_TRAIT(M, TRAIT_IMMOBILIZED) && !ismovable(M.loc))
		for(var/i = 0, i < 12, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(15)
	M.Dizzy(15)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
	if(prob(40))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage4(mob/living/carbon/human/M)
	M.hallucination += 30
	if(!HAS_TRAIT(M, TRAIT_IMMOBILIZED) && !ismovable(M.loc))
		for(var/i = 0, i < 16, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(50)
	M.Dizzy(50)
	M.adjustToxLoss(5, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
	if(prob(50))
		M.emote(pick("twitch","drool","moan"))
	..()
	. = 1

/datum/reagent/drug/aranesp
	name = "Aranesp"
	description = "Amps you up, gets you going, and rapidly restores stamina damage. Side effects include breathlessness and toxicity."
	reagent_state = LIQUID
	color = "#78FFF0"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY

/datum/reagent/drug/aranesp/on_mob_metabolize(mob/living/L)
	ADD_TRAIT(L, TRAIT_NOBLOCK, type)
	..()

/datum/reagent/drug/aranesp/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_NOBLOCK, type)
	..()

/datum/reagent/drug/aranesp/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	var/high_message = pick("You feel amped up.", "You feel ready.", "You feel like you can push it to the limit.")
	if(DT_PROB(2.5, delta_time))
		to_chat(M, span_notice("[high_message]"))
	M.adjustStaminaLoss(-18 * REM * delta_time, 0)
	M.adjustToxLoss(0.5 * REM * delta_time, 0)
	if(DT_PROB(30, delta_time))
		M.losebreath++
		M.adjustOxyLoss(1, 0)
	..()
	. = TRUE

/datum/reagent/drug/happiness
	name = "Happiness"
	description = "Fills you with ecstasic numbness and causes minor brain damage. Highly addictive. If overdosed causes sudden mood swings."
	reagent_state = LIQUID
	color = "#FFF378"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	addiction_threshold = 10
	overdose_threshold = 20

/datum/reagent/drug/happiness/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_FEARLESS, type)
	SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug)

/datum/reagent/drug/happiness/on_mob_delete(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_FEARLESS, type)
	SEND_SIGNAL(L, COMSIG_CLEAR_MOOD_EVENT, "happiness_drug")
	..()

/datum/reagent/drug/happiness/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.jitteriness = 0
	M.confused = 0
	M.disgust = 0
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.2 * REM * delta_time)
	..()
	. = TRUE

/datum/reagent/drug/happiness/overdose_process(mob/living/M, delta_time, times_fired)
	if(DT_PROB(16, delta_time))
		var/reaction = rand(1,3)
		switch(reaction)
			if(1)
				M.emote("laugh")
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug_good_od)
			if(2)
				M.emote("sway")
				M.Dizzy(25)
			if(3)
				M.emote("frown")
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug_bad_od)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5 * REM * delta_time)
	..()
	. = TRUE

/datum/reagent/drug/happiness/addiction_act_stage1(mob/living/M)// all work and no play makes jack a dull boy
	var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
	mood?.setSanity(min(mood.sanity, SANITY_DISTURBED))
	M.Jitter(5)
	if(prob(20))
		M.emote(pick("twitch","laugh","frown"))
	..()

/datum/reagent/drug/happiness/addiction_act_stage2(mob/living/M)
	var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
	mood?.setSanity(min(mood.sanity, SANITY_UNSTABLE))
	M.Jitter(10)
	if(prob(30))
		M.emote(pick("twitch","laugh","frown"))
	..()

/datum/reagent/drug/happiness/addiction_act_stage3(mob/living/M)
	var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
	mood?.setSanity(min(mood.sanity, SANITY_CRAZY))
	M.Jitter(15)
	if(prob(40))
		M.emote(pick("twitch","laugh","frown"))
	..()

/datum/reagent/drug/happiness/addiction_act_stage4(mob/living/carbon/human/M)
	var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
	mood?.setSanity(SANITY_INSANE)
	M.Jitter(20)
	if(prob(50))
		M.emote(pick("twitch","laugh","frown"))
	..()
	. = 1

//I had to do too much research on this to make this a thing. Hopefully the FBI won't kick my door down.
/datum/reagent/drug/ketamine
	name = "Ketamine"
	description = "A heavy duty tranquilizer found to also invoke feelings of euphoria, and assist with pain. Popular at parties and amongst small frogmen who drive Honda Civics."
	reagent_state = LIQUID
	color = "#c9c9c9"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	addiction_threshold = 8
	overdose_threshold = 16

/datum/reagent/drug/ketamine/on_mob_metabolize(mob/living/L)
	ADD_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	. = ..()

/datum/reagent/drug/ketamine/on_mob_delete(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	. = ..()

/datum/reagent/drug/ketamine/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	//Friendly Reminder: Ketamine is a tranquilizer and will sleep you.
	switch(current_cycle)
		if(10)
			to_chat(M, span_warning("You start to feel tired...") )
		if(11 to 25)
			M.drowsyness += 1 * REM * delta_time
		if(26 to INFINITY)
			M.Sleeping(60 * REM * delta_time, 0)
			. = TRUE
	//Providing a Mood Boost
	M.confused -= 3 * REM * delta_time
	M.jitteriness -= 5 * REM * delta_time
	M.disgust -= 3 * REM * delta_time
	//Ketamine is also a dissociative anasthetic which means Hallucinations!
	M.hallucination += 5 * REM * delta_time
	..()

/datum/reagent/drug/ketamine/overdose_process(mob/living/M)
	var/obj/item/organ/brain/B = M.get_organ_by_type(/obj/item/organ/brain)
	var/gained_trauma = FALSE
	if(!gained_trauma)
		B.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_SURGERY)
		gained_trauma = TRUE
	M.hallucination += 10
	//Uh Oh Someone is tired
	if(prob(40))
		if(HAS_TRAIT(M, TRAIT_IGNOREDAMAGESLOWDOWN))
			REMOVE_TRAIT(M, TRAIT_IGNOREDAMAGESLOWDOWN, type)
		if(prob(33))
			to_chat(M, span_warning("Your limbs begin to feel heavy..."))
		else if(prob(33))
			to_chat(M, span_warning("It feels hard to move..."))
		else
			to_chat(M, span_warning("You feel like you your limbs won't move..."))
		M.drop_all_held_items()
		M.Dizzy(5)
	..()

//Addiction Gradient
/datum/reagent/drug/ketamine/addiction_act_stage1(mob/living/M)
	if(prob(20))
		M.drop_all_held_items()
		M.Jitter(2)
	..()

/datum/reagent/drug/ketamine/addiction_act_stage2(mob/living/M)
	if(prob(30))
		M.drop_all_held_items()
		M.adjustToxLoss(2*REM, 0)
		. = 1
		M.Jitter(3)
		M.Dizzy(3)
	..()

/datum/reagent/drug/ketamine/addiction_act_stage3(mob/living/M)
	if(prob(40))
		M.drop_all_held_items()
		M.adjustToxLoss(3*REM, 0)
		. = 1
		M.Jitter(4)
		M.Dizzy(4)
	..()


/// Can bring a corpse back to life temporarily (if heart is intact)
/// Also prevents dying
/datum/reagent/drug/nooartrium
	name = "Nooartrium"
	description = "A reagent that is known to stimulate the heart in a dead patient, temporarily bringing back recently dead patients at great cost to their heart."
	overdose_threshold = 25
	color = "#280000"
	self_consuming = TRUE //No pesky liver shenanigans
	///If we brought someone back from the dead
	var/back_from_the_dead = FALSE
	var/consequences  = FALSE // This can't be healthy?
	var/time_from_consumption = 0 // For tracking consequences


/datum/reagent/drug/nooartrium/on_mob_add(mob/living/affected_mob)
	if(affected_mob.suiciding)
		return
	var/obj/item/organ/heart/heart = affected_mob.get_organ_slot(ORGAN_SLOT_HEART)
	if(!heart || heart.organ_flags & ORGAN_FAILING)
		return
	ADD_TRAIT(affected_mob, TRAIT_NOCRITDAMAGE, FROM_NOOARTRIUM)
	ADD_TRAIT(affected_mob, TRAIT_NODEATH, FROM_NOOARTRIUM)
	ADD_TRAIT(affected_mob, TRAIT_NOHARDCRIT, FROM_NOOARTRIUM)
	ADD_TRAIT(affected_mob, TRAIT_NOSOFTCRIT, FROM_NOOARTRIUM)
	ADD_TRAIT(affected_mob, TRAIT_STABLEHEART, FROM_NOOARTRIUM)
	ADD_TRAIT(affected_mob, TRAIT_STUNRESISTANCE, FROM_NOOARTRIUM)
	ADD_TRAIT(affected_mob, TRAIT_NOSTAMCRIT, FROM_NOOARTRIUM) // Moving corpses don't get tired
	ADD_TRAIT(affected_mob, TRAIT_IGNOREDAMAGESLOWDOWN, FROM_NOOARTRIUM)
	if(affected_mob.stat == DEAD)
		back_from_the_dead = TRUE
	affected_mob.set_stat(CONSCIOUS) // This doesn't touch knocked out
	affected_mob.updatehealth()
	affected_mob.update_sight()
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, STAT_TRAIT)
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, CRIT_HEALTH_TRAIT) // Normally updated using set_health() - we don't want to adjust health, and NOHARDCRIT blocks it being re-added, but not removed
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT) // Prevents knockout by oxyloss
	affected_mob.set_resting(FALSE) // Please get up. No one wants a death throes juggernaut lying on the floor
	affected_mob.SetAllImmobility(0)
	if(!back_from_the_dead)
		to_chat(affected_mob, span_userdanger("You feel your heart start beating with incredible strength!"))
		return
	affected_mob.grab_ghost(force = FALSE) //Shoves them back into their freshly reanimated corpse.
	affected_mob.emote("gasp")
	to_chat(affected_mob, span_userdanger("You feel your heart start beating with incredible strength, forcing your battered body to move!"))


/datum/reagent/drug/nooartrium/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if (!consequences)
		if (time_from_consumption > 180 SECONDS)
			consequences = TRUE
		else
			time_from_consumption += delta_time SECONDS
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, CRIT_HEALTH_TRAIT)
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, (((affected_mob.getBruteLoss() + affected_mob.getFireLoss()) / 200) + 0.5)* delta_time/6)
	var/obj/item/organ/heart/heart = affected_mob.get_organ_slot(ORGAN_SLOT_HEART)
	if(!heart || heart.organ_flags & ORGAN_FAILING)
		on_mob_delete(affected_mob)
	else
		heart.maxHealth -= 0.25 * delta_time/3


/datum/reagent/drug/nooartrium/on_mob_delete(mob/living/carbon/affected_mob)
	. = ..()
	var/obj/item/organ/heart/heart = affected_mob.get_organ_slot(ORGAN_SLOT_HEART)
	remove_buffs(affected_mob)
	if(affected_mob.health < -300 || !heart || heart.organ_flags & ORGAN_FAILING)
		affected_mob.add_splatter_floor(get_turf(affected_mob))
		qdel(heart)
		affected_mob.visible_message(span_boldwarning("[affected_mob]'s heart explodes!"))
	else if(consequences)
		affected_mob.set_heartattack(TRUE)
	time_from_consumption = 0 // Not sure if this is needed, not gonna risk it

/datum/reagent/drug/nooartrium/overdose_start(mob/living/carbon/affected_mob)
	. = ..()
	to_chat(affected_mob, span_userdanger("You feel your heart tearing itself apart as it tries to beat stronger!"))
	affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, 20)
	affected_mob.SetParalyzed(6 SECONDS)
	consequences = TRUE


/datum/reagent/drug/nooartrium/proc/remove_buffs(mob/living/carbon/affected_mob)
	to_chat(affected_mob, span_userdanger("You feel your heart grow calm."))
	REMOVE_TRAIT(affected_mob, TRAIT_NOCRITDAMAGE, FROM_NOOARTRIUM)
	REMOVE_TRAIT(affected_mob, TRAIT_NODEATH, FROM_NOOARTRIUM)
	REMOVE_TRAIT(affected_mob, TRAIT_NOHARDCRIT, FROM_NOOARTRIUM)
	REMOVE_TRAIT(affected_mob, TRAIT_NOSOFTCRIT, FROM_NOOARTRIUM)
	REMOVE_TRAIT(affected_mob, TRAIT_STABLEHEART, FROM_NOOARTRIUM)
	REMOVE_TRAIT(affected_mob, TRAIT_STUNRESISTANCE, FROM_NOOARTRIUM)
	REMOVE_TRAIT(affected_mob, TRAIT_NOSTAMCRIT, FROM_NOOARTRIUM)
	REMOVE_TRAIT(affected_mob, TRAIT_IGNOREDAMAGESLOWDOWN, FROM_NOOARTRIUM)
	affected_mob.update_sight()
