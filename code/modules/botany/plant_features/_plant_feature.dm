/datum/plant_feature
	abstract_type = /datum/plant_feature

	///The 'scientific' name for our plant feature
	var/species_name = "testus testium"
	///The regular name
	var/name = "test"

	///What category of feature/s are we? Mostly used for gene editing.
	var/feature_catagories

	///Reference to component daddy
	var/datum/component/plant/parent

	///List of features we don't wanna be with
	var/list/blacklist_features = list()
	///List of features we can only be with
	var/list/whitelist_features = list()

	///What traits are we rockin'?
	var/list/plant_traits = list()
	///What is the power coefficient for our traits that use it? Generally scale this as stuff like 1.3 1.8 2.1
	var/trait_power = 1

	///What are our desires, what we need to grow
	var/list/plant_needs = list()

	/*
		Although this is a list, it might be better, in terms of design, to only
		mutate into one thing, and have that one thing mutate into the
		next. Then the final mutation should mutate back into this.
	*/
	///What can this feature mutate into? typically list(mutation, mutation, mutation) but it can also be list(mutation = 10) if you want certain mutations to cost more
	var/list/mutations = list()

	///What is our genetic budget for how many traits we can afford?
	var/genetic_budget = 3
	var/remaining_genetic_budget
	///List of needs we've gained from overdrawing our budget
	var/list/overdraw_needs = list()

	///Trait type shortcut
	var/trait_type_shortcut = /datum/plant_feature

	///What feature do we default to in the dictionary? leave blank for most cases. Only fill in for once in a case variants
	var/dictionary_override

//Appearance
	var/icon = 'icons/obj/hydroponics/features/generic.dmi'
	var/icon_state = ""
	var/mutable_appearance/feature_appearance

//Trait editing properties
	///Can this trait be copied
	var/can_copy = TRUE
	///Can this trait be removed
	var/can_remove = TRUE

/datum/plant_feature/New(datum/component/plant/_parent)
	. = ..()
	remaining_genetic_budget = genetic_budget
	//Build our initial appearance
	feature_appearance = mutable_appearance(icon, icon_state)
	//Setup parent stuff
	setup_parent(_parent)
	//Build initial traits
	for(var/trait as anything in plant_traits)
		plant_traits -= trait
		plant_traits += new trait(src)
	//Build initial needs
	for(var/need as anything in plant_needs)
		if(!ispath(need))
			continue
		plant_needs -= need
		plant_needs += new need(src)
	//Build white & black list
	blacklist_features = typecacheof(blacklist_features)
	whitelist_features = typecacheof(whitelist_features)

/datum/plant_feature/Destroy(force, ...)
	for(var/datum/plant_trait/trait as anything in plant_traits)
		plant_traits -= trait
		qdel(trait)
	for(var/datum/plant_need/need as anything in plant_needs)
		plant_needs -= need
		qdel(need)
	//Remove ourselves from a trays concern when self immolating - Only happens with admin fuckery and tubers
	var/obj/item/plant_tray/tray = parent?.plant_item?.loc
	if(istype(tray))
		tray.remove_feature_indicator(tray, src, tray.needy_features)
	return ..()

/datum/plant_feature/proc/get_mutation_cost_string()
	if(!length(mutations))
		return "no mutations"
	var/string
	for(var/datum/plant_feature/path as anything in mutations)
		string = "[string][string ? "/" : ""][path::name] [mutations[path]||1]"
	return string

//Used to get dialogue / text for hand-held plant scanner - This is like get_ui_data() but it has more information about specific things you'd want to know on the fly
/datum/plant_feature/proc/get_scan_dialogue()
	var/list/dialogue = list()
	//identity
	dialogue += "[capitalize(name)]([species_name])\n"
	//Traits
	var/grouping = ""
	for(var/datum/plant_trait/trait as anything in plant_traits)
		grouping += "[trait.name]\n"
	dialogue += grouping
	//generic shared info - This can be a little duplicate when compared with get_ui_data() but it'll be good to keep this seperate for future additions
	grouping = ""
	grouping += "Genetic Stability: [genetic_budget]\n"
	grouping += "Genetic Availability: [remaining_genetic_budget]\n"
	grouping += "Trait Modifier: [trait_power]\n"
	dialogue += grouping
	return dialogue

//Used to get dialogue / text for needs, when a tray is scanned
/datum/plant_feature/proc/get_need_dialogue(buffs = TRUE)
	var/list/dialogue = list()
	for(var/datum/plant_need/need as anything in plant_needs)
		if(!buffs && need.buff)
			continue
		dialogue += "[need.need_description]"
	return dialogue

///This is a keyed list for UIs to get specific values, usually for logic or display
/datum/plant_feature/proc/get_ui_stats()
	return list("name" = capitalize(name), "species_name" = capitalize(species_name), "key" = REF(src), "feature_appearance" = icon2base64(feature_appearance), "type_shortcut" = "[trait_type_shortcut]",
	"can_copy" = can_copy, "can_remove" = can_remove, "mutation_cost" = get_mutation_cost_string())

///This is for display+, a pre-formatted list of nice looking text
/datum/plant_feature/proc/get_ui_data()
	return list(PLANT_DATA("Name", capitalize(name)), PLANT_DATA("Species Name", capitalize(species_name)), PLANT_DATA(null, null))

//our traits
/datum/plant_feature/proc/get_ui_traits()
	if(!length(plant_traits))
		return
	var/list/trait_ui = list()
	for(var/datum/plant_trait/trait as anything in plant_traits)
		trait_ui += trait.get_ui_stats()
	return trait_ui

///Copies the plant's unique data - This is mostly, if not entirely, for randomized stuff & custom player made plants
/datum/plant_feature/proc/copy(datum/component/plant/_parent, datum/plant_feature/_feature)
	var/datum/plant_feature/new_feature = _feature || new type(_parent)
//Copy traits & needs - The reason we do this is to handle randomized traits & needs, make them the same as this one
	//traits
	for(var/trait as anything in new_feature.plant_traits) //Remove generic type traits
		new_feature.plant_traits -= trait
		qdel(trait)
	for(var/datum/plant_trait/trait as anything in plant_traits) //Add our la-de-da new traits inherited from our grandpappy
		new_feature.plant_traits += trait.copy(new_feature)
	//needs
	for(var/datum/plant_need/need as anything in new_feature.plant_needs)
		if(need.overdrawn) //Don't fiddle with overdraw needs, they're generated on runtime as an effect of traits
			continue
		new_feature.plant_needs -= need
		qdel(need)
	for(var/datum/plant_need/need as anything in plant_needs)
		if(need.overdrawn)
			continue
		new_feature.plant_needs += need.copy(new_feature)
	return new_feature

/datum/plant_feature/proc/setup_parent(_parent, reset_features = TRUE)
	//Remove our initial parent
	if(parent)
		UnregisterSignal(parent.plant_item, COMSIG_ATOM_EXAMINE)
		UnregisterSignal(parent, COMSIG_PLANT_PLANTED)
		UnregisterSignal(parent, COMSIG_PLANT_UPROOTED)
	//Shack up with the new rockstar
	parent = _parent
	if(parent?.plant_item)
		RegisterSignal(parent.plant_item, COMSIG_ATOM_EXAMINE, PROC_REF(catch_examine))
	RegisterSignal(parent, COMSIG_PLANT_PLANTED, PROC_REF(catch_planted))
	RegisterSignal(parent, COMSIG_PLANT_UPROOTED, PROC_REF(catch_uprooted))
	SEND_SIGNAL(src, COMSIG_PF_ATTACHED_PARENT)

/datum/plant_feature/proc/remove_parent()
	setup_parent(null)

/datum/plant_feature/proc/check_needs(_delta_time)
	. = TRUE
	if(SEND_SIGNAL(parent.plant_item.loc, COMSIG_PLANT_NEEDS_PAUSE, parent))
		return FALSE
	for(var/datum/plant_need/need as anything in plant_needs)
		if(ispath(need))
			continue
		if(!need?.check_need(_delta_time) && !need?.buff)
			. = FALSE
	if(!.)
		SEND_SIGNAL(parent, COMSIG_PLANT_NEEDS_FAILS, src)
		return
	SEND_SIGNAL(parent, COMSIG_PLANT_NEEDS_PASS, src)

/datum/plant_feature/proc/catch_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	//Info
	return

///Use this to associate this feature datum with a seed packet, before it's planted
/datum/plant_feature/proc/associate_seeds(obj/item/plant_seeds/seeds)
	return

/datum/plant_feature/proc/catch_planted(datum/source, atom/destination)
	SIGNAL_HANDLER

/datum/plant_feature/proc/catch_uprooted(datum/source, mob/user, obj/item/tool, atom/old_loc)
	SIGNAL_HANDLER

///Used to adjust our genetic budget, contains logic for overdrawing our budget
/datum/plant_feature/proc/adjust_genetic_budget(amount, datum/plant_trait/source)
	//Adjust budget before anything else, because we need to see this in the editors
	remaining_genetic_budget += amount
	//This other shit only happens with a real plant, the only place you can see needs
	if(!parent)
		return
//Need management
	if(!SSbotany.previous_needs["[parent.species_id]"])
		SSbotany.previous_needs["[parent.species_id]"] = list()
	//If we're overdrawing, add needs
	if(amount < 0 && remaining_genetic_budget < 0)
		var/datum/plant_need/need = SSbotany.previous_needs["[parent.species_id]"]["[source.get_id()]"] || SSbotany.get_random_need()
		SSbotany.previous_needs["[parent.species_id]"] |= list("[source.type]" = need.type)
		need = new need(src, TRUE)
		overdraw_needs += list(REF(source) = need)
		plant_needs += need
		return
	//If we're paying it back, remove needs
	if(amount > 0 && plant_needs[REF(source)])
		var/datum/plant_need/need = overdraw_needs[REF(source)]
		plant_needs -= need
		overdraw_needs[REF(source)] = null
		overdraw_needs -= REF(source)
		qdel(need)
