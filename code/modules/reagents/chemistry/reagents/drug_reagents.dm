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
	var/hallucination_duration_in_seconds = (affected_mob.get_timed_status_effect_duration(/datum/status_effect/hallucination) / 10)
	if(hallucination_duration_in_seconds < volume && DT_PROB(10, delta_time))
		affected_mob.adjust_hallucinations(10 SECONDS)

/datum/reagent/drug/space_drugs/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.client?.give_award(/datum/award/achievement/misc/high, affected_mob)

/datum/reagent/drug/cannabis
	name = "Cannabis"
	description = "A psychoactive drug from the Cannabis plant used for recreational purposes."
	color = "#059033"
	overdose_threshold = INFINITY
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST

/datum/reagent/drug/cannabis/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.apply_status_effect(/datum/status_effect/stoned)
	if(DT_PROB(5, delta_time))
		var/smoke_message = pick("You feel relaxed.","You feel calmed.","Your mouth feels dry.","You could use some water.","Your heart beats quickly.","You feel clumsy.","You crave junk food.","You notice you've been moving more slowly.")
		to_chat(affected_mob, span_notice("[smoke_message]"))
	if(DT_PROB(10, delta_time))
		affected_mob.emote(pick("smile","laugh","giggle"))
	affected_mob.adjust_nutrition(-0.15 * REM * delta_time) //munchies
	if(DT_PROB(16, delta_time) && affected_mob.body_position == LYING_DOWN && !affected_mob.IsSleeping()) //chance to fall asleep if lying down
		to_chat(affected_mob, span_warning("You doze off..."))
		affected_mob.Sleeping(10 SECONDS)
	if(DT_PROB(16, delta_time) && affected_mob.buckled && affected_mob.body_position != LYING_DOWN && !affected_mob.IsParalyzed()) //chance to be couchlocked if sitting
		to_chat(affected_mob, span_warning("It's too comfy to move..."))
		affected_mob.Paralyze(10 SECONDS)

/datum/reagent/drug/cannabis/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.client?.give_award(/datum/award/achievement/misc/stoned, affected_mob)
	if(!affected_mob.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = affected_mob.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	game_plane_master_controller.add_filter("cannabis_blur", 1, list("type" = "radial_blur", "size" = 0))

	for(var/filter in game_plane_master_controller.get_filters("cannabis_blur"))
		animate(filter, loop = -1, size = 0.02, time = 2 SECONDS, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
		animate(filter, loop = -1, size = 0.05, time = 4 SECONDS, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
		animate(size = 0, time = 6 SECONDS, easing = SINE_EASING)

/datum/reagent/drug/cannabis/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	if(!affected_mob.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = affected_mob.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	game_plane_master_controller.remove_filter("cannabis_blur")


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
	if(!affected_mob.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = affected_mob.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	game_plane_master_controller.add_filter("meth_blur", 1, list("type" = "angular_blur", "size" = 0))

	for(var/filter in game_plane_master_controller.get_filters("meth_blur"))
		animate(filter, loop = -1, size = 10.5, time = 6 SECONDS, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
		animate(size = 0, time = 8 SECONDS, easing = SINE_EASING)

/datum/reagent/drug/methamphetamine/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine)
	if(!affected_mob.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = affected_mob.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	game_plane_master_controller.remove_filter("meth_blur")

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
	affected_mob.set_jitter_if_lower(4 SECONDS * REM * delta_time)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1)
	affected_mob.apply_status_effect(/datum/status_effect/tweaked)

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

	if(!affected_mob.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = affected_mob.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	game_plane_master_controller.add_filter("salt_blur", 1, list("type" = "radial_blur", "size" = 0))

	for(var/filter in game_plane_master_controller.get_filters("salt_blur"))
		animate(filter, loop = -1, size = 1.5, time = 4 SECONDS, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
		animate(size = 0, time = 8 SECONDS, easing = SINE_EASING)


/datum/reagent/drug/bath_salts/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	if(brawling)
		brawling.remove(affected_mob)
		QDEL_NULL(brawling)

	if(!affected_mob.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = affected_mob.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	game_plane_master_controller.remove_filter("salt_blur")

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
	affected_mob.apply_status_effect(/datum/status_effect/tweaked)
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
	affected_mob.apply_status_effect(/datum/status_effect/tweaked)
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

	if(!affected_mob.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = affected_mob.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	game_plane_master_controller.add_filter("happiness_blur", 1, list("type" = "radial_blur", "size" = 0))

	for(var/filter in game_plane_master_controller.get_filters("happiness_blur"))
		animate(filter, loop = -1, size = 0.0557, time = 4 SECONDS, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
		animate(size = 0, time = 6 SECONDS, easing = SINE_EASING)

/datum/reagent/drug/happiness/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	if(!affected_mob.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = affected_mob.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	game_plane_master_controller.remove_filter("happiness_blur")


/datum/reagent/drug/happiness/on_mob_delete(mob/living/carbon/affected_mob)
	. = ..()
	SEND_SIGNAL(affected_mob, COMSIG_CLEAR_MOOD_EVENT, "happiness_drug")

/datum/reagent/drug/happiness/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.remove_status_effect(/datum/status_effect/jitter)
	affected_mob.apply_status_effect(/datum/status_effect/glaggle)
	affected_mob.confused = 0
	affected_mob.disgust = 0
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.2 * REM * delta_time)
	affected_mob.adjust_hallucinations(3 SECONDS * REM * delta_time)

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
			affected_mob.drowsyness += 1 * REM * delta_time
		if(26 to INFINITY)
			affected_mob.Sleeping(60 * REM * delta_time)

	//Providing a Mood Boost
	affected_mob.confused -= 3 * REM * delta_time
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
		affected_mob.Dizzy(5)

/// Can bring a corpse back to life temporarily (if heart is intact)
/// Also prevents dying
/datum/reagent/drug/nooartrium
	name = "Nooartrium"
	description = "A reagent that is known to stimulate the heart in a dead patient, temporarily bringing back recently dead patients at great cost to their heart."
	overdose_threshold = 25
	color = "#280000"
	self_consuming = TRUE //No pesky liver shenanigans
	metabolization_rate = REAGENTS_METABOLISM
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY // This will be fine since Nooart is fixed.
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

/datum/reagent/drug/mushroomhallucinogen
	name = "Mushroom Hallucinogen"
	description = "A strong hallucinogenic drug derived from certain species of mushroom."
	color = "#E700E7" // rgb: 231, 0, 231
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	taste_description = "mushroom"
	overdose_threshold = 30
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	addiction_types = list(/datum/addiction/hallucinogens = 12)


/datum/reagent/drug/mushroomhallucinogen/on_mob_life(mob/living/carbon/psychonaut, delta_time, times_fired)
	. = ..()
	psychonaut.adjust_hallucinations(10 SECONDS * REM * delta_time) // hallucinogen makes you hallucinate finally
	if(!psychonaut.slurring)
		psychonaut.slurring = 1 * REM * delta_time
	SEND_SIGNAL(psychonaut, COMSIG_ADD_MOOD_EVENT, "tripping", /datum/mood_event/high, name)
	switch(current_cycle)
		if(2 to 6)
			if(DT_PROB(5, delta_time))
				psychonaut.emote(pick("twitch","giggle"))
		if(6 to 11)
			psychonaut.set_jitter_if_lower(20 SECONDS * REM * delta_time)
			if(DT_PROB(10, delta_time))
				psychonaut.emote(pick("twitch","giggle"))
		if (11 to INFINITY)
			psychonaut.set_jitter_if_lower(40 SECONDS * REM * delta_time)
			if(DT_PROB(16, delta_time))
				psychonaut.emote(pick("twitch","giggle"))

/datum/reagent/drug/mushroomhallucinogen/on_mob_metabolize(mob/living/psychonaut)
	. = ..()

	SEND_SIGNAL(psychonaut, COMSIG_ADD_MOOD_EVENT, "tripping", /datum/mood_event/high, name)
	if(!psychonaut.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = psychonaut.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	// Info for non-matrix plebs like me!

	// This doesn't change the RGB matrixes directly at all. Instead, it shifts all the colors' Hue by 33%,
	// Shifting them up the color wheel, turning R to G, G to B, B to R, making a psychedelic effect.
	// The second moves them two colors up instead, turning R to B, G to R, B to G.
	// The third does a full spin, or resets it back to normal.
	// Imagine a triangle on the color wheel with the points located at the color peaks, rotating by 90 degrees each time.
	// The value with decimals is the Hue. The rest are Saturation, Luminosity, and Alpha, though they're unused here.

	// The filters were initially named _green, _blue, _red, despite every filter changing all the colors. It caused me a 2-years-long headache.

	var/list/col_filter_identity = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.000,0,0,0)
	var/list/col_filter_shift_once = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.333,0,0,0)
	var/list/col_filter_shift_twice = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.666,0,0,0)
	var/list/col_filter_reset = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 1.000,0,0,0) //visually this is identical to the identity

	game_plane_master_controller.add_filter("rainbow", 10, color_matrix_filter(col_filter_reset, FILTER_COLOR_HSL))

	for(var/filter in game_plane_master_controller.get_filters("rainbow"))
		animate(filter, color = col_filter_identity, time = 0 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)
		animate(color = col_filter_shift_once, time = 4 SECONDS)
		animate(color = col_filter_shift_twice, time = 4 SECONDS)
		animate(color = col_filter_reset, time = 4 SECONDS)

	game_plane_master_controller.add_filter("psilocybin_wave", 1, list("type" = "wave", "size" = 2, "x" = 32, "y" = 32))

	for(var/filter in game_plane_master_controller.get_filters("psilocybin_wave"))
		animate(filter, time = 64 SECONDS, loop = -1, easing = LINEAR_EASING, offset = 32, flags = ANIMATION_PARALLEL)

/datum/reagent/drug/mushroomhallucinogen/on_mob_end_metabolize(mob/living/psychonaut)
	. = ..()
	SEND_SIGNAL(psychonaut, COMSIG_CLEAR_MOOD_EVENT, "tripping", /datum/mood_event/high, name)
	if(!psychonaut.hud_used)
		return
	var/atom/movable/plane_master_controller/game_plane_master_controller = psychonaut.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.remove_filter("rainbow")
	game_plane_master_controller.remove_filter("psilocybin_wave")

/datum/reagent/drug/mushroomhallucinogen/overdose_process(mob/living/psychonaut, delta_time, times_fired)
	. = ..()
	if(DT_PROB(10, delta_time))
		psychonaut.emote(pick("twitch","drool","moan"))

/datum/reagent/drug/blastoff
	name = "bLaStOoF"
	description = "A drug for the hardcore party crowd said to enhance one's abilities on the dance floor.\nMost old heads refuse to touch this stuff, perhaps because memories of the luna discotheque incident are seared into their brains."
	color = "#9015a9"
	taste_description = "holodisk cleaner"
	overdose_threshold = 30
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	addiction_types = list(/datum/addiction/hallucinogens = 15)
	///How many flips have we done so far?
	var/flip_count = 0
	///How many spin have we done so far?
	var/spin_count = 0
	///How many flips for a super flip?
	var/super_flip_requirement = 3

/datum/reagent/drug/blastoff/on_mob_metabolize(mob/living/dancer)
	. = ..()

	SEND_SIGNAL(dancer, COMSIG_ADD_MOOD_EVENT, "vibing", /datum/mood_event/high, name)
	RegisterSignal(dancer, COMSIG_MOB_EMOTED("flip"), PROC_REF(on_flip))
	RegisterSignal(dancer, COMSIG_MOB_EMOTED("spin"), PROC_REF(on_spin))

	if(!dancer.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = dancer.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	var/list/col_filter_shift_twice = list(0,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.764,0,0,0) //most blue color
	var/list/col_filter_mid = list(0,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.832,0,0,0) //red/blue mix midpoint
	var/list/col_filter_reset = list(0,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.900,0,0,0) //most red color

	game_plane_master_controller.add_filter("blastoff_filter", 10, color_matrix_filter(col_filter_mid, FILTER_COLOR_HCY))
	game_plane_master_controller.add_filter("blastoff_wave", 1, list("type" = "wave", "x" = 32, "y" = 32))


	for(var/filter in game_plane_master_controller.get_filters("blastoff_filter"))
		animate(filter, color = col_filter_shift_twice, time = 3 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)
		animate(color = col_filter_mid, time = 3 SECONDS)
		animate(color = col_filter_reset, time = 3 SECONDS)
		animate(color = col_filter_mid, time = 3 SECONDS)

	for(var/filter in game_plane_master_controller.get_filters("blastoff_wave"))
		animate(filter, time = 32 SECONDS, loop = -1, easing = LINEAR_EASING, offset = 32, flags = ANIMATION_PARALLEL)

	dancer.sound_environment_override = SOUND_ENVIRONMENT_PSYCHOTIC

/datum/reagent/drug/blastoff/on_mob_end_metabolize(mob/living/dancer)
	. = ..()

	SEND_SIGNAL(dancer, COMSIG_CLEAR_MOOD_EVENT, "vibing", /datum/mood_event/high, name)
	UnregisterSignal(dancer, COMSIG_MOB_EMOTED("flip"))
	UnregisterSignal(dancer, COMSIG_MOB_EMOTED("spin"))

	if(!dancer.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = dancer.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	game_plane_master_controller.remove_filter("blastoff_filter")
	game_plane_master_controller.remove_filter("blastoff_wave")
	dancer.sound_environment_override = NONE

/datum/reagent/drug/blastoff/on_mob_life(mob/living/carbon/dancer, delta_time, times_fired)
	. = ..()
	if(dancer.adjustOrganLoss(ORGAN_SLOT_LUNGS, 0.3 * REM * delta_time))
		. = UPDATE_MOB_HEALTH
	dancer.AdjustKnockdown(-20)

	if(DT_PROB(BLASTOFF_DANCE_MOVE_CHANCE_PER_UNIT * volume, delta_time))
		dancer.emote("flip")

/datum/reagent/drug/blastoff/overdose_process(mob/living/dancer, delta_time, times_fired)
	. = ..()
	if(dancer.adjustOrganLoss(ORGAN_SLOT_LUNGS, 0.3 * REM * delta_time))
		. = UPDATE_MOB_HEALTH

	if(DT_PROB(BLASTOFF_DANCE_MOVE_CHANCE_PER_UNIT * volume, delta_time))
		dancer.emote("spin")

///This proc listens to the flip signal and throws the mob every third flip
/datum/reagent/drug/blastoff/proc/on_flip()
	SIGNAL_HANDLER

	if(!iscarbon(holder.my_atom))
		return
	var/mob/living/carbon/dancer = holder.my_atom

	flip_count++
	if(flip_count < BLASTOFF_DANCE_MOVES_PER_SUPER_MOVE)
		return
	flip_count = 0
	var/atom/throw_target = get_edge_target_turf(dancer, dancer.dir)  //Do a super flip
	dancer.SpinAnimation(speed = 3, loops = 3)
	dancer.visible_message(span_notice("[dancer] does an extravagant flip!"), span_nicegreen("You do an extravagant flip!"))
	dancer.throw_at(throw_target, range = 6, speed = overdosed ? 4 : 1)

///This proc listens to the spin signal and throws the mob every third spin
/datum/reagent/drug/blastoff/proc/on_spin()
	SIGNAL_HANDLER

	if(!iscarbon(holder.my_atom))
		return
	var/mob/living/carbon/dancer = holder.my_atom

	spin_count++
	if(spin_count < BLASTOFF_DANCE_MOVES_PER_SUPER_MOVE)
		return
	spin_count = 0 //Do a super spin.
	dancer.visible_message(span_danger("[dancer] spins around violently!"), span_danger("You spin around violently!"))
	dancer.spin(30, 2)
	if(dancer.disgust < 40)
		dancer.adjust_disgust(10)
	if(!dancer.pulledby)
		return
	var/dancer_turf = get_turf(dancer)
	var/atom/movable/dance_partner = dancer.pulledby
	dance_partner.visible_message(span_danger("[dance_partner] tries to hold onto [dancer], but is thrown back!"), span_danger("You try to hold onto [dancer], but you are thrown back!"), null, COMBAT_MESSAGE_RANGE)
	var/throwtarget = get_edge_target_turf(dancer_turf, get_dir(dancer_turf, get_step_away(dance_partner, dancer_turf)))
	if(overdosed)
		dance_partner.throw_at(target = throwtarget, range = 7, speed = 4)
	else
		dance_partner.throw_at(target = throwtarget, range = 4, speed = 1) //superspeed

/datum/reagent/drug/saturnx
	name = "Saturn-X"
	description = "This compound was originally developed as a treatment for deep-space pilots experiencing disorientation and vertigo. It has since been banned from use due to it's unpredicatable bluespace properties and psychedelic effects."
	taste_description = "metallic bitterness"
	color = "#638b9b"
	overdose_threshold = 25
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	addiction_types = list(/datum/addiction/maintenance_drugs = 20)

/datum/reagent/drug/saturnx/on_mob_life(mob/living/carbon/tripper, delta_time, times_fired)
	. = ..()
	if(DT_PROB(10, delta_time))
		do_teleport(tripper, tripper, 15, channel = TELEPORT_CHANNEL_BLUESPACE)
	if(tripper.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.3 * REM * delta_time))
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/saturnx/on_mob_metabolize(mob/living/tripper)
	. = ..()
	playsound(tripper, 'sound/effects/saturnx_fade.ogg', 40)
	to_chat(tripper, span_nicegreen("You feel pins and needles all over your skin as your body suddenly becomes distant!"))
	if(!tripper.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = tripper.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	var/list/col_filter_full = list(1,0,0,0, 0,1.00,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0)
	var/list/col_filter_twothird = list(1,0,0,0, 0,0.68,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0)
	var/list/col_filter_half = list(1,0,0,0, 0,0.42,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0)
	var/list/col_filter_empty = list(1,0,0,0, 0,0,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0)

	game_plane_master_controller.add_filter("saturnx_filter", 10, color_matrix_filter(col_filter_twothird, FILTER_COLOR_HCY))
	game_plane_master_controller.add_filter("saturnx_blur", 1, list("type" = "radial_blur", "size" = 0))

	for(var/filter in game_plane_master_controller.get_filters("saturnx_filter"))
		animate(filter, loop = -1, color = col_filter_full, time = 4 SECONDS, easing = CIRCULAR_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
		//uneven so we spend slightly less time with bright colors
		animate(color = col_filter_twothird, time = 6 SECONDS, easing = LINEAR_EASING)
		animate(color = col_filter_half, time = 3 SECONDS, easing = LINEAR_EASING)
		animate(color = col_filter_empty, time = 2 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)
		animate(color = col_filter_half, time = 24 SECONDS, easing = CIRCULAR_EASING|EASE_IN)
		animate(color = col_filter_twothird, time = 12 SECONDS, easing = LINEAR_EASING)

	for(var/filter in game_plane_master_controller.get_filters("saturnx_blur"))
		animate(filter, loop = -1, size = 0.02, time = 2 SECONDS, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
		animate(size = 0, time = 6 SECONDS, easing = SINE_EASING)

	tripper.sound_environment_override = SOUND_ENVIROMENT_PHASED

/datum/reagent/drug/saturnx/on_mob_end_metabolize(mob/living/carbon/tripper)
	. = ..()
	to_chat(tripper, span_notice("As you sober up, your feelings returns to your body meats."))

	tripper.update_body()
	tripper.sound_environment_override = NONE

	if(!tripper.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = tripper.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.remove_filter("saturnx_filter")
	game_plane_master_controller.remove_filter("saturnx_blur")

/datum/reagent/drug/saturnx/overdose_process(mob/living/tripper, delta_time, times_fired)
	. = ..()
	if(DT_PROB(7.5, delta_time))
		tripper.emote("giggle")
	if(DT_PROB(5, delta_time))
		tripper.emote("laugh")
	if(tripper.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.4 * REM * delta_time))
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/krokodil
	name = "Krokodil"
	description = "Cools and calms you down. If overdosed it will deal significant Brain and Toxin damage. If addicted it will begin to deal fatal amounts of Brute damage as the subject's skin falls off."
	reagent_state = LIQUID
	color = "#0064B4"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
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
	SEND_SIGNAL(affected_mob, COMSIG_ADD_MOOD_EVENT, "smacked out", /datum/mood_event/narcotic_heavy, name)

/datum/reagent/drug/krokodil/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.25 * REM * delta_time)
	need_mob_update = affected_mob.adjustToxLoss(0.25 * REM * delta_time, updating_health = FALSE)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/*Kronkaine is a rare natural stimulant that can help you instantly clear stamina damage in combat,
but it also greatly aids civilians by letting them perform everyday actions like cleaning, building, pick pocketing and even performing surgery at double speed.

The main part of the stamina regeneration happens instantly once the reagent is added to the player and is doubled if smoked or injected.
After the initial burst of stamina, it also imparts stamina restoration per cycle.

The instant and gradual restoration effects as well as the heart damage are dose dependant, encouraging the player to push the limit of what is safe and reeasonable!

If you have at over 25u in your body you restore more than 20 stamina per cycle, enough to revive you from stamina crit, beware that this is a potentially fatal overdose!*/
/datum/reagent/drug/kronkaine
	name = "Kronkaine"
	description = "A highly illegal stimulant from the edge of the galaxy.\nIt is said the average kronkaine addict causes as much criminal damage as five stick up men, two rascals and one proferssional cambringo hustler combined."
	color = "#FAFAFA"
	taste_description = "numbing bitterness"
	overdose_threshold = 20
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	addiction_types = list(/datum/addiction/stimulants = 20)

/datum/reagent/drug/kronkaine/on_mob_metabolize(mob/living/kronkaine_fiend)
	. = ..()
	kronkaine_fiend.client?.give_award(/datum/award/achievement/misc/kronk, kronkaine_fiend)
	kronkaine_fiend.add_actionspeed_modifier(/datum/actionspeed_modifier/kronkaine)
	kronkaine_fiend.sound_environment_override = SOUND_ENVIRONMENT_HANGAR
	SEND_SOUND(kronkaine_fiend, sound('sound/health/fastbeat.ogg', repeat = TRUE, channel = CHANNEL_HEARTBEAT, volume = 60))

/datum/reagent/drug/kronkaine/on_mob_end_metabolize(mob/living/kronkaine_fiend)
	. = ..()
	kronkaine_fiend.remove_actionspeed_modifier(/datum/actionspeed_modifier/kronkaine)
	kronkaine_fiend.sound_environment_override = NONE
	//Stop the rapid heartbeats, we make sure we are not in crit as to not mess with the heartbeats from organ/heart.
	if(!kronkaine_fiend.stat)
		kronkaine_fiend.stop_sound_channel(CHANNEL_HEARTBEAT)

/datum/reagent/drug/kronkaine/expose_mob(mob/living/carbon/druggo, methods, trans_volume, show_message, touch_protection)
	. = ..()
	if(!iscarbon(druggo))
		return

	//The drug is more effective if smoked or injected, restoring more stamina per unit.
	var/stamina_heal_per_unit
	if(methods & (INJECT))
		stamina_heal_per_unit = 12
		if(trans_volume >= 3)
			SEND_SOUND(druggo, sound('sound/weapons/flash_ring.ogg')) //The efffect is often refered to as the "kronkaine bells".
			to_chat(druggo, span_danger("Your ears ring as your blood pressure suddenly spikes!"))
			to_chat(druggo, span_nicegreen("You feel an amazing rush!"))
		else if(prob(15))
			to_chat(druggo, span_nicegreen(pick("You feel the cowardice melt away...", "You feel unbothered by the judgements of others.", "My life feels lovely!", "You lower your snout... and suddenly feel more charitable!")))
	else
		stamina_heal_per_unit = 6
	druggo.adjustStaminaLoss(-stamina_heal_per_unit * trans_volume)

/datum/reagent/drug/kronkaine/on_mob_life(mob/living/carbon/kronkaine_fiend, delta_time, times_fired)
	. = ..()
	var/need_mob_update
	if(kronkaine_fiend.adjustOrganLoss(ORGAN_SLOT_HEART, (0.1 + 0.04 * volume) * REM * delta_time))
		need_mob_update = UPDATE_MOB_HEALTH
		if(kronkaine_fiend.getOrganLoss(ORGAN_SLOT_HEART) >= 75 && prob(15))
			to_chat(kronkaine_fiend, span_userdanger("You feel like your heart is about to explode!"))
			playsound(kronkaine_fiend, 'sound/effects/singlebeat.ogg', 200, TRUE)
	kronkaine_fiend.apply_status_effect(/datum/status_effect/tweaked)
	kronkaine_fiend.set_jitter_if_lower(20 SECONDS * REM * delta_time)
	kronkaine_fiend.AdjustSleeping(-2 SECONDS * REM * delta_time)
	kronkaine_fiend.drowsyness = max(kronkaine_fiend.drowsyness - (10 * REM * delta_time), 0)
	/* Do not try to cheese the overdose threshhold with purging chems to become stamina immune, if you purge and take stamina damage you will be punished!

	The reason why I choose to add the adrenal crisis anti-cheese mechanic is because the main combat benefit is so front loaded, you could easily negate all the risk and downsides by mixing it with a small amount of a purger like haloperidol.
	I think that level of safety goes against the design we would like achieve with drugs; great rewards but at the cost of great risk.*/
	if(kronkaine_fiend.getStaminaLoss() > 30)
		for(var/possible_purger in kronkaine_fiend.reagents.reagent_list)
			if(istype(possible_purger, /datum/reagent/medicine/corazone) || istype(possible_purger, /datum/reagent/medicine/haloperidol))
				if(kronkaine_fiend.HasDisease(/datum/disease/adrenal_crisis))
					break
				kronkaine_fiend.visible_message(span_bolddanger("[kronkaine_fiend.name] suddenly tenses up, it looks like the shock is causing their body to shut down!"), span_userdanger("The sudden shock in combination with the cocktail of drugs and purgatives in your body makes your adrenal system go haywire. Uh oh!"))
				kronkaine_fiend.ForceContractDisease(new /datum/disease/adrenal_crisis(), FALSE, TRUE) //We punish players for purging, since unchecked purging would allow players to reap the stamina healing benefits without any drawbacks. This also has the benefit of making haloperidol a counter, like it is supposed to be.
				break
	need_mob_update = kronkaine_fiend.adjustStaminaLoss(-0.8 * volume * REM * delta_time, updating_health = FALSE)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/kronkaine/overdose_process(mob/living/kronkaine_fiend, delta_time, times_fired)
	. = ..()
	if(kronkaine_fiend.adjustOrganLoss(ORGAN_SLOT_HEART, 0.5 * REM * delta_time))
		. = UPDATE_MOB_HEALTH
	kronkaine_fiend.set_jitter_if_lower(20 SECONDS * REM * delta_time)
	if(DT_PROB(10, delta_time))
		to_chat(kronkaine_fiend, span_danger(pick("Your heart is racing!", "Your ears are ringing!", "You sweat like a pig!", "You clench your jaw and grind your teeth.", "You feel prickles of pain in your chest.")))

/datum/reagent/drug/kronkaine/overdose_start(mob/living/affected_mob)
	. = ..()
	SEND_SOUND(affected_mob, sound('sound/health/fastbeat.ogg', repeat = TRUE, channel = CHANNEL_HEARTBEAT, volume = 90))

