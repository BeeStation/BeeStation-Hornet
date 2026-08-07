/*
	Forcing
	Inacts a pushing or pulling force on the target
*/
/datum/xenoartifact_trait/major/force
	label_name = "Forcing"
	label_desc = "Forcing: The artifact seems to contain impulsing components. Triggering these components will impulse, push or pull, the target."
	cooldown = XENOA_TRAIT_COOLDOWN_SAFE
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 21
	conductivity = 27
	///Max force we can use, aka how far we throw things
	var/max_force = 7
	///Force direction, push or pull
	var/force_dir = 1

/datum/xenoartifact_trait/major/force/pull
	label_name = "Forcing Δ"
	force_dir = 0
	conductivity = 3

/datum/xenoartifact_trait/major/force/pull/get_dictionary_hint()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("pull the target"))

/datum/xenoartifact_trait/major/force/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/atom/movable/target in focus)
		if(target.anchored)
			return
		var/turf/parent_turf = get_turf(component_parent.parent)
		var/turf/T
		if(force_dir)
			T = get_edge_target_turf(parent_turf, get_dir(parent_turf, get_turf(target)) || pick(NORTH, EAST, SOUTH, WEST))
		else
			T = parent_turf
		target.throw_at(T, max_force*(component_parent.trait_strength/100), 4)
		unregister_target(target)
	dump_targets()
	clear_focus()

/datum/xenoartifact_trait/major/force/get_dictionary_hint()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("push the target"))
