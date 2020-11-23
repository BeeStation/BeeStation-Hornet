/obj/machinery/vending/music
	name = "\improper Music Machine"
	desc = "music."
	icon_state = "clothes"
	icon_deny = "engi-deny"
	light_color = LIGHT_COLOR_SLIME_LAMP
	req_access = list(ACCESS_THEATRE)
	products = list()
	refill_canister = /obj/item/vending_refill/engineering
	default_price = 50
	extra_price = 60
	payment_department = ACCOUNT_ENG

/obj/item/vending_refill/engineering
	machine_name = "Robco Tool Maker"
	icon_state = "refill_engi"
