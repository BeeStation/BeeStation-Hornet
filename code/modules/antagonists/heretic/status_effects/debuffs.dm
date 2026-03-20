// AMOK
/datum/status_effect/amok
	id = "amok"
	status_type = STATUS_EFFECT_REPLACE
	remove_on_fullheal = TRUE
	alert_type = null
	duration = 10 SECONDS
	tick_interval = 1 SECONDS

/datum/status_effect/amok/on_apply(mob/living/afflicted)
	to_chat(owner, span_boldwarning("You feel filled with a rage that is not your own!"))
	return TRUE

/datum/status_effect/amok/tick(seconds_between_ticks)
	var/prev_combat_mode = owner.combat_mode
	owner.set_combat_mode(TRUE)

	// If we're holding a gun, expand the range a bit.
	// Otherwise, just look for adjacent targets
	var/search_radius = isgun(owner.get_active_held_item()) ? 3 : 1

	var/list/mob/living/targets = list()
	for(var/mob/living/potential_target in oview(owner, search_radius))
		if(IS_HERETIC_OR_MONSTER(potential_target))
			continue
		targets += potential_target

	if(LAZYLEN(targets))
		owner.log_message(" attacked someone due to the amok debuff.", LOG_ATTACK) //the following attack will log itself
		owner.ClickOn(pick(targets))

	owner.set_combat_mode(prev_combat_mode)

/datum/status_effect/cloudstruck
	id = "cloudstruck"
	status_type = STATUS_EFFECT_REPLACE
	remove_on_fullheal = TRUE
	alert_type = null
	duration = 3 SECONDS
	on_remove_on_mob_delete = TRUE
	///This overlay is applied to the owner for the duration of the effect.
	var/static/mutable_appearance/mob_overlay

/datum/status_effect/cloudstruck/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	if(!mob_overlay)
		mob_overlay = mutable_appearance('icons/effects/eldritch.dmi', "cloud_swirl", ABOVE_MOB_LAYER)
	return ..()

/datum/status_effect/cloudstruck/on_apply()
	owner.add_overlay(mob_overlay)
	owner.become_blind(id)
	return TRUE

/datum/status_effect/cloudstruck/on_remove()
	owner.cure_blind(id)
	owner.cut_overlay(mob_overlay)

/datum/status_effect/corrosion_curse
	id = "corrosion_curse"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	tick_interval = 1 SECONDS

/datum/status_effect/corrosion_curse/on_apply()
	to_chat(owner, span_userdanger("Your body starts to break apart!"))
	return TRUE

/datum/status_effect/corrosion_curse/tick(seconds_between_ticks)
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	var/chance = rand(0, 100)
	switch(chance)
		if(0 to 10)
			human_owner.vomit()
		if(20 to 30)
			human_owner.set_timed_status_effect(100 SECONDS, /datum/status_effect/dizziness, only_if_higher = TRUE)
			human_owner.set_timed_status_effect(100 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
		if(30 to 40)
			// Don't fully kill liver that's important
			human_owner.adjustOrganLoss(ORGAN_SLOT_LIVER, 10, 90)
		if(40 to 50)
			// Don't fully kill heart that's important
			human_owner.adjustOrganLoss(ORGAN_SLOT_HEART, 10, 90)
		if(50 to 60)
			// You can fully kill the stomach that's not crucial
			human_owner.adjustOrganLoss(ORGAN_SLOT_STOMACH, 10)
		if(60 to 70)
			// Same with eyes
			human_owner.adjustOrganLoss(ORGAN_SLOT_EYES, 5)
		if(70 to 80)
			// And same with ears
			human_owner.adjustOrganLoss(ORGAN_SLOT_EARS, 10)
		if(80 to 90)
			// But don't fully kill lungs that's usually important
			human_owner.adjustOrganLoss(ORGAN_SLOT_LUNGS, 10, 90)
		if(90 to 95)
			// And definitely don't fully kill brains
			human_owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20, 190)
		if(95 to 100)
			human_owner.adjust_confusion_up_to(12 SECONDS, 24 SECONDS)

/datum/status_effect/heretic_mark/void
	effect_icon_state = "emark4"

/datum/status_effect/heretic_mark/void/on_effect()
	var/turf/open/turfie = get_turf(owner)
	turfie.take_temperature(-40)
	owner.adjust_bodytemperature(-20)
	owner.adjust_silence(10 SECONDS)
	return ..()
