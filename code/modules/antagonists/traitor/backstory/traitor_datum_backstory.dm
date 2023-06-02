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
	return

/datum/antagonist/traitor/proc/set_backstory(datum/traitor_backstory/new_backstory)
	return

/// Useful debug proc. Remove this before merge.
/proc/backstory_objectives()
	var/backstory_html = "<body>"
	for(var/datum/traitor_backstory/path as anything in subtypesof(/datum/traitor_backstory))
		var/datum/traitor_backstory/backstory = GLOB.traitor_backstories["[path]"]
		if(!istype(backstory))
			continue
		for(var/faction in list(TRAITOR_FACTION_SYNDICATE, TRAITOR_FACTION_BLACK_MARKET, TRAITOR_FACTION_INDEPENDENT))
			if(!(faction in backstory.allowed_factions))
				continue
			backstory_html += "<h1>[backstory.name] ([faction])</h1>"
			backstory_html += "<p>[backstory.description]</p>"
			for(var/datum/objective_backstory/obj_path as anything in subtypesof(/datum/objective_backstory/assassinate))
				var/datum/objective_backstory/obj_backstory = GLOB.traitor_objective_backstories["[obj_path]"]
				if(!istype(obj_backstory))
					continue
				if(!obj_backstory.is_recommended(backstory, faction))
					continue
				backstory_html += "<h2>Why? [obj_backstory.title]</h2>"
				if(faction != TRAITOR_FACTION_INDEPENDENT)
					backstory_html += "<blockquote>[obj_backstory.faction_text]</blockquote>"
				backstory_html += "<p>[obj_backstory.personal_text]</p>"
	backstory_html += "</body>"
	usr << browse(backstory_html, "window=backstory_list")
