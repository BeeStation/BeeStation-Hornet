/datum/status_effect/woozy
	id = "woozy"
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/woozy


/datum/status_effect/woozy/nextmove_modifier()
	return 1.5

/atom/movable/screen/alert/status_effect/woozy
	name = "Woozy"
	desc = "You feel a bit slower than usual, it seems doing things with your hands takes longer than it usually does"
	icon_state = "woozy"


/datum/status_effect/high_blood_pressure
	id = "high_blood_pressure"
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/high_blood_pressure

/datum/status_effect/high_blood_pressure/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.bleed_mod *= 1.25

/datum/status_effect/high_blood_pressure/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.bleed_mod *= 0.80

/atom/movable/screen/alert/status_effect/high_blood_pressure
	name = "High blood pressure"
	desc = "Your blood pressure is real high right now ... You'd probably bleed like a stuck pig."
	icon_state = "highbloodpressure"



/datum/status_effect/seizure
	id = "seizure"
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE

/datum/status_effect/seizure/on_apply()
	if(!iscarbon(owner))
		return FALSE
	var/amplitude = rand(1 SECONDS, 3 SECONDS)
	duration = amplitude
	owner.Jitter(50)
	owner.Paralyze(duration)
	owner.visible_message("<span class='warning'>[owner] drops to the ground as [owner.p_they()] start seizing up.</span>")
	owner.visible_message("<span class='warning'>[pick("You can't collect your thoughts...", \
	"You suddenly feel extremely dizzy...", \
	"You cant think straight...", \
	"You can't move your face properly anymore...")]</span>")
	return TRUE


/datum/status_effect/stoned
	id = "stoned"
	duration = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/stoned
	status_type = STATUS_EFFECT_REFRESH
	var/original_eye_color

/datum/status_effect/stoned/on_apply()
	if(!ishuman(owner))
		CRASH("[type] status effect added to non-human owner: [owner ? owner.type : "null owner"]")
	var/mob/living/carbon/human/human_owner = owner
	original_eye_color = human_owner.eye_color
	human_owner.add_movespeed_modifier(MOVESPEED_ID_CANNABIS, TRUE, 100, override = TRUE, multiplicative_slowdown= -0.4, movetypes=(~FLYING)) //slows you down
	human_owner.eye_color = BLOODCULT_EYE //makes cult eyes less obvious
	human_owner.update_body() //updates eye color
	ADD_TRAIT(human_owner, TRAIT_BLOODSHOT_EYES, type) //dilates blood vessels in eyes
	ADD_TRAIT(human_owner, TRAIT_CLUMSY, type) //impairs motor coordination
	SEND_SIGNAL(human_owner, COMSIG_ADD_MOOD_EVENT, "stoned", /datum/mood_event/stoned) //improves mood
	human_owner.sound_environment_override = SOUND_ENVIRONMENT_DRUGGED //not realistic but very immersive
	return TRUE

/datum/status_effect/stoned/on_remove()
	if(!ishuman(owner))
		stack_trace("[type] status effect being removed from non-human owner: [owner ? owner.type : "null owner"]")
	var/mob/living/carbon/human/human_owner = owner
	human_owner.remove_movespeed_modifier(MOVESPEED_ID_CANNABIS, TRUE)
	human_owner.eye_color = original_eye_color
	human_owner.update_body()
	REMOVE_TRAIT(human_owner, TRAIT_BLOODSHOT_EYES, type)
	REMOVE_TRAIT(human_owner, TRAIT_CLUMSY, type)
	SEND_SIGNAL(human_owner, COMSIG_CLEAR_MOOD_EVENT, "stoned")
	human_owner.sound_environment_override = SOUND_ENVIRONMENT_NONE

/atom/movable/screen/alert/status_effect/stoned
	name = "Stoned"
	desc = "Cannabis is impairing your speed, motor skills, and mental cognition."
	icon_state = "stoned"
