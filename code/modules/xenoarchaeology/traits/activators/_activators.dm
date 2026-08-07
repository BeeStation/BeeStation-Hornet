/*
	Activators
	These traits cause the xenoartifact to trigger, activate

	* weight - All activators MUST have a weight that is a multiple of 8
	* conductivity - If an activator should have conductivity, it will be a multiple of 8 too
*/

/datum/xenoartifact_trait/activator
	register_targets = FALSE
	weight = 8
	conductivity = 0
	///Do we override the artifact's generic cooldown?
	var/override_cooldown = FALSE

//Translation procs that catch a signal and translate it into a trigger
//Throw custom cooldown logic in here
/datum/xenoartifact_trait/activator/proc/trigger_artifact(atom/target, type = XENOA_ACTIVATION_CONTACT, force)
	SIGNAL_HANDLER

	//Trait check - This is different from an anti artifact check and should be done here to avoid activations, this trait is a helper essentially
	if(isatom(target) && HAS_TRAIT(target, TRAIT_ARTIFACT_IGNORE))
		return FALSE
	//Stop traits that don't register targets activating when we feel them
	if(component_parent?.anti_check(target, type))
		return FALSE
	component_parent.register_target(target, force, type)
	component_parent.trigger()
	return TRUE

///Translates a (atom/target) input
/datum/xenoartifact_trait/activator/proc/translation_type_a(datum/source, atom/target)
	SIGNAL_HANDLER

	trigger_artifact(target)

///Translates a (atom/item, atom/target) input
/datum/xenoartifact_trait/activator/proc/translation_type_b(datum/source, atom/item, atom/target)
	SIGNAL_HANDLER

	if(check_item_safety(item))
		return
	trigger_artifact(target)

///Translates a (atom/target, atom/item) input
/datum/xenoartifact_trait/activator/proc/translation_type_c(datum/source, atom/target, atom/item)
	SIGNAL_HANDLER

	if(check_item_safety(item))
		return
	trigger_artifact(target)

///Translates a (atom/target) input, different to A becuase we use this one to handle dense cases and other conditions
/datum/xenoartifact_trait/activator/proc/translation_type_d(datum/source, atom/target)
	SIGNAL_HANDLER

	var/atom/atom_parent = component_parent?.parent
	if(!atom_parent.density)
		return
	trigger_artifact(target)

/datum/xenoartifact_trait/activator/proc/check_item_safety(atom/item)
	//Anti artifact check
	var/datum/component/anti_artifact/anti_component = item.GetComponent(/datum/component/anti_artifact)
	if(anti_component?.charges)
		anti_component.charges -= 1
		return TRUE
	//Trait check
	if(HAS_TRAIT(item, TRAIT_ARTIFACT_IGNORE))
		return TRUE
	return FALSE
