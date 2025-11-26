/obj/machinery/vending/security
	name = "\improper SecTech"
	desc = "A security equipment vendor."
	product_ads = "Crack capitalist skulls!;Beat some heads in!;Don't forget - harm is good!;Your weapons are right here.;Handcuffs!;Freeze, scumbag!;Don't tase me bro!;Tase them, bro."
	icon_state = "sec"
	icon_deny = "sec-deny"
	light_mask = "sec-light-mask"
	req_access = list(ACCESS_SECURITY)
	products = list(
		/obj/item/restraints/handcuffs = 8,
		/obj/item/restraints/handcuffs/cable/zipties = 10,
		/obj/item/grenade/flashbang = 4,
		/obj/item/assembly/flash/handheld = 5,
		/obj/item/ammo_casing/taser = 12,
		/obj/item/book/manual/wiki/security_space_law = 3,
		/obj/item/storage/box/evidence = 6,
		/obj/item/flashlight/seclite = 4,
		/obj/item/holosign_creator/security = 3,
		/obj/item/restraints/legcuffs/bola/energy = 7,
		/obj/item/club = 5,
		/obj/item/melee/tonfa = 5,
		/obj/item/clothing/gloves/tackler = 5,
	)
	contraband = list(
		/obj/item/clothing/glasses/sunglasses/advanced = 2,
	)
	premium = list(
		/obj/item/storage/belt/security/webbing = 5,
		/obj/item/storage/backpack/duffelbag/sec/deputy = 4,
		/obj/item/coin/antagtoken = 1,
		/obj/item/security_barricade = 4,
		/obj/item/clothing/head/helmet/blueshirt = 1,
		/obj/item/clothing/suit/armor/vest/blueshirt = 1,
		/obj/item/grenade/stingbang = 1,
	)
	refill_canister = /obj/item/vending_refill/security
	default_price = 100
	extra_price = 150

/obj/machinery/vending/security/pre_throw(obj/item/I)
	if(istype(I, /obj/item/grenade))
		var/obj/item/grenade/G = I
		G.preprime()
	else if(istype(I, /obj/item/flashlight))
		var/obj/item/flashlight/F = I
		F.on = TRUE
		F.update_brightness()

/obj/item/vending_refill/security
	machine_name = "SecTech"
	icon_state = "refill_sec"

/obj/machinery/vending/security/proc/RedeemVoucher(obj/item/mining_voucher/security/voucher, mob/redeemer)
	var/items = list("Carbon Fibre Sabre", "NPS-10")

	var/selection = input(redeemer, "Pick your equipment", "Voucher Redemption") as null|anything in sort_list(items)
	if(!selection || !Adjacent(redeemer) || QDELETED(voucher) || voucher.loc != redeemer)
		return
	var/drop_location = drop_location()
	switch(selection)
		if("Carbon Fibre Sabre")
			new /obj/item/storage/belt/sabre/carbon_fiber(drop_location)

		if("NPS-10")
			new /obj/item/gun/ballistic/automatic/pistol/security(drop_location)
			new /obj/item/ammo_box/magazine/x200law(drop_location)
			new /obj/item/ammo_box/magazine/x200law(drop_location)

	qdel(voucher)

/obj/machinery/vending/security/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mining_voucher/security))
		var/obj/item/mining_voucher/security/V = I
		RedeemVoucher(V, user)
		return
	return ..()

/obj/item/mining_voucher/security
	name = "Sec-Tech equipment voucher"
	desc = "A token to redeem for a choice of lethal side-arm. Use on any registered Sec-Tech equipment vendor."
	icon = 'icons/obj/mining.dmi'
	icon_state = "security_voucher"
	w_class = WEIGHT_CLASS_TINY
	voucher_type = "security"
