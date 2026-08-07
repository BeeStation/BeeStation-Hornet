/*
//////////////////////////////////////

Hyphema (Eye bleeding)

	Slightly noticeable.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity.
	Critical Level.

Bonus
	Causes blindness.

//////////////////////////////////////
*/

/datum/symptom/visionloss

	name = "Hyphema"
	desc = "The virus causes inflammation of the retina, leading to eye damage and eventually blindness."
	stealth = -1
	resistance = -3
	stage_speed = -4
	transmission = -2
	level = 3
	severity = 3
	base_message_chance = 50
	symptom_delay_min = 25
	symptom_delay_max = 80
	prefixes = list("Eye ")
	bodies = list("Blind")
	suffixes = list(" Blindness")
	threshold_desc = "<b>Resistance 12:</b> Weakens extraocular muscles, eventually leading to complete detachment of the eyes.<br>\
						<b>Stealth 4:</b> The symptom remains hidden until active."

	/// At max stage: If FALSE, cause blindness. If TRUE, cause their eyes to fall out.
	var/remove_eyes = FALSE

/datum/symptom/visionloss/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 12 || ((CONFIG_GET(flag/unconditional_symptom_thresholds) || A.event) && A.resistance >= 8)) //goodbye eyes
		severity += 1
	if(CONFIG_GET(flag/unconditional_symptom_thresholds))
		threshold_desc = "<b>Resistance 8:</b> Weakens extraocular muscles, eventually leading to complete detachment of the eyes.<br>\
						<b>Stealth 4:</b> The symptom remains hidden until active."

/datum/symptom/visionloss/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.stealth >= 4)
		suppress_warning = TRUE
	if(A.resistance >= 12 || ((CONFIG_GET(flag/unconditional_symptom_thresholds) || A.event) && A.resistance >= 8)) //goodbye eyes
		remove_eyes = TRUE

/datum/symptom/visionloss/Activate(datum/disease/advance/source_disease)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/ill_mob = source_disease.affected_mob
	var/obj/item/organ/eyes/eyes = ill_mob.get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes)
		return // can't do much

	switch(source_disease.stage)
		if(1, 2)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(ill_mob, span_warning("Your eyes itch."))

		if(3, 4)
			to_chat(ill_mob, span_boldwarning("Your eyes burn!"))
			ill_mob.set_eye_blur_if_lower(20 SECONDS)
			eyes.apply_organ_damage(1)

		else
			ill_mob.set_eye_blur_if_lower(40 SECONDS)
			eyes.apply_organ_damage(5)

			// Applies nearsighted at minimum
			if(!ill_mob.is_nearsighted_from(EYE_DAMAGE) && eyes.damage <= eyes.low_threshold)
				eyes.set_organ_damage(eyes.low_threshold)

			if(prob(eyes.damage - eyes.low_threshold + 1))
				if(remove_eyes)
					ill_mob.visible_message(
						span_warning("[ill_mob]'s eyes fall out of their sockets!"),
						span_userdanger("Your eyes fall out of their sockets!"),
					)
					eyes.Remove(ill_mob)
					eyes.forceMove(get_turf(ill_mob))

				else if(!ill_mob.is_blind_from(EYE_DAMAGE))
					to_chat(ill_mob, span_userdanger("You go blind!"))
					eyes.apply_organ_damage(eyes.maxHealth)

			else
				to_chat(ill_mob, span_userdanger("Your eyes burn horrifically!"))
