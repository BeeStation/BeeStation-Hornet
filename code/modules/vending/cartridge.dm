//This one's from bay12
/obj/machinery/vending/cart
	name = "\improper PTech"
	desc = "Cartridges for PDAs."
	product_slogans = "Carts to go!"
	icon_state = "cart"
	icon_deny = "cart-deny"
	light_color = LIGHT_COLOR_WHITE
	products = list(/obj/item/cartridge/medical = 10,
					/obj/item/cartridge/engineering = 10,
					/obj/item/cartridge/security = 10,
					/obj/item/cartridge/janitor = 10,
					/obj/item/cartridge/signal/toxins = 10,
					/obj/item/pda/heads = 10,
					/obj/item/cartridge/captain = 3,
					/obj/item/cartridge/quartermaster = 10)
	refill_canister = /obj/item/vending_refill/cart
	default_price = 50
	extra_price = 100
	payment_department = ACCOUNT_SRV

/obj/item/vending_refill/cart
	machine_name = "PTech"
	icon_state = "refill_smoke"

