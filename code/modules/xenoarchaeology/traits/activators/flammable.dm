/*
	Flammable
	This trait activates the artifact when it's lit
*/
/datum/xenoartifact_trait/activator/flammable
	material_desc = "flammable"
	label_name = "Flammable"
	label_desc = "Flammable: The artifact seems to be made of a flammable material. This material seems to be triggered by heat interaction."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	///Are we 'lit' and looking for targets
	var/lit = FALSE
	///Search cooldown logic
	var/search_cooldown = 4 SECONDS
	var/search_cooldown_timer

/datum/xenoartifact_trait/activator/flammable/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	RegisterSignal(component_parent?.parent, COMSIG_ATOM_ATTACKBY, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_b))
	RegisterSignal(component_parent?.parent, COMSIG_ATOM_ATTACK_HAND, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_d))
	RegisterSignal(component_parent?.parent, COMSIG_ITEM_ATTACK_SELF, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_a))

/datum/xenoartifact_trait/activator/flammable/remove_parent(datum/source, pensive)
	if(!component_parent?.parent)
		return ..()
	UnregisterSignal(component_parent?.parent, COMSIG_ATOM_ATTACKBY)
	UnregisterSignal(component_parent?.parent, COMSIG_ATOM_ATTACK_HAND)
	UnregisterSignal(component_parent?.parent, COMSIG_ITEM_ATTACK_SELF)
	return ..()

/datum/xenoartifact_trait/activator/flammable/translation_type_a(datum/source, atom/target)
	lit = FALSE
	//Indicator hint
	indicator_hint()

/datum/xenoartifact_trait/activator/flammable/translation_type_b(datum/source, atom/item, atom/target)
	var/obj/item/I = item
	if(isitem(I) && I.is_hot() && !check_item_safety(item))
		if(HAS_TRAIT(item, TRAIT_ARTIFACT_IGNORE))
			return FALSE
		if(component_parent.anti_check(target, XENOA_ACTIVATION_TOUCH))
			return FALSE
		lit = TRUE
		indicator_hint(1)
		search_cooldown_timer = addtimer(CALLBACK(src, PROC_REF(reset_timer)), search_cooldown, TIMER_STOPPABLE)
		START_PROCESSING(SSobj, src)

/datum/xenoartifact_trait/activator/flammable/translation_type_d(datum/source, atom/target)
	var/atom/atom_parent = component_parent?.parent
	if(atom_parent?.density)
		lit = FALSE
		indicator_hint()

/datum/xenoartifact_trait/activator/flammable/process(delta_time)
	if(!lit)
		return ..()
	if(search_cooldown_timer)
		return
	for(var/atom/target in oview(component_parent.target_range, get_turf(component_parent?.parent)))
		//Only add mobs
		if(!ismob(target))
			continue
		trigger_artifact(target)
		lit = FALSE
		indicator_hint()
		break
	search_cooldown_timer = addtimer(CALLBACK(src, PROC_REF(reset_timer)), search_cooldown, TIMER_STOPPABLE)

/datum/xenoartifact_trait/activator/flammable/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL, XENOA_TRAIT_HINT_TRIGGER("'hot' tool"), list("icon" = "exclamation", "desc" = "This trait will, after an arming time, activate on the nearest living target."))

/datum/xenoartifact_trait/activator/flammable/proc/reset_timer()
	if(search_cooldown_timer)
		deltimer(search_cooldown_timer)
	search_cooldown_timer = null

/datum/xenoartifact_trait/activator/flammable/proc/indicator_hint(engaging = FALSE)
	var/atom/atom_parent = component_parent?.parent
	atom_parent?.balloon_alert_to_viewers("[atom_parent] [engaging ? "flicks on" : "snuffs out."]!")
