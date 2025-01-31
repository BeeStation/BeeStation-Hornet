/*
//////////////////////////////////////

Fever

	No change to hidden.
	Increases resistance.
	Increases stage speed.
	Little transmission.
	Low level.

Bonus
	Heats up your body.

//////////////////////////////////////
*/

/datum/symptom/fever
	name = "Fever"
	desc = "The virus causes a febrile response from the host, raising its body temperature."
	stealth = -1
	resistance = 3
	stage_speed = 3
	transmission = 2
	level = 2
	severity = 0
	base_message_chance = 20
	symptom_delay_min = 10
	symptom_delay_max = 30
	bodies = list("Fever")
	suffixes = list(" Fever")
	var/unsafe = FALSE //over the heat threshold
	threshold_desc = "<b>Resistance 5:</b> Increases fever intensity, fever can overheat and harm the host.<br>\
						<b>Resistance 10:</b> Further increases fever intensity."

/datum/symptom/fever/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 5)
		severity += 1
		prefixes = list("Desert")
		if(A.resistance >= 10)
			severity += 1
			prefixes = list("Volcanic")

/datum/symptom/fever/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 5) //dangerous fever
		power = 1.5
		unsafe = TRUE
		if(A.resistance >= 10)
			power = 2.5

/datum/symptom/fever/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	if(M.stat == DEAD)
		return
	if(!unsafe || A.stage < 4)
		to_chat(M, span_warning("[pick("You feel hot.", "You feel like you're burning.")]"))
	else
		to_chat(M, span_userdanger("[pick("You feel too hot.", "You feel like your blood is boiling.")]"))
	set_body_temp(A.affected_mob, A)

/**
 * set_body_temp Sets the body temp change
 *
 * Sets the body temp change to the mob based on the stage and resistance of the disease
 * arguments:
 * * mob/living/M The mob to apply changes to
 * * datum/disease/advance/A The disease applying the symptom
 */
/datum/symptom/fever/proc/set_body_temp(mob/living/M, datum/disease/advance/A)
	if(!unsafe)
		M.add_body_temperature_change("fever", max((6 * power) * A.stage, (BODYTEMP_HEAT_DAMAGE_LIMIT - 1)))
	else
		M.add_body_temperature_change("fever", max((6 * power) * A.stage, (BODYTEMP_HEAT_DAMAGE_LIMIT + 20)))

/// Update the body temp change based on the new stage
/datum/symptom/fever/on_stage_change(datum/disease/advance/A)
	. = ..()
	if(.)
		set_body_temp(A.affected_mob, A)

/// remove the body temp change when removing symptom
/datum/symptom/fever/End(datum/disease/advance/A)
	var/mob/living/carbon/M = A.affected_mob
	if(M)
		M.remove_body_temperature_change("fever")
