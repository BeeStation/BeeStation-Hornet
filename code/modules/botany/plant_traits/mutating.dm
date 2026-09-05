/datum/plant_trait/mutating
	name = "Mutating Emissions"
	desc = "This gene causes this plant to release gamma radiation that mutates neighbour plant's features of this trait's parent type."
	genetic_cost = 0

	// How long this trait takes between mutations
	var/mutate_timer = 10 //This is in seconds already, don't use the shortcut
	// How much time has passed
	var/mutation_time = 0

/datum/plant_trait/mutating/setup_component_parent(datum/source)
	. = ..()
	if(!parent || !parent.parent)
		return
	START_PROCESSING(SSobj, src)

/datum/plant_trait/mutating/process(delta_time)
	mutation_time += delta_time
	if(mutation_time < mutate_timer)
		return
	mutation_time = 0
	//This is pretty similar to / stolen from the mutator machine. Probably not work making this a dedicated proc though, not enough in common
	var/datum/component/planter/plant_tray = parent.parent.plant_item.loc.GetComponent(/datum/component/planter)
	if(!plant_tray)
		return
	for(var/datum/component/plant/plant_comp as anything in plant_tray.plants)
		if(plant_comp == parent.parent) //Dont mutate ourselves
			continue
		var/datum/plant_feature/feature = locate(parent.trait_type_shortcut) in plant_comp.plant_features
		//Flight checks
		if(!feature || !length(feature.mutations))
			continue
		var/datum/plant_feature/new_feature = pick(feature.mutations)
		new_feature = new new_feature(plant_comp)
		for(var/datum/plant_feature/current_feature as anything in plant_comp.plant_features-feature)
			//Is this feature blacklisted from another feature
			if(is_type_in_typecache(new_feature, current_feature.blacklist_features) || is_type_in_typecache(current_feature, new_feature.blacklist_features))
				qdel(new_feature)
				continue
			//If a feature has a whitelist, are we in it?
			if(length(current_feature.whitelist_features) && !is_type_in_typecache(new_feature, current_feature.whitelist_features) || length(new_feature.whitelist_features) && !is_type_in_typecache(current_feature, new_feature.whitelist_features))
				qdel(new_feature)
				continue
		//In case there's fruit on us and we're mutating a non-fruit feature
		var/datum/plant_feature/fruit/fruit_feature = locate(/datum/plant_feature/fruit) in plant_comp.plant_features
		fruit_feature?.force_drop_fruit()
		//Out with the old, in with the new
		plant_comp.plant_features -= feature
		if(!QDELING(new_feature))
			plant_comp.plant_features += new_feature
		//Reset species id so a new one can be made
		plant_comp.compile_species_id()
		plant_comp.plant_item.name = get_species_name(plant_comp.plant_features)
		//Reset the plant's growth
		for(var/datum/plant_feature/body/body_feature in plant_comp.plant_features)
			body_feature.growth_time_elapsed = 0
			body_feature.current_stage = 1
			body_feature.growth_step(1)
		qdel(feature)
		playsound(parent.parent.plant_item.loc, 'sound/effects/magic.ogg', 60, TRUE)
		playsound(parent.parent.plant_item.loc, 'sound/items/geiger/med4.ogg', 60, TRUE)
