/datum/component/transfer_reagents
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/mob/living/touch_owner
	var/datum/reagents/reagents

/datum/component/transfer_reagents/Initialize(datum/reagents/reagent_source, volume_ratio = 1)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	reagents = new /datum/reagents(reagent_source.maximum_volume)
	reagents.my_atom = parent
	reagent_source.trans_to(reagents, reagent_source.maximum_volume * volume_ratio)

	var/obj/item/item_parent = parent
	if (iscarbon(item_parent.loc))
		var/mob/living/carbon/carbon_weraer = item_parent.loc
		register_touch_signals(carbon_weraer)

/datum/component/transfer_reagents/Destroy(force, silent)
	. = ..()
	QDEL_NULL(reagents)

/datum/component/transfer_reagents/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_touched))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))

/datum/component/transfer_reagents/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ATOM_ATTACKBY,
		COMSIG_COMPONENT_CLEAN_ACT
	))
	if (touch_owner)
		unregister_touch_signals(touch_owner)
	return ..()

/datum/component/transfer_reagents/proc/on_touched(datum/source, obj/item/item, mob/living/user)
	SIGNAL_HANDLER
	// Transfer half of the poison onto the item used
	if (reagents.total_volume > 1)
		item.AddComponent(/datum/component/transfer_reagents, reagents, 0.5)
	if (iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		var/obj/item/clothing/gloves = carbon_user.gloves
		// If we have gloves that cover the hands and they don't have the fingerprint passthrough
		// trait, then transfer our reagents
		if(gloves && (gloves.body_parts_covered & HANDS) && !HAS_TRAIT(gloves, TRAIT_FINGERPRINT_PASSTHROUGH && !HAS_TRAIT(carbon_user, TRAIT_FINGERPRINT_PASSTHROUGH)))
			// Transfer half of the poison to the gloves
			if (reagents.total_volume > 1)
				gloves.AddComponent(/datum/component/transfer_reagents, reagents, 0.5)
			return
	apply_poison(user)

/datum/component/transfer_reagents/proc/on_equipped(obj/item/target, mob/living/carbon/equipper, slot)
	SIGNAL_HANDLER
	if (slot == ITEM_SLOT_GLOVES)
		register_touch_signals(equipper)
		return
	else
		unregister_touch_signals(equipper)
	if (slot != ITEM_SLOT_HANDS)
		return
	if (!istype(equipper))
		return
	var/obj/item/clothing/gloves = equipper.gloves
	// If we have gloves that cover the hands and they don't have the fingerprint passthrough
	// trait, then transfer our reagents
	if(gloves && (gloves.body_parts_covered & HANDS) && !HAS_TRAIT(gloves, TRAIT_FINGERPRINT_PASSTHROUGH && !HAS_TRAIT(equipper, TRAIT_FINGERPRINT_PASSTHROUGH)))
		// Transfer half of the poison to the gloves
		if (reagents.total_volume > 1)
			gloves.AddComponent(/datum/component/transfer_reagents, reagents, 0.5)
		return
	apply_poison(equipper)

/datum/component/transfer_reagents/proc/apply_poison(mob/living/victim)
	reagents.expose(victim, TOUCH)
	qdel(src)

/datum/component/transfer_reagents/proc/on_clean(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/component/transfer_reagents/proc/on_touch(datum/source, mob/living/attacker, mob/living/target, datum/martial_art/attacker_style)
	SIGNAL_HANDLER
	// Protected
	if (prob(target.run_armor_check(attacker.get_combat_bodyzone(target), BIO, silent = TRUE)))
		return
	// Check for biological protection on the target
	apply_poison(target)

/datum/component/transfer_reagents/proc/register_touch_signals(mob/living/target)
	if (touch_owner)
		unregister_touch_signals(touch_owner)
	RegisterSignal(target, COMSIG_MOB_ATTACK_HAND, PROC_REF(on_touch))
	touch_owner = target

/datum/component/transfer_reagents/proc/unregister_touch_signals(mob/living/target)
	if (target != touch_owner)
		return
	UnregisterSignal(target, COMSIG_MOB_ATTACK_HAND)
