/obj/machinery/vending/coffee
	name = "\improper Solar's Best Hot Drinks"
	desc = "A vending machine which dispenses hot drinks."
	product_ads = "Have a drink!;Drink up!;It's good for you!;Would you like a hot joe?;I'd kill for some coffee!;The best beans in the galaxy.;Only the finest brew for you.;Mmmm. Nothing like a coffee.;I like coffee, don't you?;Coffee helps you work!;Try some tea.;We hope you like the best!;Try our new chocolate!;Admin conspiracies"
	icon_state = "coffee"
	icon_vend = "coffee-vend"
	products = list(
		/obj/item/reagent_containers/cup/glass/coffee = 6,
		/obj/item/reagent_containers/cup/glass/mug/tea = 6,
		/obj/item/reagent_containers/cup/glass/mug/cocoa = 3,
		/obj/item/reagent_containers/cup/glass/bubble_tea = 4
	)
	contraband = list(
		/obj/item/reagent_containers/cup/glass/ice = 12
	)
	refill_canister = /obj/item/vending_refill/coffee
	default_price = PAYCHECK_LOWER
	extra_price = PAYCHECK_MEDIUM
	dept_req_for_free = ACCOUNT_SRV_BITFLAG
	light_mask = "coffee-light-mask"
	light_color = COLOR_DARK_MODERATE_ORANGE

/obj/item/vending_refill/coffee
	machine_name = "Solar's Best Hot Drinks"
	icon_state = "refill_joe"
