/datum/round_event_control/wizard/race //Lizard Wizard? Lizard Wizard.
	name = "Race Swap"
	weight = 2
	typepath = /datum/round_event/wizard/race
	max_occurrences = 5
	earliest_start = 0 MINUTES

/datum/round_event/wizard/race/start()

	var/all_the_same = 0
	var/all_species = list()

	for(var/stype in subtypesof(/datum/species))
		var/datum/species/S = stype
		if(initial(S.changesource_flags) & RACE_SWAP)
			all_species += stype

	var/datum/species/new_species = pick(all_species)

	if(prob(50))
		all_the_same = 1

	for(var/mob/living/carbon/human/H in GLOB.carbon_list) //yes, even the dead
		H.set_species(new_species)
		H.dna.unique_enzymes = H.dna.generate_unique_enzymes()
		to_chat(H, "<span class='notice'>You feel somehow... different?</span>")
		if(!all_the_same)
			new_species = pick(all_species)
