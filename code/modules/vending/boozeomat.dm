/obj/machinery/vending/boozeomat
	name = "\improper Booze-O-Mat"
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	icon_state = "boozeomat"
	icon_deny = "boozeomat-deny"

	product_categories = list(
		list(
			"name" = "Alcoholic",
			"icon" = "wine-bottle",
			"products" = list(
				/obj/item/reagent_containers/cup/glass/bottle/applejack = 5,
				/obj/item/reagent_containers/cup/glass/bottle/tequila = 5,
				/obj/item/reagent_containers/cup/glass/bottle/rum = 5,
				/obj/item/reagent_containers/cup/glass/bottle/cognac = 5,
				/obj/item/reagent_containers/cup/glass/bottle/wine = 5,
				/obj/item/reagent_containers/cup/glass/bottle/absinthe = 5,
				/obj/item/reagent_containers/cup/glass/bottle/vermouth = 5,
				/obj/item/reagent_containers/cup/glass/bottle/gin = 5,
				/obj/item/reagent_containers/cup/glass/bottle/grenadine = 4,
				/obj/item/reagent_containers/cup/glass/bottle/hcider = 5,
				/obj/item/reagent_containers/cup/glass/bottle/ale = 6,
				/obj/item/reagent_containers/cup/glass/bottle/grappa = 5,
				/obj/item/reagent_containers/cup/glass/bottle/kahlua = 5,
				/obj/item/reagent_containers/cup/glass/bottle/sake = 5,
				/obj/item/reagent_containers/cup/glass/bottle/beer = 6,
				/obj/item/reagent_containers/cup/glass/bottle/vodka = 5,
				/obj/item/reagent_containers/cup/glass/bottle/whiskey = 5,
			),
		),

		list(
			"name" = "Non-Alcoholic",
			"icon" = "bottle-water",
			"products" = list(
				/obj/item/reagent_containers/cup/glass/ice = 10,
				/obj/item/reagent_containers/cup/glass/bottle/juice/limejuice = 4,
				/obj/item/reagent_containers/cup/glass/bottle/juice/menthol = 4,
				/obj/item/reagent_containers/cup/glass/bottle/juice/cream = 4,
				/obj/item/reagent_containers/cup/glass/bottle/juice/orangejuice = 4,
				/obj/item/reagent_containers/cup/glass/bottle/juice/tomatojuice = 4,
				/obj/item/reagent_containers/cup/soda_cans/sodawater = 15,
				/obj/item/reagent_containers/cup/soda_cans/sol_dry = 8,
				/obj/item/reagent_containers/cup/soda_cans/cola = 8,
				/obj/item/reagent_containers/cup/soda_cans/tonic = 8,
			),
		),

		list(
			"name" = "Glassware",
			"icon" = "wine-glass",
			"products" = list(
				/obj/item/reagent_containers/cup/glass/drinkingglass = 30,
				/obj/item/reagent_containers/cup/glass/drinkingglass/shotglass = 12,
				/obj/item/reagent_containers/cup/glass/flask = 3,
				/obj/item/reagent_containers/cup/glass/bottle = 15,
				/obj/item/reagent_containers/cup/glass/bottle/small = 15,
			),
		),
	)

	contraband = list(
		/obj/item/reagent_containers/cup/glass/mug/tea = 12,
		/obj/item/reagent_containers/cup/glass/bottle/fernet = 5
	)
	premium = list(
		/obj/item/reagent_containers/cup/bottle/ethanol = 4,
		/obj/item/reagent_containers/cup/glass/bottle/champagne = 5,
		/obj/item/reagent_containers/cup/glass/bottle/trappist = 5,
	)

	product_slogans = "I hope nobody asks me for a bloody cup o' tea...;Alcohol is humanity's friend. Would you abandon a friend?;Quite delighted to serve you!;Is nobody thirsty on this station?"
	product_ads = "Drink up!;Booze is good for you!;Alcohol is humanity's best friend.;Quite delighted to serve you!;Care for a nice, cold beer?;Nothing cures you like booze!;Have a sip!;Have a drink!;Have a beer!;Beer is good for you!;Only the finest alcohol!;Best quality booze since 2053!;Award-winning wine!;Maximum alcohol!;Man loves beer.;A toast for progress!"
	req_access = list(ACCESS_BAR)
	refill_canister = /obj/item/vending_refill/boozeomat
	default_price = 20
	extra_price = 50
	light_mask = "boozeomat-light-mask"

/obj/machinery/vending/boozeomat/all_access
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one. This model appears to have no access restrictions."
	req_access = null

/obj/machinery/vending/boozeomat/syndicate_access
	req_access = list(ACCESS_SYNDICATE)

/obj/item/vending_refill/boozeomat
	machine_name = "Booze-O-Mat"
	icon_state = "refill_booze"

/obj/machinery/vending/boozeomat/maint //abandoned bar on randomaints usually
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one. This one is kinda run down, almost forgotten down here..."
	products = list(/obj/item/reagent_containers/cup/glass/bottle/whiskey = 1,
			/obj/item/reagent_containers/cup/glass/bottle/absinthe = 1,
			/obj/item/reagent_containers/cup/glass/bottle/juice/limejuice = 1,
			/obj/item/reagent_containers/cup/glass/bottle/juice/cream = 1,
			/obj/item/reagent_containers/cup/soda_cans/tonic = 1,
			/obj/item/reagent_containers/cup/glass/drinkingglass = 10,
			/obj/item/reagent_containers/cup/glass/ice = 3,
			/obj/item/reagent_containers/cup/glass/drinkingglass/shotglass = 6,
			/obj/item/reagent_containers/cup/glass/flask = 1)
	req_access = null

/obj/machinery/vending/boozeomat/captain//Captain's quarters variant
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one. This one has less items, yet more fit for a captain."
	products = list(/obj/item/reagent_containers/cup/glass/bottle/rum = 1,
					/obj/item/reagent_containers/cup/glass/bottle/wine = 1,
					/obj/item/reagent_containers/cup/glass/bottle/ale = 1,
					/obj/item/reagent_containers/cup/glass/drinkingglass = 6,
					/obj/item/reagent_containers/cup/glass/ice = 1,
					/obj/item/reagent_containers/cup/glass/drinkingglass/shotglass = 4);
	req_access = list(ACCESS_CAPTAIN)

