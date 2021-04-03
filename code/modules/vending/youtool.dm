/obj/machinery/vending/tool
	name = "\improper YouTool"
	desc = "Tools for tools."
	icon_state = "tool"
	icon_deny = "tool-deny"
	light_color = LIGHT_COLOR_YELLOW
	products = list(/obj/item/stack/cable_coil/random = 10,
		            /obj/item/crowbar = 5,
		            /obj/item/weldingtool = 3,
		            /obj/item/wirecutters = 5,
		            /obj/item/wrench = 5,
		            /obj/item/analyzer = 5,
		            /obj/item/t_scanner = 5,
		            /obj/item/screwdriver = 5,
					/obj/item/geiger_counter = 3,
		            /obj/item/flashlight/glowstick = 3,
		            /obj/item/flashlight/glowstick/red = 3,
		            /obj/item/flashlight = 5,
					/obj/item/extinguisher/mini = 5,
		            /obj/item/clothing/ears/earmuffs = 1)
	contraband = list(/obj/item/clothing/gloves/color/fyellow = 2)
	premium = list(/obj/item/storage/belt/utility = 2,
		           /obj/item/weldingtool/hugetank = 2,
				   /obj/item/multitool = 2,
		           /obj/item/clothing/head/welding = 2,
				   /obj/item/pipe_painter = 1,
				   /obj/item/airlock_painter = 1,
		           /obj/item/clothing/gloves/color/yellow = 1)
	refill_canister = /obj/item/vending_refill/tool
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 70, "stamina" = 0)
	resistance_flags = FIRE_PROOF
	default_price = 5
	extra_price = 45
	payment_department = ACCOUNT_ENG

/obj/item/vending_refill/tool
	machine_name = "YouTool"
	icon_state = "refill_engi"
