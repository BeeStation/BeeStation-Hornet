/obj/machinery/vending/snack
	name = "\improper Getmore Chocolate Corp"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars."
	product_slogans = "Try our new nougat bar!;Twice the calories for half the price!"
	product_ads = "The healthiest!;Award-winning chocolate bars!;Mmm! So good!;Oh my god it's so juicy!;Have a snack.;Snacks are good for you!;Have some more Getmore!;Best quality snacks straight from mars.;We love chocolate!;Try our new jerky!"
	icon_state = "snack"
	light_mask = "snack-light-mask"
	products = list(/obj/item/food/spacetwinkie = 6,
					/obj/item/food/cheesiehonkers = 6,
					/obj/item/food/candy = 6,
					/obj/item/food/chips = 6,
					/obj/item/food/sosjerky = 6,
					/obj/item/food/no_raisin = 6,
					/obj/item/reagent_containers/food/drinks/dry_ramen = 3,
					/obj/item/food/energybar = 6)
	contraband = list(/obj/item/food/syndicake = 6,
					/obj/item/food/swirl_lollipop = 2)

	refill_canister = /obj/item/vending_refill/snack
	var/chef_compartment_access = "28" //ACCESS_KITCHEN
	default_price = 20
	extra_price = 30
	dept_req_for_free = ACCOUNT_SRV_BITFLAG

/obj/item/vending_refill/snack
	machine_name = "Getmore Chocolate Corp"

/obj/machinery/vending/snack/blue
	icon_state = "snackblue"

/obj/machinery/vending/snack/orange
	icon_state = "snackorange"

/obj/machinery/vending/snack/green
	icon_state = "snackgreen"

/obj/machinery/vending/snack/teal
	icon_state = "snackteal"
