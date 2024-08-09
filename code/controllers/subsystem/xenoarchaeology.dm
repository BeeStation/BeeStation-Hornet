SUBSYSTEM_DEF(xenoarchaeology)
	name = "Xenoarchaeology"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_XENOARCHAEOLOGY

	///Which console is the main character
	var/obj/machinery/computer/xenoarchaeology_console/main_console

	//All the traits - before we sort them, semi needed for generation
	var/list/xenoa_all_traits
	///All traits indexed by name, used for labelling stuff
	var/list/xenoa_all_traits_keyed

	///Names for science sellers & artifacts
	var/list/xenoa_seller_names
	var/list/xenoa_seller_dialogue
	var/list/xenoa_artifact_names

	///Whitelist for traits by material type
	var/list/material_traits

	///Incompatability lists - Partial future proofing some stuff
	var/list/xenoa_item_incompatible
	var/list/xenoa_mob_incompatible
	var/list/xenoa_structure_incompatible

	///Labeler trait lists, basically just names
	var/datum/xenoa_material_traits/stats/labeler_traits
	///Other labeler shit
	var/list/labeler_tooltip_stats = list()
	var/list/labeler_traits_filter

	///Material weights, basically rarity - Also used to populate some other lists
	var/list/xenoartifact_material_weights = list(XENOA_BLUESPACE = 10, XENOA_PLASMA = 8, XENOA_URANIUM = 5, XENOA_BANANIUM = 1)

	///Trait priority list - The order is important and it represents priotity
	var/list/xenoartifact_trait_priorities = list(TRAIT_PRIORITY_ACTIVATOR, TRAIT_PRIORITY_MINOR, TRAIT_PRIORITY_MALFUNCTION, TRAIT_PRIORITY_MAJOR)

	///List of 'discovered' traits
	var/list/discovered_traits = list()

/datum/controller/subsystem/xenoarchaeology/Initialize(timeofday)
	. = ..()
	//Poplate seller & artifact personalities
	xenoa_seller_names = world.file2list("strings/names/science_seller.txt")
	xenoa_seller_dialogue = world.file2list("strings/science_dialogue.txt")
	xenoa_artifact_names = world.file2list("strings/names/artifact_sentience.txt")

	//Dirty unwashed masses
	xenoa_all_traits = compile_artifact_weights(/datum/xenoartifact_trait)
	xenoa_all_traits_keyed = compile_artifact_weights(/datum/xenoartifact_trait, TRUE)

	//Compatabilities
	xenoa_item_incompatible = compile_artifact_compatibilties(TRAIT_INCOMPATIBLE_ITEM)
	xenoa_mob_incompatible = compile_artifact_compatibilties(TRAIT_INCOMPATIBLE_MOB)
	xenoa_structure_incompatible = compile_artifact_compatibilties(TRAIT_INCOMPATIBLE_STRUCTURE)

	//Labeler
	labeler_traits = new()
	labeler_traits.compile_artifact_whitelist(/datum/xenoartifact_material)
	labeler_traits_filter = list()
	for(var/datum/xenoartifact_trait/T as() in xenoa_all_traits)
		T = new T() //Instantiate so we can access a PROC
		var/list/hints = T.get_dictionary_hint()
		for(var/i in hints)
			if(!labeler_traits_filter[i["icon"]])
				labeler_traits_filter[i["icon"]] = list()
			labeler_traits_filter[i["icon"]] += list("[initial(T.label_name)]")
		QDEL_NULL(T)

	//Populate traits by material
	material_traits = list()
	for(var/datum/xenoartifact_material/material_index as() in typesof(/datum/xenoartifact_material))
		if(SSxenoarchaeology.material_traits[initial(material_index.material_parent)])
			continue
		var/datum/xenoa_material_traits/material = new()
		material_traits[material_index] = material
		//Populate datum fields
		material.compile_artifact_whitelist(material_index)

/datum/controller/subsystem/xenoarchaeology/Shutdown()
	. = ..()

/datum/controller/subsystem/xenoarchaeology/Recover()
	. = ..()
	xenoa_seller_names = SSxenoarchaeology.xenoa_seller_names
	xenoa_seller_dialogue = SSxenoarchaeology.xenoa_seller_dialogue
	xenoa_artifact_names = SSxenoarchaeology.xenoa_artifact_names

	xenoa_all_traits = SSxenoarchaeology.xenoa_all_traits
	xenoa_all_traits_keyed = SSxenoarchaeology.xenoa_all_traits_keyed

	material_traits = SSxenoarchaeology.material_traits

	xenoa_item_incompatible = SSxenoarchaeology.xenoa_item_incompatible
	xenoa_mob_incompatible = SSxenoarchaeology.xenoa_mob_incompatible
	xenoa_structure_incompatible = SSxenoarchaeology.xenoa_structure_incompatible

	labeler_tooltip_stats = SSxenoarchaeology.labeler_tooltip_stats
	labeler_traits_filter = SSxenoarchaeology.labeler_traits_filter

/datum/controller/subsystem/xenoarchaeology/proc/register_console(var/obj/machinery/computer/xenoarchaeology_console/new_console)
	if(main_console)
		main_console.main_console = FALSE
		UnregisterSignal(main_console, COMSIG_PARENT_QDELETING)
	main_console = new_console
	main_console.main_console = TRUE
	RegisterSignal(main_console, COMSIG_PARENT_QDELETING, PROC_REF(catch_console))

/datum/controller/subsystem/xenoarchaeology/proc/catch_console(datum/source)
	SIGNAL_HANDLER

	main_console = null
	SEND_SIGNAL(src, XENOA_NEW_CONSOLE)

///Proc used to compile trait weights into a list
/datum/controller/subsystem/xenoarchaeology/proc/compile_artifact_weights(path, keyed = FALSE)
	if(!ispath(path))
		return
	var/list/temp = subtypesof(path)
	var/list/weighted = list()
	for(var/datum/xenoartifact_trait/T as() in temp)
		if(initial(T.flags) & XENOA_HIDE_TRAIT)
			continue
		//Filter out abstract types
		if(T == /datum/xenoartifact_trait/activator || T == /datum/xenoartifact_trait/minor || T == /datum/xenoartifact_trait/major || T == /datum/xenoartifact_trait/malfunction)
			continue
		if(keyed)
			weighted += list(initial(T.label_name) = (T))
		else
			weighted += list((T) = initial(T.rarity)) //The (T) will not work if it is T
	return weighted

///Compile a list of traits from a given compatability flag/s
/datum/controller/subsystem/xenoarchaeology/proc/compile_artifact_compatibilties(flags)
	var/list/output = list()
	for(var/datum/xenoartifact_trait/T as() in xenoa_all_traits)
		if(initial(T.incompatabilities) & flags)
			output += T
	return output

///Get a trait incompatability list based on the passed type
/datum/controller/subsystem/xenoarchaeology/proc/get_trait_incompatibilities(atom/type)
	//Items
	if(isitem(type))
		return xenoa_item_incompatible
	//Mob
	if(ismob(type))
		return xenoa_mob_incompatible
	//Structure
	if(isstructure(type))
		return xenoa_structure_incompatible

	return list()

///Proc for labeler baking
/datum/controller/subsystem/xenoarchaeology/proc/get_trait_list_stats(list/trait_type)
	var/list/temp = list()
	for(var/datum/xenoartifact_trait/T as() in trait_type)
		//generate tool tips
		temp += list(initial(T.label_name))
		var/datum/xenoartifact_trait/hint_holder = new T()
		labeler_tooltip_stats["[initial(T.label_name)]"] = list("weight" = initial(T.weight), "conductivity" = initial(T.conductivity), "alt_name" = initial(T.alt_label_name), "desc" = initial(T.label_desc), "hints" = hint_holder.get_dictionary_hint())
		qdel(hint_holder)
		//Generate material availability
		var/list/materials = list(XENOA_BLUESPACE, XENOA_PLASMA, XENOA_URANIUM, XENOA_BANANIUM, XENOA_PEARL)
		labeler_tooltip_stats["[initial(T.label_name)]"] += list("availability" = list())
		for(var/datum/xenoartifact_material/M as() in materials)
			if(initial(M.trait_flags) & initial(T.flags))
				labeler_tooltip_stats["[initial(T.label_name)]"]["availability"] += list(list("color" = initial(M.material_color), "icon" = initial(M.label_icon)))
	return temp

/*
	Datum for holding a bunch of listed traits for a certain material
	Thanks, EvilDragon
*/

/datum/xenoa_material_traits
	///List of traits per category
	var/list/activators = list()
	var/list/minors = list()
	var/list/majors = list()
	var/list/malfunctions = list()
	///Has this datum been compiled / populated?
	var/compiled = FALSE

///Populate our trait lists from a given material path
/datum/xenoa_material_traits/proc/compile_artifact_whitelist(datum/xenoartifact_material/material)
	for(var/datum/xenoartifact_trait/T as() in SSxenoarchaeology.xenoa_all_traits)
		if(initial(T.flags) & XENOA_HIDE_TRAIT)
			continue
		if(!(initial(T.flags) & initial(material.trait_flags)))
			continue
		//Sort trait into list
		if(ispath(T, /datum/xenoartifact_trait/activator))
			activators[T] = initial(T.rarity)
			continue
		if(ispath(T, /datum/xenoartifact_trait/minor))
			minors[T] = initial(T.rarity)
			continue
		if(ispath(T, /datum/xenoartifact_trait/major))
			majors[T] = initial(T.rarity)
			continue
		if(ispath(T, /datum/xenoartifact_trait/malfunction))
			malfunctions[T] = initial(T.rarity)
			continue
	compiled = TRUE

//Variant for stats, labeler baking
/datum/xenoa_material_traits/stats

/datum/xenoa_material_traits/stats/compile_artifact_whitelist(datum/xenoartifact_material/material)
	for(var/datum/xenoartifact_trait/T as() in SSxenoarchaeology.xenoa_all_traits)
		if(initial(T.flags) & XENOA_HIDE_TRAIT)
			continue
		if(!(initial(T.flags) & initial(material.trait_flags)))
			continue
		//We're gonna be nice an populate labeler_tooltip_stats while we're at it, because we're nice
		//generate tool tips
		var/datum/xenoartifact_trait/hint_holder = new T() //Instantiate so we can access a PROC
		SSxenoarchaeology.labeler_tooltip_stats["[initial(T.label_name)]"] = list("weight" = initial(T.weight), "conductivity" = initial(T.conductivity), "alt_name" = initial(T.alt_label_name), "desc" = initial(T.label_desc), "hints" = hint_holder.get_dictionary_hint())
		qdel(hint_holder)
		//Generate material availability
		var/list/materials = list(XENOA_BLUESPACE, XENOA_PLASMA, XENOA_URANIUM, XENOA_BANANIUM, XENOA_PEARL)
		SSxenoarchaeology.labeler_tooltip_stats["[initial(T.label_name)]"] += list("availability" = list())
		for(var/datum/xenoartifact_material/M as() in materials)
			if(initial(M.trait_flags) & initial(T.flags))
				SSxenoarchaeology.labeler_tooltip_stats["[initial(T.label_name)]"]["availability"] += list(list("color" = initial(M.material_color), "icon" = initial(M.label_icon)))
		//Sort trait into list
		if(ispath(T, /datum/xenoartifact_trait/activator) && T != /datum/xenoartifact_trait/activator)
			activators += initial(T.label_name)
			continue
		if(ispath(T, /datum/xenoartifact_trait/minor) && T != /datum/xenoartifact_trait/minor)
			minors += initial(T.label_name)
			continue
		if(ispath(T, /datum/xenoartifact_trait/major) && T != /datum/xenoartifact_trait/major)
			majors += initial(T.label_name)
			continue
		if(ispath(T, /datum/xenoartifact_trait/malfunction) && T != /datum/xenoartifact_trait/malfunction)
			malfunctions += initial(T.label_name)
			continue
