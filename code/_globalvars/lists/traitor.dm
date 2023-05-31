/// Associative list of /datum/traitor_backstory path strings to datums
GLOBAL_LIST_INIT(traitor_backstories, generate_traitor_backstories())
/// Associative list of /datum/objective_backstory path strings to datums
GLOBAL_LIST_INIT(traitor_objective_backstories, generate_traitor_objective_backstories())

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
