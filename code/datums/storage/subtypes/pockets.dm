/datum/storage/pockets
	max_slots = 2
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = 50
	rustle_sound = FALSE

/datum/storage/pockets/attempt_insert(obj/item/to_insert, mob/user, override, force, messages)
	. = ..()
	if(!.)
		return

	if(!silent || override)
		return

	if(quickdraw)
		to_chat(user, span_notice("You discreetly slip [to_insert] into [parent]. Right-click to remove it."))
	else
		to_chat(user, span_notice("You discreetly slip [to_insert] into [parent]."))

/datum/storage/pockets/small
	max_slots = 1
	max_specific_storage = WEIGHT_CLASS_SMALL
	attack_hand_interact = FALSE

/datum/storage/pockets/tiny
	max_slots = 1
	max_specific_storage = WEIGHT_CLASS_TINY
	attack_hand_interact = FALSE

/datum/storage/pockets/exo
	max_slots = 2
	max_specific_storage = WEIGHT_CLASS_SMALL
	attack_hand_interact = FALSE
	quickdraw = FALSE
	silent = FALSE

/datum/storage/pockets/exo/cloak
	max_slots = 1
	quickdraw = TRUE

/datum/storage/pockets/exo/large
	max_slots = 3

/datum/storage/pockets/small/fedora/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()

	set_holdable(exception_hold_list = list(
		/obj/item/katana,
		/obj/item/toy/katana,
		/obj/item/nullrod/claymore/katana,
		/obj/item/energy_katana,
		/obj/item/gun/ballistic/automatic/tommygun,
	))

/datum/storage/pockets/small/fedora/detective
	attack_hand_interact = TRUE // so the detectives would discover pockets in their hats

/datum/storage/pockets/shoes
	max_slots = 2
	attack_hand_interact = FALSE
	max_specific_storage = WEIGHT_CLASS_SMALL
	quickdraw = TRUE
	silent = TRUE

/datum/storage/pockets/shoes/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	set_holdable(
		can_hold_list = list(
			/obj/item/knife,
			/obj/item/switchblade,
			/obj/item/pen,
			/obj/item/flashlight/pen, //i mean cmon if a pen fits in there this does
			/obj/item/scalpel,
			/obj/item/dnainjector,
			/obj/item/reagent_containers/syringe,
			/obj/item/reagent_containers/pill,
			/obj/item/reagent_containers/hypospray/medipen,
			/obj/item/reagent_containers/dropper,
			/obj/item/implanter,
			/obj/item/screwdriver,
			/obj/item/weldingtool/mini,
			/obj/item/firing_pin,
			/obj/item/suppressor,
			/obj/item/ammo_box/magazine/m10mm,
			/obj/item/ammo_box/magazine/m45,
			/obj/item/ammo_box/magazine/toy/pistol,
			/obj/item/ammo_casing,
			/obj/item/lipstick,
			/obj/item/cigarette,
			/obj/item/lighter,
			/obj/item/match,
			/obj/item/holochip,
			/obj/item/toy/crayon,
			/obj/item/reagent_containers/cup/glass/flask,
		),
		cant_hold_list = list(
			/obj/item/cigarette/pipe,
			/obj/item/toy/crayon/spraycan,
		)
	)

///Clown shoe pockets
/datum/storage/pockets/shoes/clown/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	set_holdable(
		can_hold_list = list(
			/obj/item/ammo_box/magazine/m10mm,
			/obj/item/ammo_box/magazine/m45,
			/obj/item/ammo_casing,
			/obj/item/bikehorn,
			/obj/item/cigarette,
			/obj/item/dnainjector,
			/obj/item/firing_pin,
			/obj/item/holochip,
			/obj/item/implanter,
			/obj/item/knife,
			/obj/item/lighter,
			/obj/item/lipstick,
			/obj/item/match,
			/obj/item/pen,
			/obj/item/flashlight/pen,
			/obj/item/reagent_containers/cup/glass/flask,
			/obj/item/reagent_containers/dropper,
			/obj/item/reagent_containers/hypospray/medipen,
			/obj/item/reagent_containers/syringe,
			/obj/item/scalpel,
			/obj/item/screwdriver,
			/obj/item/suppressor,
			/obj/item/switchblade,
			/obj/item/toy/crayon,
			/obj/item/weldingtool/mini,
		),
		cant_hold_list = list(
			/obj/item/cigarette/pipe,
			/obj/item/toy/crayon/spraycan,
		),
	)

/datum/storage/pockets/pocketprotector
	max_slots = 3
	max_specific_storage = WEIGHT_CLASS_TINY

/datum/storage/pockets/pocketprotector/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	set_holdable(
		list( //Same items as a PDA
			/obj/item/pen,
			/obj/item/toy/crayon,
			/obj/item/lipstick,
			/obj/item/flashlight/pen,
			/obj/item/cigarette,
		)
	)

/datum/storage/pockets/holster
	max_slots = 2
	max_specific_storage  = WEIGHT_CLASS_LARGE

/datum/storage/pockets/holster/New()
	. = ..()
	set_holdable(
		list(
			/obj/item/gun/ballistic/automatic/pistol,
			/obj/item/gun/ballistic/revolver,
			/obj/item/ammo_box,
			/obj/item/ammo_casing
		)
	)

/datum/storage/pockets/holster/detective/New()
	. = ..()
	set_holdable(
		list(
			/obj/item/gun/ballistic/revolver/detective,
			/obj/item/ammo_box/c38,
			/obj/item/ammo_casing/c38
			)
		)

/datum/storage/pockets/helmet
	max_slots = 2
	quickdraw = TRUE
	max_total_storage = 6

/datum/storage/pockets/helmet/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	set_holdable(
		list(
			/obj/item/reagent_containers/cup/glass/bottle/vodka,
			/obj/item/reagent_containers/cup/glass/bottle/molotov,
			/obj/item/reagent_containers/cup/glass/drinkingglass,
			/obj/item/ammo_box/a762
			)
		)

/datum/storage/pockets/void_cloak
	quickdraw = TRUE
	max_total_storage = 12 // 2 medium, or 1 large item + 1 normal item
	max_slots = 3
	max_specific_storage = WEIGHT_CLASS_LARGE

/datum/storage/pockets/void_cloak/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	set_holdable(
		can_hold_list = list(
			/obj/item/bodypart,
			/obj/item/clothing/neck/eldritch_amulet,
			/obj/item/clothing/neck/heretic_focus,
			/obj/item/codex_cicatrix,
			/obj/item/eldritch_potion,
			/obj/item/food/grown/flower/poppy,
			/obj/item/melee/rune_carver,
			/obj/item/melee/sickly_blade,
			/obj/item/organ,
			/obj/item/reagent_containers/cup/beaker/eldritch,
		),
		exception_hold_list = list(
			/obj/item/bodypart,
			/obj/item/melee/sickly_blade
		)
	)
