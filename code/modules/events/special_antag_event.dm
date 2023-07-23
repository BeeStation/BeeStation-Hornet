/datum/round_event_control/spawn_special_antagonist
	name = "Special Antagonist Spawn Event"
	typepath = /datum/round_event/create_special_antag
	auto_add = FALSE
	//Antagonist data
	var/datum/antagonist/antagonist_datum = /datum/antagonist/special
	var/antag_name	//The datum of the antag E.G. /datum/antagonist/special/undercover
	var/preference_type = /datum/role_preference/antagonist/traitor
	var/banning_key = BAN_ROLE_ALL_ANTAGONISTS
	var/protected_jobs = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_CHIEFENGINEER, JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_CAPTAIN)

/datum/round_event_control/spawn_special_antagonist/runEvent()
	var/datum/round_event/create_special_antag/E = new /datum/round_event/create_special_antag
	E.antag_datum = antagonist_datum
	E.role_name = antag_name
	E.preference_type = preference_type
	E.banning_key = banning_key
	E.protected_jobs = protected_jobs
	E.current_players = get_active_player_count(alive_check = 1, afk_check = 1, human_check = 1)
	E.control = src
	SSblackbox.record_feedback("tally", "event_ran", 1, "[E]")
	occurrences++

	testing("[time2text(world.time, "hh:mm:ss")] [E.type]")
	if(random)
		log_game("Random Event triggering: [name] ([typepath])")
	if (alert_observers)
		deadchat_broadcast("<span class='deadsay'><b>[name]</b> has just been[random ? " randomly" : ""] triggered!</span>") //STOP ASSUMING IT'S BADMINS!
	return E

////////////////////////////////
//////    Round event    ///////
////////////////////////////////
//The event that is associated with the special antag

/datum/round_event/create_special_antag
	fakeable = FALSE
	var/role_name
	var/datum/antagonist/antag_datum	//The datum of the antag E.G. /datum/antagonist/special/undercover
	var/banning_key = BAN_ROLE_ALL_ANTAGONISTS
	var/preference_type = /datum/role_preference/antagonist/traitor
	var/protected_jobs = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_CHIEFENGINEER, JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_CAPTAIN)

/datum/round_event/create_special_antag/start()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.player_list))
		if(!H.client)
			continue
		if(!H.client.should_include_for_role(initial(antag_datum.banning_key), preference_type))
			continue
		if(H.stat == DEAD)
			continue
		if(!SSjob.GetJob(H.mind.assigned_role) || (H.mind.assigned_role in GLOB.nonhuman_positions)) //only station jobs sans nonhuman roles, prevents ashwalkers trying to stalk with crewmembers they never met
			continue
		if(H.mind.assigned_role in protected_jobs)
			continue
		if(H.mind.has_antag_datum(antag_datum))
			continue
		var/datum/mind/M = H.mind
		M.special_role = role_name
		var/datum/antagonist/special/A = M.add_antag_datum(antag_datum)
		if(!A)
			message_admins("[key_name(H.mind)] failed to become a [role_name]")
			log_game("[key_name(H.mind)] failed to become a [role_name]")
			return
		A.forge_objectives(M)
		A.equip()
		message_admins("[key_name(H.mind)] was randomly selected as [A.name]")
		log_game("[key_name(H.mind)] was randomly selected as [A.name]")
		announce_to_ghosts(H)
		break
