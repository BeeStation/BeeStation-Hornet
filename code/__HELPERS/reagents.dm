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

//see build_chemical_reactions_list in holder.dm for explanations
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
