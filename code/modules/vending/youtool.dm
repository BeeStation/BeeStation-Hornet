/obj/machinery/vending/tool
	name = "\improper YouTool"
	desc = "Tools for tools."
	icon_state = "tool"
	icon_deny = "tool-deny"
	light_mask = "tool-light-mask"
	products = list(/obj/item/stack/cable_coil/random = 10,
					/obj/item/crowbar = 5,
					/obj/item/weldingtool = 3,
					/obj/item/wirecutters = 5,
					/obj/item/multitool = 5,
					/obj/item/wrench = 5,
					/obj/item/analyzer = 5,
					/obj/item/t_scanner = 5,
					/obj/item/screwdriver = 5,
					/obj/item/flashlight/glowstick = 3,
					/obj/item/flashlight/glowstick/red = 3,
					/obj/item/flashlight = 5,
					/obj/item/clothing/ears/earmuffs = 1,
					/obj/item/stack/sticky_tape/duct = 3)
	contraband = list(/obj/item/clothing/gloves/color/fyellow = 2)
	premium = list(/obj/item/storage/belt/utility = 2,
		           /obj/item/weldingtool/hugetank = 2,
		           /obj/item/clothing/head/utility/welding = 2,
		           /obj/item/clothing/gloves/color/yellow = 1)
	refill_canister = /obj/item/vending_refill/tool
	armor_type = /datum/armor/vending_tool
	resistance_flags = FIRE_PROOF
	default_price = 10
	extra_price = 80

/datum/armor/vending_tool
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	fire = 100
	acid = 70

/obj/item/vending_refill/tool
	machine_name = "YouTool"
	icon_state = "refill_engi"
