
/datum/unit_test/reagent_id_duplicates/Run()
	for(var/datum/chemical_reaction/reaction_path as anything in subtypesof(/datum/chemical_reaction))
		if (!reaction_path::name)
			TEST_FAIL("The reaction with the path [reaction_path] has no name.")

	var/paths = subtypesof(/datum/reagent)

	for(var/datum/reagent/path as anything in paths)
		if (!path::name)
			TEST_FAIL("The reagent [path] has no display name.")
		else if (ispath(path::name))
			TEST_FAIL("The reagent [path] is using a path for it's display name, rather than an appropriate name.")
