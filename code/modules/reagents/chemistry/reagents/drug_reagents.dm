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
	addiction_types = list(/datum/addiction/hallucinogens = 10) //4 per 2 seconds

/datum/reagent/drug/space_drugs/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.set_drugginess(30 SECONDS * REM * delta_time)
	if(isturf(affected_mob.loc) && !isspaceturf(affected_mob.loc) && !HAS_TRAIT(affected_mob, TRAIT_IMMOBILIZED) && DT_PROB(5, delta_time))
		step(affected_mob, pick(GLOB.cardinals))

	if(DT_PROB(3.5, delta_time))
		affected_mob.emote(pick("twitch", "drool", "moan", "giggle"))

/datum/reagent/drug/space_drugs/overdose_start(mob/living/carbon/affected_mob)
	to_chat(affected_mob, span_userdanger("You start tripping hard!"))
	SEND_SIGNAL(affected_mob, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/overdose, name)

/datum/reagent/drug/space_drugs/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/hallucination_duration_in_seconds = (affected_mob.get_timed_status_effect_duration(/datum/status_effect/hallucination) / 10)
	if(hallucination_duration_in_seconds < volume && DT_PROB(10, delta_time))
		affected_mob.adjust_hallucinations(10 SECONDS)

/datum/reagent/drug/nicotine
	name = "Nicotine"
	description = "Slightly reduces stun times. If overdosed it will deal toxin and oxygen damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST | CHEMICAL_GOAL_BARTENDER_SERVING
	taste_description = "smoke"
	trippy = FALSE
	overdose_threshold=15
	metabolization_rate = 0.125 * REAGENTS_METABOLISM
	addiction_types = list(/datum/addiction/nicotine = 15) // 6 per 2 seconds

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
	description = "Reduces stun times by about 200%. If overdosed it will deal significant Toxin, Brute and Brain damage."
	reagent_state = LIQUID
	color = "#FA00C8"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	overdose_threshold = 20
	addiction_types = list(/datum/addiction/stimulants = 14) //5.6 per 2 seconds
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

/datum/reagent/drug/krokodil
	name = "Krokodil"
	description = "Cools and calms you down. If overdosed it will deal significant Brain and Toxin damage. If addicted it will begin to deal fatal amounts of Brute damage as the subject's skin falls off."
	reagent_state = LIQUID
	color = "#0064B4"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	overdose_threshold = 20
	addiction_types = list(/datum/addiction/opioids = 18) //7.2 per 2 seconds

/datum/reagent/drug/krokodil/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(2.5, delta_time))
		to_chat(affected_mob, span_notice(pick("You feel calm.", "You feel collected.", "You feel like you need to relax.")))
	if(current_cycle == 35)
		if(!istype(affected_mob.dna.species, /datum/species/human/krokodil_addict))
			to_chat(affected_mob, span_userdanger("Your skin falls off!"))
			affected_mob.adjustBruteLoss(50 * REM, updating_health = FALSE) // holy shit your skin just FELL THE FUCK OFF
			affected_mob.set_species(/datum/species/human/krokodil_addict)
			if(affected_mob.adjustBruteLoss(50 * REM, updating_health = FALSE)) // holy shit your skin just FELL THE FUCK OFF
				return UPDATE_MOB_HEALTH

/datum/reagent/drug/krokodil/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update = FALSE
	need_mob_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.25 * REM * delta_time)
	need_mob_update += affected_mob.adjustToxLoss(0.25 * REM * delta_time, updating_health = FALSE)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/methamphetamine
	name = "Methamphetamine"
	description = "Reduces stun times by about 300%, speeds the user up, and allows the user to quickly recover stamina while dealing a small amount of Brain damage. If overdosed the subject will move randomly, laugh randomly, drop items and suffer from Toxin and Brain damage. If addicted the subject will constantly jitter and drool, before becoming dizzy and losing motor control and eventually suffer heavy toxin damage."
	reagent_state = LIQUID
	color = "#FAFAFA"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	overdose_threshold = 20
	addiction_types = list(/datum/addiction/stimulants = 12) //4.8 per 2 seconds
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
	affected_mob.set_drowsiness_if_lower(-8 SECONDS * REM * delta_time)
	affected_mob.set_jitter_if_lower(4 SECONDS * REM * delta_time)
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

/datum/reagent/drug/bath_salts
	name = "Bath Salts"
	description = "Makes you impervious to stuns and grants a stamina regeneration buff, but you will be a nearly uncontrollable tramp-bearded raving lunatic."
	reagent_state = LIQUID
	color = "#FAFAFA"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	overdose_threshold = 20
	addiction_types = list(/datum/addiction/stimulants = 25) //8 per 2 seconds
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
	affected_mob.adjust_hallucinations(10 SECONDS * REM * delta_time)
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

	affected_mob.adjust_hallucinations(10 SECONDS * REM * delta_time)

/datum/reagent/drug/aranesp
	name = "Aranesp"
	description = "Amps you up, gets you going, and rapidly restores stamina damage. Side effects include breathlessness and toxicity."
	reagent_state = LIQUID
	color = "#78FFF0"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolized_traits = list(TRAIT_NOBLOCK)
	addiction_types = list(/datum/addiction/stimulants = 8)

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
	addiction_types = list(/datum/addiction/hallucinogens = 18)
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
	affected_mob.remove_status_effect(/datum/status_effect/jitter)
	affected_mob.remove_status_effect(/datum/status_effect/confusion)
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
				affected_mob.set_dizzy_if_lower(50 SECONDS)

	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5 * REM * delta_time)

//I had to do too much research on this to make this a thing. Hopefully the FBI won't kick my door down.
/datum/reagent/drug/ketamine
	name = "Ketamine"
	description = "A heavy duty tranquilizer found to also invoke feelings of euphoria, and assist with pain. Popular at parties and amongst small frogmen who drive Honda Civics."
	reagent_state = LIQUID
	color = "#c9c9c9"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	addiction_types = list(/datum/addiction/hallucinogens = 18)
	overdose_threshold = 16
	metabolized_traits = list(TRAIT_IGNOREDAMAGESLOWDOWN)

/datum/reagent/drug/ketamine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	//Friendly Reminder: Ketamine is a tranquilizer and will sleep you.
	switch(current_cycle)
		if(10)
			to_chat(affected_mob, span_warning("You start to feel tired..."))
		if(11 to 25)
			affected_mob.adjust_drowsiness(2 SECONDS * REM * delta_time)
		if(26 to INFINITY)
			affected_mob.Sleeping(60 * REM * delta_time)

	//Providing a Mood Boost
	affected_mob.adjust_confusion(-3 SECONDS * REM * delta_time)
	affected_mob.adjust_jitter(-10 SECONDS * REM * delta_time)
	affected_mob.disgust -= 3 * REM * delta_time
	//Ketamine is also a dissociative anasthetic which means Hallucinations!
	affected_mob.adjust_hallucinations(10 SECONDS * REM * delta_time)

/datum/reagent/drug/ketamine/overdose_process(mob/living/carbon/affected_mob)
	. = ..()
	var/obj/item/organ/brain/brain = affected_mob.get_organ_by_type(/obj/item/organ/brain)
	brain?.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_SURGERY)

	affected_mob.adjust_hallucinations(20 SECONDS)
	//Uh Oh Someone is tired
	if(prob(40))
		if(HAS_TRAIT(affected_mob, TRAIT_IGNOREDAMAGESLOWDOWN))
			REMOVE_TRAIT(affected_mob, TRAIT_IGNOREDAMAGESLOWDOWN, type)

		to_chat(affected_mob, span_warning(pick("Your limbs begin to feel heavy...", "It feels hard to move...", "You feel like you your limbs won't move...")))

		affected_mob.drop_all_held_items()
		affected_mob.set_dizzy_if_lower(10 SECONDS)

/// Can bring a corpse back to life temporarily (if heart is intact)
/// Also prevents dying
/datum/reagent/drug/nooartrium
	name = "Nooartrium"
	description = "A reagent that is known to stimulate the heart in a dead patient, temporarily bringing back recently dead patients at great cost to their heart."
	overdose_threshold = 25
	color = "#280000"
	self_consuming = TRUE //No pesky liver shenanigans
	metabolization_rate = REAGENTS_METABOLISM
	added_traits = list(
		TRAIT_NOCRITDAMAGE,
		TRAIT_NODEATH,
		TRAIT_NOHARDCRIT,
		TRAIT_NOSOFTCRIT,
		TRAIT_STABLEHEART,
		TRAIT_STUNRESISTANCE,
		TRAIT_NOSTAMCRIT,
		TRAIT_IGNOREDAMAGESLOWDOWN,
	)
	///If we brought someone back from the dead
	var/back_from_the_dead = FALSE
	var/list/zombie_sounds = list(
		'sound/hallucinations/growl1.ogg',
		'sound/hallucinations/growl2.ogg',
		'sound/hallucinations/growl3.ogg'
	)

/datum/reagent/drug/nooartrium/on_mob_add(mob/living/carbon/affected_mob)
	//If they aren't a mob that this should affect
	if(!ishuman(affected_mob))
		return
	. = ..()
	var/mob/living/carbon/human/human_mob = affected_mob
	if((human_mob.dna.species.reagent_tag & PROCESS_SYNTHETIC))
		return
	if(affected_mob.suiciding)
		return

	//If they don't have a functional heart or are so damaged the drug would stop working
	var/obj/item/organ/heart/heart = affected_mob.get_organ_slot(ORGAN_SLOT_HEART)
	if(!heart || (heart.organ_flags & ORGAN_FAILING) || affected_mob.health <= -300)
		return

	if(affected_mob.stat == DEAD)
		back_from_the_dead = TRUE
	affected_mob.set_stat(CONSCIOUS) // This doesn't touch knocked out
	affected_mob.updatehealth()
	affected_mob.update_sight()
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, STAT_TRAIT)
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, CRIT_HEALTH_TRAIT) // Normally updated using set_health() - we don't want to adjust health, and NOHARDCRIT blocks it being re-added, but not removed
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT) // Prevents knockout by oxyloss
	affected_mob.SetAllImmobility(0)
	playsound(affected_mob, 'sound/hallucinations/wail.ogg', 50, TRUE, 10)
	if(!back_from_the_dead)
		to_chat(affected_mob, span_userdanger("You feel your heart start beating with incredible strength!"))
		return
	affected_mob.grab_ghost(force = FALSE) //Shoves them back into their freshly reanimated corpse.
	affected_mob.emote("gasp")
	to_chat(affected_mob, span_userdanger("You feel your heart start beating with incredible strength, forcing your battered body to move!"))

/datum/reagent/drug/nooartrium/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/obj/item/organ/heart/heart = affected_mob.get_organ_slot(ORGAN_SLOT_HEART)

	//If the heart has totally failed, or their body has taken 100 damage past the point where full death normally occurs
	if(!heart || (heart.organ_flags & ORGAN_FAILING) || affected_mob.health <= -300)
		holder.remove_reagent(/datum/reagent/drug/nooartrium, 1000)
		return

	//After 15 cycles heart damage will overtake the only heart med we have, this exponential growth ensures the drug cannot keep going indefinitely
	affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, (0.1 * current_cycle))

	if(prob(15))
		playsound(affected_mob, pick(zombie_sounds), 50, TRUE, 10)

/datum/reagent/drug/nooartrium/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	playsound(affected_mob, 'sound/hallucinations/far_noise.ogg', 50, TRUE, 10)
	affected_mob.update_sight()

	//Make sure heart removal isn't the reason the drug stopped working
	var/obj/item/organ/heart/heart = affected_mob.get_organ_slot(ORGAN_SLOT_HEART)
	if(heart)
		//A spike of heart damage proportional to the amount of time the drug was active.
		affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, max(current_cycle, 25))

		//If the mob was pushed to their absolute limits, or the above spike caused organ failure, the heart explodes
		if(affected_mob.health <= -300 || heart.organ_flags & ORGAN_FAILING)
			affected_mob.add_splatter_floor(get_turf(affected_mob))
			qdel(heart)
			affected_mob.visible_message(span_boldwarning("[affected_mob]'s heart explodes!"))

/datum/reagent/drug/nooartrium/overdose_start(mob/living/carbon/affected_mob)
	. = ..()
	to_chat(affected_mob, span_userdanger("You feel your heart tearing itself apart as it tries to beat stronger!"))
	affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, 20)
