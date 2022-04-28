GLOBAL_LIST_EMPTY(loaded_ruin_parts)

//Reads all ruin parts from the ruin generation file and processes them.
/proc/load_ruin_parts()
	GLOB.loaded_ruin_parts.Cut()
	for(var/subtype in subtypesof(/datum/map_template/ruin_part))
		var/datum/map_template/ruin_part/ruin_st = new subtype()
		GLOB.loaded_ruin_parts += ruin_st
	message_admins("Loaded ruin parts")
	log_mapping("Ruin parts loaded.")
