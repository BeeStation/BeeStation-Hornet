/datum/antagonist/special
	name = "Special Additional Role"
	job_rank = ROLE_SPECIAL
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = FALSE
	var/probability = 0				//The probability of any spawning
	var/proportion = 0				//The prbability per person of rolling it
	var/max_amount = 0				//The maximum amount
	var/latejoin_allowed = TRUE		//Can latejoins be assigned to this?
	var/allowAntagTargets = FALSE
	var/role_name = "special role"
	var/list/protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Head of Personnel", "Chief Medical Officer", "Chief Engineer", "Research Director", "Captain", "Brig Physician")

/datum/antagonist/special/proc/equip()
	return

/datum/antagonist/special/proc/forge_objectives(var/datum/mind/undercovermind)
	return

/proc/is_special_type(var/datum/mind/M, var/datum/antagonist/special/A)
	for(var/i in M.antag_datums)
		if(istype(i, A))
			return TRUE
	return FALSE
