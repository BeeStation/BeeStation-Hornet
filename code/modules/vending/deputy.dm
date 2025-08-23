/obj/machinery/vending/deputy
	name = "\improper DepVend"
	desc = "A machine that dispenses the equipment required to join security voluntarily. Helpfully provided by Auri private security, it's used on stations with skeleton crews to make sure someone is always available to maintain the peace."
	product_slogans = "Free weapons!;Time to kill your collegues!;You always wanted to do this!;Your weapons are right here.;Come and declare martial law!;Any friend can be an enemy!;To test for a changeling, kill them and see if they survive!;Everyone is a syndicate if they don't follow orders."
	icon_state = "dep"
	icon_deny = "dep-deny"
	light_mask = "dep-light-mask"
	vend_reply = "Thank you for your service!"
	req_access = list(ACCESS_BRIG)
	var/obj/item/radio/Radio

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
				/obj/item/restraints/handcuffs/cable = 16,
				/obj/item/reagent_containers/peppercloud_deployer = 4,
				/obj/item/flashlight/seclite = 4,
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
	dept_req_for_free = NONE

/obj/machinery/vending/deputy/Initialize(mapload)
	. = ..()

	Radio = new/obj/item/radio(src)
	Radio.set_listening(FALSE)
	Radio.set_frequency(FREQ_COMMON)

/obj/machinery/vending/deputy/vend(list/params, list/greyscale_colors)
	var/datum/vending_product/item = locate(params["ref"])
	var/cat_name = item.get_category_name()

	if(!allowed(usr))
		if(cat_name == "Kit")
			ADD_TRAIT(usr.mind, TRAIT_SECURITY, JOB_TRAIT)
			playsound(src, 'sound/effects/startup.ogg', 80, FALSE)
			say("Auri private security thanks you for enlisting in our volunteer program!")
			Radio.talk_into(src, "[usr.name], [get_area(usr.loc)], has just enlisted for Auri Private Security’s volunteer deputy program! APS thanks you for your service, and reminds all crew members that unauthorized enforcement is strictly prohibited! Remember; Compliance is a team effort! ")

		else if(cat_name == "Contraband" || scan_id == 0)
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
			say("ERR-!")

		else
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
			say("Only qualified personnel are allowed to purchase spare equipment. Enlist now!")
			return

	else if(cat_name == "Kit")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		say("ERROR! You are already enlisted. Please purchase spare gear separately.")
		return

	..()

/obj/machinery/vending/deputy/Destroy()
	QDEL_NULL(Radio)
	return ..()

/obj/item/vending_refill/deputy
	machine_name = "DepVend"
	icon_state = "refill_sec"
