/proc/reagent_paths_list_to_text(list/reagents, addendum)
	var/list/temp = list()
	for(var/datum/reagent/R as anything in reagents)
		temp |= initial(R.name)
	if(addendum)
		temp += addendum
	return jointext(temp, ", ")

// Returns the name of the mathematical tuple of same length as the number arg (rounded down).
/proc/make_tuple(number)
	var/static/list/units_prefix = list("", "un", "duo", "tre", "quattuor", "quin", "sex", "septen", "octo", "novem")
	var/static/list/tens_prefix = list("", "decem", "vigin", "trigin", "quadragin", "quinquagin", "sexagin", "septuagin", "octogin", "nongen")
	var/static/list/one_to_nine = list("monuple", "double", "triple", "quadruple", "quintuple", "sextuple", "septuple", "octuple", "nonuple")
	number = round(number)
	switch(number)
		if(0)
			return "empty tuple"
		if(1 to 9)
			return one_to_nine[number]
		if(10 to 19)
			return "[units_prefix[(number%10)+1]]decuple"
		if(20 to 99)
			return "[units_prefix[(number%10)+1]][tens_prefix[round((number % 100)/10)+1]]tuple"
		if(100)
			return "centuple"
		else //It gets too tedious to use latin prefixes from here.
			return "[number]-tuple"

///Returns a list of chemical_reaction datums that have the input STRING as a product
/proc/get_reagent_type_from_product_string(string)
	var/input_reagent = replacetext(lowertext(string), " ", "") //95% of the time, the reagent id is a lowercase/no spaces version of the name
	if (isnull(input_reagent))
		return

	var/list/shortcuts = list("meth" = /datum/reagent/drug/methamphetamine)
	if(shortcuts[input_reagent])
		input_reagent = shortcuts[input_reagent]
	else
		input_reagent = find_reagent(input_reagent)
	return input_reagent

///Returns reagent datum from typepath
/proc/find_reagent(input)
	. = FALSE
	if(GLOB.chemical_reagents_list[input]) //prefer IDs!
		return input
	else
		return get_chem_id(input)

/proc/find_reagent_object_from_type(input)
	if(GLOB.chemical_reagents_list[input]) //prefer IDs!
		return GLOB.chemical_reagents_list[input]
	else
		return null

/proc/get_random_reagent_id()	// Returns a random reagent ID minus blacklisted reagents and most foods and drinks
	var/static/list/random_reagents = list()
	if(!random_reagents.len)
		for(var/thing  in subtypesof(/datum/reagent))
			var/datum/reagent/R = thing
			if(initial(R.can_synth) && initial(R.random_unrestricted))
				random_reagents += R
	var/picked_reagent = pick(random_reagents)
	return picked_reagent

///Returns reagent datum from reagent name string
/proc/get_chem_id(chem_name)
	for(var/chemical in GLOB.chemical_reagents_list)
		var/datum/reagent/Reagent = GLOB.chemical_reagents_list[chemical]
		if(ckey(chem_name) == ckey(lowertext(Reagent.name)))
			return chemical

///Takes a type in and returns a list of associated recipes
/proc/get_recipe_from_reagent_product(input_type)
	if(!input_type)
		return
	var/list/matching_reactions = GLOB.chemical_reactions_list_product_index[input_type]
	return matching_reactions

/proc/get_chemical_reaction(id)
	if(!GLOB.chemical_reactions_list_reactant_index)
		return
	for(var/reagent in GLOB.chemical_reactions_list_reactant_index)
		for(var/R in GLOB.chemical_reactions_list_reactant_index[reagent])
			var/datum/reac = R
			if(reac.type == id)
				return R
