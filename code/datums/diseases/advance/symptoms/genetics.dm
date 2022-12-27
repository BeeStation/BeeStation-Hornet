/*
//////////////////////////////////////

DNA Saboteur

	Very noticable.
	Lowers resistance tremendously.
	No changes to stage speed.
	Decreases transmittablity tremendously.
	Fatal Level.

Bonus
	Cleans the DNA of a person and then randomly gives them a trait.

//////////////////////////////////////
*/

/datum/symptom/genetic_mutation
	name = "Deoxyribonucleic Acid Saboteur"
	desc = "The virus bonds with the DNA of the host, causing damaging mutations until removed."
	stealth = -2
	resistance = -3
	stage_speed = 0
	transmission = -3
	level = 3
	severity = 3
	var/list/possible_mutations
	var/archived_dna = null
	base_message_chance = 50
	symptom_delay_min = 60
	symptom_delay_max = 120
	prefixes = list("Genetic ", "Chromosomal ", "Mutagenic ", "Muta-")
	bodies = list("Mutant")
	var/no_reset = FALSE
	threshold_desc = "<b>Resistance 8:</b> Causes two harmful mutations at once.<br>\
					  <b>Stage Speed 10:</b> Increases mutation frequency.<br>\
					  <b>Stealth 5:</b> The mutations persist even if the virus is cured."

/datum/symptom/genetic_mutation/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= disease_genetic_mutation_resistance)
		severity += 1

/datum/symptom/genetic_mutation/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/C = A.affected_mob
	if(!C.has_dna())
		return
	switch(A.stage)
		if(4, 5)
			to_chat(C, "<span class='warning'>[pick("Your skin feels itchy.", "You feel light headed.")]</span>")
			C.dna.remove_mutation_group(possible_mutations)
			for(var/i in 1 to power)
				C.randmut(possible_mutations)

// Archive their DNA before they were infected.
/datum/symptom/genetic_mutation/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= disease_genetic_mutation_stealth) //don't restore dna after curing
		no_reset = TRUE
	if(A.stage_rate >= disease_genetic_mutation_stage_speed) //mutate more often
		symptom_delay_min = 20
		symptom_delay_max = 60
	if(A.resistance >= disease_genetic_mutation_resistance) //mutate twice
		power = 2
	possible_mutations = (GLOB.bad_mutations | GLOB.not_good_mutations) - GLOB.all_mutations[RACEMUT]
	var/mob/living/carbon/M = A.affected_mob
	if(M)
		if(!M.has_dna())
			return
		archived_dna = M.dna.mutation_index

// Give them back their old DNA when cured.
/datum/symptom/genetic_mutation/End(datum/disease/advance/A)
	if(!..())
		return
	if(!no_reset)
		var/mob/living/carbon/M = A.affected_mob
		if(M && archived_dna)
			if(!M.has_dna())
				return
			M.dna.mutation_index = archived_dna
			M.domutcheck()

/datum/symptom/genetic_mutation/Threshold(datum/disease/advance/A)
	if(!..())
		return
	threshold_desc = "<b>Resistance [disease_genetic_mutation_resistance]:</b> Causes two harmful mutations at once.<br>\
					  <b>Stage Speed [disease_genetic_mutation_stage_speed]:</b> Increases mutation frequency.<br>\
					  <b>Stealth [disease_genetic_mutation_stealth]:</b> The mutations persist even if the virus is cured."
	return threshold_desc