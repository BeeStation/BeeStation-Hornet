/*
//////////////////////////////////////

Deafness

	Slightly noticeable.
	Lowers resistance.
	Decreases stage speed slightly.
	Decreases transmittablity.
	Intense Level.

Bonus
	Causes intermittent loss of hearing.

//////////////////////////////////////
*/

/datum/symptom/deafness

	name = "Deafness"
	desc = "The virus causes inflammation of the eardrums, causing intermittent deafness."
	stealth = -1
	resistance = -1
	stage_speed = 1
	transmission = -3
	level = 3
	severity = 2
	base_message_chance = 100
	symptom_delay_min = 25
	symptom_delay_max = 80
	prefixes = list("Aural ")
	bodies = list("Ear")
	threshold_desc = "<b>Resistance 9:</b> Causes permanent deafness, instead of intermittent.<br>\
						<b>Stealth 4:</b> The symptom remains hidden until active."
	var/causes_permanent_deafness = FALSE

/datum/symptom/deafness/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 9)
		severity += 1

/datum/symptom/deafness/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.stealth >= 4)
		suppress_warning = TRUE
	if(A.resistance >= 9) //permanent deafness
		causes_permanent_deafness = TRUE

/datum/symptom/deafness/Activate(datum/disease/advance/advanced_disease)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/infected_mob = advanced_disease.affected_mob
	var/obj/item/organ/ears/ears = infected_mob.get_organ_slot(ORGAN_SLOT_EARS)

	switch(advanced_disease.stage)
		if(3, 4)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(infected_mob, span_warning("[pick("You hear a ringing in your ear.", "Your ears pop.")]"))
		if(5)
			if(causes_permanent_deafness)
				if(ears.damage < ears.maxHealth)
					to_chat(infected_mob, span_userdanger("Your ears pop painfully and start bleeding!"))
					// Just absolutely murder me man
					ears.apply_organ_damage(ears.maxHealth)
					infected_mob.emote("scream")
					ADD_TRAIT(infected_mob, TRAIT_DEAF, DISEASE_TRAIT)
			else
				to_chat(infected_mob, span_userdanger("Your ears pop and begin ringing loudly!"))
				ears.deaf = min(20, ears.deaf + 15)

/datum/symptom/deafness/on_stage_change(datum/disease/advance/advanced_disease)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/infected_mob = advanced_disease.affected_mob
	if(advanced_disease.stage < 5 || !causes_permanent_deafness)
		REMOVE_TRAIT(infected_mob, TRAIT_DEAF, DISEASE_TRAIT)
	return TRUE
