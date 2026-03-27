/datum/plant_trait
	///Daddy-o, refers to the feature we belong to
	var/datum/plant_feature/parent
	///How much does this trait cost to use, in terms of genetic cost
	var/genetic_cost = 1
	///Can this trait appear as a random trait?
	var/random_trait = TRUE
	///Type path that represents our abstract type, this type is ommited from records
	var/abstract_type = /datum/plant_trait
//Identity
	var/name = ""
	var/desc = ""
//Compatability
	//Traits we're incompatible with
	var/list/blacklist = list()
	//Traits we're exclusively compatible with - leave blank to allow this trait to work with all traits
	var/list/whitelist = list()
	///What kind of plant feature are we compatible with - Random traits will need this to be a specific type, so they know where to appear
	var/plant_feature_compat = /datum/plant_feature
//Trait editing properties
	///Can this trait be copied
	var/can_copy = TRUE
	///Can this trait be removed
	var/can_remove = TRUE
	///Can this trait coexist with itself?
	var/allow_multiple = FALSE

/datum/plant_trait/New(datum/plant_feature/_parent)
	. = ..()
	if(plant_feature_compat && istype(_parent, /datum/plant_feature) && !istype(_parent, plant_feature_compat))
		// INITIALIZE_HINT_QDEL doesn't work here
		qdel(src)
		return
	setup_parent(_parent)

/datum/plant_trait/Destroy(force, ...)
	. = ..()
	//Return genetic budget
	parent?.adjust_genetic_budget(genetic_cost, src)

/datum/plant_trait/proc/get_ui_stats()
	return list(list("trait_name" = name, "trait_desc" = desc, "trait_ref" = REF(src), "dictionary_name" = name, "trait_id" = get_id(), "can_copy" = can_copy, "can_remove" = can_remove))

/datum/plant_trait/proc/copy(datum/plant_feature/_parent, datum/plant_trait/_trait)
	var/datum/plant_trait/new_trait = _trait || new type(_parent)
	return new_trait

/datum/plant_trait/proc/setup_parent(_parent)
	parent = _parent
	if(!parent || plant_feature_compat && !istype(parent))
		parent = null
		return
	if(!istype(parent))
		return
//Stuff we can do with just our feature parent
	//Tax genetic budget
	parent.adjust_genetic_budget(-genetic_cost, src)
//Stuff we need a component parent for
	if(!parent.parent)
		RegisterSignal(parent, COMSIG_PF_ATTACHED_PARENT, PROC_REF(setup_component_parent))
		return
	else
		setup_component_parent(parent.parent)

/datum/plant_trait/proc/setup_component_parent(datum/source)
	SIGNAL_HANDLER

	return

//use this to give randomized traits unique IDs, mostly for reagent traits
/datum/plant_trait/proc/get_id()
	return "[type]"
