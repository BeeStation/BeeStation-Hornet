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
			/obj/item/coin,
			/obj/item/dice,
			/obj/item/disk,
			/obj/item/flashlight/pen,
			/obj/item/food/chococoin,
			/obj/item/implanter,
			/obj/item/laser_pointer,
			/obj/item/lighter,
			/obj/item/lipstick,
			/obj/item/match,
			/obj/item/paper,
			/obj/item/pen,
			/obj/item/photo,
			/obj/item/reagent_containers/dropper,
			/obj/item/reagent_containers/syringe,
			/obj/item/screwdriver,
			/obj/item/seeds,
			/obj/item/stack/medical,
			/obj/item/stamp,
			/obj/item/toy/crayon,
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

/// Stasis fish case
/datum/storage/fish_case
	max_slots = 1
	can_hold_description = "fish and aquarium equipment"

/datum/storage/fish_case/can_insert(obj/item/to_insert, mob/user, messages = TRUE, force = STORAGE_NOT_LOCKED)
	. = ..()
	if(!.)
		return

	if(!HAS_TRAIT(to_insert, TRAIT_FISH_CASE_COMPATIBILE))
		if(messages && user)
			user.balloon_alert(user, "can't hold!")
		return FALSE
