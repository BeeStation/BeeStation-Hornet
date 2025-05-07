/*
	Slippery
	makes the artifact slippery
*/
/datum/xenoartifact_trait/minor/slippery
	material_desc = "slippery"
	label_name = "Slippery"
	label_desc = "Slippery: The artifact's design seems to incorporate slippery elements. This will cause the artifact to be slippery."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	conductivity = 5
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE
	///Refernce to slip component for later cleanup
	var/datum/component/slippery/slip_comp

/datum/xenoartifact_trait/minor/slippery/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	var/atom/atom_parent = component_parent.parent
	slip_comp = atom_parent.AddComponent(/datum/component/slippery, 60)

/datum/xenoartifact_trait/minor/slippery/remove_parent(datum/source, pensive)
	if(!component_parent?.parent)
		return ..()
	QDEL_NULL(slip_comp)
	return ..()

/datum/xenoartifact_trait/minor/slippery/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL)
