// Cold
/datum/disease/advance/cold
	copy_type = /datum/disease/advance

/datum/disease/advance/cold/New()
	name = "Cold"
	symptoms = list(new/datum/symptom/sneeze)
	..()

// Flu
/datum/disease/advance/flu
	copy_type = /datum/disease/advance

/datum/disease/advance/flu/New()
	name = "Flu"
	symptoms = list(new/datum/symptom/cough)
	..()

//Randomly generated Disease, for virus crates and events
/datum/disease/advance/random
	name = "Experimental Disease"
	copy_type = /datum/disease/advance
	var/randomname = TRUE
	var/datum/symptom/setsymptom = null

/datum/disease/advance/random/New(max_symptoms, max_level = 9, min_level = 1, var/datum/symptom/specialsymptom = setsymptom)
	if(!max_symptoms)
		max_symptoms = (2 + rand(1, (VIRUS_SYMPTOM_LIMIT-2)))
	if(specialsymptom)
		max_symptoms -= 1
	var/list/datum/symptom/possible_symptoms = list()
	for(var/symptom in subtypesof(/datum/symptom))
		var/datum/symptom/S = symptom
		if(S == specialsymptom)
			continue
		if(initial(S.level) > max_level || initial(S.level) < min_level)
			continue
		if(initial(S.level) <= 0) //unobtainable symptoms
			continue
		possible_symptoms += S
	for(var/i in 1 to max_symptoms)
		var/datum/symptom/chosen_symptom = pick_n_take(possible_symptoms)
		if(chosen_symptom)
			var/datum/symptom/S = new chosen_symptom
			symptoms += S
	if(specialsymptom)
		var/datum/symptom/special = new specialsymptom
		symptoms += special
	Finalize()
	Refresh()
	if(randomname)
		name = "Sample #[rand(1,10000)]"

/datum/disease/advance/random/macrophage
	name = "Unknown Disease"
	setsymptom = /datum/symptom/macrophage


/datum/disease/advance/random/necropolis
	name = "Necropolis Seed"
	setsymptom = /datum/symptom/necroseed
	randomname = FALSE

/datum/disease/advance/random/blob // had to do it this way due to an odd glitch
	name = "Blob Spores"
	setsymptom = /datum/symptom/blobspores
	randomname = FALSE
