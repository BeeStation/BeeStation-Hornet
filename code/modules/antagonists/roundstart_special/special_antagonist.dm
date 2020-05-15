////////////////////////////////
//////Special Role 'Controller'///////
////////////////////////////////
//To make your own special antagonist, simple setup the variables
//and setup the antag datum. See the undercover.dm file for help

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
	var/weight = 10
	var/earliest_start = 20 MINUTES
	var/max_occurrences = 1
	var/holidayID = ""
	//Preferences
	var/preference_type = ROLE_TRAITOR

/datum/special_role/proc/add_to_pool()
	if(spawn_mode == SPAWNTYPE_ROUNDSTART)
		return
	//Create a new event for spawning the antag
	var/datum/round_event_control/spawn_special_antagonist/E = new()
	E.name = role_name
	E.antagonist_datum = attached_antag_datum
	E.antag_name = role_name
	E.preference_type = preference_type
	E.protected_jobs = protected_jobs
	E.typepath = /datum/round_event/create_special_antag
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
//////  Antagonist Datum ///////
////////////////////////////////
//The datum associated with the role

/datum/antagonist/special
	name = "Role that should not be accessable in game."
	job_rank = ROLE_SYNDICATE
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = FALSE
	prevent_roundtype_conversion = FALSE
	delay_roundend = FALSE

/datum/antagonist/special/proc/equip()
	return

/datum/antagonist/special/proc/forge_objectives(var/datum/mind/undercovermind)
	return

/proc/is_special_type(var/datum/mind/M, var/datum/antagonist/special/A)
	for(var/i in M.antag_datums)
		if(istype(i, A))
			return TRUE
	return FALSE
