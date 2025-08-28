/datum/storage/implant
	max_specific_storage = WEIGHT_CLASS_NORMAL
	//desc states "two big items"
	max_total_storage = (WEIGHT_CLASS_LARGE + WEIGHT_CLASS_LARGE)
	max_slots = 2
	silent = TRUE
	allow_big_nesting = TRUE

/datum/storage/implant/New()
	. = ..()
	set_holdable(cant_hold_list = list(/obj/item/disk/nuclear))
