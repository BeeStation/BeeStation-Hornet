/obj/machinery/vendor/exploration
	name = "exploration equipment vendor"
	desc = "An equipment vendor for exploration teams. Points are acquired by completing missions and shared between team members."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "mining"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/exploration_equipment_vendor

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
		new /datum/data/vendor_equipment("Charge Detonator",			/obj/item/exploration_detonator,									10000),
		new /datum/data/vendor_equipment("Multi-Purpose Energy Gun",	/obj/item/gun/energy/e_gun/mini/exploration,						20000),
		new /datum/data/vendor_equipment("Expanded E. Oxygen Tank",		/obj/item/tank/internals/emergency_oxygen/engi,						1000),
		new /datum/data/vendor_equipment("Survival Knife",				/obj/item/kitchen/knife/combat/survival,							1000),
		new /datum/data/vendor_equipment("Pizza",						/obj/item/pizzabox/margherita,										200),
		new /datum/data/vendor_equipment("Whiskey",						/obj/item/reagent_containers/food/drinks/bottle/whiskey,			1000),
		new /datum/data/vendor_equipment("Absinthe",					/obj/item/reagent_containers/food/drinks/bottle/absinthe/premium,	1000),
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
