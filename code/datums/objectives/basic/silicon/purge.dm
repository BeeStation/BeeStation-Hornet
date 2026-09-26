/datum/objective/purge
	name = "no mutants on shuttle"
	explanation_text = "Ensure no mutant humanoid species are present aboard the escape shuttle."
	murderbone_flag = TRUE

/datum/objective/purge/check_completion()
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return TRUE

	for(var/mob/living/carbon/human/human_player in GLOB.player_list)
		if(!human_player.mind)
			continue
		if(human_player.stat == DEAD)
			continue
		if(!(get_area(human_player) in SSshuttle.emergency.shuttle_areas))
			continue
		if(human_player.dna.species.id == SPECIES_HUMAN)
			continue
		return ..()
	return TRUE
