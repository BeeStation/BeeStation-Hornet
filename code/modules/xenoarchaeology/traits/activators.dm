//These traits cause the xenoartifact to trigger, activate
/datum/xenoartifact_trait/activator
	register_targets = FALSE
	///Do we override the artifact's generic cooldown?
	var/override_cooldown = FALSE

//Throw custom cooldown logic in here
/datum/xenoartifact_trait/activator/proc/trigger_artifact()
	SIGNAL_HANDLER

	parent.trigger()
	return

/*
	Sturdy
	This trait activates the artifact when it's used, like a generic item
*/

/datum/xenoartifact_trait/activator/strudy
	examine_desc = "sturdy"
	label_name = "Sturdy"
	label_desc = "The artifact seems to be made of a sturdy material. This material seems to be triggered by physical interaction."
	weight = 3

/datum/xenoartifact_trait/activator/strudy/New()
	. = ..()
	//Register all the relevant signals we trigger from
	RegisterSignal(parent.parent, COMSIG_PARENT_ATTACKBY, PROC_REF(translation_type_b))
	RegisterSignal(parent.parent, COMSIG_MOVABLE_IMPACT, PROC_REF(translation_type_a))
	RegisterSignal(parent.parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(translation_type_a))
	RegisterSignal(parent.parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(translation_type_c))
	RegisterSignal(parent.parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(translation_type_d))

/datum/xenoartifact_trait/activator/strudy/proc/translation_type_a(datum/source, atom/target)
	SIGNAL_HANDLER

	parent.register_target(target)
	trigger_artifact()

/datum/xenoartifact_trait/activator/strudy/proc/translation_type_b(datum/source, atom/item, atom/target)
	SIGNAL_HANDLER

	parent.register_target(target)
	trigger_artifact()

/datum/xenoartifact_trait/activator/strudy/proc/translation_type_c(datum/source, atom/target, atom/item)
	SIGNAL_HANDLER

	parent.register_target(target)
	trigger_artifact()

/datum/xenoartifact_trait/activator/strudy/proc/translation_type_d(datum/source, atom/target)
	SIGNAL_HANDLER

	var/atom/A = parent.parent
	if(!A.density)
		return
	parent.register_target(target)
	trigger_artifact()
