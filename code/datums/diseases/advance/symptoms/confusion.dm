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
					  <b>Transmission 6:</b> Increases confusion duration.<br>\
					  <b>Stealth 4:</b> The symptom remains hidden until active."
	threshold_ranges = list(
		"resistance" = list(5, 7),
		"transmission" = list(5, 7),
		"stealth" = list(3, 5)
	)

/datum/symptom/confusion/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= get_threshold("resistance"))
		severity += 1

/datum/symptom/confusion/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= get_threshold("resistance"))
		brain_damage = TRUE
	if(A.transmission >= get_threshold("transmission"))
		power = 1.5
	if(A.stealth >= get_threshold("stealth"))
		suppress_warning = TRUE

/datum/symptom/confusion/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3, 4)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, "<span class='warning'>[pick("Your head hurts.", "Your mind blanks for a moment.")]</span>")
		else
			to_chat(M, "<span class='userdanger'>You can't think straight!</span>")
			M.confused = min(100 * power, M.confused + 8)
			if(brain_damage)
				M.adjustOrganLoss(ORGAN_SLOT_BRAIN,3 * power, 80)
				M.updatehealth()

	return

/datum/symptom/confusion/Threshold(datum/disease/advance/A)
	if(!..())
		return
	threshold_desc = "<b>Resistance [get_threshold("resistance")]:</b> Causes brain damage over time.<br>\
					  <b>Transmission [get_threshold("transmission")]:</b> Increases confusion duration.<br>\
					  <b>Stealth [get_threshold("stealth")]:</b> The symptom remains hidden until active."
	return threshold_desc
