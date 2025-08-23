/obj/machinery/vending/deputy
	name = "\improper DepVend"
	desc = "A machine that dispenses the equipment required to join security voluntarily. Used on stations with skeleton crews as all crew are forced to collectively maintain the station."
	product_ads = "Free weapons!;Time to kill your collegues!;You always wanted to do this!;Your weapons are right here.;Come and declare military law!;Your friends are your enemies!;To test for a changeling, kill them and see if they survive!;Everyone is a syndicate if they don't follow orders."
	icon_state = "sec"
	icon_deny = "sec-deny"
	light_mask = "sec-light-mask"
	vend_reply = "Thank you for your service!"
	req_access = list()
	// The deputisation kit
	products = list(/obj/item/storage/backpack/duffelbag/sec/deputy = 4)
	// Things that could be useful to antags
	contraband = list(/obj/item/clothing/glasses/sunglasses/advanced = 2)
	// Things that could be useful for crew protection
	premium = list(/obj/item/clothing/head/helmet = 4,
				   /obj/item/clothing/suit/armor/vest = 4)
	refill_canister = /obj/item/vending_refill/deputy
	default_price = 450
	extra_price = 700
	dept_req_for_free = NONE

/obj/item/vending_refill/deputy
	machine_name = "DepVend"
	icon_state = "refill_sec"
