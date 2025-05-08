/*
	Weighted
	This trait activates the artifact when it is picked up
*/
/datum/xenoartifact_trait/activator/weighted
	label_name = "Weighted"
	label_desc = "Weighted: The artifact seems to be made of a weighted material. This material seems to be triggered by motion, such as being picked up."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	weight = 32
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE

/datum/xenoartifact_trait/activator/weighted/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	RegisterSignal(component_parent?.parent, COMSIG_ITEM_EQUIPPED, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_d))

/datum/xenoartifact_trait/activator/weighted/remove_parent(datum/source, pensive)
	if(!component_parent?.parent)
		return ..()
	UnregisterSignal(component_parent?.parent, COMSIG_ITEM_EQUIPPED)
	return ..()

/datum/xenoartifact_trait/activator/weighted/translation_type_d(datum/source, atom/target)
	trigger_artifact(target, XENOA_ACTIVATION_TOUCH)
