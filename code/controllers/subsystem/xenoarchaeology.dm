SUBSYSTEM_DEF(xenoarchaeology)
	name = "Xenoarchaeology"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_XENOARCHAEOLOGY

	///Which console is the main character
	var/obj/machinery/computer/xenoarchaeology_console/main_console

	///Traits types, referenced for generation
	var/list/xenoa_activators
	var/list/xenoa_minors
	var/list/xenoa_majors
	var/list/xenoa_malfunctions
	var/list/xenoa_all_traits
	///All traits indexed by name
	var/list/xenoa_all_traits_keyed

	///Names for science sellers & artifacts
	var/list/xenoa_seller_names
	var/list/xenoa_seller_dialogue
	var/list/xenoa_artifact_names

	///Whitelist for traits by type
	var/list/xenoa_bluespace_traits
	var/list/xenoa_plasma_traits
	var/list/xenoa_uranium_traits
	var/list/xenoa_bananium_traits
	var/list/xenoa_pearl_traits

	///Incompatability lists - Partial future proof
	var/list/xenoa_item_incompatible
	var/list/xenoa_mob_incompatible
	var/list/xenoa_structure_incompatible

	///Labeler trait lists
	var/list/labeler_activator_traits
	var/list/labeler_minor_traits
	var/list/labeler_major_traits
	var/list/labeler_malfunction_traits
	var/list/labeler_tooltip_stats = list()
	var/list/labeler_traits_filter

	///Material weights, basically rarity
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
	//Bruh
	xenoa_seller_names -= ""
	xenoa_seller_dialogue -= ""
	xenoa_artifact_names -= ""

	//List of weights based on trait type
	xenoa_activators = compile_artifact_weights(/datum/xenoartifact_trait/activator)
	xenoa_minors = compile_artifact_weights(/datum/xenoartifact_trait/minor)
	xenoa_majors = compile_artifact_weights(/datum/xenoartifact_trait/major)
	xenoa_malfunctions = compile_artifact_weights(/datum/xenoartifact_trait/malfunction)
	xenoa_all_traits = compile_artifact_weights(/datum/xenoartifact_trait)
	xenoa_all_traits_keyed = compile_artifact_weights(/datum/xenoartifact_trait, TRUE)

	//Traits divided by flavor
	xenoa_bluespace_traits = compile_artifact_whitelist(/datum/xenoartifact_material/bluespace)
	xenoa_plasma_traits = compile_artifact_whitelist(/datum/xenoartifact_material/plasma)
	xenoa_uranium_traits = compile_artifact_whitelist(/datum/xenoartifact_material/uranium)
	xenoa_bananium_traits = compile_artifact_whitelist(/datum/xenoartifact_material/bananium)
	xenoa_pearl_traits = compile_artifact_whitelist(/datum/xenoartifact_material/pearl)

	//Compatabilities
	xenoa_item_incompatible = compile_artifact_compatibilties(TRAIT_INCOMPATIBLE_ITEM)
	xenoa_mob_incompatible = compile_artifact_compatibilties(TRAIT_INCOMPATIBLE_MOB)
	xenoa_structure_incompatible = compile_artifact_compatibilties(TRAIT_INCOMPATIBLE_STRUCTURE)

	//Labeler
	labeler_activator_traits = get_trait_list_stats(xenoa_activators)
	labeler_minor_traits = get_trait_list_stats(xenoa_minors)
	labeler_major_traits = get_trait_list_stats(xenoa_majors)
	labeler_malfunction_traits = get_trait_list_stats(xenoa_malfunctions)
	labeler_traits_filter = build_trait_filters()

/datum/controller/subsystem/xenoarchaeology/Shutdown()
	. = ..()

/datum/controller/subsystem/xenoarchaeology/Recover()
	. = ..()
	xenoa_seller_names = SSxenoarchaeology.xenoa_seller_names
	xenoa_seller_dialogue = SSxenoarchaeology.xenoa_seller_dialogue
	xenoa_artifact_names = SSxenoarchaeology.xenoa_artifact_names

	xenoa_activators = SSxenoarchaeology.xenoa_activators
	xenoa_minors = SSxenoarchaeology.xenoa_minors
	xenoa_majors = SSxenoarchaeology.xenoa_majors
	xenoa_malfunctions = SSxenoarchaeology.xenoa_malfunctions
	xenoa_all_traits = SSxenoarchaeology.xenoa_all_traits
	xenoa_all_traits_keyed = SSxenoarchaeology.xenoa_all_traits_keyed

	xenoa_bluespace_traits = SSxenoarchaeology.xenoa_bluespace_traits
	xenoa_plasma_traits = SSxenoarchaeology.xenoa_plasma_traits
	xenoa_uranium_traits = SSxenoarchaeology.xenoa_uranium_traits
	xenoa_bananium_traits = SSxenoarchaeology.xenoa_bananium_traits
	xenoa_pearl_traits = SSxenoarchaeology.xenoa_pearl_traits

	xenoa_item_incompatible = SSxenoarchaeology.xenoa_item_incompatible
	xenoa_mob_incompatible = SSxenoarchaeology.xenoa_mob_incompatible
	xenoa_structure_incompatible = SSxenoarchaeology.xenoa_structure_incompatible

	labeler_activator_traits = SSxenoarchaeology.labeler_activator_traits
	labeler_minor_traits = SSxenoarchaeology.labeler_minor_traits
	labeler_major_traits = SSxenoarchaeology.labeler_major_traits
	labeler_malfunction_traits = SSxenoarchaeology.labeler_malfunction_traits
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
		if(keyed)
			weighted += list(initial(T.label_name) = (T))
		else
			weighted += list((T) = initial(T.rarity)) //The (T) will not work if it is T
	return weighted

///Compile a blacklist of traits from a given flag/s
/datum/controller/subsystem/xenoarchaeology/proc/compile_artifact_whitelist(var/flags)
	var/list/output = list()
	for(var/datum/xenoartifact_trait/T as() in xenoa_all_traits)
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
/datum/controller/subsystem/xenoarchaeology/proc/compile_artifact_compatibilties(var/flags)
	var/list/output = list()
	for(var/datum/xenoartifact_trait/T as() in xenoa_all_traits)
		if(initial(T.incompatabilities) & flags)
			output += T
	return output

///Get a trait incompatability list based on the passed type
/datum/controller/subsystem/xenoarchaeology/proc/get_trait_incompatibilities(atom/type)
	//Items
	if(istype(type, /obj/item))
		return xenoa_item_incompatible
	//Mob
	if(istype(type, /mob))
		return xenoa_mob_incompatible
	//Structure
	if(istype(type, /obj/structure))
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

/datum/controller/subsystem/xenoarchaeology/proc/build_trait_filters()
	var/list/temp = list()
	for(var/datum/xenoartifact_trait/T as() in xenoa_all_traits)
		T = new T()
		var/list/hints = T.get_dictionary_hint()
		for(var/i in hints)
			if(!temp[i["icon"]])
				temp[i["icon"]] = list()
			temp[i["icon"]] += list("[initial(T.label_name)]")
		QDEL_NULL(T)
	return temp
