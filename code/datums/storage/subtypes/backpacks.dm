///Regular backpack
/datum/storage/backpack
	max_specific_storage = WEIGHT_CLASS_LARGE
	max_total_storage = 28
	max_slots = 25

/// Satchel flat
/datum/storage/backpack/satchel_flat
	max_total_storage = 15

/datum/storage/backpack/satchel_flat/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(cant_hold_list = /obj/item/storage/backpack/satchel/flat) //muh recursive backpacks

/// Santa bag
/datum/storage/backpack/santabag
	max_total_storage = 60

/// Mail bag
/datum/storage/backpack/mail
	allow_quick_gather = TRUE
	allow_quick_empty = TRUE
	numerical_stacking = TRUE
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = 32
	max_slots = 32

/datum/storage/backpack/mail/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(can_hold_list = list(
		/obj/item/mail,
		/obj/item/delivery/small,
		/obj/item/paper,
		/obj/item/reagent_containers/condiment/milk,
		/obj/item/food/bread/plain,
	))
