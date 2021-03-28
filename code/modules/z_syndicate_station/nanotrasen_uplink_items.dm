/obj/item/storage/box/syndie_kit/nanospace
	name = "nanotrasen boxed space suit and helmet"

/obj/item/storage/box/syndie_kit/nanospace/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.can_hold = typecacheof(list(/obj/item/clothing/suit/space/eva, /obj/item/clothing/head/helmet/space/eva))

/obj/item/storage/box/syndie_kit/nanospace/PopulateContents()
	new /obj/item/clothing/suit/space/eva(src) // Black and red is so in right now
	new /obj/item/clothing/head/helmet/space/eva(src)

/obj/item/clothing/suit/space/hardsuit/shielded/syndie/nanotrasen
	name = "emergency response team assault operative hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has blue highlights and an integrated energy shield. Offers superb protection against environmental hazards."
	icon_state = "ert_command"
	item_state = "ert_command"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list("melee" = 65, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 80, "stamina" = 70)
	slowdown = 0
	strip_delay = 130
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	jetpack = /obj/item/tank/jetpack/suit
	actions_types = list(
		/datum/action/item_action/toggle_helmet,
		/datum/action/item_action/toggle_beacon,
		/datum/action/item_action/toggle_beacon_frequency
	)

/obj/item/stock_parts/cell/centcom_recharging
	self_recharge = TRUE

/obj/item/gun/energy/tesla_revolver/self_recharge
	cell_type = /obj/item/stock_parts/cell/centcom_recharging
