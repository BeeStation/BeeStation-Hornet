/obj/machinery/vending/pool
	name = "\improper Pool party vendor"
	desc = "It's a pool party alright? Have fun"
	product_ads = "Escape to a fantasy world!;Fuel your gambling addiction!;Ruin your friendships!;Roll for initiative!;Elves and dwarves!;Paranoid computers!;Totally not satanic!;Fun times forever!"
	icon_state = "poolparty"
	light_color = LIGHT_COLOR_ORANGE
	products = list(
		/obj/item/clothing/under/shorts/pool = 10,
		/obj/item/clothing/under/dress/skirt/pool = 10,
		/obj/item/clothing/under/dress/skirt/pool = 10,
		/obj/item/pool/rubber_ring = 5
	)
	premium = list(
		/obj/item/pool/pool_noodle = 5,
		/obj/item/toy/beach_ball = 2
	)
	refill_canister = /obj/item/vending_refill/games
	default_price = 40
	extra_price = 80
	light_mask = "poolparty-light-mask"

/obj/item/vending_refill/pool
	machine_name = "Pool party vendor"
	icon_state = "refill_pool"
