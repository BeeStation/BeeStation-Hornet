///Global names for science sellers
GLOBAL_LIST_INIT(xenoa_seller_names, world.file2list("strings/names/science_seller.txt"))
GLOBAL_LIST_INIT(xenoa_seller_dialogue, world.file2list("strings/science_dialogue.txt"))
GLOBAL_LIST_INIT(xenoa_artifact_names, world.file2list("strings/names/artifact_sentience.txt"))

///traits types, referenced for generation
GLOBAL_LIST(xenoa_activators)
GLOBAL_LIST(xenoa_minors)
GLOBAL_LIST(xenoa_majors)
GLOBAL_LIST(xenoa_malfunctions)
GLOBAL_LIST(xenoa_all_traits)
///All traits indexed by name
GLOBAL_LIST(xenoa_all_traits_keyed)

///Blacklist for traits
GLOBAL_LIST(xenoa_bluespace_traits)
GLOBAL_LIST(xenoa_plasma_traits)
GLOBAL_LIST(xenoa_uranium_traits)
GLOBAL_LIST(xenoa_bananium_traits)
GLOBAL_LIST(xenoa_pearl_traits)

///Whitelist of items ofr familiar artifacts
GLOBAL_LIST_INIT(xenoa_familiar_items, list(/obj/item/kitchen/fork))

///Incompatability lists
GLOBAL_LIST(xenoa_item_incompatible)
GLOBAL_LIST(xenoa_mob_incompatible)
GLOBAL_LIST(xenoa_structure_incompatible)

///Labeler trait lists
GLOBAL_LIST(labeler_activator_traits)
GLOBAL_LIST(labeler_minor_traits)
GLOBAL_LIST(labeler_major_traits)
GLOBAL_LIST(labeler_malfunction_traits)
GLOBAL_LIST_INIT(labeler_tooltip_stats, list())

///Material weights, basically rarity
GLOBAL_LIST_INIT(xenoartifact_material_weights, list(XENOA_BLUESPACE = 10, XENOA_PLASMA = 8, XENOA_URANIUM = 5, XENOA_BANANIUM = 1))

///Trait priority list - The order is important and it represents priotity
GLOBAL_LIST_INIT(xenoartifact_trait_priorities, list(TRAIT_PRIORITY_ACTIVATOR, TRAIT_PRIORITY_MINOR, TRAIT_PRIORITY_MALFUNCTION, TRAIT_PRIORITY_MAJOR))

///List of 'discovered' traits
GLOBAL_LIST_INIT(discovered_traits, list())

///Fill xenoarchaeology globals
/proc/generate_xenoa_statics()
	if(length(GLOB.xenoa_all_traits))
		return

	//Bruh
	GLOB.xenoa_seller_names -= ""
	GLOB.xenoa_seller_dialogue -= ""
	GLOB.xenoa_artifact_names -= ""

	//List of weights based on trait type
	GLOB.xenoa_activators = compile_artifact_weights(/datum/xenoartifact_trait/activator)
	GLOB.xenoa_minors = compile_artifact_weights(/datum/xenoartifact_trait/minor)
	GLOB.xenoa_majors = compile_artifact_weights(/datum/xenoartifact_trait/major)
	GLOB.xenoa_malfunctions = compile_artifact_weights(/datum/xenoartifact_trait/malfunction)
	GLOB.xenoa_all_traits = compile_artifact_weights(/datum/xenoartifact_trait)
	GLOB.xenoa_all_traits_keyed = compile_artifact_weights(/datum/xenoartifact_trait, TRUE)

	//Traits divided by flavor
	GLOB.xenoa_bluespace_traits = compile_artifact_whitelist(/datum/xenoartifact_material/bluespace)
	GLOB.xenoa_plasma_traits = compile_artifact_whitelist(/datum/xenoartifact_material/plasma)
	GLOB.xenoa_uranium_traits = compile_artifact_whitelist(/datum/xenoartifact_material/uranium)
	GLOB.xenoa_bananium_traits = compile_artifact_whitelist(/datum/xenoartifact_material/bananium)
	GLOB.xenoa_pearl_traits = compile_artifact_whitelist(/datum/xenoartifact_material/pearl)

	//Compatabilities
	GLOB.xenoa_item_incompatible = compile_artifact_compatibilties(TRAIT_INCOMPATIBLE_ITEM)
	GLOB.xenoa_mob_incompatible = compile_artifact_compatibilties(TRAIT_INCOMPATIBLE_MOB)
	GLOB.xenoa_structure_incompatible = compile_artifact_compatibilties(TRAIT_INCOMPATIBLE_STRUCTURE)

	//Labeler
	GLOB.labeler_activator_traits = get_trait_list_stats(GLOB.xenoa_activators)
	GLOB.labeler_minor_traits = get_trait_list_stats(GLOB.xenoa_minors)
	GLOB.labeler_major_traits = get_trait_list_stats(GLOB.xenoa_majors)
	GLOB.labeler_malfunction_traits = get_trait_list_stats(GLOB.xenoa_malfunctions)

///Proc used to compile trait weights into a list
/proc/compile_artifact_weights(path, keyed = FALSE)
	if(!ispath(path))
		return
	var/list/temp = subtypesof(path)
	var/list/weighted = list()
	for(var/datum/xenoartifact_trait/T as() in temp)
		if(initial(T.flags) & XENOA_HIDE_TRAIT)
			continue
		if(keyed)
			weighted += list(initial(T.label_name) = (T))
		else
			weighted += list((T) = initial(T.rarity)) //The (T) will not work if it is T
	return weighted

///Compile a blacklist of traits from a given flag/s
/proc/compile_artifact_whitelist(var/flags)
	var/list/output = list()
	for(var/datum/xenoartifact_trait/T as() in GLOB.xenoa_all_traits)
		if(initial(T.flags) & XENOA_HIDE_TRAIT)
			continue
		if(!ispath(flags))
			if((initial(T.flags) & flags))
				output += T
		else
			var/datum/xenoartifact_material/M = flags
			if((initial(T.flags) & initial(M.trait_flags)))
				output += T
	return output

///Compile a list of traits from a given compatability flag/s
/proc/compile_artifact_compatibilties(var/flags)
	var/list/output = list()
	for(var/datum/xenoartifact_trait/T as() in GLOB.xenoa_all_traits)
		if(initial(T.incompatabilities) & flags)
			output += T
	return output

///Get a trait incompatability list based on the passed type
/proc/get_trait_incompatibilities(atom/type)
	//Items
	if(istype(type, /obj/item))
		return GLOB.xenoa_item_incompatible
	//Mob
	if(istype(type, /mob))
		return GLOB.xenoa_mob_incompatible
	//Structure
	if(istype(type, /obj/structure))
		return GLOB.xenoa_structure_incompatible

	return list()

///Proc for labeler baking
/proc/get_trait_list_stats(list/trait_type)
	var/list/temp = list()
	for(var/datum/xenoartifact_trait/T as() in trait_type)
		temp += list(initial(T.label_name))
		var/datum/xenoartifact_trait/hint_holder = new T()
		GLOB.labeler_tooltip_stats["[initial(T.label_name)]"] = list("weight" = initial(T.weight), "conductivity" = initial(T.conductivity), "alt_name" = initial(T.alt_label_name), "desc" = initial(T.label_desc), "hints" = hint_holder.get_dictionary_hint())
		qdel(hint_holder)
		//Generate material availability
		var/list/materials = list(XENOA_BLUESPACE, XENOA_PLASMA, XENOA_URANIUM, XENOA_BANANIUM, XENOA_PEARL)
		GLOB.labeler_tooltip_stats["[initial(T.label_name)]"] += list("availability" = list())
		for(var/datum/xenoartifact_material/M as() in materials)
			if(initial(M.trait_flags) & initial(T.flags))
				GLOB.labeler_tooltip_stats["[initial(T.label_name)]"]["availability"] += list(list("color" = initial(M.material_color), "icon" = initial(M.label_icon)))
	return temp
