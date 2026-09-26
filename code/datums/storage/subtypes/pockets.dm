/datum/storage/pockets
	max_slots = 2
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = 50
	rustle_sound = FALSE

/datum/storage/pockets/attempt_insert(obj/item/to_insert, mob/user, override, force)
	. = ..()
	if(!.)
		return

	var/obj/item/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return

	if(!silent || override)
		return

	if(quickdraw)
		to_chat(user, "<span class='notice'>You discreetly slip [to_insert] into [resolve_parent].  Right-click [resolve_parent] to remove it.</span>")
	else
		to_chat(user, "<span class='notice'>You discreetly slip [to_insert] into [resolve_parent].</span>")

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

/datum/storage/pockets/small/fedora/New()
	. = ..()
	var/static/list/exception_cache = typecacheof(list(
		/obj/item/katana,
		/obj/item/toy/katana,
		/obj/item/nullrod/claymore/katana,
		/obj/item/energy_katana,
		/obj/item/gun/ballistic/automatic/tommygun,
	))
	exception_hold = exception_cache

/datum/storage/pockets/small/fedora/detective
	attack_hand_interact = TRUE // so the detectives would discover pockets in their hats

/datum/storage/pockets/shoes
	max_slots = 2
	attack_hand_interact = FALSE
	max_specific_storage = WEIGHT_CLASS_SMALL
	quickdraw = TRUE
	silent = TRUE

/datum/storage/pockets/shoes/clown

/datum/storage/pockets/pocketprotector
	max_slots = 3
	max_specific_storage = WEIGHT_CLASS_TINY

/datum/storage/pockets/pocketprotector/New()
	. = ..()
	set_holdable(
		list( //Same items as a PDA
			/obj/item/pen,
			/obj/item/toy/crayon,
			/obj/item/lipstick,
			/obj/item/flashlight/pen,
			/obj/item/cigarette
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

/datum/storage/pockets/helmet/New()
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

/datum/storage/pockets/void_cloak/New()
	. = ..()
	set_holdable(list(
		/obj/item/bodypart,
		/obj/item/clothing/neck/eldritch_amulet,
		/obj/item/clothing/neck/heretic_focus,
		/obj/item/codex_cicatrix,
		/obj/item/eldritch_potion,
		/obj/item/melee/rune_carver,
		/obj/item/melee/sickly_blade,
		/obj/item/organ,
		/obj/item/reagent_containers/cup/beaker/eldritch,
	))

	var/static/list/exception_cache = typecacheof(list(
		/obj/item/bodypart,
		/obj/item/melee/sickly_blade,
	))
	exception_hold = exception_cache
