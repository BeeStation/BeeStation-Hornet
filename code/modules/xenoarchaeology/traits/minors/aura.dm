/*
	Aura
	Adds nearby atoms to the target list
*/
/datum/xenoartifact_trait/minor/aura
	label_name = "Aura"
	label_desc = "Aura: The artifact's design seems to incorporate aura elements. This will cause the artifact to target things nearby."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	cooldown = XENOA_TRAIT_COOLDOWN_DANGEROUS
	extra_target_range = 2
	weight = 15
	conductivity = 5
	///Max amount of extra targets we can have
	var/max_extra_targets = 10

/datum/xenoartifact_trait/minor/aura/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/atom/target in oview(component_parent.target_range, get_turf(component_parent?.parent)))
		if(length(component_parent.targets) > (max_extra_targets * (component_parent.trait_strength/100)))
			continue
		//Only add mobs or items
		if(!ismob(target) && !isitem(target))
			continue
		component_parent.register_target(target)
