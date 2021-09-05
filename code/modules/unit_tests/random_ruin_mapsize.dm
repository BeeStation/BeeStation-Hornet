/// Verifies that roundstart dynamic rulesets are setup properly without external configuration.
/datum/unit_test/random_ruin_mapsize

/datum/unit_test/random_ruin_mapsize/Run()
	load_ruin_parts()
	if(!length(GLOB.loaded_ruin_parts))
		Fail("Ruin maps failed to load")
	for(var/datum/map_template/ruin_part/part in GLOB.loaded_ruin_parts)
		if((part.width - 1) % 4 != 0)
			Fail("Ruin [part.file_name] width is not of size 4N+1")
		if((part.height - 1) % 4 != 0)
			Fail("Ruin [part.file_name] height is not of size 4N+1")
