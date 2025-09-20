/obj/machinery/vending/deputy
	name = "\improper DepVend"
	desc = "A machine that dispenses the equipment required to join security voluntarily. Helpfully provided by Auri private security, it's used on stations with skeleton crews to make sure someone is always available to maintain the peace."
	product_slogans = "Free weapons!;Time to kill your collegues!;You always wanted to do this!;Your weapons are right here.;Come and declare martial law!;Any friend can be an enemy!;To test for a changeling, kill them and see if they survive!;Everyone is a syndicate if they don't follow orders."
	icon_state = "dep"
	icon_deny = "dep-deny"
	light_mask = "dep-light-mask"
	vend_reply = "Thank you for your service!"
	req_access = list(ACCESS_BRIG)
	light_color = "#ff2466"
	var/obj/item/radio/radio

	// The deputisation kit
	product_categories = list(
		list(
			"name" = "Kit",
			"icon" = "shield-halved",
			"products" = list(
				/obj/item/storage/backpack/duffelbag/sec/deputy = 4
			),
		),

		list(
			"name" = "Replacement Clothes",
			"icon" = "shirt",
			"products" = list(
				/obj/item/clothing/head/soft/sec = 4,
				/obj/item/clothing/under/rank/security/officer/blueshirt = 4,
				/obj/item/clothing/shoes/sneakers/black = 4,
				/obj/item/storage/belt/security = 4,
				/obj/item/clothing/accessory/armband/deputy = 4,
			),
		),

		list(
			"name" = "Replacement Gear",
			"icon" = "gun",
			"products" = list(
				/obj/item/melee/classic_baton/police/deputy = 4,
				/obj/item/melee/tonfa = 4,
				/obj/item/restraints/handcuffs/cable/zipties = 16,
				/obj/item/reagent_containers/peppercloud_deployer = 4,
				/obj/item/flashlight/seclite = 4,
				/obj/item/ammo_casing/taser = 12,
			),
		),
	)
	// Things that could be useful to antags
	contraband = list(/obj/item/clothing/glasses/sunglasses/advanced = 2)

	// Things that could be useful for crew protection
	premium = list(/obj/item/clothing/head/helmet = 4,
					/obj/item/clothing/suit/armor/vest = 4)

	refill_canister = /obj/item/vending_refill/deputy
	default_price = PAYCHECK_MINIMAL * 10
	extra_price = PAYCHECK_MINIMAL * 15

/obj/machinery/vending/deputy/Initialize(mapload)
	. = ..()

	radio = new/obj/item/radio(src)
	radio.set_listening(FALSE)
	radio.set_frequency(FREQ_COMMON)

/obj/machinery/vending/deputy/vend(list/params, list/greyscale_colors)

	var/datum/vending_product/item_to_buy = locate(params["ref"]) in src.product_records + src.coin_records + src.hidden_records

	var/list/record_to_check = product_records + coin_records

	if(extended_inventory)
		record_to_check = product_records + coin_records + hidden_records

	if(!item_to_buy || !istype(item_to_buy) || !item_to_buy.product_path)
		return

	if(item_to_buy in hidden_records)
		if(!extended_inventory)
			return

	else if (!(item_to_buy in record_to_check))
		message_admins("Vending machine exploit attempted by [ADMIN_LOOKUPFLW(usr)]!")
		return

	var/item_category = item_to_buy.get_category_name()

	var/mob/user_mob = usr
	if(!user_mob || !user_mob.mind)
		return

	vend_reply = initial(vend_reply)
	if(allowed(user_mob))
		return ..()
	if(item_category == "Kit")
		var/obj/item/card/id/card
		card = user_mob.get_idcard(TRUE)
		var/buyer = card?.registered_account?.account_holder

		vend_reply = "APS thanks you for enlisting in our volunteer program!"

		if(!..())
			return FALSE
		playsound(src, 'sound/effects/startup.ogg', 100, FALSE)
		radio.talk_into(src, "[buyer], [get_area(src)], has just enlisted for Auri Private Security’s volunteer deputy program! APS thanks you for your service, and reminds all crew members: **Unauthorized enforcement is strictly prohibited!** Remember; Compliance is a team effort!")
		return TRUE

	if(item_category == "Contraband" || scan_id == 0)
		vend_reply = "ERR-!"
		if(!..())
			return FALSE
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		flick(icon_deny,src)
		return TRUE

	playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
	say("Only qualified personnel are allowed to purchase spare equipment. Enlist now!")
	flick(icon_deny,src)
	return FALSE

/obj/machinery/vending/deputy/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/item/vending_refill/deputy
	machine_name = "DepVend"
	icon_state = "refill_sec"

