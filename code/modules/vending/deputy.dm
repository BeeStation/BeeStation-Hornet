/obj/machinery/vending/deputy
	name = "\improper DepVend"
	desc = "A machine that dispenses the equipment required to join security voluntarily. Helpfully provided by Auri private security, it's used on stations with skeleton crews to make sure someone is always available to maintain the peace."
	product_ads = "Free weapons!;Time to kill your collegues!;You always wanted to do this!;Your weapons are right here.;Come and declare martial law!;Any friend can be an enemy!;To test for a changeling, kill them and see if they survive!;Everyone is a syndicate if they don't follow orders."
	icon_state = "dep"
	icon_deny = "dep-deny"
	light_mask = "dep-light-mask"
	vend_reply = "Thank you for your service!"
	req_access = list()

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
				/obj/item/storage/belt/security/deputy = 4,
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
	default_price = 50
	extra_price = 70
	dept_req_for_free = NONE

	var/obj/item/radio/internal_radio
	var/radio_key = /obj/item/encryptionkey/headset_sec
	var/radio_channel = RADIO_CHANNEL_COMMON
	var/msg = null
	COOLDOWN_DECLARE(radio_cooldown)

/obj/machinery/vending/deputy/Initialize(mapload)
	. = ..()
	internal_radio = new(src)
	internal_radio.keyslot = new radio_key
	internal_radio.canhear_range = 0
	internal_radio.recalculateChannels()

/obj/machinery/vending/deputy/vend(list/params, list/greyscale_colors)
	var/datum/vending_product/R = locate(params["ref"])

	// Is security personnel buying it?
	if(!HAS_MIND_TRAIT(usr, TRAIT_SECURITY))

		// It's not a seccie. Is it a any category except kit or contraband? If yes, deny.
		if("[R.category.get_]" != "Kit" || "[R.category]" != "Contraband" )
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
			say("Only qualified personnel are allowed to purchase spare equipment. Enlist now!")
			return

		// Not a seccie, but wants to be one.
		if("[R.category]" == "Kit")
			ADD_TRAIT(usr.mind, TRAIT_SECURITY, JOB_TRAIT)
			playsound(src, 'sound/effects/startup.ogg', 50, FALSE)
			say("Auri private security thanks you for enlisting in our volunteer program!")

			if(COOLDOWN_FINISHED(src, radio_cooldown))
				COOLDOWN_START(src, radio_cooldown, 1 MINUTES)
				msg = "[usr.name], [get_area(usr.loc)], has just enlisted into the ranks of Auri Private Security’s certified volunteer deputy program. We remind you; Compliance is a team effort. APS thanks you for your service, and reminds all crew members that unauthorized enforcement is strictly prohibited."
				internal_radio.talk_into(src, msg, radio_channel)

	// It's a seccie. Are they trying to buy a kit? If yes, deny.
	if("[R.category]" != "Kit")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		say("ERROR! You are already enlisted. Please purchase spare gear separately.")
		return

	..()

/obj/machinery/vending/deputy/Destroy()
	QDEL_NULL(internal_radio)
	return ..()

/obj/item/vending_refill/deputy
	machine_name = "DepVend"
	icon_state = "refill_sec"
