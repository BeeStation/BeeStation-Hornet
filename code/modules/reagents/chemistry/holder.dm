#define CHEMICAL_QUANTISATION_LEVEL 0.0001 //stops floating point errors causing issues with checking reagent amounts

#define REAGENTS_UI_MODE_LOOKUP 0
#define REAGENTS_UI_MODE_REAGENT 1
#define REAGENTS_UI_MODE_RECIPE 2

/proc/build_chemical_reagent_list()
	//Chemical Reagents - Initialises all /datum/reagent into a list indexed by reagent id

	if(GLOB.chemical_reagents_list)
		return

	var/paths = subtypesof(/datum/reagent)
	GLOB.chemical_reagents_list = list()

	for(var/path in paths)
		var/datum/reagent/D = new path()
		GLOB.chemical_reagents_list[path] = D

/proc/build_chemical_reactions_list()
	//Chemical Reactions - Initialises all /datum/chemical_reaction into a list
	// It is filtered into multiple lists within a list.
	// For example:
	// chemical_reaction_list[/datum/reagent/toxin/plasma] is a list of all reactions relating to plasma

	//For chemical reaction list product index - indexes reactions based off the product reagent type - see get_recipe_from_reagent_product() in helpers
	//For chemical reactions list lookup list - creates a bit list of info passed to the UI. This is saved to reduce lag from new windows opening, since it's a lot of data.




	if(GLOB.chemical_reactions_list)
		return


	var/paths = subtypesof(/datum/chemical_reaction)
	GLOB.chemical_reactions_list = list()
	GLOB.chemical_reactions_list_reactant_index = list() //reagents to reaction list
	GLOB.chemical_reactions_results_lookup_list = list() //UI glob
	GLOB.chemical_reactions_list_product_index = list() //product to reaction list

	for(var/path in paths)
		var/datum/chemical_reaction/D = new path()
		var/list/reaction_ids = list()
		var/list/product_ids = list()
		var/list/reagents = list()
		var/list/product_names = list()
		var/bitflags = D.reaction_tags

		if(!D.required_reagents || !D.required_reagents.len) //Skip impossible reactions
			continue
		for(var/reaction in D.required_reagents)
			reaction_ids += reaction
			var/datum/reagent/reagent = find_reagent_object_from_type(reaction)
			reagents += list(list("name" = reagent.name, "id" = reagent.type))

		for(var/product in D.results)
			var/datum/reagent/reagent = find_reagent_object_from_type(product)
			product_names += reagent.name
			product_ids += product

		var/product_name
		if(!length(product_names))
			var/list/names = splittext("[D.type]", "/")
			product_name = names[names.len]
		else
			product_name = product_names[1]

		// Create filters based on each reagent id in the required reagents list - this is specifically for finding reactions from product(reagent) ids/typepaths.
		for(var/id in product_ids)
			if(!GLOB.chemical_reactions_list_product_index[id])
				GLOB.chemical_reactions_list_product_index[id] = list()
			GLOB.chemical_reactions_list_product_index[id] += D

		//Master list of ALL reactions that is used in the UI lookup table. This is expensive to make, and we don't want to lag the server by creating it on UI request, so it's cached to send to UIs instantly.
		if(bitflags)
			GLOB.chemical_reactions_results_lookup_list += list(list("name" = product_name, "id" = D.type, "bitflags" = bitflags, "reactants" = reagents))

				// Create filters based on each reagent id in the required reagents list - this is used to speed up handle_reactions()
		for(var/id in reaction_ids)
			if(!GLOB.chemical_reactions_list_reactant_index[id])
				GLOB.chemical_reactions_list_reactant_index[id] = list()
			GLOB.chemical_reactions_list_reactant_index[id] += D

///////////////////////////////////////////////////////////////////////////////////

/datum/reagents
	var/list/datum/reagent/reagent_list = new/list()
	var/total_volume = 0
	var/maximum_volume = 100
	var/atom/my_atom = null
	var/chem_temp = 150
	var/last_tick = 1
	///cached list of reagents typepaths (not object references), this is a lazylist for optimisation
	var/list/datum/reagent/previous_reagent_list
	var/flags
	///UI lookup stuff
	///Keeps the id of the reaction displayed in the ui
	var/ui_reaction_id = null
	///Keeps the id of the reagent displayed in the ui
	var/ui_reagent_id = null
	///The bitflag of the currently selected tags in the ui
	var/ui_tags_selected = NONE
	///What index we're at if we have multiple reactions for a reagent product
	var/ui_reaction_index = 1
	///If we're syncing with the beaker - so return reactions that are actively happening
	var/ui_beaker_sync = FALSE

/datum/reagents/New(maximum=100, new_flags=0)
	maximum_volume = maximum

	//I dislike having these here but map-objects are initialised before world/New() is called. >_>
	if(!GLOB.chemical_reagents_list)
		build_chemical_reagent_list()
	if(!GLOB.chemical_reactions_list)
		build_chemical_reactions_list()

	flags = new_flags

/datum/reagents/Destroy()
	. = ..()
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		qdel(R)
	cached_reagents.Cut()
	cached_reagents = null
	if(my_atom?.reagents == src)
		my_atom.reagents = null
	my_atom = null

// Used in attack logs for reagents in pills and such
/datum/reagents/proc/log_list()
	if(!length(reagent_list))
		return "no reagents"

	var/list/data = list()
	for(var/r in reagent_list) //no reagents will be left behind
		var/datum/reagent/R = r
		data += "[R.type] ([round(R.volume, 0.1)]u)"
		//Using IDs because SOME chemicals (I'm looking at you, chlorhydrate-beer) have the same names as other chemicals.
	return english_list(data)

/////////////////////////////////////////////////////////////////////////////////
///////////////////////////UI / REAGENTS LOOKUP CODE/////////////////////////////
/////////////////////////////////////////////////////////////////////////////////


/datum/reagents/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Reagents", "Reaction search")
		ui.status = UI_INTERACTIVE //How do I prevent a UI from autoclosing if not in LoS
		ui_tags_selected = NONE //Resync with gui on open (gui expects no flags)
		ui_reagent_id = null
		ui_reaction_id = null
		ui.open()


/datum/reagents/ui_status(mob/user)
	return UI_INTERACTIVE //please advise

/datum/reagents/ui_state(mob/user)
	return GLOB.physical_state

/datum/reagents/proc/generate_possible_reactions()
	var/list/cached_reagents = reagent_list
	if(!cached_reagents)
		return null
	var/list/cached_reactions = list()
	var/list/possible_reactions = list()
	if(!length(cached_reagents))
		return null
	cached_reactions = GLOB.chemical_reactions_list_reactant_index
	for(var/_reagent in cached_reagents)
		var/datum/reagent/reagent = _reagent
		for(var/_reaction in cached_reactions[reagent.type]) // Was a big list but now it should be smaller since we filtered it with our reagent id
			var/datum/chemical_reaction/reaction = _reaction
			if(!_reaction)
				continue
			if(!reaction.required_reagents)//Don't bring in empty ones
				continue
			var/list/cached_required_reagents = reaction.required_reagents
			var/total_matching_reagents = 0
			for(var/req_reagent in cached_required_reagents)
				if(!has_reagent(req_reagent, (cached_required_reagents[req_reagent]*0.01)))
					continue
				total_matching_reagents++
			if(total_matching_reagents >= reagent_list.len)
				possible_reactions += reaction
	return possible_reactions

/datum/reagents/proc/parse_addictions(datum/reagent/reagent)
	var/addict_text = list()
	for(var/entry in reagent.addiction_types)
		var/datum/addiction/ref = SSaddiction.all_addictions[entry]
		switch(reagent.addiction_types[entry])
			if(-INFINITY to 0)
				continue
			if(0 to 5)
				addict_text += "Weak [ref.name]"
			if(5 to 10)
				addict_text += "[ref.name]"
			if(10 to 20)
				addict_text += "Strong [ref.name]"
			if(20 to INFINITY)
				addict_text += "Potent [ref.name]"
	return addict_text

/datum/reagents/ui_data(mob/user)
	var/data = list()
	data["selectedBitflags"] = ui_tags_selected
	data["currentReagents"] = previous_reagent_list //This keeps the string of reagents that's updated when handle_reactions() is called
	data["beakerSync"] = ui_beaker_sync
	data["linkedBeaker"] = my_atom.name //To solidify the fact that the UI is linked to a beaker - not a machine.
	//reagent lookup data
	if(ui_reagent_id)
		var/datum/reagent/reagent = find_reagent_object_from_type(ui_reagent_id)
		if(!reagent)
			to_chat(user, "Could not find reagent!")
			ui_reagent_id = null
		else
			data["reagent_mode_reagent"] = list("name" = reagent.name, "id" = reagent.type, "desc" = reagent.description, "reagentCol" = reagent.color, "metaRate" = (reagent.metabolization_rate/2), "OD" = reagent.overdose_threshold)
			data["reagent_mode_reagent"]["addictions"] = list()
			data["reagent_mode_reagent"]["addictions"] = parse_addictions(reagent)


	//reaction lookup data
	if (ui_reaction_id)

		var/datum/chemical_reaction/reaction = get_chemical_reaction(ui_reaction_id)
		if(!reaction)
			to_chat(user, "Could not find reaction!")
			to_chat(user, "[ui_reaction_id]")
			ui_reaction_id = null
			return data
		//Required holder
		var/container_name
		if(reaction.required_container)
			var/list/names = splittext("[reaction.required_container]", "/")
			container_name = "[names[names.len-1]] [names[names.len]]"
			container_name = replacetext(container_name, "_", " ")

		//Next, find the product
		var/has_product = TRUE
		//If we have no product, use the typepath to create a name for it
		if(!length(reaction.results))
			has_product = FALSE
			var/list/names = splittext("[reaction.type]", "/")
			var/product_name = names[names.len]
			data["reagent_mode_recipe"] = list("name" = product_name, "id" = reaction.type, "hasProduct" = has_product, "reagentCol" = "#FFFFFF", "tempMin" = reaction.required_temp, "reqContainer" = container_name, "subReactLen" = 1, "subReactIndex" = 1)

		//If we do have a product then we find it
		else
			//Find out if we have multiple reactions for the same product
			var/datum/reagent/primary_reagent = find_reagent_object_from_type(reaction.results[1])//We use the first product - though it might be worth changing this
			//If we're syncing from the beaker
			var/list/sub_reactions = list()
			sub_reactions = get_recipe_from_reagent_product(primary_reagent.type)
			var/sub_reaction_length = length(sub_reactions)
			var/i = 1
			for(var/datum/chemical_reaction/sub_reaction in sub_reactions)
				if(sub_reaction.type == reaction.type)
					ui_reaction_index = i //update our index
					break
				i += 1
			data["reagent_mode_recipe"] = list("name" = primary_reagent.name, "id" = reaction.id, "hasProduct" = has_product, "reagentCol" = primary_reagent.color, "tempMin" = reaction.required_temp, "reqContainer" = container_name, "subReactLen" = sub_reaction_length, "subReactIndex" = ui_reaction_index)

		//Results sweep
		var/has_reagent = "default"
		for(var/_reagent in reaction.results)
			var/datum/reagent/reagent = find_reagent_object_from_type(_reagent)
			if(has_reagent(_reagent))
				has_reagent = "green"
			data["reagent_mode_recipe"]["products"] += list(list("name" = reagent.name, "id" = reagent.type, "ratio" = reaction.results[reagent.type], "hasReagentCol" = has_reagent))

		//Reactant sweep
		for(var/_reagent in reaction.required_reagents)
			var/datum/reagent/reagent = find_reagent_object_from_type(_reagent)
			var/color_r = "default" //If the holder is missing the reagent, it's displayed in orange
			if(has_reagent(reagent.type))
				color_r = "green" //It's green if it's present
			var/tooltip
			var/tooltip_bool = FALSE
			var/list/sub_reactions = get_recipe_from_reagent_product(reagent.type)
			//Get sub reaction possibilities, but ignore ones that need a specific holder atom
			var/sub_index = 0
			for(var/datum/chemical_reaction/sub_reaction as anything in sub_reactions)
				if(sub_reaction.required_container)//So we don't have slime reactions confusing things
					sub_index++
					continue
				sub_index++
				break
			if(sub_index)
				var/datum/chemical_reaction/sub_reaction = sub_reactions[sub_index]
				//Subreactions sweep (if any)
				for(var/_sub_reagent in sub_reaction.required_reagents)
					var/datum/reagent/sub_reagent = find_reagent_object_from_type(_sub_reagent)
					tooltip += "[sub_reaction.required_reagents[_sub_reagent]]u [sub_reagent.name]\n" //I forgot the better way of doing this - fix this after this works
					tooltip_bool = TRUE
			data["reagent_mode_recipe"]["reactants"] += list(list("name" = reagent.name, "id" = reagent.type, "ratio" = reaction.required_reagents[reagent.type], "color" = color_r, "tooltipBool" = tooltip_bool, "tooltip" = tooltip))

		//Catalyst sweep
		for(var/_reagent in reaction.required_catalysts)
			var/datum/reagent/reagent = find_reagent_object_from_type(_reagent)
			var/color_r = "default"
			if(has_reagent(reagent.type))
				color_r = "green"
			var/tooltip
			var/tooltip_bool = FALSE
			var/list/sub_reactions = get_recipe_from_reagent_product(reagent.type)
			if(length(sub_reactions))
				var/datum/chemical_reaction/sub_reaction = sub_reactions[1]
				//Subreactions sweep (if any)
				for(var/_sub_reagent in sub_reaction.required_reagents)
					var/datum/reagent/sub_reagent = find_reagent_object_from_type(_sub_reagent)
					tooltip += "[sub_reaction.required_reagents[_sub_reagent]]u [sub_reagent.name]\n" //I forgot the better way of doing this - fix this after this works
					tooltip_bool = TRUE
			data["reagent_mode_recipe"]["catalysts"] += list(list("name" = reagent.name, "id" = reagent.type, "ratio" = reaction.required_catalysts[reagent.type], "color" = color_r, "tooltipBool" = tooltip_bool, "tooltip" = tooltip))
		data["reagent_mode_recipe"]["isColdRecipe"] = reaction.is_cold_recipe

	return data

/datum/reagents/ui_static_data(mob/user)
	var/data = list()
	//Use GLOB list - saves processing
	data["master_reaction_list"] = GLOB.chemical_reactions_results_lookup_list
	data["bitflags"] = list()
	data["bitflags"]["BRUTE"] = REACTION_TAG_BRUTE
	data["bitflags"]["BURN"] = REACTION_TAG_BURN
	data["bitflags"]["TOXIN"] = REACTION_TAG_TOXIN
	data["bitflags"]["OXY"] = REACTION_TAG_OXY
	data["bitflags"]["CLONE"] = REACTION_TAG_CLONE
	data["bitflags"]["HEALING"] = REACTION_TAG_HEALING
	data["bitflags"]["DAMAGING"] = REACTION_TAG_DAMAGING
	data["bitflags"]["EXPLOSIVE"] = REACTION_TAG_EXPLOSIVE
	data["bitflags"]["OTHER"] = REACTION_TAG_OTHER
	data["bitflags"]["DANGEROUS"] = REACTION_TAG_DANGEROUS
	data["bitflags"]["EASY"] = REACTION_TAG_EASY
	data["bitflags"]["MODERATE"] = REACTION_TAG_MODERATE
	data["bitflags"]["HARD"] = REACTION_TAG_HARD
	data["bitflags"]["ORGAN"] = REACTION_TAG_ORGAN
	data["bitflags"]["DRINK"] = REACTION_TAG_DRINK
	data["bitflags"]["FOOD"] = REACTION_TAG_FOOD
	data["bitflags"]["SLIME"] = REACTION_TAG_SLIME
	data["bitflags"]["DRUG"] = REACTION_TAG_DRUG
	data["bitflags"]["UNIQUE"] = REACTION_TAG_UNIQUE
	data["bitflags"]["CHEMICAL"] = REACTION_TAG_CHEMICAL
	data["bitflags"]["PLANT"] = REACTION_TAG_PLANT
	data["bitflags"]["COMPETITIVE"] = REACTION_TAG_COMPETITIVE

	return data

/* Returns a reaction type by index from an input reagent type
* i.e. the input reagent's associated reactions are found, and the index determines which one to return
* If the index is out of range, it is set to 1
*/
/datum/reagents/proc/get_reaction_from_indexed_possibilities(path, index = null)
	if(index)
		ui_reaction_index = index
	var/list/sub_reactions = get_recipe_from_reagent_product(path)
	if(!length(sub_reactions))
		to_chat(usr, "There is no recipe associated with this product.")
		return FALSE
	if(ui_reaction_index > length(sub_reactions))
		ui_reaction_index = 1
	var/datum/chemical_reaction/reaction = sub_reactions[ui_reaction_index]
	return reaction.type

/datum/reagents/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("find_reagent_reaction")
			ui_reaction_id = get_reaction_from_indexed_possibilities(text2path(params["id"]))
			return TRUE
		if("reagent_click")
			ui_reagent_id = text2path(params["id"])
			return TRUE
		if("recipe_click")
			ui_reaction_id = text2path(params["id"])
			return TRUE
		if("search_reagents")
			var/input_reagent = (input("Enter the name of any reagent", "Input") as text|null)
			input_reagent = get_reagent_type_from_product_string(input_reagent) //from string to type
			var/datum/reagent/reagent = find_reagent_object_from_type(input_reagent)
			if(!reagent)
				to_chat(usr, "Could not find reagent!")
				return FALSE
			ui_reagent_id = reagent.type
			return TRUE
		if("search_recipe")
			var/input_reagent = (input("Enter the name of product reagent", "Input") as text|null)
			input_reagent = get_reagent_type_from_product_string(input_reagent) //from string to type
			var/datum/reagent/reagent = find_reagent_object_from_type(input_reagent)
			if(!reagent)
				to_chat(usr, "Could not find product reagent!")
				return
			ui_reaction_id = get_reaction_from_indexed_possibilities(reagent.type)
			return TRUE
		if("increment_index")
			ui_reaction_index += 1
			if(!ui_beaker_sync)
				ui_reaction_id = get_reaction_from_indexed_possibilities(get_reagent_type_from_product_string(params["id"]))
			return TRUE
		if("reduce_index")
			if(ui_reaction_index == 1)
				return
			ui_reaction_index -= 1
			if(!ui_beaker_sync)
				ui_reaction_id = get_reaction_from_indexed_possibilities(get_reagent_type_from_product_string(params["id"]))
			return TRUE
		if("beaker_sync")
			ui_beaker_sync = !ui_beaker_sync
			return TRUE
		if("toggle_tag_brute")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_BRUTE
			return TRUE
		if("toggle_tag_burn")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_BURN
			return TRUE
		if("toggle_tag_toxin")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_TOXIN
			return TRUE
		if("toggle_tag_oxy")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_OXY
			return TRUE
		if("toggle_tag_clone")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_CLONE
			return TRUE
		if("toggle_tag_healing")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_HEALING
			return TRUE
		if("toggle_tag_damaging")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_DAMAGING
			return TRUE
		if("toggle_tag_explosive")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_EXPLOSIVE
			return TRUE
		if("toggle_tag_other")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_OTHER
			return TRUE
		if("toggle_tag_easy")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_EASY
			return TRUE
		if("toggle_tag_moderate")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_MODERATE
			return TRUE
		if("toggle_tag_hard")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_HARD
			return TRUE
		if("toggle_tag_organ")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_ORGAN
			return TRUE
		if("toggle_tag_drink")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_DRINK
			return TRUE
		if("toggle_tag_food")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_FOOD
			return TRUE
		if("toggle_tag_dangerous")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_DANGEROUS
			return TRUE
		if("toggle_tag_slime")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_SLIME
			return TRUE
		if("toggle_tag_drug")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_DRUG
			return TRUE
		if("toggle_tag_unique")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_UNIQUE
			return TRUE
		if("toggle_tag_chemical")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_CHEMICAL
			return TRUE
		if("toggle_tag_plant")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_PLANT
			return TRUE
		if("toggle_tag_competitive")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_COMPETITIVE
			return TRUE
		if("update_ui")
			return TRUE

/datum/reagents/proc/remove_any(amount = 1)
	var/list/cached_reagents = reagent_list
	var/total_transfered = 0
	var/current_list_element = 1

	current_list_element = rand(1, cached_reagents.len)

	while(total_transfered != amount)
		if(total_transfered >= amount)
			break
		if(total_volume <= 0 || !cached_reagents.len)
			break

		if(current_list_element > cached_reagents.len)
			current_list_element = 1

		var/datum/reagent/R = cached_reagents[current_list_element]
		remove_reagent(R.type, 1)

		current_list_element++
		total_transfered++
		update_total()

	handle_reactions()
	return total_transfered

/datum/reagents/proc/remove_all(amount = 1)
	var/list/cached_reagents = reagent_list
	if(total_volume > 0)
		var/part = amount / total_volume
		for(var/reagent in cached_reagents)
			var/datum/reagent/R = reagent
			remove_reagent(R.type, R.volume * part)

		update_total()
		handle_reactions()
		return amount

/datum/reagents/proc/get_master_reagent_name()
	var/list/cached_reagents = reagent_list
	var/name
	var/max_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume > max_volume)
			max_volume = R.volume
			name = R.name

	return name

/datum/reagents/proc/get_master_reagent_id()
	var/list/cached_reagents = reagent_list
	var/max_type
	var/max_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume > max_volume)
			max_volume = R.volume
			max_type = R.type

	return max_type

/datum/reagents/proc/get_master_reagent()
	var/list/cached_reagents = reagent_list
	var/datum/reagent/master
	var/max_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume > max_volume)
			max_volume = R.volume
			master = R

	return master

/datum/reagents/proc/trans_to(obj/target, amount = 1, multiplier = 1, preserve_data = TRUE, no_react = FALSE, mob/transfered_by, remove_blacklisted = FALSE, method = null, show_message = TRUE, round_robin = FALSE)
	//if preserve_data=0, the reagents data will be lost. Usefull if you use data for some strange stuff and don't want it to be transferred.
	//if round_robin=TRUE, so transfer 5 from 15 water, 15 sugar and 15 plasma becomes 10, 15, 15 instead of 13.3333, 13.3333 13.3333. Good if you hate floating point errors
	var/list/cached_reagents = reagent_list
	if(!target || !total_volume)
		return
	if(amount < 0)
		return

	var/atom/target_atom
	var/datum/reagents/R
	if(istype(target, /datum/reagents))
		R = target
		target_atom = R.my_atom
	else
		if(!target.reagents)
			return
		R = target.reagents
		target_atom = target

	if(transfered_by && target_atom)
		target_atom.add_hiddenprint(transfered_by) //log prints so admins can figure out who touched it last.
		log_combat(transfered_by, target_atom, "transferred reagents ([log_list()]) from [my_atom] to")

	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/trans_data = null
	var/transfer_log = list()
	if(!round_robin)
		var/part = amount / src.total_volume
		for(var/reagent in cached_reagents)
			var/datum/reagent/T = reagent
			if(remove_blacklisted && !T.can_synth)
				continue
			var/transfer_amount = T.volume * part
			if(preserve_data)
				trans_data = copy_data(T)
			R.add_reagent(T.type, transfer_amount * multiplier, trans_data, chem_temp, no_react = 1) //we only handle reaction after every reagent has been transfered.
			if(method)
				R.react_single(T, target_atom, method, part, show_message)
				T.on_transfer(target_atom, method, transfer_amount * multiplier)
			remove_reagent(T.type, transfer_amount, no_react) //MONKESTATION EDIT CHANGE
			transfer_log[T.type] = transfer_amount
	else
		var/to_transfer = amount
		for(var/reagent in cached_reagents)
			if(!to_transfer)
				break
			var/datum/reagent/T = reagent
			if(remove_blacklisted && !T.can_synth)
				continue
			if(preserve_data)
				trans_data = copy_data(T)
			var/transfer_amount = amount
			if(amount > T.volume)
				transfer_amount = T.volume
			R.add_reagent(T.type, transfer_amount * multiplier, trans_data, chem_temp, no_react = 1)
			to_transfer = max(to_transfer - transfer_amount , 0)
			if(method)
				R.react_single(T, target_atom, method, transfer_amount, show_message)
				T.on_transfer(target_atom, method, transfer_amount * multiplier)
			remove_reagent(T.type, transfer_amount)
			transfer_log[T.type] = transfer_amount

	if(transfered_by && target_atom)
		target_atom.add_hiddenprint(transfered_by) //log prints so admins can figure out who touched it last.
		log_combat(transfered_by, target_atom, "transferred reagents ([log_list(transfer_log)]) from [my_atom] to")

	update_total()
	R.update_total()
	if(!no_react)
		R.handle_reactions()
		src.handle_reactions()
	return amount

/datum/reagents/proc/copy_to(obj/target, amount=1, multiplier=1, preserve_data=1, no_react=0) //MONKESTATION EDIT CHANGE
	var/list/cached_reagents = reagent_list
	if(!target || !total_volume)
		return

	var/datum/reagents/R
	if(istype(target, /datum/reagents))
		R = target
	else
		if(!target.reagents)
			return
		R = target.reagents

	if(amount < 0)
		return
	amount = min(min(amount, total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / total_volume
	var/trans_data = null
	for(var/reagent in cached_reagents)
		var/datum/reagent/T = reagent
		var/copy_amount = T.volume * part
		if(preserve_data)
			trans_data = T.data
		R.add_reagent(T.type, copy_amount * multiplier, trans_data, chem_temp)

	src.update_total()
	R.update_total()
	//MONKESTATION EDIT CHANGE BEGIN
	if(!no_react)
		R.handle_reactions()
		src.handle_reactions()
	//MONKESTATION EDIT CHANGE END
	return amount

/datum/reagents/proc/trans_id_to(obj/target, reagent, amount=1, preserve_data=1)//Not sure why this proc didn't exist before. It does now! /N
	var/list/cached_reagents = reagent_list
	if (!target)
		return
	if (!target.reagents || src.total_volume<=0 || !src.get_reagent_amount(reagent))
		return
	if(amount < 0)
		return

	var/datum/reagents/R = target.reagents
	if(src.get_reagent_amount(reagent)<amount)
		amount = src.get_reagent_amount(reagent)
	amount = min(amount, R.maximum_volume-R.total_volume)
	var/trans_data = null
	for (var/CR in cached_reagents)
		var/datum/reagent/current_reagent = CR
		if(current_reagent.type == reagent)
			if(preserve_data)
				trans_data = current_reagent.data
			R.add_reagent(current_reagent.type, amount, trans_data, src.chem_temp)
			remove_reagent(current_reagent.type, amount, 1)
			break

	src.update_total()
	R.update_total()
	R.handle_reactions()
	return amount

/datum/reagents/proc/metabolize(mob/living/carbon/C, can_overdose = FALSE, liverless = FALSE)
	if(C?.dna?.species && (NOREAGENTS in C.dna.species.species_traits))
		return 0
	var/list/cached_reagents = reagent_list
	if(C)
		expose_temperature(C.bodytemperature, 0.25)
	var/need_mob_update = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(QDELETED(R.holder))
			continue

		if(!C)
			C = R.holder.my_atom

		if(C && R)
			if(C.reagent_check(R) != TRUE) //Most relevant to Humans, this handles species-specific chem interactions.
				if(liverless && !R.self_consuming) //need to be metabolized
					continue
				if(!R.metabolizing)
					R.metabolizing = TRUE
					R.on_mob_metabolize(C)
				if(can_overdose)
					if(R.overdose_threshold)
						if(R.volume >= R.overdose_threshold && !R.overdosed)
							R.overdosed = 1
							need_mob_update += R.overdose_start(C)
					for(var/addiction in R.addiction_types)
						C.mind?.add_addiction_points(addiction, R.addiction_types[addiction] * REAGENTS_METABOLISM)
					if(R.overdosed)
						need_mob_update += R.overdose_process(C)
				need_mob_update += R.on_mob_life(C)

	if(C && need_mob_update) //some of the metabolized reagents had effects on the mob that requires some updates.
		C.updatehealth()
		C.update_mobility()
		C.update_stamina()
	update_total()

//Signals that metabolization has stopped, triggering the end of trait-based effects
/datum/reagents/proc/end_metabolization(mob/living/carbon/C, keep_liverless = TRUE)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(QDELETED(R.holder))
			continue
		if(keep_liverless && R.self_consuming) //Will keep working without a liver
			continue
		if(!C)
			C = R.holder.my_atom
		if(R.metabolizing)
			R.metabolizing = FALSE
			R.on_mob_end_metabolize(C)

/datum/reagents/proc/conditional_update_move(atom/A, Running = 0)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		R.on_move (A, Running)
	update_total()

/datum/reagents/proc/conditional_update(atom/A)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		R.on_update (A)
	update_total()

/datum/reagents/proc/handle_reactions()
	if(flags & NO_REACT)
		return //Yup, no reactions here. No siree.

	var/list/cached_reagents = reagent_list
	var/list/cached_reactions = GLOB.chemical_reactions_list_reactant_index
	var/datum/cached_my_atom = my_atom

	var/reaction_occurred = 0
	do
		var/list/possible_reactions = list()
		reaction_occurred = 0
		for(var/reagent in cached_reagents)
			var/datum/reagent/R = reagent
			for(var/reaction in cached_reactions[R.type]) // Was a big list but now it should be smaller since we filtered it with our reagent id
				if(!reaction)
					continue

				var/datum/chemical_reaction/C = reaction
				var/list/cached_required_reagents = C.required_reagents
				var/total_required_reagents = cached_required_reagents.len
				var/total_matching_reagents = 0
				var/list/cached_required_catalysts = C.required_catalysts
				var/total_required_catalysts = cached_required_catalysts.len
				var/total_matching_catalysts= 0
				var/matching_container = 0
				var/matching_other = 0
				var/required_temp = C.required_temp
				var/is_cold_recipe = C.is_cold_recipe
				var/meets_temp_requirement = 0

				for(var/B in cached_required_reagents)
					if(!has_reagent(B, cached_required_reagents[B]))
						break
					total_matching_reagents++
				for(var/B in cached_required_catalysts)
					if(!has_reagent(B, cached_required_catalysts[B]))
						break
					total_matching_catalysts++
				if(cached_my_atom)
					if(!C.required_container)
						matching_container = 1

					else
						if(cached_my_atom.type == C.required_container)
							matching_container = 1
					if (isliving(cached_my_atom) && !C.mob_react) //Makes it so certain chemical reactions don't occur in mobs
						return
					if(!C.required_other)
						matching_other = 1

					else if(istype(cached_my_atom, /obj/item/slime_extract))
						var/obj/item/slime_extract/M = cached_my_atom

						if(M.Uses > 0) // added a limit to slime cores -- Muskets requested this
							matching_other = 1
				else
					if(!C.required_container)
						matching_container = 1
					if(!C.required_other)
						matching_other = 1

				if(required_temp == 0 || (is_cold_recipe && chem_temp <= required_temp) || (!is_cold_recipe && chem_temp >= required_temp))
					meets_temp_requirement = 1

				if(total_matching_reagents == total_required_reagents && total_matching_catalysts == total_required_catalysts && matching_container && matching_other && meets_temp_requirement)
					possible_reactions  += C

		if(possible_reactions.len)
			var/datum/chemical_reaction/selected_reaction = possible_reactions[1]
			//select the reaction with the most extreme temperature requirements
			for(var/V in possible_reactions)
				var/datum/chemical_reaction/competitor = V
				if(selected_reaction.is_cold_recipe) //if there are no recipe conflicts, everything in possible_reactions will have this same value for is_cold_reaction. warranty void if assumption not met.
					if(competitor.required_temp <= selected_reaction.required_temp)
						selected_reaction = competitor
				else
					if(competitor.required_temp >= selected_reaction.required_temp)
						selected_reaction = competitor
			var/list/cached_required_reagents = selected_reaction.required_reagents
			var/list/cached_results = selected_reaction.results
			var/list/multiplier = INFINITY
			for(var/B in cached_required_reagents)
				multiplier = min(multiplier, round(get_reagent_amount(B) / cached_required_reagents[B]))

			for(var/B in cached_required_reagents)
				remove_reagent(B, (multiplier * cached_required_reagents[B]), safety = 1)

			for(var/P in selected_reaction.results)
				multiplier = max(multiplier, 1) //this shouldn't happen ...
				SSblackbox.record_feedback("tally", "chemical_reaction", cached_results[P]*multiplier, P)
				add_reagent(P, cached_results[P]*multiplier, null, chem_temp)

			var/list/seen = viewers(4, get_turf(my_atom))
			var/iconhtml = icon2html(cached_my_atom, seen)
			if(cached_my_atom)
				if(!ismob(cached_my_atom)) // No bubbling mobs
					if(selected_reaction.mix_sound)
						playsound(get_turf(cached_my_atom), selected_reaction.mix_sound, 80, 1)

					for(var/mob/M as() in seen)
						to_chat(M, "<span class='notice'>[iconhtml] [selected_reaction.mix_message]</span>")

				if(istype(cached_my_atom, /obj/item/slime_extract))
					var/obj/item/slime_extract/ME2 = my_atom
					ME2.Uses--
					if(ME2.Uses <= 0) // give the notification that the slime core is dead
						for(var/mob/M as() in seen)
							to_chat(M, "<span class='notice'>[iconhtml] \The [my_atom]'s power is consumed in the reaction.</span>")
							ME2.name = "used slime extract"
							ME2.desc = "This extract has been used up."

			selected_reaction.on_reaction(src, multiplier)
			reaction_occurred = 1

	while(reaction_occurred)
	update_total()
	return 0

/datum/reagents/proc/isolate_reagent(reagent)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if(R.type != reagent)
			del_reagent(R.type)
			update_total()

/datum/reagents/proc/del_reagent(reagent)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if(R.type == reagent)
			var/mob/living/mob_consumer

			if (isliving(my_atom))
				mob_consumer = my_atom
			else if (istype(my_atom, /obj/item/organ))
				var/obj/item/organ/organ = my_atom
				mob_consumer = organ.owner

			if (mob_consumer)
				if(R.metabolizing)
					R.metabolizing = FALSE
					R.on_mob_end_metabolize(mob_consumer)
				R.on_mob_delete(mob_consumer)
			qdel(R)
			reagent_list -= R
			update_total()
			if(my_atom)
				my_atom.on_reagent_change(DEL_REAGENT)
	return 1

/datum/reagents/proc/update_total()
	var/list/cached_reagents = reagent_list
	total_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume < 0.1)
			del_reagent(R.type)
		else
			total_volume += R.volume

	return 0

/datum/reagents/proc/clear_reagents()
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		del_reagent(R.type)
	if(my_atom)
		my_atom.on_reagent_change(CLEAR_REAGENTS)
	return 0

/datum/reagents/proc/reaction_check(mob/living/M, datum/reagent/R)
	var/can_process = FALSE
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		//Check if this mob's species is set and can process this type of reagent
		if(H.dna && H.dna.species.reagent_tag)
			if((R.process_flags & SYNTHETIC) && (H.dna.species.reagent_tag & PROCESS_SYNTHETIC))		//SYNTHETIC-oriented reagents require PROCESS_SYNTHETIC
				can_process = TRUE
			if((R.process_flags & ORGANIC) && (H.dna.species.reagent_tag & PROCESS_ORGANIC))		//ORGANIC-oriented reagents require PROCESS_ORGANIC
				can_process = TRUE
	//We'll assume that non-human mobs lack the ability to process synthetic-oriented reagents (adjust this if we need to change that assumption)
	else
		if(R.process_flags != SYNTHETIC)
			can_process = TRUE
	return can_process

/datum/reagents/proc/reaction(atom/A, method = TOUCH, volume_modifier = 1, show_message = 1, liquid = FALSE)
	var/react_type
	if(isliving(A))
		react_type = "LIVING"
		if(method == INGEST)
			var/mob/living/L = A
			L.taste(src)
	else if(isturf(A))
		react_type = "TURF"
	else if(isobj(A))
		react_type = "OBJ"
	else if(liquid == TRUE)
		react_type = "LIQUID"
	else
		return
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		switch(react_type)
			if("LIVING")
				var/check = reaction_check(A, R)
				if(!check)
					continue
				var/touch_protection = 0
				if(method == VAPOR)
					var/mob/living/L = A
					touch_protection = L.get_permeability_protection()
				R.reaction_mob(A, method, R.volume * volume_modifier, show_message, touch_protection)
			if("TURF")
				R.reaction_turf(A, R.volume * volume_modifier, show_message)
			if("OBJ")
				R.reaction_obj(A, R.volume * volume_modifier, show_message)
			if("LIQUID")
				R.reaction_liquid(A, R.volume * volume_modifier, show_message)

/datum/reagents/proc/holder_full()
	if(total_volume >= maximum_volume)
		return TRUE
	return FALSE

//Returns the average specific heat for all reagents currently in this holder.
/datum/reagents/proc/specific_heat()
	. = 0
	var/cached_amount = total_volume		//cache amount
	var/list/cached_reagents = reagent_list		//cache reagents
	for(var/I in cached_reagents)
		var/datum/reagent/R = I
		. += R.specific_heat * (R.volume / cached_amount)

/datum/reagents/proc/adjust_thermal_energy(J, min_temp = 2.7, max_temp = 1000)
	var/S = specific_heat()
	chem_temp = CLAMP(chem_temp + (J / (S * total_volume)), 2.7, 1000)

/datum/reagents/proc/add_reagent(reagent, amount, list/data=null, reagtemp = 300, no_react = 0)
	if(!isnum_safe(amount) || !amount)
		return FALSE

	if(amount <= 0)
		return FALSE

	var/datum/reagent/D = GLOB.chemical_reagents_list[reagent]
	if(!D)
		WARNING("[my_atom] attempted to add a reagent called '[reagent]' which doesn't exist. ([usr])")
		return FALSE

	update_total()
	var/cached_total = total_volume
	if(cached_total + amount > maximum_volume)
		amount = (maximum_volume - cached_total) //Doesnt fit in. Make it disappear. Shouldnt happen. Will happen.
		if(amount <= 0)
			return FALSE
	var/new_total = cached_total + amount
	var/cached_temp = chem_temp
	var/list/cached_reagents = reagent_list

	//Equalize temperature - Not using specific_heat() because the new chemical isn't in yet.
	var/specific_heat = 0
	var/thermal_energy = 0
	for(var/i in cached_reagents)
		var/datum/reagent/R = i
		specific_heat += R.specific_heat * (R.volume / new_total)
		thermal_energy += R.specific_heat * R.volume * cached_temp
	specific_heat += D.specific_heat * (amount / new_total)
	thermal_energy += D.specific_heat * amount * reagtemp
	chem_temp = thermal_energy / (specific_heat * new_total)
	////

	//add the reagent to the existing if it exists
	for(var/A in cached_reagents)
		var/datum/reagent/R = A
		if (R.type == reagent)
			R.volume += amount
			update_total()
			if(my_atom)
				my_atom.on_reagent_change(ADD_REAGENT)
			R.on_merge(data, amount)
			if(!no_react)
				handle_reactions()
			return TRUE

	//otherwise make a new one
	var/datum/reagent/R = new D.type(data)
	cached_reagents += R
	R.holder = src
	R.volume = amount
	if(data)
		R.data = data
		R.on_new(data)

	if(isliving(my_atom))
		R.on_mob_add(my_atom) //Must occur befor it could posibly run on_mob_delete
	update_total()
	if(my_atom)
		my_atom.on_reagent_change(ADD_REAGENT)
	if(!no_react)
		handle_reactions()
	return TRUE

/datum/reagents/proc/add_reagent_list(list/list_reagents, list/data=null, no_react = FALSE) //MONKESTATION EDIT CHANGE Like add_reagent but you can enter a list. Format it like this: list(/datum/reagent/toxin = 10, "beer" = 15)
	for(var/r_id in list_reagents)
		var/amt = list_reagents[r_id]
	//MONKESTATION CHANGE BEGIN
		add_reagent(r_id, amt, data, no_react = TRUE)
	if(!no_react)
		handle_reactions()
	//MONKESTATION EDIT CHANGE END

/datum/reagents/proc/remove_reagent(reagent, amount, safety = TRUE, no_react = FALSE)// MONKESTATION EDIT CHANGE Added a safety check for the trans_id_to

	if(isnull(amount))
		amount = 0
		CRASH("null amount passed to reagent code")

	if(!isnum_safe(amount))
		return FALSE

	if(amount < 0)
		return FALSE

	var/list/cached_reagents = reagent_list

	for(var/A in cached_reagents)
		var/datum/reagent/R = A
		if (R.type == reagent)
			//clamp the removal amount to be between current reagent amount
			//and zero, to prevent removing more than the holder has stored
			amount = CLAMP(amount, 0, R.volume)
			R.volume -= amount
			update_total()
			if(!safety)//So it does not handle reactions when it need not to //MONKESTATION EDIT CHANGE
				handle_reactions()
			if(my_atom)
				my_atom.on_reagent_change(REM_REAGENT)
			return TRUE

	return FALSE

/datum/reagents/proc/has_reagent(reagent, amount = -1, needs_metabolizing = FALSE)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if (R.type == reagent)
			if(!amount)
				if(needs_metabolizing && !R.metabolizing)
					return
				return R
			else
				if(round(R.volume, CHEMICAL_QUANTISATION_LEVEL) >= amount)
					if(needs_metabolizing && !R.metabolizing)
						return
					return R
				else
					return

	return

/datum/reagents/proc/get_reagent_amount(reagent)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if (R.type == reagent)
			return round(R.volume, CHEMICAL_QUANTISATION_LEVEL)

	return 0

/datum/reagents/proc/get_reagents()
	var/list/names = list()
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		names += R.name

	return jointext(names, ",")

/datum/reagents/proc/remove_all_type(reagent_type, amount, strict = 0, safety = 1) // Removes all reagent of X type. @strict set to 1 determines whether the childs of the type are included.
	if(!isnum_safe(amount))
		return 1
	var/list/cached_reagents = reagent_list
	var/has_removed_reagent = 0

	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		var/matches = 0
		// Switch between how we check the reagent type
		if(strict)
			if(R.type == reagent_type)
				matches = 1
		else
			if(istype(R, reagent_type))
				matches = 1
		// We found a match, proceed to remove the reagent.	Keep looping, we might find other reagents of the same type.
		if(matches)
			// Have our other proc handle removement
			has_removed_reagent = remove_reagent(R.type, amount, safety)

	return has_removed_reagent

//two helper functions to preserve data across reactions (needed for xenoarch)
/datum/reagents/proc/get_data(reagent_id)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.type == reagent_id)
			return R.data

/datum/reagents/proc/set_data(reagent_id, new_data)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.type == reagent_id)
			R.data = new_data

/datum/reagents/proc/copy_data(datum/reagent/current_reagent)
	if(!current_reagent || !current_reagent.data)
		return null
	if(!istype(current_reagent.data, /list))
		return current_reagent.data

	var/list/trans_data = current_reagent.data.Copy()

	// We do this so that introducing a virus to a blood sample
	// doesn't automagically infect all other blood samples from
	// the same donor.
	//
	// Technically we should probably copy all data lists, but
	// that could possibly eat up a lot of memory needlessly
	// if most data lists are read-only.
	if(trans_data["viruses"])
		var/list/v = trans_data["viruses"]
		trans_data["viruses"] = v.Copy()

	return trans_data

/datum/reagents/proc/get_reagent(type)
	var/list/cached_reagents = reagent_list
	. = locate(type) in cached_reagents

/datum/reagents/proc/generate_taste_message(minimum_percent=15)
	// the lower the minimum percent, the more sensitive the message is.
	var/list/out = list()
	var/list/tastes = list() //descriptor = strength
	if(minimum_percent <= 100)
		for(var/datum/reagent/R in reagent_list)
			if(!R.taste_mult)
				continue

			if(istype(R, /datum/reagent/consumable/nutriment))
				var/list/taste_data = R.data
				for(var/taste in taste_data)
					var/ratio = taste_data[taste]
					var/amount = ratio * R.taste_mult * R.volume
					if(taste in tastes)
						tastes[taste] += amount
					else
						tastes[taste] = amount
			else
				var/taste_desc = R.taste_description
				var/taste_amount = R.volume * R.taste_mult
				if(taste_desc in tastes)
					tastes[taste_desc] += taste_amount
				else
					tastes[taste_desc] = taste_amount
		//deal with percentages
		// TODO it would be great if we could sort these from strong to weak
		var/total_taste = counterlist_sum(tastes)
		if(total_taste > 0)
			for(var/taste_desc in tastes)
				var/percent = tastes[taste_desc]/total_taste * 100
				if(percent < minimum_percent)
					continue
				var/intensity_desc = "a hint of"
				if(percent > minimum_percent * 2 || percent == 100)
					intensity_desc = ""
				else if(percent > minimum_percent * 3)
					intensity_desc = "the strong flavor of"
				if(intensity_desc != "")
					out += "[intensity_desc] [taste_desc]"
				else
					out += "[taste_desc]"

	return english_list(out, "something indescribable")

/datum/reagents/proc/expose_temperature(var/temperature, var/coeff=0.02)
	var/temp_delta = (temperature - chem_temp) * coeff
	if(temp_delta > 0)
		chem_temp = min(chem_temp + max(temp_delta, 1), temperature)
	else
		chem_temp = max(chem_temp + min(temp_delta, -1), temperature)
	chem_temp = round(chem_temp)
	handle_reactions()

///////////////////////////////////////////////////////////////////////////////////


// Convenience proc to create a reagents holder for an atom
// Max vol is maximum volume of holder
/atom/proc/create_reagents(max_vol, flags)
	if(reagents)
		qdel(reagents)
	reagents = new /datum/reagents(max_vol, flags)
	reagents.my_atom = src


/proc/get_unrestricted_random_reagent_id()	// Returns a random reagent ID minus most foods and drinks
	var/static/list/random_reagents = list()
	if(!random_reagents.len)
		for(var/thing  in subtypesof(/datum/reagent))
			var/datum/reagent/R = thing
			if(initial(R.random_unrestricted))
				random_reagents += R
	var/picked_reagent = pick(random_reagents)
	return picked_reagent

