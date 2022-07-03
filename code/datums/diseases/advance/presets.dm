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

/datum/disease/advance/feline_hysteria
	name = "Feline Hysteria"
	desc = "A very dangerous disease supposedly engineered by the Animal Rights Coalition. Causes mass feline hysteria."
	copy_type = /datum/disease/advance
	mutable = FALSE

/datum/disease/advance/feline_hysteria/New()
	name = "Feline Hysteria"
	desc = "A very dangerous disease supposedly engineered by the Animal Rights Coalition. Causes mass feline hysteria."
	mutable = FALSE
	symptoms = list(new/datum/symptom/toxoplasmosis, new/datum/symptom/viralincubate, new/datum/symptom/sneeze, new/datum/symptom/revitiligo, new/datum/symptom/inorganic_adaptation, new/datum/symptom/organ_restoration)
	for(var/datum/symptom/S as() in (symptoms))
		if(istype(S, /datum/symptom/toxoplasmosis))
			continue
		if(istype(S, /datum/symptom/organ_restoration))
			continue
		S.neutered = TRUE
	..()

//Randomly generated Disease, for virus crates and events
/datum/disease/advance/random
	name = "Experimental Disease"
	copy_type = /datum/disease/advance
	var/randomname = TRUE
	var/datum/symptom/setsymptom = null
	//this will determine later if the virus is the Original advanced random disease or, the mail version Minor Advanced random disease
	var/max_symptoms_override

//Randomly generated Disease, for mail!
/datum/disease/advance/random/minor
	name = "Minor Experimental Disease"
	max_symptoms_override = 4

/datum/disease/advance/random/New(max_symptoms, max_level = 9, min_level = 1, var/datum/symptom/specialsymptom = setsymptom, var/atom/infected)
	if(!max_symptoms)
		max_symptoms = (2 + rand(1, (VIRUS_SYMPTOM_LIMIT-2)))
	if(max_symptoms_override)
		max_symptoms = (max_symptoms_override - rand(0, 2))
	if(specialsymptom)
		max_symptoms -= 1
	var/list/datum/symptom/possible_symptoms = list()
	for(var/symptom in subtypesof(/datum/symptom))
		var/datum/symptom/S = symptom
		if(S == specialsymptom)
			continue
		if(initial(S.level) > max_level || initial(S.level) < min_level)
			continue
		if(initial(S.level) <= -1) //unobtainable symptoms
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
		var/randname = random_disease_name(infected)
		AssignName(randname)
		name = randname


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
