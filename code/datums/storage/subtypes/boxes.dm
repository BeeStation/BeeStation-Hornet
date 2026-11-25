/// Normal box
/datum/storage/box
	max_slots = 8
	max_total_storage = 8
	max_specific_storage = WEIGHT_CLASS_NORMAL
	open_sound = 'sound/items/handling/cardboard_box/cardboard_box_open.ogg'
	rustle_sound = 'sound/items/handling/cardboard_box/cardboard_box_rustle.ogg'

/// Debug box
/datum/storage/box/debug
	allow_big_nesting = TRUE
	max_slots = 99
	max_specific_storage = WEIGHT_CLASS_GIGANTIC
	max_total_storage = 99

/// Survival box
/datum/storage/box/survival
	max_slots = 5
	max_total_storage = 21
	max_specific_storage = WEIGHT_CLASS_TINY

/datum/storage/box/survival/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	var/static/list/exception_hold = typecacheof(list(
		/obj/item/flashlight/flare,
		/obj/item/radio,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/gas,
		/obj/item/reagent_containers/hypospray/medipen,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman/belt,
	))
	exception_hold = exception_hold

/// Donk Pocket box
/datum/storage/box/donk_pockets

/datum/storage/box/donk_pockets/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(/obj/item/food/donkpocket)

/// Monkey cube box
/datum/storage/box/monkey_cube
	max_slots = 7

/datum/storage/box/monkey_cube/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(
		can_hold_list = /obj/item/food/monkeycube,
		cant_hold_list = /obj/item/food/monkeycube/gorilla,
	)

/// Gorilla cube box
/datum/storage/box/gorilla_cube
	max_slots = 3

/datum/storage/box/gorilla_cube/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(/obj/item/food/monkeycube/gorilla)

/// Handcuff box
/datum/storage/box/handcuffs
	max_slots = 7
	max_total_storage = 14
	max_specific_storage = WEIGHT_CLASS_SMALL

/// COMPACT handcuff box
/datum/storage/box/handcuffs/compact
	max_slots = 4
	max_total_storage = 8

/// Zipties box
/datum/storage/box/zipties
	max_slots = 14
	max_total_storage = 28
	max_specific_storage = WEIGHT_CLASS_SMALL

/// COMPACT zipties box
/datum/storage/box/zipties/compact
	max_slots = 7

/// Snap pops box
/datum/storage/box/snap_pops
	max_slots = 8

/datum/storage/box/snap_pops/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(/obj/item/toy/snappop)

/// Match box
/datum/storage/box/match
	max_slots = 10

/datum/storage/box/match/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(/obj/item/match)

/// Light Box
/datum/storage/box/lights
	max_slots = 21
	max_total_storage = 21
	allow_quick_gather = FALSE //temp workaround to re-enable filling the light replacer with the box

/datum/storage/box/lights/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(list(
		/obj/item/light/tube,
		/obj/item/light/bulb,
	))
