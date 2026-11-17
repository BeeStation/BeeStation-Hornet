/*
	Flourishing
	Ages up plants
*/
/datum/xenoartifact_trait/major/growing
	label_name = "Flourishing"
	label_desc = "Flourishing: The artifact seems to contain flourishing components. Triggering these components will revive the plant, resetting its yields."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	conductivity = 6
	weight = 6
	///Do we revive or kill the plant?
	var/revive = TRUE

/datum/xenoartifact_trait/major/growing/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/obj/target in focus)
		var/datum/component/plant/plant_comp = target.GetComponent(/datum/component/plant)
		if(!plant_comp)
			return
		var/datum/plant_feature/body/body_feature = locate(/datum/plant_feature/body) in plant_comp.plant_features
		if(!body_feature)
			return
		body_feature.yields = revive ? initial(body_feature.yields) : 0
		if(!revive)
			var/datum/plant_feature/fruit/fruit_feature = locate(/datum/plant_feature/fruit) in plant_comp.plant_features
			for(var/obj/fruit as anything in fruit_feature.fruits)
				fruit_feature.fruits -= fruit
				qdel(fruit)
			fruit_feature.visual_fruits = list()
			fruit_feature.growth_timers = list()
			body_feature.catch_harvest()
	dump_targets()
	clear_focus()

/datum/xenoartifact_trait/major/growing/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("revives plants"))

//Makes plants younger
/datum/xenoartifact_trait/major/growing/youth
	label_name = "Flourishing Δ"
	label_desc = "Flourishing Δ: The artifact seems to contain flourishing components. Triggering these components will wither plants, killing them."
	conductivity = 3
	revive = FALSE

/datum/xenoartifact_trait/major/growing/youth/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("withers plants"))
