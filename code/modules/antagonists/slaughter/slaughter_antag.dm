/datum/antagonist/slaughter
	name = "Slaughter demon"
	show_name_in_check_antagonists = TRUE
	banning_key = ROLE_SLAUGHTER_DEMON
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE

	var/objective_verb = "Kill"
	var/datum/mind/summoner

/datum/antagonist/slaughter/on_gain()
	. = ..()
	if(give_objectives)
		forge_objectives()

/datum/antagonist/slaughter/greet()
	owner.announce_objectives()

/datum/antagonist/slaughter/get_antag_name() // makes laughter demon in the same category with slaughter demon in orbit panel
	return "Slaughter demon"

/datum/antagonist/slaughter/forge_objectives()
	if(summoner)
		var/datum/objective/assassinate/assassinate_objective = new()
		assassinate_objective.set_target(summoner)
		assassinate_objective.explanation_text = "[objective_verb] [summoner.name], the one who summoned you."
		add_objective(assassinate_objective)

	add_objective(new /datum/objective("[objective_verb] everyone[summoner ? " else while you're at it":""]."))

/datum/antagonist/slaughter/laughter
	name = "Laughter demon"
	objective_verb = "Hug and Tickle"
