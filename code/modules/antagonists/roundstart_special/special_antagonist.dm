#define SPAWNTYPE_ROUNDSTART 1
#define SPAWNTYPE_MIDROUND 2
#define SPAWNTYPE_EITHER 3

/datum/special_role
	var/attached_antag_datum = /datum/antagonist/special
	var/spawn_mode = SPAWNTYPE_ROUNDSTART
	var/probability = 0				//The probability of any spawning
	var/proportion = 0				//The prbability per person of rolling it
	var/max_amount = 0				//The maximum amount
	var/latejoin_allowed = TRUE		//Can latejoins be assigned to this?
	var/allowAntagTargets = FALSE
	var/role_name = "special role"
	var/list/protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Head of Personnel", "Chief Medical Officer", "Chief Engineer", "Research Director", "Captain", "Brig Physician")

/datum/special_role/New()
	. = ..()
	if(spawn_mode != SPAWNTYPE_ROUNDSTART)


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
