/*
//////////////////////////////////////

Self-Respiration

	Slightly hidden.
	Lowers resistance significantly.
	Decreases stage speed significantly.
	Decreases transmittablity tremendously.
	Fatal Level.

Bonus
	The body generates salbutamol.

//////////////////////////////////////
*/

/datum/symptom/oxygen

	name = "Self-Respiration"
	desc = "The virus rapidly synthesizes oxygen, effectively removing the need for breathing."
	stealth = 1
	resistance = -3
	stage_speed = -3
	transmission = -4
	severity = -1
	level = 8
	base_message_chance = 5
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Breathless ", "Anaerobic ")
	required_organ = ORGAN_SLOT_LUNGS
	threshold_desc = "<b>Resistance 8:</b> Additionally regenerates lost blood.<br>"
	var/regenerate_blood = FALSE

/datum/symptom/oxygen/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 8) //blood regeneration
		regenerate_blood = TRUE

/datum/symptom/oxygen/Activate(datum/disease/advance/advanced_disease)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/infected_mob = advanced_disease.affected_mob
	switch(advanced_disease.stage)
		if(4, 5)
			infected_mob.losebreath = max(0, infected_mob.losebreath - 4)
			infected_mob.adjustOxyLoss(-7)
			if(regenerate_blood && infected_mob.blood_volume < BLOOD_VOLUME_NORMAL)
				infected_mob.blood_volume += 1
		else
			if(prob(base_message_chance))
				to_chat(infected_mob, span_notice("[pick("Your lungs feel great.", "You realize you haven't been breathing.", "You don't feel the need to breathe.")]"))
	return

/datum/symptom/oxygen/on_stage_change(datum/disease/advance/A)
	if(!..())
		return FALSE
	var/mob/living/carbon/M = A.affected_mob
	if(A.stage >= 4)
		ADD_TRAIT(M, TRAIT_NOBREATH, DISEASE_TRAIT)
	else
		REMOVE_TRAIT(M, TRAIT_NOBREATH, DISEASE_TRAIT)
	return TRUE

/datum/symptom/oxygen/End(datum/disease/advance/A)
	if(!..())
		return
	REMOVE_TRAIT(A.affected_mob, TRAIT_NOBREATH, DISEASE_TRAIT)
