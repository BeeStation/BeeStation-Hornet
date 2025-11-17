/obj/machinery/vending/sovietsoda
	name = "\improper BODA"
	desc = "Old sweet water vending machine."
	icon_state = "sovietsoda"
	light_mask = "soviet-light-mask"
	product_ads = "For Tsar and Country.;Have you fulfilled your nutrition quota today?;Very nice!;We are simple people, for this is all we eat.;If there is a person, there is a problem. If there is no person, then there is no problem."
	products = list(/obj/item/reagent_containers/cup/glass/drinkingglass/filled/soda = 30)
	contraband = list(/obj/item/reagent_containers/cup/glass/drinkingglass/filled/cola = 20)
	refill_canister = /obj/item/vending_refill/sovietsoda
	resistance_flags = FIRE_PROOF
	default_price = 1
	extra_price = 1
	light_color = COLOR_PALE_ORANGE

/obj/item/vending_refill/sovietsoda
	machine_name = "BODA"
	icon_state = "refill_cola"
