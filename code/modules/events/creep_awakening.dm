/datum/round_event_control/obsessed
	name = "Obsession Awakening"
	typepath = /datum/round_event/obsessed
	max_occurrences = 1
	min_players = 20
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event/obsessed
	fakeable = FALSE

/datum/round_event/obsessed/start()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.player_list))
		if(!H.client || !(ROLE_OBSESSED in H.client.prefs.be_special))
			continue
		if(H.stat == DEAD)
			continue
		if(H.mind.get_mind_role(JTYPE_JOB_PATH) == JOB_UNASSIGNED) // Unassigned might be not a crew you would meet never
			continue
		if(H.mind.has_antag_datum(/datum/antagonist/obsessed))
			continue
		if(!H.getorgan(/obj/item/organ/brain))
			continue
		H.gain_trauma(/datum/brain_trauma/special/obsessed)
		announce_to_ghosts(H)
		break
