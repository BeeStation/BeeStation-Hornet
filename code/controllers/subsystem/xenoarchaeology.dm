SUBSYSTEM_DEF(xenoarchaeology)
	name = "Xenoarchaeology"
	flags = SS_NO_FIRE

	///Which console is the main character
	var/obj/machinery/computer/xenoarchaeology_console/main_console

	//All the traits - before we sort them, semi needed for generation
	var/list/xenoa_all_traits = list()
	///All traits indexed by name, used for labelling stuff
	var/list/xenoa_all_traits_keyed = list()

	///Names for science sellers & artifacts
	var/list/xenoa_seller_names = list()
	var/list/xenoa_seller_dialogue = list()
	var/list/xenoa_artifact_names = list()

	///Whitelist for traits by material type
	var/list/material_info_list = list()

	///Incompatability lists - Partial future proofing some stuff
	var/list/xenoa_item_incompatible = list()
	var/list/xenoa_mob_incompatible = list()
	var/list/xenoa_structure_incompatible = list()

	///Labeler trait lists, basically just names
	var/datum/xenoa_material_info_holder/stats/labeler_traits
	///Other labeler shit
	var/list/labeler_tooltip_stats = list()
	var/list/labeler_traits_filter = list()

	///Material weights, basically rarity - Also used to populate some other lists
	var/list/xenoartifact_material_weights = list(XENOA_BLUESPACE = 10, XENOA_PLASMA = 8, XENOA_URANIUM = 5, XENOA_BANANIUM = 1)

	///Trait priority list - The order is important and it represents priotity
	var/list/xenoartifact_trait_category_priorities = list(TRAIT_PRIORITY_ACTIVATOR, TRAIT_PRIORITY_MINOR, TRAIT_PRIORITY_MALFUNCTION, TRAIT_PRIORITY_MAJOR)

	///List of 'discovered' traits
	var/list/discovered_traits = list()

/datum/controller/subsystem/xenoarchaeology/Initialize(timeofday)
//Poplate seller & artifact personalities
	xenoa_seller_names = world.file2list("strings/names/science_seller.txt")
	xenoa_seller_dialogue = world.file2list("strings/science_dialogue.txt")
	xenoa_artifact_names = world.file2list("strings/names/artifact_sentience.txt")
	//in a rare case where that the game failed to get these texts
	if(!length(xenoa_seller_names))
		xenoa_seller_names = list("Brock Enn")
	if(!length(xenoa_seller_dialogue))
		xenoa_seller_dialogue = list("Something isn't right!")
	if(!length(xenoa_artifact_names))
		xenoa_artifact_names = list("Brock Enn")

//Dirty unwashed masses
	var/list/standard_traits = typesof(/datum/xenoartifact_trait) - list(/datum/xenoartifact_trait, /datum/xenoartifact_trait/activator, /datum/xenoartifact_trait/minor, /datum/xenoartifact_trait/major, /datum/xenoartifact_trait/malfunction)
	xenoa_all_traits = list()
	xenoa_all_traits_keyed = list()
	for(var/datum/xenoartifact_trait/trait as anything in standard_traits)
		if(initial(trait.flags) & XENOA_HIDE_TRAIT)
			continue
		xenoa_all_traits_keyed[initial(trait.label_name)] = trait
		xenoa_all_traits[trait] = initial(trait.rarity)

//Compatabilities & labeler
	labeler_traits = new()
	labeler_traits.compile_artifact_whitelist(/datum/xenoartifact_material)
	labeler_traits_filter = list()
	for(var/datum/xenoartifact_trait/trait as anything in xenoa_all_traits)
	//Compat
		var/flags = initial(trait.incompatabilities)
		if(flags & TRAIT_INCOMPATIBLE_ITEM)
			xenoa_item_incompatible += trait
		if(flags & TRAIT_INCOMPATIBLE_MOB)
			xenoa_mob_incompatible += trait
		if(flags & TRAIT_INCOMPATIBLE_STRUCTURE)
			xenoa_structure_incompatible += trait
	//Label
		trait = new trait() //Instantiate so we can access a PROC
		var/list/hints = trait.get_dictionary_hint()
		for(var/each_hint in hints)
			if(!labeler_traits_filter[each_hint["icon"]])
				labeler_traits_filter[each_hint["icon"]] = list()
			labeler_traits_filter[each_hint["icon"]] += list("[initial(trait.label_name)]")
		QDEL_NULL(trait)

//Populate traits by material
	material_info_list = list()
	for(var/datum/xenoartifact_material/material_index as anything in typesof(/datum/xenoartifact_material))
		if(SSxenoarchaeology.material_info_list[initial(material_index.material_parent)])
			continue
		var/datum/xenoa_material_info_holder/material = new()
		material_info_list[material_index] = material
		//Populate datum fields
		material.compile_artifact_whitelist(material_index)

	return SS_INIT_SUCCESS

/datum/controller/subsystem/xenoarchaeology/Recover()
	. = ..()
	xenoa_seller_names = SSxenoarchaeology.xenoa_seller_names
	xenoa_seller_dialogue = SSxenoarchaeology.xenoa_seller_dialogue
	xenoa_artifact_names = SSxenoarchaeology.xenoa_artifact_names

	xenoa_all_traits = SSxenoarchaeology.xenoa_all_traits
	xenoa_all_traits_keyed = SSxenoarchaeology.xenoa_all_traits_keyed

	material_info_list = SSxenoarchaeology.material_info_list

	xenoa_item_incompatible = SSxenoarchaeology.xenoa_item_incompatible
	xenoa_mob_incompatible = SSxenoarchaeology.xenoa_mob_incompatible
	xenoa_structure_incompatible = SSxenoarchaeology.xenoa_structure_incompatible

	labeler_tooltip_stats = SSxenoarchaeology.labeler_tooltip_stats
	labeler_traits_filter = SSxenoarchaeology.labeler_traits_filter

/datum/controller/subsystem/xenoarchaeology/proc/register_console(obj/machinery/computer/xenoarchaeology_console/new_console)
	if(main_console)
		main_console.is_main_console = FALSE
		UnregisterSignal(main_console, COMSIG_QDELETING)
	main_console = new_console
	main_console.is_main_console = TRUE
	RegisterSignal(main_console, COMSIG_QDELETING, PROC_REF(catch_console))

/datum/controller/subsystem/xenoarchaeology/proc/catch_console(datum/source)
	SIGNAL_HANDLER

	main_console = null
	SEND_SIGNAL(src, COMSIG_XENOA_REQUEST_NEW_CONSOLE)

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

/*
	Datum for holding a bunch of listed traits for a certain material
	Thanks, EvilDragon
*/

/datum/xenoa_material_info_holder
	///List of traits per category
	var/list/activators = list()
	var/list/minors = list()
	var/list/majors = list()
	var/list/malfunctions = list()
	///Has this datum been compiled / populated?
	var/compiled = FALSE

///Populate our trait lists from a given material path
/datum/xenoa_material_info_holder/proc/compile_artifact_whitelist(datum/xenoartifact_material/material)
	for(var/datum/xenoartifact_trait/trait as anything in SSxenoarchaeology.xenoa_all_traits)
		if(initial(trait.flags) & XENOA_HIDE_TRAIT)
			continue
		if(!(initial(trait.flags) & initial(material.trait_flags)))
			continue
		//Sort trait into list
		if(ispath(trait, /datum/xenoartifact_trait/activator))
			activators[trait] = initial(trait.rarity)
			continue
		if(ispath(trait, /datum/xenoartifact_trait/minor))
			minors[trait] = initial(trait.rarity)
			continue
		if(ispath(trait, /datum/xenoartifact_trait/major))
			majors[trait] = initial(trait.rarity)
			continue
		if(ispath(trait, /datum/xenoartifact_trait/malfunction))
			malfunctions[trait] = initial(trait.rarity)
			continue
	compiled = TRUE

//Variant for stats, labeler baking
/datum/xenoa_material_info_holder/stats

/datum/xenoa_material_info_holder/stats/compile_artifact_whitelist(datum/xenoartifact_material/material)
	for(var/datum/xenoartifact_trait/trait as anything in SSxenoarchaeology.xenoa_all_traits)
		if(initial(trait.flags) & XENOA_HIDE_TRAIT)
			continue
		if(!(initial(trait.flags) & initial(material.trait_flags)))
			continue
		//We're gonna be nice an populate labeler_tooltip_stats while we're at it, because we're nice
		//generate tool tips
		var/datum/xenoartifact_trait/hint_holder = new trait() //Instantiate so we can access a PROC
		var/name = initial(trait.label_name)
		SSxenoarchaeology.labeler_tooltip_stats["[name]"] = list("weight" = initial(trait.weight), "conductivity" = initial(trait.conductivity), "alt_name" = initial(trait.alt_label_name), "desc" = initial(trait.label_desc), "hints" = hint_holder.get_dictionary_hint())
		qdel(hint_holder)
		//Generate material availability
		var/list/materials = list(XENOA_BLUESPACE, XENOA_PLASMA, XENOA_URANIUM, XENOA_BANANIUM, XENOA_PEARL)
		SSxenoarchaeology.labeler_tooltip_stats["[name]"]["availability"] = list()
		for(var/datum/xenoartifact_material/M as anything in materials)
			if(initial(M.trait_flags) & initial(trait.flags))
				SSxenoarchaeology.labeler_tooltip_stats["[name]"]["availability"] += list(list("color" = initial(M.material_color), "icon" = initial(M.label_icon)))
		//Sort trait into list
		if(ispath(trait, /datum/xenoartifact_trait/activator) && (trait != /datum/xenoartifact_trait/activator))
			activators += name
			continue
		if(ispath(trait, /datum/xenoartifact_trait/minor) && (trait != /datum/xenoartifact_trait/minor))
			minors += name
			continue
		if(ispath(trait, /datum/xenoartifact_trait/major) && (trait != /datum/xenoartifact_trait/major))
			majors += name
			continue
		if(ispath(trait, /datum/xenoartifact_trait/malfunction) && (trait != /datum/xenoartifact_trait/malfunction))
			malfunctions += name
			continue
