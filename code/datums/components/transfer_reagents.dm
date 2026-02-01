/datum/component/transfer_reagents
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/datum/reagents/reagents

/datum/component/transfer_reagents/Initialize(datum/reagents/reagent_source)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	reagents = new /datum/reagents(reagent_source.maximum_volume)
	reagents.my_atom = parent
	reagent_source.trans_to(reagents, reagent_source.maximum_volume)

/datum/component/transfer_reagents/Destroy(force, silent)
	. = ..()
	QDEL_NULL(reagents)

/datum/component/transfer_reagents/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))

/datum/component/transfer_reagents/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED,
	))
	return ..()

/datum/component/transfer_reagents/proc/on_equipped(obj/item/target, mob/living/carbon/equipper, slot)
	if (slot != ITEM_SLOT_HANDS)
		return
	if (!istype(equipper))
		return
	var/obj/item/clothing/gloves = equipper.gloves
	// If we have gloves that cover the hands and they don't have the fingerprint passthrough
	// trait, then transfer our reagents
	if(gloves && (gloves.body_parts_covered & HANDS) && !HAS_TRAIT(gloves, TRAIT_FINGERPRINT_PASSTHROUGH && !HAS_TRAIT(equipper, TRAIT_FINGERPRINT_PASSTHROUGH)))
		return
	reagents.expose(equipper, TOUCH)
	qdel(src)
