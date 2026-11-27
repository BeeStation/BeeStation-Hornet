/// list of all /datum/chemical_reaction datums indexed by their typepath. Use this for general lookup stuff
GLOBAL_LIST(chemical_reactions_list)
/// list of all /datum/chemical_reaction datums. Used during chemical reactions. Indexed by REACTANT types
GLOBAL_LIST(chemical_reactions_list_reactant_index)
/// list of all /datum/reagent datums indexed by reagent id. Used by chemistry stuff
GLOBAL_LIST_INIT(chemical_reagents_list, init_chemical_reagent_list())
/// Map of ckey'd reagent names to their datum path
GLOBAL_LIST_INIT(name2reagent, build_name2reagent())

/proc/init_chemical_reagent_list()
	var/list/reagent_list = list()

	for(var/path in subtypesof(/datum/reagent))
		reagent_list[path] = new path()

	return reagent_list

/**
 * Chemical Reactions - Initialises all /datum/chemical_reaction into a list
 * It is filtered into multiple lists within a list.
 * For example:
 * chemical_reactions_list_reactant_index[/datum/reagent/toxin/plasma] is a list of all reactions relating to plasma
 */
/proc/build_chemical_reactions_lists()
	if(GLOB.chemical_reactions_list_reactant_index)
		return

	GLOB.chemical_reactions_list = list() //typepath to reaction list
	GLOB.chemical_reactions_list_reactant_index = list() //reagents to reaction list

	var/list/datum/chemical_reaction/reactions = list()
	for(var/path in subtypesof(/datum/chemical_reaction))
		var/datum/chemical_reaction/reaction = new path()
		if(!length(reaction.required_reagents)) //Skip impossible reactions
			continue
		reactions += reaction
		GLOB.chemical_reactions_list[path] = reaction

	// Ok so we're gonna do a thingTM here
	// I want to distribute all our reactions such that each reagent id links to as few as possible
	// I get the feeling there's a canonical way of doing this, but I don't know it
	// So instead, we're gonna wing it
	var/list/reagent_to_react_count = list()
	for(var/datum/chemical_reaction/reaction as anything in reactions)
		for(var/reagent_id in reaction.required_reagents)
			reagent_to_react_count[reagent_id] += 1

	var/list/reaction_lookup = GLOB.chemical_reactions_list_reactant_index
	// Create filters based on a random reagent id in the required reagents list - this is used to speed up handle_reactions()
	// Basically, we only really need to care about ONE reagent, at least when initially filtering, since any others are ignorable
	for(var/datum/chemical_reaction/reaction as anything in reactions)
		var/preferred_id = null
		for(var/reagent_id in reaction.required_reagents)
			if(isnull(preferred_id))
				preferred_id = reagent_id
				continue
			// If we would have less then they would, take it
			if(length(reaction_lookup[reagent_id]) < length(reaction_lookup[preferred_id]))
				preferred_id = reagent_id
				continue
			// If they potentially have more then us, we take it
			if(reagent_to_react_count[reagent_id] < reagent_to_react_count[preferred_id])
				preferred_id = reagent_id
				continue
		if(!reaction_lookup[preferred_id])
			reaction_lookup[preferred_id] = list()
		reaction_lookup[preferred_id] += reaction

/proc/build_name2reagent()
	. = list()
	for(var/datum/reagent/path as anything in subtypesof(/datum/reagent))
		if(length(initial(path.name)))
			.[ckey(initial(path.name))] = path
