//yoinked from hippie (infiltrators)
/datum/dynamic_ruleset/roundstart/infiltrator
	name = "Infiltration Unit"
	antag_flag = ROLE_INFILTRATOR
	antag_datum = /datum/antagonist/infiltrator
	minimum_required_age = 14
	required_candidates = 3
	weight = 10
	cost = 25
	requirements = list(90,90,90,80,60,40,30,20,10,10)
	high_population_requirement = 10
	var/infil_cap = list(2,3,3,3,3,4,4,5,5,5)
	var/datum/team/infiltrator/sit_team

/datum/dynamic_ruleset/roundstart/infiltrator/ready(forced = FALSE)
	var/indice_pop = min(10,round(mode.roundstart_pop_ready/pop_per_requirement)+1)
	required_candidates = infil_cap[indice_pop]
	. = ..()

/datum/dynamic_ruleset/roundstart/infiltrator/pre_execute()
	// If ready() did its job, candidates should have 5 or more members in it
	var/indice_pop = min(10,round(mode.roundstart_pop_ready/pop_per_requirement)+1)
	var/infiltrators = infil_cap[indice_pop]
	for(var/infils_number = 1 to infiltrators)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.assigned_role = ROLE_INFILTRATOR
		M.mind.special_role = ROLE_INFILTRATOR
	return TRUE

/datum/dynamic_ruleset/roundstart/infiltrator/execute()
	sit_team = new /datum/team/infiltrator
	for(var/datum/mind/M in assigned)
		M.add_antag_datum(/datum/antagonist/infiltrator, sit_team)
	sit_team.update_objectives()
	return TRUE
