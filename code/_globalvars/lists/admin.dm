/proc/init_smites()
	var/list/smite_list = list()
	for (var/_smite_path in subtypesof(/datum/smite))
		var/datum/smite/smite_path = _smite_path
		smite_list[initial(smite_path.name)] = smite_path
	return smite_list

GLOBAL_LIST_INIT_TYPED(smite_list, /datum/smite, init_smites())

GLOBAL_VAR_INIT(admin_notice, "") // Admin notice that all clients see when joining the server
