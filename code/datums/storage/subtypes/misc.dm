///Wallet storage
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
			/obj/item/seeds,
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
