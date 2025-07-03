/datum/antagonist/slaughter
	name = "Slaughter demon"
	show_name_in_check_antagonists = TRUE
	var/objective_verb = "Kill"
	var/datum/mind/summoner
	banning_key = ROLE_SLAUGHTER_DEMON
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE

/datum/antagonist/slaughter/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/slaughter/greet()
	. = ..()
	owner.announce_objectives()

/datum/antagonist/slaughter/get_antag_name() // makes laughter demon in the same category with slaughter demon in orbit panel
	return "Slaughter demon"

/datum/antagonist/slaughter/proc/forge_objectives()
	if(summoner)
		var/datum/objective/assassinate/new_objective = new /datum/objective/assassinate
		new_objective.owner = owner
		new_objective.set_target(summoner)
		new_objective.explanation_text = "[objective_verb] [summoner.name], the one who summoned you."
		objectives += new_objective
		log_objective(owner, new_objective.explanation_text)
	var/datum/objective/new_objective2 = new /datum/objective
	new_objective2.owner = owner
	new_objective2.explanation_text = "[objective_verb] everyone[summoner ? " else while you're at it":""]."
	objectives += new_objective2
	log_objective(owner, new_objective2.explanation_text)

/datum/antagonist/slaughter/laughter
	name = "Laughter demon"
	objective_verb = "Hug and Tickle"
