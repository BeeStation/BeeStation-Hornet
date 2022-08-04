/obj/machinery/vending/meta
	name = "Meta Vendor"
	desc = "A vendor for vendor circuits. Seems someone overestimated how many to produce."
	iconstate = "metavend"
	iconstate_deny = "metavend_deny"
	light_color = LIGHT_COLOR_BLUE
	products = list(
		/obj/item/circuitboard/machine/vending/station/sovietsoda = 20  // nobody wants it
		/obj/item/circuitboard/machine/vending/station/coffee = 5,
		/obj/item/circuitboard/machine/vending/station/snack = 5,
		/obj/item/circuitboard/machine/vending/station/cola = 5,
		/obj/item/circuitboard/machine/vending/station/cigarette = 5,
		/obj/item/circuitboard/machine/vending/station/games = 5,
		/obj/item/circuitboard/machine/vending/station/autodrobe = 3,
		/obj/item/circuitboard/machine/vending/station/clothing = 3,
		/obj/item/circuitboard/machine/vending/station/assist = 2
	)
	premium = list(
		/obj/item/circuitboard/machine/vending/station/boozemat = 3,
		/obj/item/circuitboard/machine/vending/station/modularapc = 1
	)
	contraband = list(/obj/item/circuitboard/machine/vending/donksofttoyvendor = 2)
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 70, "stamina" = 0)
	resistance_flags = FIRE_PROOF
	default_price = 20
	extra_price = 80
	payment_department = ACCOUNT_ENG

/obj/item/vending_refill/meta
	machine_name = "Meta Vendor"
	icon_state = "refill_engi"
