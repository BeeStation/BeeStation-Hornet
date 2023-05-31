/proc/init_smites()
	var/list/smites = list()
	for (var/_smite_path in subtypesof(/datum/smite))
		var/datum/smite/smite_path = _smite_path
		smites[initial(smite_path.name)] = smite_path
	return smites

GLOBAL_LIST_INIT_TYPED(smites, /datum/smite, init_smites())
