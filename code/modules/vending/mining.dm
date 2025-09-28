/obj/machinery/vending/mining
	name = "\improper Miner Nutrition Vendor"
	desc = "A vending machine which vends pre-packaged meals. Nothing gourmet, but it won't taste horrible."
	product_slogans = "Stay in the Fight!;Get back out there, champ!;Remember, stay alive!;Your services are much appreciated!"
	product_ads = "Keep up, keep going!; Stay alive with the new Menu-35!;Meals fit for a demon slayer!; Grab a bite, and make us proud!"
	icon_state = "sustenance"
	products = list(/obj/item/food/donkpocket/warm = 8,
					/obj/item/food/salad/herbsalad = 6,
					/obj/item/food/canned/beans = 4,
					/obj/item/reagent_containers/cup/glass/waterbottle/large = 10)
	contraband = list(/obj/item/reagent_containers/cup/glass/coffee = 10,
						/obj/item/food/chips = 6,
						/obj/item/food/icecreamsandwich = 6)
	refill_canister = /obj/item/vending_refill/mining
	default_price = 0
	extra_price = 0
	light_mask = "snack-light-mask"

/obj/item/vending_refill/mining
	machine_name = "Mining Nutrition Vendor"
	icon_state = "refill_snack"
