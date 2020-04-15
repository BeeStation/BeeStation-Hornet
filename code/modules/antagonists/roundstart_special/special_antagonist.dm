////////////////////////////////
//////Special Role 'Controller'///////
////////////////////////////////

/datum/special_role
	var/attached_antag_datum = /datum/antagonist/special
	var/spawn_mode = SPAWNTYPE_ROUNDSTART
	var/probability = 0				//The probability of any spawning
	var/min_players = 0				//Min player count (Forgot about this, might be important)
	var/max_players = -1			//Max player count (-1 for no max count)
	var/proportion = 0				//The prbability per person of rolling it
	var/max_amount = 0				//The maximum amount
	var/role_name = "special role"
	//----Required for roundspawn----
	var/allowAntagTargets = FALSE	//Not used in events
	var/latejoin_allowed = TRUE		//Can latejoins be assigned to this? If you want this to be a midround spawn, put these in the round_event
	var/list/protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Head of Personnel", "Chief Medical Officer", "Chief Engineer", "Research Director", "Captain", "Brig Physician")
	//----Required for midround----
	var/event_typepath = /datum/round_event/create_special_antag
	var/weight = 10
	var/earliest_start = 20 MINUTES
	var/max_occurrences = 1
	var/holidayID = ""
	//Preferences
	var/preference_type = ROLE_SPECIAL

/datum/special_role/New()
	. = ..()
	if(spawn_mode == SPAWNTYPE_ROUNDSTART)
		return
	//Create a new event for spawning the antag
	var/datum/round_event_control/E = new()
	E.name = role_name
	E.typepath = event_typepath
	E.weight = weight
	E.holidayID = holidayID
	if(config)
		E.earliest_start = CEILING(earliest_start * CONFIG_GET(number/events_min_time_mul), 1)
		E.min_players = CEILING(min_players * CONFIG_GET(number/events_min_players_mul), 1)
	else
		E.earliest_start = earliest_start
		E.min_players = min_players
	//Shove our event into the subsystem pool :)
	SSevents.control += E

/datum/special_role/proc/add_antag_status_to(var/datum/mind/M)
	M.special_role = role_name
	var/datum/antagonist/special/A = M.add_antag_datum(new attached_antag_datum())
	A.forge_objectives(M)
	A.equip()
	return A

////////////////////////////////
//////    Round event    ///////
////////////////////////////////
//The event that is associated with the special antag
//If you are making a midround event that uses this system
//Create a datum that implements /datum/round_event/create_special_antag
//and put that datum as the event_typepath variable in
//The controller.
//If your role cannot spawn midround, don't bother making it.

/datum/round_event/create_special_antag
	fakeable = FALSE
	var/role_name
	var/antag_datum	//The datum of the antag E.G. /datum/antagonist/special/undercover
	var/preference_type = ROLE_SPECIAL
	var/protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Head of Personnel", "Chief Medical Officer", "Chief Engineer", "Research Director", "Captain", "Brig Physician")

/datum/round_event/create_special_antag/start()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.player_list))
		if(!H.client || !(preference_type in H.client.prefs.be_special) || !(H.client.prefs.allow_midround_antag))
			continue
		if(is_banned_from(H, list(preference_type)))
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

////////////////////////////////
//////  Antagonist Datum ///////
////////////////////////////////
//The datum associated with the role

/datum/antagonist/special
	name = "Special Additional Role"
	job_rank = ROLE_SPECIAL
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = FALSE

/datum/antagonist/special/proc/equip()
	return

/datum/antagonist/special/proc/forge_objectives(var/datum/mind/undercovermind)
	return

/proc/is_special_type(var/datum/mind/M, var/datum/antagonist/special/A)
	for(var/i in M.antag_datums)
		if(istype(i, A))
			return TRUE
	return FALSE
