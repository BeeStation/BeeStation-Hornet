/datum/antagonist/morph
	name = "Morph"
	show_name_in_check_antagonists = TRUE
	show_in_antagpanel = FALSE

//It does nothing! (Besides tracking)//Scratch that, it does something now at least

/datum/antagonist/morph/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/morph/greet()
	owner.announce_objectives()

/datum/antagonist/morph/proc/forge_objectives()
	var/datum/objective/eat_everything/consume = new
	consume.owner = owner
	objectives += consume


/datum/objective/eat_everything
	explanation_text = "Eat everything and anything to sate your never-ending hunger."
	completed = TRUE
