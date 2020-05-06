/datum/antagonist/supermatter_survivalist
	name = "Supermatter Survivalist"
	show_in_antagpanel = FALSE

/datum/antagonist/supermatter_survivalist/on_gain()
	. = ..()
	var/datum/objective/survive = new()
	survive.explanation_text = "Survive."
	survive.owner = owner
	objectives |= survive

/datum/antagonist/supermatter_survivalist/greet()
	. = ..()
	to_chat(owner, "<span class='boldannounce'>The severity of the situation dawns upon you. The end of the universe is nigh. You must do whatever it takes to survive it..</span>")

