/datum/antagonist/synapse_leech
	name = "Synapse Leech"
	roundend_category = "Synapse Leeches"
	antagpanel_category = "Synapse Leech"
	banning_key = ROLE_SPACE_LEECH
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	show_in_roundend = TRUE
	required_living_playtime = 0
	prevent_roundtype_conversion = FALSE

/datum/antagonist/synapse_leech/on_gain()
	owner.special_role = "Synapse Leech"
	forge_objectives()
	. = ..()

/datum/antagonist/synapse_leech/greet()
	. = ..()
	to_chat(owner, span_boldannounce("You are a Synapse Leech!"))
	to_chat(owner, span_alertwarning("You are a parasitic creature that thrives by burrowing into the skulls of the living and feeding on their brain matter. Survive, find a host, and propagate your kind."))
	owner.announce_objectives()

/datum/antagonist/synapse_leech/proc/forge_objectives()
	if(!give_objectives)
		return

	var/datum/objective/survive/leech/survive = new
	survive.owner = owner
	objectives += survive
	log_objective(owner, survive.explanation_text)

	var/datum/objective/synapse_leech_inside_host/host_objective = new
	host_objective.owner = owner
	objectives += host_objective
	log_objective(owner, host_objective.explanation_text)

	var/datum/objective/synapse_leech_reproduce/reproduce = new
	reproduce.owner = owner
	objectives += reproduce
	log_objective(owner, reproduce.explanation_text)

/// Survive subtype that also accepts simple/basic mob shells; the leech mob is the antag body.
/datum/objective/survive/leech
	name = "survive as a leech"
	explanation_text = "Stay alive, and not in critical condition, until the end of the round."

/**
 * Dummy objective: be currently nested inside a living host at roundend.
 * TODO: Implement once the host-burrowing mechanic is fleshed out.
 */
/datum/objective/synapse_leech_inside_host
	name = "inside host"
	explanation_text = "Be burrowed inside a living host when the round ends."

/datum/objective/synapse_leech_inside_host/check_completion()
	// Mechanic not yet implemented; treat as failed for now.
	return FALSE

/**
 * Dummy objective: have produced at least one offspring during the round.
 * TODO: Implement once the reproduction mechanic is fleshed out.
 */
/datum/objective/synapse_leech_reproduce
	name = "reproduce"
	explanation_text = "Reproduce at least once before the round ends."

/datum/objective/synapse_leech_reproduce/check_completion()
	// Mechanic not yet implemented; treat as failed for now.
	return FALSE
