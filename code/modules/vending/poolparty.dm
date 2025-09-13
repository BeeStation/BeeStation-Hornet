/obj/machinery/vending/pool
	name = "\improper Pool party vendor"
	desc = "It's a pool party alright? Have fun"
	product_ads = "Splash splash!; Pool noodle battle fight, anyone?; Get a tan line!;Pool party time!; Diving head first not recommended!"
	icon_state = "poolparty"
	light_color = LIGHT_COLOR_CYAN
	products = list(
		/obj/item/clothing/under/shorts/pool = 10,
		/obj/item/clothing/under/dress/skirt/pool = 10,
		/obj/item/clothing/under/dress/pool = 10,
		/obj/item/pool/rubber_ring = 5
	)
	premium = list(
		/obj/item/pool/pool_noodle = 5,
		/obj/item/toy/beach_ball = 2
	)
	refill_canister = /obj/item/vending_refill/pool_party
	default_price = 40
	extra_price = 80
	light_mask = "poolparty-light-mask"

/obj/item/vending_refill/pool_party
	machine_name = "Pool party vendor"
	icon_state = "refill_pool"
