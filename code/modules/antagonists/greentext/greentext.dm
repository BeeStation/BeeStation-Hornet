/datum/antagonist/greentext
	name = "winner"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE //Not that it will be there for long
	banning_key = UNBANNABLE_ANTAGONIST
	leave_behaviour = ANTAGONIST_LEAVE_DESPAWN

/datum/antagonist/greentext/on_gain()
	. = ..()
	if(give_objectives)
		forge_objectives()

/datum/antagonist/greentext/forge_objectives()
	var/datum/objective/winner_objective = new("Succeed")
	winner_objective.completed = TRUE
	add_objective(winner_objective)
