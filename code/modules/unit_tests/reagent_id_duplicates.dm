
/datum/unit_test/reagent_id_duplicates/Run()
	build_chemical_reactions_list()
	build_chemical_reagent_list()

	var/list/names = list()

	for(var/datum/chemical_reaction/reaction_path as anything in subtypesof(/datum/chemical_reaction))
		if (names[reaction_path::id])
			TEST_FAIL("The reaction with the ID [reaction_path::id] and path [reaction_path] is duplicated.")
		names[reaction_path::id] = TRUE

	var/paths = subtypesof(/datum/reagent)

	for(var/datum/reagent/path as anything in paths)
		if (ispath(path::name))
			TEST_FAIL("The reagent [path] is using a path for it's display name, rather than an appropriate name.")
