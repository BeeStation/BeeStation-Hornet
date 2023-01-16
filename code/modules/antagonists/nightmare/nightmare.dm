/datum/antagonist/nightmare
	name = "Nightmare"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE

/datum/antagonist/nightmare/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/nightmare/greet()
	owner.announce_objectives()

/datum/antagonist/nightmare/proc/forge_objectives()
	var/datum/objective/smash_lights/nolight = new
	nolight.owner = owner
	objectives += nolight

/datum/objective/smash_lights
	explanation_text = "Ensure the station is shrouded in darkness, snuff out all lights and lightbringers that come after you."
	completed = TRUE
