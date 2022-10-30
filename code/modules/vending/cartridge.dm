//This one's from bay12
/obj/machinery/vending/cart
	name = "\improper PTech"
	desc = "Job disks for PDAs."
	product_slogans = "Disks to go!"
	icon_state = "cart"
	icon_deny = "cart-deny"
	light_color = LIGHT_COLOR_WHITE
	products = list(/obj/item/computer_hardware/hard_drive/role/medical = 10,
					/obj/item/computer_hardware/hard_drive/role/engineering = 10,
					/obj/item/computer_hardware/hard_drive/role/security = 10,
					/obj/item/computer_hardware/hard_drive/role/janitor = 10,
					/obj/item/computer_hardware/hard_drive/role/signal/toxins = 10,
					/obj/item/modular_computer/tablet/pda/heads = 10,
					/obj/item/computer_hardware/hard_drive/role/cargo_technician = 10,
					/obj/item/computer_hardware/hard_drive/role/maint = 3)
	premium = list(/obj/item/computer_hardware/hard_drive/role/captain = 3)
	refill_canister = /obj/item/vending_refill/cart
	default_price = 100
	extra_price = 300
	dept_req_for_free = ACCOUNT_COM_BITFLAG
	seller_department = ACCOUNT_SRV_BITFLAG | ACCOUNT_CIV_BITFLAG // don't send the profic to CentCom Budget account.

/obj/item/vending_refill/cart
	machine_name = "PTech"
	icon_state = "refill_smoke"

