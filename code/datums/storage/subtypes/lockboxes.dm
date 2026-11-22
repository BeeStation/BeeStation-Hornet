///Normal lockbox
/datum/storage/lockbox
	max_total_storage = 14
	max_slots = 4
	locked = TRUE

/datum/storage/lockbox/medal
	max_slots = 10
	max_total_storage = 20
	max_specific_storage = WEIGHT_CLASS_SMALL

/datum/storage/lockbox/medal/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(/obj/item/clothing/accessory/medal)
