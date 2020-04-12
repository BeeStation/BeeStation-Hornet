#define SPAWNTYPE_ROUNDSTART "roundstart"
#define SPAWNTYPE_MIDROUND "midround"
#define SPAWNTYPE_EITHER "either"

/datum/special_role
	var/attached_antag_datum = /datum/antagonist/special
	var/spawn_mode = SPAWNTYPE_ROUNDSTART
	var/probability = 0				//The probability of any spawning
	var/min_players = 0				//Min player count (Forgot about this, might be important)
	var/max_players = -1			//Max player count (-1 for no max count)
	var/proportion = 0				//The prbability per person of rolling it
	var/max_amount = 0				//The maximum amount
	var/latejoin_allowed = TRUE		//Can latejoins be assigned to this?
	var/allowAntagTargets = FALSE
	var/role_name = "special role"
	var/list/protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Head of Personnel", "Chief Medical Officer", "Chief Engineer", "Research Director", "Captain", "Brig Physician")
	//Midround event vars
	var/weight = 10
	var/earliest_start = 20 MINUTES
	var/max_occurrences = 1
	var/holidayID = ""

/datum/special_role/New()
	. = ..()
	if(spawn_mode == SPAWNTYPE_ROUNDSTART)
		return
	//Create a new event for spawning the antag
	var/datum/round_event_control/E = new()
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
	return(A)

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
