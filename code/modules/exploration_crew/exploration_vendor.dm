/obj/machinery/vendor/exploration
	name = "exploration equipment vendor"
	desc = "An equipment vendor for exploration teams. Points are acquired by completing missions and shared between team members."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "mining"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/exploration_equipment_vendor
	vendor_type = "exploration"
	bound_bank_account = ACCOUNT_SCI_ID
	currency_type = ACCOUNT_CURRENCY_EXPLO

	icon_deny = "mining-deny"
	prize_list = list(
		new /datum/data/vendor_equipment("1 Marker Beacon",				/obj/item/stack/marker_beacon,										50),
		new /datum/data/vendor_equipment("10 Marker Beacons",			/obj/item/stack/marker_beacon/ten,									300),
		new /datum/data/vendor_equipment("30 Marker Beacons",			/obj/item/stack/marker_beacon/thirty,								500),
		new /datum/data/vendor_equipment("Survival Medipen",			/obj/item/reagent_containers/hypospray/medipen/survival,			2000),
		new /datum/data/vendor_equipment("Brute Healing Kit",			/obj/item/storage/firstaid/brute,									3000),
		new /datum/data/vendor_equipment("Burn Healing Kit",			/obj/item/storage/firstaid/fire,									3000),
		new /datum/data/vendor_equipment("Advanced Healing Kit",		/obj/item/storage/firstaid/advanced,								5000),
		new /datum/data/vendor_equipment("Explorer's Webbing",			/obj/item/storage/belt/mining,										2000),
		new /datum/data/vendor_equipment("Breaching Charge",			/obj/item/grenade/exploration,										1000),
		new /datum/data/vendor_equipment(".38 Prospector Ammo box",		/obj/item/ammo_box/c38/exploration,									1000),
		new /datum/data/vendor_equipment("Charge Detonator",			/obj/item/exploration_detonator,									10000),
		new /datum/data/vendor_equipment("Multi-Purpose Energy Gun",	/obj/item/gun/energy/e_gun/mini/exploration,						20000),
		new /datum/data/vendor_equipment("Expanded E. Oxygen Tank",		/obj/item/tank/internals/emergency_oxygen/engi,						1000),
		new /datum/data/vendor_equipment("Survival Knife",				/obj/item/knife/combat/survival,									1000),
		new /datum/data/vendor_equipment("Pizza",						/obj/item/pizzabox/margherita,										200),
		new /datum/data/vendor_equipment("Whiskey",						/obj/item/reagent_containers/cup/glass/bottle/whiskey,				1000),
		new /datum/data/vendor_equipment("Absinthe",					/obj/item/reagent_containers/cup/glass/bottle/absinthe/premium,		1000),
		new /datum/data/vendor_equipment("Cigar",						/obj/item/clothing/mask/cigarette/cigar/havana,						1500),
		new /datum/data/vendor_equipment("Soap",						/obj/item/soap/nanotrasen,											2000),
		new /datum/data/vendor_equipment("Laser Pointer",				/obj/item/laser_pointer,											3000),
		new /datum/data/vendor_equipment("Toy Alien",					/obj/item/clothing/mask/facehugger/toy,								3000),
	)

/obj/machinery/vendor/exploration/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_ID_GIVE_EXPLO_POINT, "Give Explo Points")

/obj/machinery/vendor/exploration/vv_do_topic(list/href_list)
	. = ..()

	if(href_list[VV_ID_GIVE_EXPLO_POINT])
		if(bound_bank_account != SSeconomy.get_budget_account(ACCOUNT_SCI_ID, force=TRUE))
			bound_bank_account = SSeconomy.get_budget_account(ACCOUNT_SCI_ID, force=TRUE) // failsafe - why are you playing var edits
		var/target_value = input(usr, "How many exploration points would you like to add? (use negative to take)", "Give exploration points") as num
		if(!bound_bank_account.adjust_currency(ACCOUNT_CURRENCY_EXPLO, target_value))
			to_chat(usr, "Failed: Your input was [target_value], but [bound_bank_account.account_holder] has only [bound_bank_account.report_currency(ACCOUNT_CURRENCY_EXPLO)].")
		else
			to_chat(usr, "Success: [target_value] points have been added. [bound_bank_account.account_holder] now holds [bound_bank_account.report_currency(ACCOUNT_CURRENCY_EXPLO)].")

/obj/machinery/vendor/exploration/RedeemVoucher(obj/item/mining_voucher/voucher, mob/redeemer)
	var/items = list("Engineering Kit", "Medical Kit", "Scientist Kit", "Gunslinger Kit", "Laser Repeater Kit")
	if(CONFIG_GET(flag/jobs_have_minimal_access) == FALSE)	//If we are in a skeleton crew, it is likely we only have a single explorer
		items += "Ghost Shift Kit"

	var/selection = input(redeemer, "Pick your equipment", "Mining Voucher Redemption") as null|anything in sort_list(items)
	if(!selection || !Adjacent(redeemer) || QDELETED(voucher) || voucher.loc != redeemer)
		return
	var/drop_location = drop_location()
	switch(selection)
		if("Engineering Kit")
			new /obj/item/storage/belt/utility/full(drop_location)
			new /obj/item/grenade/exploration(drop_location)
			new /obj/item/grenade/exploration(drop_location)
			new /obj/item/grenade/exploration(drop_location)
			new /obj/item/exploration_detonator(drop_location)
			new /obj/item/discovery_scanner(drop_location)
		if("Medical Kit")
			new /obj/item/storage/firstaid/medical(drop_location)
			new /obj/item/pinpointer/crew(drop_location)
			new /obj/item/sensor_device(drop_location)
			new /obj/item/rollerbed(drop_location)
			new /obj/item/discovery_scanner(drop_location)
		if("Scientist Kit")
			new /obj/item/sbeacondrop/exploration(drop_location)
			new /obj/item/research_disk_pinpointer(drop_location)
			new /obj/item/discovery_scanner(drop_location)
		if("Ghost Shift Kit")	//A little bit of everything. We don't want the only explorer to die from a single mistake.
			new /obj/item/discovery_scanner(drop_location)
			new /obj/item/storage/firstaid/compact(drop_location)
			new /obj/item/storage/belt/utility/full(drop_location)
			new /obj/item/sbeacondrop/exploration(drop_location)
			new /mob/living/simple_animal/bot/medbot/filled(drop_location)	//This will save you if you are not stupid.
			new /obj/item/reagent_containers/hypospray/medipen/atropine(drop_location)		//Aaaand this will kill you if you are stupid. Atropine makes you drop your gun.
		if("Gunslinger Kit")
			new /obj/item/discovery_scanner(drop_location)
			new /obj/item/gun/ballistic/rifle/leveraction/exploration(drop_location)
			new /obj/item/ammo_box/c38/exploration(drop_location)
			new /obj/item/storage/belt/bandolier/western(drop_location)
			new /obj/item/tank/internals/emergency_oxygen/double(drop_location)
			new /obj/item/clothing/head/cowboy(drop_location)
			new /obj/item/mob_lasso(drop_location)	//see you space cowboy
		if("Laser Repeater Kit")
			new /obj/item/discovery_scanner(drop_location)
			new /obj/item/gun/energy/laser/repeater/explorer(drop_location)
			new /obj/item/tank/internals/emergency_oxygen/double(drop_location)
			new /obj/item/clothing/head/costume/sombrero(drop_location)
			new /obj/item/mob_lasso(drop_location)	//see you space cowboy

	SSblackbox.record_feedback("tally", "mining_voucher_redeemed", 1, selection)
	qdel(voucher)

/obj/item/mining_voucher/exploration
	name = "exploration equipment voucher"
	desc = "A token to redeem a piece of equipment. Use it on an exploration equipment vendor."
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_voucher"
	w_class = WEIGHT_CLASS_TINY
	voucher_type = "exploration"
