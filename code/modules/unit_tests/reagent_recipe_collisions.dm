/datum/unit_test/reagent_recipe_collisions

/datum/unit_test/reagent_recipe_collisions/Run()
	build_chemical_reactions_list()

	var/list/chemical_reactions = GLOB.chemical_reactions_list_reactant_index

	for(var/reaction_type_a as anything in chemical_reactions)
		for(var/reaction_type_b as anything in chemical_reactions)
			if(reaction_type_a == reaction_type_b)
				continue
			var/datum/chemical_reaction/reaction_a = chemical_reactions[reaction_type_a]
			var/datum/chemical_reaction/reaction_b = chemical_reactions[reaction_type_b]
			if(chem_recipes_do_conflict(reaction_a, reaction_b))
				TEST_FAIL("Chemical recipe conflict between [reaction_type_a] and [reaction_type_b]")
