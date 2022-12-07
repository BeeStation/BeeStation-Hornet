/datum/team/frostwings
	name = "Frostwings"
	show_roundend_report = FALSE

/datum/antagonist/frostwing
	name = "Frostwing"
	job_rank = ROLE_LAVALAND
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	prevent_roundtype_conversion = FALSE
	antagpanel_category = "Frostwings"
	delay_roundend = FALSE
	count_against_dynamic_roll_chance = FALSE
	var/datum/team/frostwings/frost_team

/datum/antagonist/frostwing/create_team(datum/team/team)
	if(team)
		frost_team = team
		objectives |= frost_team.objectives
	else
		frost_team = new

/datum/antagonist/frostwing/get_team()
	return frost_team

/datum/antagonist/frostwing/on_gain()
	. = ..()
	give_objectives()

/datum/antagonist/frostwing/proc/give_objectives()
	var/datum/objective/newobjective = new
	newobjective.explanation_text = "Obtain resources and technology from the station in order to expand your home. Grow in numbers, and regain your footing as the natives of the ice moon."
	newobjective.owner = owner
	objectives += newobjective
	log_objective(owner, newobjective.explanation_text)
