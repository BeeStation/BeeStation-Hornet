//This one's from bay12
/obj/machinery/vending/job_disk
	name = "\improper PTech"
	desc = "Job disks for PDAs."
	product_slogans = "Disks to go!"
	icon_state = "cart"
	icon_deny = "cart-deny"
	light_color = LIGHT_COLOR_WHITE
	products = list(/obj/item/modular_computer/tablet/pda = 15,
					/obj/item/computer_hardware/hard_drive/role/medical = 5,
					/obj/item/computer_hardware/hard_drive/role/chemistry = 5,
					/obj/item/computer_hardware/hard_drive/role/brig_physician = 3,
					/obj/item/computer_hardware/hard_drive/role/security = 3,
					/obj/item/computer_hardware/hard_drive/role/detective = 3,
					/obj/item/computer_hardware/hard_drive/role/engineering = 5,
					/obj/item/computer_hardware/hard_drive/role/atmos = 5,
					/obj/item/computer_hardware/hard_drive/role/signal/toxins = 5,
					/obj/item/computer_hardware/hard_drive/role/roboticist = 3,
					/obj/item/computer_hardware/hard_drive/role/lawyer = 3,
					/obj/item/computer_hardware/hard_drive/role/curator = 3,
					/obj/item/computer_hardware/hard_drive/role/janitor = 5,
					/obj/item/computer_hardware/hard_drive/role/quartermaster = 3,
					/obj/item/computer_hardware/hard_drive/role/cargo_technician = 5,
					/obj/item/computer_hardware/hard_drive/role/maint = 5,
					/obj/item/computer_hardware/hard_drive/role/head = 5)
	premium = list(/obj/item/computer_hardware/hard_drive/role/captain = 3)
	contraband = list(/obj/item/computer_hardware/hard_drive/role/virus/clown = 2,
					/obj/item/computer_hardware/hard_drive/role/virus/mime = 2)
	refill_canister = /obj/item/vending_refill/job_disk
	default_price = 100
	extra_price = 300
	dept_req_for_free = ACCOUNT_COM_BITFLAG
	seller_department = ACCOUNT_SRV_BITFLAG | ACCOUNT_CIV_BITFLAG // don't send the profic to CentCom Budget account.

/obj/item/vending_refill/job_disk
	machine_name = "PTech"
	icon_state = "refill_smoke"

