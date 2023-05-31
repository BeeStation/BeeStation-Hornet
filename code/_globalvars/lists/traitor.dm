/// Associative list of /datum/traitor_backstory path strings to datums
GLOBAL_LIST_INIT(traitor_backstories, generate_traitor_backstories())
/// Associative list of /datum/objective_backstory path strings to datums
GLOBAL_LIST_INIT(traitor_objective_backstories, generate_traitor_objective_backstories())
/// Associative list of /datum/traitor_faction keys to datums
GLOBAL_LIST_INIT(traitor_factions_to_datum, generate_traitor_factions())
GLOBAL_LIST_INIT(traitor_factions, assoc_list_strip_value(GLOB.traitor_factions_to_datum))

/proc/generate_traitor_backstories()
	var/list/result = list()
	for(var/datum/traitor_backstory/path as anything in subtypesof(/datum/traitor_backstory))
		if(isnull(initial(path.name)))
			continue
		result["[path]"] = new path()
	return result

/proc/generate_traitor_objective_backstories()
	var/list/result = list()
	for(var/datum/objective_backstory/path as anything in subtypesof(/datum/objective_backstory))
		if(isnull(initial(path.title)))
			continue
		result["[path]"] = new path()
	return result

/proc/generate_traitor_factions()
	var/list/result = list()
	for(var/datum/traitor_faction/path as anything in subtypesof(/datum/traitor_faction))
		var/key = initial(path.key)
		if(!istext(key))
			continue
		result[key] = new path()
	return result
