/// Associative list of /datum/traitor_backstory path strings to datums
GLOBAL_LIST_INIT(traitor_backstories, generate_traitor_backstories())
/// Associative list of /datum/traitor_faction keys to datums
GLOBAL_LIST_INIT(traitor_factions_to_datum, generate_traitor_factions())
GLOBAL_LIST_INIT(traitor_factions, assoc_to_keys(GLOB.traitor_factions_to_datum))

/proc/generate_traitor_backstories()
	var/list/result = list()
	for(var/datum/traitor_backstory/path as anything in subtypesof(/datum/traitor_backstory))
		if(isnull(initial(path.name)))
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

GLOBAL_LIST_INIT(traitor_motivations, list(
	TRAITOR_MOTIVATION_FORCED,
	TRAITOR_MOTIVATION_NOT_FORCED,
	TRAITOR_MOTIVATION_MONEY,
	TRAITOR_MOTIVATION_POLITICAL,
	TRAITOR_MOTIVATION_LOVE,
	TRAITOR_MOTIVATION_REPUTATION,
	TRAITOR_MOTIVATION_DEATH_THREAT,
	TRAITOR_MOTIVATION_AUTHORITY,
	TRAITOR_MOTIVATION_FUN,
))
