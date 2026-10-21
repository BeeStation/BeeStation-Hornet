///Normal lockbox
/datum/storage/lockbox
	max_total_storage = 14
	max_slots = 4
	locked = STORAGE_FULLY_LOCKED

/datum/storage/lockbox/medal
	max_slots = 10
	max_total_storage = 20
	max_specific_storage = WEIGHT_CLASS_SMALL

/datum/storage/lockbox/medal/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(/obj/item/clothing/accessory/medal)
