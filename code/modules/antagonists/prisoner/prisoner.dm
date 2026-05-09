/datum/antagonist/prisoner
	name = "Prisoner"
	roundend_category = "Prisoner"
	banning_key = ROLE_PRISONER
	show_in_antagpanel = TRUE
	antagpanel_category = "Prisoners"
	show_to_ghosts = TRUE
	antag_hud_name = "prisoner"
	leave_behaviour = ANTAGONIST_LEAVE_DESPAWN

/datum/antagonist/prisoner/on_gain()
	forge_objectives()
	return ..()

/datum/antagonist/prisoner/proc/forge_objectives()
	var/datum/objective/escape/escape = new
	escape.owner = owner
	objectives += escape

/datum/antagonist/prisoner/greet()
	to_chat(owner, span_bigbold("You are the Prisoner!"))
	to_chat(owner, span_boldannounce("Due to overcrowding, you have been transferred from a Nanotrasen security facility out to this middle-of-nowhere science station. This might be your chance to escape! \
					Do anything you can to escape prison and sneak off the station when the shift ends, via an emergency pod or the main transfer shuttle. \
					Avoid killing as much as possible, especially non-security staff, but everything else is fair game!"))
	owner.announce_objectives()
