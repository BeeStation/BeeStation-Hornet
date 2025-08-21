/*
//////////////////////////////////////

Shivering

	No change to hidden.
	Increases resistance.
	Increases stage speed.
	Little transmittable.
	Low level.

Bonus
	Cools down your body.

//////////////////////////////////////
*/

/datum/symptom/shivering
	name = "Shivering"
	desc = "The virus inhibits the body's thermoregulation, cooling the body down."
	stealth = 0
	resistance = 2
	stage_speed = 2
	transmission = 2
	level = 2
	severity = 0
	symptom_delay_min = 10
	symptom_delay_max = 30
	bodies = list("Shiver")
	suffixes = list(" Shivers")
	var/unsafe = FALSE //over the cold threshold
	threshold_desc = "<b>Stage Speed 5:</b> Increases cooling speed; the host can fall below safe temperature levels.<br>\
						<b>Stage Speed 10:</b> Further increases cooling speed."

/datum/symptom/shivering/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stage_rate >= 5) //dangerous cold
		severity += 1
		if(A.stage_rate >= 10)
			severity += 1

/datum/symptom/shivering/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 5) //dangerous cold
		power = 1.5
		unsafe = TRUE
		if(A.stage_rate >= 10)
			power = 2.5

/datum/symptom/shivering/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	if(M.stat == DEAD)
		return
	if(!unsafe || A.stage < 4)
		to_chat(M, span_warning("[pick("You feel cold.", "You shiver.")]"))
	else
		to_chat(M, span_userdanger("[pick("You feel your blood run cold.", "You feel ice in your veins.", "You feel like you can't heat up.", "You shiver violently." )]"))
	set_body_temp(A.affected_mob, A)

/**
 * set_body_temp Sets the body temp change
 *
 * Sets the body temp change to the mob based on the stage and resistance of the disease
 * arguments:
 * * mob/living/M The mob to apply changes to
 * * datum/disease/advance/A The disease applying the symptom
 */
/datum/symptom/shivering/proc/set_body_temp(mob/living/M, datum/disease/advance/A)
	if(!unsafe)
		M.add_body_temperature_change("shivering", max(-((6 * power) * A.stage), (BODYTEMP_COLD_DAMAGE_LIMIT + 1)))
	else
		M.add_body_temperature_change("shivering", max(-((6 * power) * A.stage), (BODYTEMP_COLD_DAMAGE_LIMIT - 20)))

/// Update the body temp change based on the new stage
/datum/symptom/shivering/on_stage_change(datum/disease/advance/A)
	. = ..()
	if(.)
		set_body_temp(A.affected_mob, A)

/// remove the body temp change when removing symptom
/datum/symptom/shivering/End(datum/disease/advance/A)
	var/mob/living/carbon/M = A.affected_mob
	if(M)
		M.remove_body_temperature_change("shivering")
