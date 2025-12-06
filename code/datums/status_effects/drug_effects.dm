/datum/status_effect/woozy
	id = "woozy"
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/woozy

/datum/status_effect/woozy/nextmove_modifier()
	return 1.5

/atom/movable/screen/alert/status_effect/woozy
	name = "Woozy"
	desc = "You feel a bit slower than usual, it seems doing things with your hands takes longer than it usually does."
	icon_state = "woozy"

/datum/status_effect/high_blood_pressure
	id = "high_blood_pressure"
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/high_blood_pressure

/datum/status_effect/high_blood_pressure/on_apply()
	if(!ishuman(owner))
		return FALSE

	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.bleed_mod *= 1.25
	return TRUE

/datum/status_effect/high_blood_pressure/on_remove()
	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.bleed_mod /= 1.25

/atom/movable/screen/alert/status_effect/high_blood_pressure
	name = "High blood pressure"
	desc = "Your blood pressure is real high right now ... You'd probably bleed like a stuck pig."
	icon_state = "highbloodpressure"

/datum/status_effect/seizure
	id = "seizure"
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/seizure

/datum/status_effect/seizure/on_apply()
	if(!iscarbon(owner))
		return FALSE
	var/amplitude = rand(1 SECONDS, 3 SECONDS)
	duration = amplitude
	owner.set_jitter_if_lower(100 SECONDS)
	owner.Paralyze(duration)
	owner.visible_message(span_warning("[owner] drops to the ground as [owner.p_they()] start seizing up."), \
	span_warning("[pick("You can't collect your thoughts...", "You suddenly feel extremely dizzy...", "You can't think straight...","You can't move your face properly anymore...")]"))
	return TRUE

/atom/movable/screen/alert/status_effect/seizure
	name = "Seizure"
	desc = "FJOIWEHUWQEFGYUWDGHUIWHUIDWEHUIFDUWGYSXQHUIODSDBNJKVBNKDML <--- this is you right now"
	icon_state = "paralysis"

/datum/status_effect/stoned
	id = "stoned"
	duration = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/stoned
	status_type = STATUS_EFFECT_REFRESH
	var/original_eye_color

/datum/status_effect/stoned/on_apply()
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	original_eye_color = human_owner.eye_color
	human_owner.add_movespeed_modifier(/datum/movespeed_modifier/reagent/cannabis) //slows you down
	human_owner.eye_color = BLOODCULT_EYE //makes cult eyes less obvious
	human_owner.update_body() //updates eye color
	human_owner.add_traits(list(TRAIT_CLUMSY, TRAIT_BLOODSHOT_EYES, TRAIT_DUMB), TRAIT_STATUS_EFFECT(id)) // impairs motor coordination, dilates blood vessels in eyes and disrupts cognitive function.
	SEND_SIGNAL(human_owner, COMSIG_ADD_MOOD_EVENT, "stoned", /datum/mood_event/stoned) //improves mood
	human_owner.sound_environment_override = SOUND_ENVIRONMENT_DRUGGED //not realistic but very immersive
	human_owner.overlay_fullscreen("high", /atom/movable/screen/fullscreen/high)
	return TRUE

/datum/status_effect/stoned/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	human_owner.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/cannabis)
	human_owner.eye_color = original_eye_color
	human_owner.update_body()
	human_owner.remove_traits(list(TRAIT_CLUMSY, TRAIT_BLOODSHOT_EYES, TRAIT_DUMB), TRAIT_STATUS_EFFECT(id))
	SEND_SIGNAL(human_owner, COMSIG_CLEAR_MOOD_EVENT, "stoned")
	human_owner.sound_environment_override = SOUND_ENVIRONMENT_NONE
	human_owner.clear_fullscreen("high")

/atom/movable/screen/alert/status_effect/stoned
	name = "Stoned"
	desc = "Cannabis is impairing your speed, motor skills, and mental cognition."
	icon_state = "stoned"

/datum/status_effect/tweaked
	id = "tweaked"
	duration = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/tweaked
	status_type = STATUS_EFFECT_REFRESH

/datum/status_effect/tweaked/on_apply()
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	human_owner.add_traits(list(TRAIT_CLUMSY), TRAIT_STATUS_EFFECT(id))
	SEND_SIGNAL(human_owner, COMSIG_ADD_MOOD_EVENT, "tweaking", /datum/mood_event/stimulant_medium) //improves mood
	human_owner.sound_environment_override = SOUND_ENVIROMENT_PHASED
	human_owner.overlay_fullscreen("tweak", /atom/movable/screen/fullscreen/tweak)
	return TRUE

/datum/status_effect/tweaked/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	human_owner.remove_traits(list(TRAIT_CLUMSY), TRAIT_STATUS_EFFECT(id))
	SEND_SIGNAL(human_owner, COMSIG_CLEAR_MOOD_EVENT, "tweaked")
	human_owner.sound_environment_override = SOUND_ENVIRONMENT_NONE
	human_owner.clear_fullscreen("tweak")

/atom/movable/screen/alert/status_effect/tweaked
	name = "Tweaking"
	desc = "You are tweaking out hard right now."
	icon_state = "energized"

/datum/status_effect/glaggle
	id = "glaggle"
	duration = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/glaggle
	status_type = STATUS_EFFECT_REFRESH

/datum/status_effect/glaggle/on_apply()
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	human_owner.sound_environment_override = SOUND_ENVIROMENT_PHASED
	human_owner.overlay_fullscreen("glaggle", /atom/movable/screen/fullscreen/tweak)
	return TRUE

/datum/status_effect/glaggle/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	human_owner.sound_environment_override = SOUND_ENVIRONMENT_NONE
	human_owner.clear_fullscreen("glaggle")

/atom/movable/screen/alert/status_effect/glaggle
	name = "Forced Euphoria"
	desc = "You are happy right now, or are you?"
	icon_state = "glaggle"
