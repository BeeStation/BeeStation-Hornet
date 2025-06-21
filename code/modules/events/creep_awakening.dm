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
		if(!H.client?.should_include_for_role(ROLE_OBSESSED, /datum/role_preference/midround_living/obsessed))
			continue
		if(H.stat == DEAD)
			continue
		if(!SSjob.GetJob(H.mind.assigned_role) || (H.mind.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SILICON))) //only station jobs sans nonhuman roles, prevents ashwalkers trying to stalk with crewmembers they never met
			continue
		if(H.mind.has_antag_datum(/datum/antagonist/obsessed))
			continue
		if(!H.get_organ_by_type(/obj/item/organ/brain))
			continue
		H.gain_trauma(/datum/brain_trauma/special/obsessed)
		announce_to_ghosts(H)
		break
