/*
//////////////////////////////////////

Confusion

	Little bit hidden.
	Lowers resistance.
	Decreases stage speed.
	Not very transmissibile.
	Intense Level.

Bonus
	Makes the affected mob be confused for short periods of time.

//////////////////////////////////////
*/

/datum/symptom/confusion

	name = "Confusion"
	desc = "The virus interferes with the proper function of the neural system, leading to bouts of confusion and erratic movement."
	stealth = 1
	resistance = -1
	stage_speed = -3
	transmission = 0
	level = 3
	severity = 2
	base_message_chance = 25
	symptom_delay_min = 10
	symptom_delay_max = 30
	prefixes = list("Dizzy ")
	bodies = list("Ditz")
	var/brain_damage = FALSE
	threshold_desc = "<b>Resistance 6:</b> Causes brain damage over time.<br>\
						<b>Transmission 6:</b> Increases confusion duration and strength.<br>\
						<b>Stealth 4:</b> The symptom remains hidden until active."

/datum/symptom/confusion/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 6)
		severity += 1

/datum/symptom/confusion/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.resistance >= 6)
		brain_damage = TRUE
	if(A.transmission >= 6)
		power = 1.5
	if(A.stealth >= 4)
		suppress_warning = TRUE

/datum/symptom/confusion/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/M = A.affected_mob
	if(M.stat == DEAD)
		return
	switch(A.stage)
		if(1, 2, 3, 4)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, span_warning("[pick("Your head hurts.", "Your mind blanks for a moment.")]"))
		else
			to_chat(M, span_userdanger("You can't think straight!"))
			M.adjust_confusion_up_to(16 SECONDS * power, 30 SECONDS)
			if(brain_damage)
				M.adjustOrganLoss(ORGAN_SLOT_BRAIN,3 * power, 80)
				M.updatehealth()
	return
