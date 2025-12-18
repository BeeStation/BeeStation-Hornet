/*
	Pitched
	This trait activates the artifact when it is thrown
*/
/datum/xenoartifact_trait/activator/pitched
	label_name = "Pitched"
	label_desc = "Pitched: The artifact seems to be made of an aerodynamic material. This material seems to be triggered by motion, such as being thrown."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	weight = -8
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE

/datum/xenoartifact_trait/activator/pitched/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	RegisterSignal(component_parent?.parent, COMSIG_MOVABLE_IMPACT, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_a))

/datum/xenoartifact_trait/activator/pitched/remove_parent(datum/source, pensive)
	if(!component_parent?.parent)
		return ..()
	UnregisterSignal(component_parent?.parent, COMSIG_MOVABLE_IMPACT)
	return ..()
