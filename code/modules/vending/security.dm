/obj/machinery/vending/security
	name = "\improper SecTech"
	desc = "A security equipment vendor."
	product_ads = "Crack capitalist skulls!;Beat some heads in!;Don't forget - harm is good!;Your weapons are right here.;Handcuffs!;Freeze, scumbag!;Don't tase me bro!;Tase them, bro.;Why not have a donut?"
	icon_state = "sec"
	icon_deny = "sec-deny"
	light_color = LIGHT_COLOR_BLUE
	req_access = list(ACCESS_SECURITY)
	products = list(/obj/item/restraints/handcuffs = 8,
					/obj/item/restraints/handcuffs/cable/zipties = 10,
					/obj/item/grenade/flashbang = 4,
					/obj/item/assembly/flash/handheld = 5,
					/obj/item/reagent_containers/food/snacks/donut = 12,
					/obj/item/storage/box/evidence = 6,
					/obj/item/flashlight/seclite = 4,
					/obj/item/holosign_creator/security = 3,
					/obj/item/restraints/legcuffs/bola/energy = 7)
	contraband = list(/obj/item/clothing/glasses/sunglasses/advanced = 2,
					  /obj/item/storage/fancy/donut_box = 2)
	premium = list(/obj/item/storage/belt/security/webbing = 5,
					/obj/item/storage/backpack/duffelbag/sec/deputy = 4,
				   /obj/item/coin/antagtoken = 1,
				   /obj/item/grenade/barrier = 4,
				   /obj/item/clothing/head/helmet/blueshirt = 1,
				   /obj/item/clothing/suit/armor/vest/blueshirt = 1)
	refill_canister = /obj/item/vending_refill/security
	default_price = 100
	extra_price = 150
	payment_department = ACCOUNT_SEC

/obj/machinery/vending/security/pre_throw(obj/item/I)
	if(istype(I, /obj/item/grenade))
		var/obj/item/grenade/G = I
		G.preprime()
	else if(istype(I, /obj/item/flashlight))
		var/obj/item/flashlight/F = I
		F.on = TRUE
		F.update_brightness()

/obj/item/vending_refill/security
	icon_state = "refill_sec"

//Detective vendor
/obj/machinery/vending/dic
	name = "\improper DicTech"
	desc = "A fashion and essentials vendor for the discerning detective."
	product_ads = "Just one more question: Are you ready to look swag?; Upgrade your LA Noir threads today!;Evidence bags? Cigs? Matches? We got it all!;Get your fix of cheap cigs and burnt coffee!;Stogies here to complete that classic noir look!;Stylish apparel here! Crack your case in style!;Fedoras for her tipping pleasure.;Why not have a donut?"
	icon_state = "det"
	icon_deny = "det-deny"
	req_access = list(ACCESS_FORENSICS_LOCKERS)
	products = list(/obj/item/clothing/suit/det_suit = 1,
					/obj/item/clothing/suit/det_suit/grey = 1,
					/obj/item/clothing/suit/det_suit/noir = 1,
					/obj/item/clothing/under/rank/security/detective = 1,
					/obj/item/clothing/under/rank/security/detective/grey = 1,
					/obj/item/clothing/accessory/waistcoat = 1,
					/obj/item/clothing/neck/tie/red = 1,
					/obj/item/clothing/neck/tie/black = 1,
					/obj/item/clothing/shoes/laceup = 1,
					/obj/item/clothing/head/fedora/det_hat = 1,
					/obj/item/clothing/head/fedora = 1,
					/obj/item/clothing/neck/tie/detective = 3,
					/obj/item/clothing/gloves/color/black = 3,
					/obj/item/pinpointer/crew = 2,					
					/obj/item/toy/crayon/white = 2,
					/obj/item/radio/headset/headset_sec = 2,
					/obj/item/flashlight/seclite = 2,
					/obj/item/taperecorder = 2,
					/obj/item/storage/box/evidence = 2,
					/obj/item/storage/box/matches = 5,
					/obj/item/storage/fancy/cigarettes/cigars = 5)
	contraband = list(/obj/item/clothing/shoes/jackboots/aerostatic = 1,
					/obj/item/clothing/suit/det_suit/disco/aerostatic = 1,
					/obj/item/clothing/under/rank/security/detective/disco/aerostatic = 1,
					/obj/item/clothing/gloves/color/black/aerostatic_gloves = 1,
					/obj/item/clothing/glasses/hud/security/sunglasses/disco = 1,
					/obj/item/clothing/shoes/sneakers/disco = 1,
					/obj/item/clothing/suit/det_suit/disco = 1,
					/obj/item/clothing/under/rank/security/detective/disco = 1)
	premium = list(	/obj/item/detective_scanner = 1,
					/obj/item/twohanded/binoculars = 1,
					/obj/item/camera/detective = 1,
					/obj/item/holosign_creator/security = 1)

	refill_canister = /obj/item/vending_refill/detective
	extra_price = 100
	payment_department = ACCOUNT_SEC

/obj/machinery/vending/dic/pre_throw(obj/item/I)
	if(istype(I, /obj/item/grenade))
		var/obj/item/grenade/G = I
		G.preprime()
	else if(istype(I, /obj/item/flashlight))
		var/obj/item/flashlight/F = I
		F.on = TRUE
		F.update_brightness()

/obj/item/vending_refill/detective
	icon_state = "refill_det"

/datum/supply_pack/security/vending/detective
	name = "DicTech Supply Crate"
	desc = "Did the other detectives snatch all the good outfits and gear? Regain your swag with this!"
	cost = 1500
	contains = list(/obj/item/vending_refill/detective)
	crate_name = "DicTech supply crate"
