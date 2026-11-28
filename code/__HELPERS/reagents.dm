/proc/chem_recipes_do_conflict(datum/chemical_reaction/r1, datum/chemical_reaction/r2)
	// Ensure both arguments are valid chemical reactions
	if(!istype(r1, /datum/chemical_reaction) || !istype(r2, /datum/chemical_reaction))
		return FALSE

	//do the non-list tests first, because they are cheaper
	if(r1.required_container != r2.required_container)
		return FALSE

	//do the non-list tests first, because they are cheaper
	if(r1.is_cold_recipe == r2.is_cold_recipe)
		if(r1.required_temp != r2.required_temp)
			//one reaction requires a more extreme temperature than the other, so there is no conflict
			return FALSE
	else
		var/datum/chemical_reaction/cold_one = r1.is_cold_recipe ? r1 : r2
		var/datum/chemical_reaction/warm_one = r1.is_cold_recipe ? r2 : r1
		if(cold_one.required_temp < warm_one.required_temp)
			//the range of temperatures does not overlap, so there is no conflict
			return FALSE

	//find the reactions with the shorter and longer required_reagents list
	var/datum/chemical_reaction/long_req
	var/datum/chemical_reaction/short_req
	if(r1.required_reagents.len > r2.required_reagents.len)
		long_req = r1
		short_req = r2
	else if(r1.required_reagents.len < r2.required_reagents.len)
		long_req = r2
		short_req = r1
	else
		//if they are the same length, sort instead by the length of the catalyst list
		//this is important if the required_reagents lists are the same
		if(r1.required_catalysts.len > r2.required_catalysts.len)
			long_req = r1
			short_req = r2
		else
			long_req = r2
			short_req = r1


	//check if the shorter reaction list is a subset of the longer one
	var/list/overlap = r1.required_reagents & r2.required_reagents
	if(overlap.len != short_req.required_reagents.len)
		//there is at least one reagent in the short list that is not in the long list, so there is no conflict
		return FALSE

	//check to see if the shorter reaction's catalyst list is also a subset of the longer reaction's catalyst list
	//if the longer reaction's catalyst list is a subset of the shorter ones, that is fine
	//if the reaction lists are the same, the short reaction will have the shorter required_catalysts list, so it will register as a conflict
	var/list/short_minus_long_catalysts = short_req.required_catalysts - long_req.required_catalysts
	if(short_minus_long_catalysts.len)
		//there is at least one unique catalyst for the short reaction, so there is no conflict
		return FALSE

	//if we got this far, the longer reaction will be impossible to create if the shorter one is earlier in GLOB.chemical_reactions_list_reactant_index, and will require the reagents to be added in a particular order otherwise
	return TRUE

/proc/get_chemical_reaction(id)
	if(!GLOB.chemical_reactions_list_reactant_index)
		return
	for(var/reagent in GLOB.chemical_reactions_list_reactant_index)
		for(var/R in GLOB.chemical_reactions_list_reactant_index[reagent])
			var/datum/reac = R
			if(reac.type == id)
				return R

/proc/remove_chemical_reaction(datum/chemical_reaction/R)
	if(!GLOB.chemical_reactions_list_reactant_index || !R)
		return
	for(var/rid in R.required_reagents)
		GLOB.chemical_reactions_list_reactant_index[rid] -= R

//see build_chemical_reactions_lists in _globalvars/lists/reagents.dm for explanations
/proc/add_chemical_reaction(datum/chemical_reaction/add)
	if(!GLOB.chemical_reactions_list_reactant_index || !add.required_reagents || !add.required_reagents.len)
		return
	var/rand_reagent = pick(add.required_reagents)
	if(!GLOB.chemical_reactions_list_reactant_index[rand_reagent])
		GLOB.chemical_reactions_list_reactant_index[rand_reagent] = list()
	GLOB.chemical_reactions_list_reactant_index[rand_reagent] += add

/proc/find_reagent_object_from_type(input)
	if(GLOB.chemical_reagents_list[input]) //prefer IDs!
		return GLOB.chemical_reagents_list[input]
	else
		return null

/* This proc returns a random reagent ID based on given 'flag_check' which is used to check bitflag for each reagent.
	 *--- arguments ---*
		* flag_check
			the method will return a random reagent id which has this flag.
			if you want a single category - get_random_reagent_id(CHEMICAL_BASIC_ELEMENT)
			if you want a multiple category - get_random_reagent_id(CHEMICAL_BASIC_ELEMENT|CHEMICAL_BASIC_DRINK|CHEMICAL_RNG_GENERAL)
			(check defines at `code\__DEFINES\reagents.dm`)
		* blacklist_flag
			the method will remove random reagents from the possible list when they have this flag. default NONE(0)
			same rule above
			(uses chemical defines)
		* union
			default TRUE. if FALSE, the same item will be added to the possible list, making some reagent higher chance to spawn when a reagent is called more than once.
			you will hardly use this though.
			(Bicaridine, Bicardine, Bicaridine means 3x chance than normal.)
		* return_as_list
			default FALSE. if TRUE, the proc will return its list rather than pick a certain ID from the list. Useful when you're going to set blacklist yourself (or add)

	 *--- How to add a new random reagent category ---*
		1. add a new flag at 'code\__DEFINES\reagents.dm' and `var/list/chem_defines` below
			i.e.) `define CHEMICAL_SOMETHING_NEW (1<10)`
		2. add a new static variable which is corresponding to the new flag.
			i.e.) `var/static/list/random_reagents_xx = list() // CHEMICAL_SOMETHING_NEW`
		3. add the new static variable to the 'random_reagent' list
			then done! (of course, don't forget to turn on the new flag at each desired reagent)
*/
/proc/get_random_reagent_id(flag_check, blacklist_flag = NONE, union = TRUE, return_as_list = FALSE)


	// ----below is a section you might want to edit for more chem RNGs----
	var/static/list/chem_defines = list( // check `code/__DEFINES/reagents.dm`
		CHEMICAL_BASIC_ELEMENT, // (1<<0)
		CHEMICAL_BASIC_DRINK,   // (1<<1)
		CHEMICAL_RNG_GENERAL,   // (1<<2)
		CHEMICAL_RNG_FUN,       // (1<<3)
		CHEMICAL_RNG_BOTANY,    // (1<<4)
		CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE,         // (1<<23) - goal_define starts at 23 and goes reversed.
		CHEMICAL_GOAL_BOTANIST_HARVEST,     // (1<<22)
		CHEMICAL_GOAL_BARTENDER_SERVING)    // (1<<21)
	var/static/list/random_reagents_b = list()  // CHEMICAL_BASIC_ELEMENT
	var/static/list/random_reagents_c = list()  // CHEMICAL_BASIC_DRINK
	var/static/list/random_reagents_d = list()  // CHEMICAL_RNG_GENERAL
	var/static/list/random_reagents_e = list()  // CHEMICAL_RNG_FUN
	var/static/list/random_reagents_f = list()  // CHEMICAL_RNG_BOTANY
	var/static/list/random_reagents_goal_a = list()  // CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE
	var/static/list/random_reagents_goal_b = list()  // CHEMICAL_GOAL_BOTANIST_HARVEST
	var/static/list/random_reagents_goal_c = list()  // CHEMICAL_GOAL_BARTENDER_SERVING
	var/static/list/random_reagent = list(
		random_reagents_b,
		random_reagents_c,
		random_reagents_d,
		random_reagents_e,
		random_reagents_f,
		random_reagents_goal_a,
		random_reagents_goal_b,
		random_reagents_goal_c)
	// ----above is a section you might want to edit for more chem RNGs----

	// initialize random reagent static lists
	if(!random_reagents_b.len)
		for(var/thing in subtypesof(/datum/reagent))
			var/i = 0
			for(var/each_define in chem_defines)
				i += 1
				var/datum/reagent/R = thing
				if(initial(R.randomized_spawns) & each_define)
					random_reagent[i] += R

	// returns a pick from a static before making a list - saving memory
	var/j = 0
	if(!blacklist_flag)
		for(var/each_define in chem_defines)
			j += 1
			if(each_define == flag_check)
				return (return_as_list ? random_reagent[j] : pick(random_reagent[j]))

	// if flag_check has multiple bitflags, then we're going to make a possible list.
	var/list/possible = list()
	j = 0
	for(var/each_define in chem_defines)
		j += 1
		if(each_define & flag_check)
			if(union)
				possible |= random_reagent[j]
			else //concatenation
				possible += random_reagent[j]

	if(blacklist_flag)
		j = 0
		for(var/each_define in chem_defines)
			j += 1
			if(each_define & flag_check)
				possible -= random_reagent[j]

	return (return_as_list ? possible : pick(possible))

/proc/get_chem_id(chem_name)
	for(var/X in GLOB.chemical_reagents_list)
		var/datum/reagent/R = GLOB.chemical_reagents_list[X]
		if(ckey(chem_name) == ckey(LOWER_TEXT(R.name)))
			return X

