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

/datum/disease/advance/random/New(max_symptoms, max_level = 9, min_level = 1, list/guaranteed_symptoms = setsymptom, var/atom/infected)
	if(!max_symptoms)
		max_symptoms = (2 + rand(1, (VIRUS_SYMPTOM_LIMIT - 2)))
	if(max_symptoms_override)
		max_symptoms = (max_symptoms_override - rand(0, 2))
	if(guaranteed_symptoms)
		if(islist(guaranteed_symptoms))
			max_symptoms -= length(guaranteed_symptoms)
		else
			guaranteed_symptoms = list(guaranteed_symptoms)
			max_symptoms -= 1
	var/list/datum/symptom/possible_symptoms = list()
	for(var/datum/symptom/symptom as anything in subtypesof(/datum/symptom))
		if(symptom in guaranteed_symptoms)
			continue
		if(initial(symptom.level) > max_level || initial(symptom.level) < min_level)
			continue
		if(initial(symptom.level) <= -1) //unobtainable symptoms
			continue
		possible_symptoms += symptom
	for(var/i in 1 to max_symptoms)
		var/datum/symptom/chosen_symptom = pick_n_take(possible_symptoms)
		if(chosen_symptom)
			symptoms += new chosen_symptom
	for(var/guaranteed_symptom in guaranteed_symptoms)
		symptoms += new guaranteed_symptom
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

/mob/living/carbon/proc/give_random_dormant_disease(biohazard = 20, min_symptoms = 2, max_symptoms = 4, min_level = 4, max_level = 9, list/guaranteed_symptoms = list())
	. = FALSE
	var/sickrisk = 1
	if(islizard(src) || iscatperson(src))
		sickrisk += 0.5 //these races like eating diseased mice, ew
	if(MOB_INORGANIC in mob_biotypes)
		sickrisk -= 0.5
		guaranteed_symptoms |= /datum/symptom/inorganic_adaptation
	else if(MOB_ROBOTIC in mob_biotypes)
		sickrisk -= 0.75
		guaranteed_symptoms |= /datum/symptom/robotic_adaptation
	else if(MOB_UNDEAD in mob_biotypes)//this doesnt matter if it's not halloween, but...
		sickrisk -= 0.25
		guaranteed_symptoms |= /datum/symptom/undead_adaptation
	else if(!(MOB_ORGANIC in mob_biotypes))
		return //this mob cant be given a disease
	if(prob(min(100, (biohazard * sickrisk))))
		var/symptom_amt = rand(min_symptoms, max_symptoms)
		var/datum/disease/advance/dormant_disease = new /datum/disease/advance/random(symptom_amt, max_level, min_level, guaranteed_symptoms, infected = src)
		dormant_disease.dormant = TRUE
		dormant_disease.spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
		dormant_disease.spread_text = "None"
		dormant_disease.visibility_flags |= HIDDEN_SCANNER
		ForceContractDisease(dormant_disease)
		return TRUE
