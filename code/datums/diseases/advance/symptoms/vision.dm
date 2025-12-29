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
	var/remove_eyes = FALSE
	threshold_desc = "<b>Resistance 12:</b> Weakens extraocular muscles, eventually leading to complete detachment of the eyes.<br>\
						<b>Stealth 4:</b> The symptom remains hidden until active."

/datum/symptom/visionloss/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 12 || ((CONFIG_GET(flag/unconditional_symptom_thresholds) || A.event) && A.resistance >= 8)) //goodbye eyes
		severity += 1
	if(CONFIG_GET(flag/unconditional_symptom_thresholds))
		threshold_desc = "<b>Resistance 8:</b> Weakens extraocular muscles, eventually leading to complete detachment of the eyes.<br>\
						<b>Stealth 4:</b> The symptom remains hidden until active."

/datum/symptom/visionloss/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= 4)
		suppress_warning = TRUE
	if(A.resistance >= 12 || ((CONFIG_GET(flag/unconditional_symptom_thresholds) || A.event) && A.resistance >= 8)) //goodbye eyes
		remove_eyes = TRUE

/datum/symptom/visionloss/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	var/obj/item/organ/eyes/eyes = M.get_organ_slot(ORGAN_SLOT_EYES)
	if(eyes)
		switch(A.stage)
			if(1, 2)
				if(prob(base_message_chance) && !suppress_warning && M.stat != DEAD)
					to_chat(M, span_warning("Your eyes itch."))
			if(3, 4)
				if(M.stat != DEAD)
					to_chat(M, span_warning("<b>Your eyes burn!</b>"))
				M.blur_eyes(10)
				eyes.apply_organ_damage(1)
			else
				M.blur_eyes(20)
				eyes.apply_organ_damage(5)
				if(eyes.damage >= 10)
					M.become_nearsighted(EYE_DAMAGE)
				if(prob(eyes.damage - 10 + 1))
					if(!remove_eyes)
						if(!M.is_blind())
							if(M.stat != DEAD)
								to_chat(M, span_userdanger("You go blind!"))
							eyes.apply_organ_damage(eyes.maxHealth)
					else
						M.visible_message(span_warning("[M]'s eyes fall out of their sockets!"), span_userdanger("Your eyes fall out of their sockets!"))
						eyes.Remove(M)
						eyes.forceMove(get_turf(M))
				else
					if(M.stat != DEAD)
						to_chat(M, span_userdanger("Your eyes burn horrifically!"))
