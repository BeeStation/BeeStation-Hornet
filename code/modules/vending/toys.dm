/obj/machinery/vending/donksofttoyvendor
	name = "\improper Donksoft Toy Vendor"
	desc = "Ages 8 and up approved vendor that dispenses toys."
	icon_state = "nt-donk"
	product_slogans = "Get your cool toys today!;Trigger a valid hunter today!;Quality toy weapons for cheap prices!;Give them to HoPs for all access!;Give them to HoS to get permabrigged!"
	product_ads = "Feel robust with your toys!;Express your inner child today!;Toy weapons don't kill people, but valid hunters do!;Who needs responsibilities when you have toy weapons?;Make your next murder FUN!"
	vend_reply = "Come back for more!"
	light_mask = "donksoft-light-mask"
	circuit = /obj/item/circuitboard/machine/vending/donksofttoyvendor
	products = list(
		/obj/item/gun/ballistic/automatic/toy/unrestricted = 10,
		/obj/item/gun/ballistic/automatic/toy/pistol/unrestricted = 10,
		/obj/item/gun/ballistic/shotgun/toy/unrestricted = 10,
		/obj/item/toy/sword = 10,
		/obj/item/ammo_box/foambox = 20,
		/obj/item/toy/foamblade = 10,
		/obj/item/toy/syndicateballoon = 10,
		/obj/item/clothing/suit/syndicatefake = 5,
		/obj/item/clothing/head/syndicatefake = 5)
	contraband = list(
		/obj/item/gun/ballistic/shotgun/toy/crossbow = 10,
		/obj/item/gun/ballistic/automatic/c20r/toy/unrestricted = 10,
		/obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted = 10,
		/obj/item/toy/katana = 10,
		/obj/item/dualsaber/toy = 5)

	armor_type = /datum/armor/vending_donksofttoyvendor
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/donksoft
	default_price = 75
	extra_price = 300
	dept_req_for_free = ACCOUNT_SRV_BITFLAG

/datum/armor/vending_donksofttoyvendor
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	fire = 100
	acid = 50

/obj/item/vending_refill/donksoft
	machine_name = "Donksoft Toy Vendor"
	icon_state = "refill_donksoft"
