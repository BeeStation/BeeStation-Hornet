/*
	Ringed
	Allows the artifact to be worn in the glove slot
*/
/datum/xenoartifact_trait/minor/ringed
	material_desc = "ringed"
	label_name = "Ringed"
	label_desc = "Ringed: The artifact's design seems to incorporate ringed elements. This will allow the artifact to be worn, and catch information from the wearer."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense, /datum/xenoartifact_trait/minor/ringed/attack)
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE
	///Old wearable state
	var/old_wearable

/datum/xenoartifact_trait/minor/ringed/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	//Item equipping
	var/obj/item/item_parent = component_parent.parent
	if(isitem(item_parent))
		old_wearable = item_parent.slot_flags
		item_parent.slot_flags |= ITEM_SLOT_GLOVES
		//Action
		RegisterSignal(item_parent, COMSIG_ITEM_EQUIPPED, PROC_REF(equip_action))
		RegisterSignal(item_parent, COMSIG_ITEM_DROPPED, PROC_REF(drop_action))

/datum/xenoartifact_trait/minor/ringed/remove_parent(datum/source, pensive)
	if(!component_parent?.parent)
		return ..()
	var/obj/item/item_parent = component_parent.parent
	if(isitem(item_parent))
		item_parent.slot_flags = old_wearable
	return ..()

/datum/xenoartifact_trait/minor/ringed/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("pass attacks on the user to the artifact, when worn. This only applies to attacks involving items"))

/datum/xenoartifact_trait/minor/ringed/proc/equip_action(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(slot == ITEM_SLOT_GLOVES)
		RegisterSignal(equipper, COMSIG_PARENT_ATTACKBY, PROC_REF(catch_attack))

/datum/xenoartifact_trait/minor/ringed/proc/drop_action(datum/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, COMSIG_PARENT_ATTACKBY)

//Foward the attack to our artifact
/datum/xenoartifact_trait/minor/ringed/proc/catch_attack(datum/source, obj/item, mob/living, params)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(cool_async_action), item, living, params)

/datum/xenoartifact_trait/minor/ringed/proc/cool_async_action(obj/item, mob/living, params)
	var/atom/atom_parent = component_parent?.parent
	atom_parent?.attackby(item, living, params)

//Variant for when the user attacks
/datum/xenoartifact_trait/minor/ringed/attack
	material_desc = "ringed"
	label_name = "Ringed Δ"
	label_desc = "Ringed Δ: The artifact's design seems to incorporate ringed elements. This will allow the artifact to be worn, and catch information from the wearer."
	conductivity = 15
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense, /datum/xenoartifact_trait/minor/ringed)

/datum/xenoartifact_trait/minor/ringed/attack/equip_action(datum/source, mob/equipper, slot)
	if(slot == ITEM_SLOT_GLOVES)
		RegisterSignal(equipper, COMSIG_MOB_ATTACK_HAND, PROC_REF(catch_user_attack))

/datum/xenoartifact_trait/minor/ringed/attack/drop_action(datum/source, mob/user)
	UnregisterSignal(user, COMSIG_MOB_ATTACK_HAND)

/datum/xenoartifact_trait/minor/ringed/attack/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("pass attacks from the user to the artifact, when worn"))

/datum/xenoartifact_trait/minor/ringed/attack/proc/catch_user_attack(datum/source, mob/user, mob/target, params)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(other_cool_async_action), user, target, params)

/datum/xenoartifact_trait/minor/ringed/attack/proc/other_cool_async_action(mob/user, mob/target, params)
	if(user == target)
		return
	var/obj/item/item_parent = component_parent?.parent
	item_parent?.afterattack(target, user, TRUE)
