/obj/machinery/vending/assist
	products = list(/obj/item/assembly/prox_sensor = 5,
					/obj/item/assembly/igniter = 3,
					/obj/item/assembly/signaler = 4,
					/obj/item/wirecutters = 1,
					/obj/item/computer_hardware/hard_drive/role/signal = 4)
	contraband = list(/obj/item/assembly/timer = 2,
					  /obj/item/assembly/voice = 2,
					  /obj/item/assembly/health = 2)
	premium = list(/obj/item/price_tagger = 4,
				   /obj/item/vending_refill/custom = 4,
				   /obj/item/circuitboard/machine/vendor = 4)
	refill_canister = /obj/item/vending_refill/assist
	product_ads = "Only the finest!;Have some tools.;The most robust equipment.;The finest gear in space!"
	default_price = 10
	extra_price = 40
	dept_req_for_free = NO_FREEBIES

/obj/item/vending_refill/assist
	machine_name = "Vendomat"
	icon_state = "refill_engi"
