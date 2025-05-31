/// Test that all reagent names are different in order to prevent #65231 and tests that searching for that reagent by name gives the correct one
/datum/unit_test/reagent_names

/datum/unit_test/reagent_names/Run()
	var/used_names = list()

	// First check chemical reactions have names
	for(var/datum/chemical_reaction/reaction_path as anything in subtypesof(/datum/chemical_reaction))
		if (!reaction_path::name)
			TEST_FAIL("The reaction with the path [reaction_path] has no name.")

	// Then check reagents have valid names and no duplicates
	for (var/datum/reagent/reagent as anything in subtypesof(/datum/reagent))
		// Make sure names are different
		var/name = initial(reagent.name)
		if (!name)
			continue
		else if (ispath(name))
			TEST_FAIL("The reagent [reagent] is using a path for it's display name, rather than an appropriate name.")

		// Check for duplicate names
		if (name in used_names)
			TEST_FAIL("[used_names[name]] shares a name with [reagent] ([name])")
		else
			used_names[name] = reagent

		// Now make sure searching for that name gets us the right reagent
		var/datum/reagent/found_reagent = get_chem_id(name)

		if (!found_reagent)
			TEST_FAIL("Searching for [reagent] ([name]) returned nothing")

		var/found_name = initial(found_reagent.name)

		if (found_reagent != reagent)
			TEST_FAIL("Searching for [reagent] ([name]) returned [found_reagent] ([found_name]) instead")
