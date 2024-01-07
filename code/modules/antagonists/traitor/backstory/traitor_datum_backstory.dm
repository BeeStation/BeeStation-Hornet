/datum/antagonist/traitor
	/// A list of factions the traitor can pick from freely.
	var/list/allowed_factions = list(TRAITOR_FACTION_SYNDICATE, TRAITOR_FACTION_BLACK_MARKET, TRAITOR_FACTION_INDEPENDENT)
	/// A list of factions the traitor can pick from freely.
	var/list/recommended_factions = list()
	/// A list of backstories that are allowed for this traitor.
	var/list/allowed_backstories
	/// A list of recommended backstories for this traitor, based on their murderbone status.
	var/list/recommended_backstories
	/// The actual backstory for this traitor. Can be null.
	var/datum/traitor_backstory/backstory
	/// The actual faction for this traitor. Can be null.
	var/datum/traitor_faction/faction

/datum/antagonist/traitor/proc/setup_backstories(murderbone, hijack)
	if(murderbone || hijack)
		recommended_factions = list(TRAITOR_FACTION_SYNDICATE, TRAITOR_FACTION_INDEPENDENT)
	allowed_backstories = list()
	recommended_backstories = list()
	for(var/datum/traitor_backstory/path as anything in subtypesof(/datum/traitor_backstory))
		var/datum/traitor_backstory/backstory = GLOB.traitor_backstories["[path]"]
		if(!istype(backstory))
			continue
		if(!murderbone)
			allowed_backstories += "[path]"
			if(hijack && backstory.murderbone)
				recommended_backstories += "[path]"
			continue
		if(backstory.has_motivation(TRAITOR_MOTIVATION_FORCED))
			continue
		allowed_backstories += "[path]"
		if(backstory.murderbone)
			recommended_backstories += "[path]"

	add_menu_action()

/datum/antagonist/traitor/proc/set_faction(datum/traitor_faction/new_faction)
	if(!istype(new_faction))
		return
	var/no_faction = isnull(faction)
	faction = new_faction
	employer = new_faction.employer_name
	if(no_faction)
		if(new_faction.give_codewords)
			give_codewords()
		equip(silent)
	log_game("[key_name(owner)] selected traitor faction [new_faction.name]")
	SSblackbox.record_feedback("tally", "traitor_faction_selected", 1, new_faction.name)

/datum/antagonist/traitor/proc/set_backstory(datum/traitor_backstory/new_backstory)
	backstory = new_backstory
	log_game("[key_name(owner)] selected traitor backstory [new_backstory.name]")
	SSblackbox.record_feedback("tally", "traitor_backstory_selected", 1, new_backstory.name)
