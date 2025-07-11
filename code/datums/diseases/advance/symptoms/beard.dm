/*
//////////////////////////////////////
Facial Hypertrichosis

	No change to stealth.
	Increases resistance.
	Increases speed.
	Slighlty increases transmittability
	Intense Level.

BONUS
	Makes the mob grow a massive beard, regardless of gender.

//////////////////////////////////////
*/

/datum/symptom/beard

	name = "Facial Hypertrichosis"
	desc = "The virus increases hair production significantly, causing rapid beard growth."
	stealth = 1
	resistance = 3
	stage_speed = 3
	transmission = 1
	level = 5
	severity = 0
	symptom_delay_min = 18
	symptom_delay_max = 36
	prefixes = list("Facial ")
	bodies = list("Beard")

	var/list/beard_order = list("Beard (Jensen)", "Beard (Full)", "Beard (Dwarf)", "Beard (Very Long)")

/datum/symptom/beard/Activate(datum/disease/advance/disease)
	. = ..()
	if(!.)
		return

	var/mob/living/manly_mob = disease.affected_mob
	if(ishuman(manly_mob))
		var/mob/living/carbon/human/manly_man = manly_mob
		var/index = min(max(beard_order.Find(manly_man.facial_hairstyle)+1, disease.stage-1), beard_order.len)
		if(index > 0 && manly_man.facial_hairstyle != beard_order[index])
			to_chat(manly_man, span_warning("Your chin itches."))
			manly_man.set_facial_hairstyle(beard_order[index], update = TRUE)

