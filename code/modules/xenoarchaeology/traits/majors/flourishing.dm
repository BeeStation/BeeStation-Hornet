/*
	Flourishing
	Ages up plants
*/
/datum/xenoartifact_trait/major/growing
	label_name = "Flourishing"
	label_desc = "Flourishing: The artifact seems to contain flourishing components. Triggering these components will age up plant targets."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	conductivity = 6
	weight = 6
	///Max amount we increase age by
	var/max_aging = 5

/datum/xenoartifact_trait/major/growing/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/obj/machinery/hydroponics/target in focus)
		target.age += max_aging * (component_parent.trait_strength/100)
	dump_targets()
	clear_focus()

/datum/xenoartifact_trait/major/growing/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("make plants age up"))

//Makes plants younger
/datum/xenoartifact_trait/major/growing/youth
	label_name = "Flourishing Δ"
	label_desc = "Flourishing Δ: The artifact seems to contain flourishing components. Triggering these components will age down plant targets."
	max_aging = -5
	conductivity = 3

/datum/xenoartifact_trait/major/growing/youth/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("make plants age down"))
