/// Wallet storage
/datum/storage/wallet
	max_specific_storage = WEIGHT_CLASS_SMALL
	max_slots = 4

/datum/storage/wallet/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(
		can_hold_list = list(
			/obj/item/stack/spacecash,
			/obj/item/holochip,
			/obj/item/card,
			/obj/item/cigarette,
			/obj/item/flashlight/pen,
			/obj/item/plant_seeds,
			/obj/item/stack/medical,
			/obj/item/toy/crayon,
			/obj/item/coin,
			/obj/item/dice,
			/obj/item/disk,
			/obj/item/implanter,
			/obj/item/lighter,
			/obj/item/lipstick,
			/obj/item/match,
			/obj/item/paper,
			/obj/item/pen,
			/obj/item/photo,
			/obj/item/reagent_containers/dropper,
			/obj/item/reagent_containers/syringe,
			/obj/item/screwdriver,
			/obj/item/stamp,
			/obj/item/clothing/accessory/badge,
		),
	)

/// Debug backpack/box
/datum/storage/debug
	allow_big_nesting = TRUE
	max_specific_storage = WEIGHT_CLASS_GIGANTIC
	max_slots = 1000
	max_total_storage = 1000

///Pill bottle
/datum/storage/pillbottle
	allow_quick_gather = TRUE
	open_sound = 'sound/items/handling/pill_bottle/pill_bottle_open.ogg'
	open_sound_vary = FALSE

/datum/storage/pillbottle/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/reagent_containers/applicator,
	))
