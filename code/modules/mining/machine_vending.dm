/**********************Mining Equipment Vendor**************************/

/obj/machinery/mineral/equipment_vendor
	name = "mining equipment vendor"
	desc = "An equipment vendor for miners, points collected at an ore redemption machine can be spent here."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "mining"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/mining_equipment_vendor


	var/icon_deny = "mining-deny"
	var/obj/item/card/id/inserted_id
	var/list/prize_list = list( //if you add something to this, please, for the love of god, sort it by price/type. use tabs and not spaces.
		new /datum/data/mining_equipment("1 Marker Beacon",				/obj/item/stack/marker_beacon,										5),
		new /datum/data/mining_equipment("10 Marker Beacons",			/obj/item/stack/marker_beacon/ten,									500),
		new /datum/data/mining_equipment("30 Marker Beacons",			/obj/item/stack/marker_beacon/thirty,								150),
		new /datum/data/mining_equipment("Shelter Capsule",				/obj/item/survivalcapsule,											400),
		new /datum/data/mining_equipment("Regen. Core Stabilizer",		/obj/item/hivelordstabilizer,										400),
		new /datum/data/mining_equipment("Skeleton Key",				/obj/item/skeleton_key,												750),
		new /datum/data/mining_equipment("Survival Medipen",			/obj/item/reagent_containers/hypospray/medipen/survival,			500),
		new /datum/data/mining_equipment("Brute Healing Kit",			/obj/item/storage/firstaid/brute,									600),
		new /datum/data/mining_equipment("Burn Healing Kit",			/obj/item/storage/firstaid/fire,									600),
		new /datum/data/mining_equipment("Advanced Healing Kit",		/obj/item/storage/firstaid/advanced,								1200),
		new /datum/data/mining_equipment("Fulton Beacon",				/obj/item/fulton_core,												500),
		new /datum/data/mining_equipment("Fulton Extraction Pack",		/obj/item/extraction_pack,											1000),
		new /datum/data/mining_equipment("Jaunter",						/obj/item/wormhole_jaunter,											750),
		new /datum/data/mining_equipment("Advanced Ore Scanner",		/obj/item/t_scanner/adv_mining_scanner,								800),
		new /datum/data/mining_equipment("Explorer's Webbing",			/obj/item/storage/belt/mining,										500),
		new /datum/data/mining_equipment("Jump Boots",					/obj/item/clothing/shoes/bhop,										2000),
		new /datum/data/mining_equipment("Proto-Kinetic Crusher",		/obj/item/kinetic_crusher,								800),
		new /datum/data/mining_equipment("Proto-Kinetic Accelerator",	/obj/item/gun/energy/kinetic_accelerator,							500),
		new /datum/data/mining_equipment("Resonator",					/obj/item/resonator,												750),
		new /datum/data/mining_equipment("Upgraded Resonator",			/obj/item/resonator/upgraded,										1500),
		new /datum/data/mining_equipment("Silver Pickaxe",				/obj/item/pickaxe/silver,											500),
		new /datum/data/mining_equipment("Diamond Pickaxe",				/obj/item/pickaxe/diamond,											1000),
		new /datum/data/mining_equipment("Mining Bot Companion",		/mob/living/simple_animal/hostile/mining_drone,						800),
		new /datum/data/mining_equipment("Minebot Upgrade: Melee",		/obj/item/mine_bot_upgrade,											400),
		new /datum/data/mining_equipment("Minebot Upgrade: Armor",		/obj/item/mine_bot_upgrade/health,									400),
		new /datum/data/mining_equipment("Minebot Upgrade: Cooldown",	/obj/item/borg/upgrade/modkit/cooldown/minebot,						600),
		new /datum/data/mining_equipment("Minebot Upgrade: A.I.",		/obj/item/slimepotion/slime/sentience/mining,						1000),
		new /datum/data/mining_equipment("P-KA Upgrade: Bot-Friendly",	/obj/item/borg/upgrade/modkit/minebot_passthrough,					100),
		new /datum/data/mining_equipment("P-KA Upgrade: Tracer Shots",	/obj/item/borg/upgrade/modkit/tracer,								200),
		new /datum/data/mining_equipment("P-KA Upgrade: Adj. T. Shots",	/obj/item/borg/upgrade/modkit/tracer/adjustable,					300),
		new /datum/data/mining_equipment("P-KA Upgrade: Range",			/obj/item/borg/upgrade/modkit/range,								1000),
		new /datum/data/mining_equipment("P-KA Upgrade: Damage",		/obj/item/borg/upgrade/modkit/damage,								1000),
		new /datum/data/mining_equipment("P-KA Upgrade: Cooldown",		/obj/item/borg/upgrade/modkit/cooldown,								1000),
		new /datum/data/mining_equipment("P-KA Upgrade: Damage Radius",	/obj/item/borg/upgrade/modkit/aoe/mobs,								2000),
		new /datum/data/mining_equipment("P-KA Cosmetic Super Chassis",	/obj/item/borg/upgrade/modkit/chassis_mod,							200),
		new /datum/data/mining_equipment("P-KA Cosmetic Hyper Chassis",	/obj/item/borg/upgrade/modkit/chassis_mod/orange,					200),
		new /datum/data/mining_equipment("Mining Hardsuit",				/obj/item/clothing/suit/space/hardsuit/mining,						2000),
		new /datum/data/mining_equipment("Expanded E. Oxygen Tank",		/obj/item/tank/internals/emergency_oxygen/engi,						1000),
		new /datum/data/mining_equipment("Mining Conscription Kit",		/obj/item/storage/backpack/duffelbag/mining_conscript,				1000),
		new /datum/data/mining_equipment("Survival Knife",				/obj/item/kitchen/knife/combat/survival,							1000),
		new /datum/data/mining_equipment("Tracking Implant Kit", 		/obj/item/storage/box/minertracker,									1000),
		new /datum/data/mining_equipment("Point Transfer Card",			/obj/item/card/mining_point_card,									500),
		new /datum/data/mining_equipment("GAR Mesons",					/obj/item/clothing/glasses/meson/gar,								500),
		new /datum/data/mining_equipment("Luxury Shelter Capsule",		/obj/item/survivalcapsule/luxury,									3000),
		new /datum/data/mining_equipment("Mining Outpost Capsule",		/obj/item/survivalcapsule/encampment,								5000),
		new /datum/data/mining_equipment("Luxury Bar Capsule",			/obj/item/survivalcapsule/luxuryelite,								10000),
		new /datum/data/mining_equipment("Lazarus Injector",			/obj/item/lazarus_injector,											1000),
		new /datum/data/mining_equipment("1000 Space Cash",				/obj/item/stack/spacecash/c1000,									2000),
		new /datum/data/mining_equipment("Pizza",						/obj/item/pizzabox/margherita,										200),
		new /datum/data/mining_equipment("Whiskey",						/obj/item/reagent_containers/food/drinks/bottle/whiskey,			100),
		new /datum/data/mining_equipment("Absinthe",					/obj/item/reagent_containers/food/drinks/bottle/absinthe/premium,	100),
		new /datum/data/mining_equipment("Cigar",						/obj/item/clothing/mask/cigarette/cigar/havana,						150),
		new /datum/data/mining_equipment("Soap",						/obj/item/soap/nanotrasen,											200),
		new /datum/data/mining_equipment("Laser Pointer",				/obj/item/laser_pointer,											300),
		new /datum/data/mining_equipment("Toy Alien",					/obj/item/clothing/mask/facehugger/toy,								300),
		)

/datum/data/mining_equipment
	var/equipment_name = "generic"
	var/equipment_path = null
	var/cost = 0

/datum/data/mining_equipment/New(name, path, cost)
	src.equipment_name = name
	src.equipment_path = path
	src.cost = cost

/obj/machinery/mineral/equipment_vendor/Initialize()
	. = ..()
	build_inventory()

/obj/machinery/mineral/equipment_vendor/proc/build_inventory()
	for(var/p in prize_list)
		var/datum/data/mining_equipment/M = p
		GLOB.vending_products[M.equipment_path] = 1

/obj/machinery/mineral/equipment_vendor/power_change()
	..()
	update_icon()

/obj/machinery/mineral/equipment_vendor/update_icon()
	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/mineral/equipment_vendor/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/vending),
	)


/obj/machinery/mineral/equipment_vendor/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/mineral/equipment_vendor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MiningVendor")
		ui.open()

/obj/machinery/mineral/equipment_vendor/ui_static_data(mob/user)
	. = list()
	.["product_records"] = list()
	for(var/datum/data/mining_equipment/prize in prize_list)
		var/list/product_data = list(
			path = replacetext(replacetext("[prize.equipment_path]", "/obj/item/", ""), "/", "-"),
			name = prize.equipment_name,
			price = prize.cost,
			ref = REF(prize)
		)
		.["product_records"] += list(product_data)

/obj/machinery/mineral/equipment_vendor/ui_data(mob/user)
	. = list()
	var/mob/living/carbon/human/H
	var/obj/item/card/id/C
	if(ishuman(user))
		H = user
		C = H.get_idcard(TRUE)
		if(C)
			.["user"] = list()
			.["user"]["points"] = C.mining_points
			if(C.registered_account)
				.["user"]["name"] = C.registered_account.account_holder
				if(C.registered_account.account_job)
					.["user"]["job"] = C.registered_account.account_job.title
				else
					.["user"]["job"] = "No Job"

/obj/machinery/mineral/equipment_vendor/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("purchase")
			var/mob/M = usr
			var/obj/item/card/id/I = M.get_idcard(TRUE)
			if(!istype(I))
				to_chat(usr, "<span class='alert'>Error: An ID is required!</span>")
				flick(icon_deny, src)
				return
			var/datum/data/mining_equipment/prize = locate(params["ref"]) in prize_list
			if(!prize || !(prize in prize_list))
				to_chat(usr, "<span class='alert'>Error: Invalid choice!</span>")
				flick(icon_deny, src)
				return
			if(prize.cost > I.mining_points)
				to_chat(usr, "<span class='alert'>Error: Insufficient points for [prize.equipment_name] on [I]!</span>")
				flick(icon_deny, src)
				return
			I.mining_points -= prize.cost
			to_chat(usr, "<span class='notice'>[src] clanks to life briefly before vending [prize.equipment_name]!</span>")
			new prize.equipment_path(loc)
			SSblackbox.record_feedback("nested tally", "mining_equipment_bought", 1, list("[type]", "[prize.equipment_path]"))
			. = TRUE

/obj/machinery/mineral/equipment_vendor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mining_voucher))
		RedeemVoucher(I, user)
		return
	if(default_deconstruction_screwdriver(user, "mining-open", "mining", I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/mineral/equipment_vendor/proc/RedeemVoucher(obj/item/mining_voucher/voucher, mob/redeemer)
	var/items = list("Survival Capsule and Explorer's Webbing", "Resonator Kit", "Minebot Kit", "Extraction and Rescue Kit", "Crusher Kit", "Mining Conscription Kit")

	var/selection = input(redeemer, "Pick your equipment", "Mining Voucher Redemption") as null|anything in sortList(items)
	if(!selection || !Adjacent(redeemer) || QDELETED(voucher) || voucher.loc != redeemer)
		return
	var/drop_location = drop_location()
	switch(selection)
		if("Survival Capsule and Explorer's Webbing")
			new /obj/item/storage/belt/mining/vendor(drop_location)
		if("Resonator Kit")
			new /obj/item/storage/firstaid/brute(drop_location)
			new /obj/item/resonator(drop_location)
		if("Minebot Kit")
			new /mob/living/simple_animal/hostile/mining_drone(drop_location)
			new /obj/item/weldingtool/hugetank(drop_location)
			new /obj/item/clothing/head/welding(drop_location)
			new /obj/item/borg/upgrade/modkit/minebot_passthrough(drop_location)
		if("Extraction and Rescue Kit")
			new /obj/item/extraction_pack(drop_location)
			new /obj/item/fulton_core(drop_location)
			new /obj/item/stack/marker_beacon/thirty(drop_location)
		if("Crusher Kit")
			new /obj/item/extinguisher/mini(drop_location)
			new /obj/item/kinetic_crusher(drop_location)
		if("Mining Conscription Kit")
			new /obj/item/storage/backpack/duffelbag/mining_conscript(drop_location)

	SSblackbox.record_feedback("tally", "mining_voucher_redeemed", 1, selection)
	qdel(voucher)

/obj/machinery/mineral/equipment_vendor/ex_act(severity, target)
	do_sparks(5, TRUE, src)
	if(prob(50 / severity) && severity < 3)
		qdel(src)

/****************Golem Point Vendor**************************/

/obj/machinery/mineral/equipment_vendor/golem
	name = "golem ship equipment vendor"
	circuit = /obj/item/circuitboard/machine/mining_equipment_vendor/golem

/obj/machinery/mineral/equipment_vendor/golem/Initialize()
	. = ..()
	desc += "\nIt seems a few selections have been added."
	prize_list += list(
		new /datum/data/mining_equipment("Extra Id",       				/obj/item/card/id/mining, 				                   		250),
		new /datum/data/mining_equipment("Science Goggles",       		/obj/item/clothing/glasses/science,								250),
		new /datum/data/mining_equipment("Monkey Cube",					/obj/item/reagent_containers/food/snacks/monkeycube,        	300),
		new /datum/data/mining_equipment("Toolbelt",					/obj/item/storage/belt/utility,	    							350),
		new /datum/data/mining_equipment("Royal Cape of the Liberator", /obj/item/bedsheet/rd/royal_cape, 								500),
		new /datum/data/mining_equipment("Grey Slime Extract",			/obj/item/slime_extract/grey,									1000),
		new /datum/data/mining_equipment("P-KA Upgrade: Trigger Mod",	/obj/item/borg/upgrade/modkit/trigger_guard,					1000),
		new /datum/data/mining_equipment("The Liberator's Legacy",  	/obj/item/storage/box/rndboards,								2000)
		)

/**********************Mining Equipment Vendor Items**************************/

/**********************Mining Equipment Voucher**********************/

/obj/item/mining_voucher
	name = "mining voucher"
	desc = "A token to redeem a piece of equipment. Use it on a mining equipment vendor."
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_voucher"
	w_class = WEIGHT_CLASS_TINY

/**********************Mining Point Card**********************/

/obj/item/card/mining_point_card
	name = "mining points card"
	desc = "A small card preloaded with mining points. Swipe your ID card over it to transfer the points, then discard."
	icon_state = "data_1"
	var/points = 500

/obj/item/card/mining_point_card/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id))
		if(points)
			var/obj/item/card/id/C = I
			C.mining_points += points
			to_chat(user, "<span class='info'>You transfer [points] points to [C].</span>")
			points = 0
		else
			to_chat(user, "<span class='info'>There's no points left on [src].</span>")
	..()

/obj/item/card/mining_point_card/examine(mob/user)
	. = ..()
	. += "<span class='info'>There's [points] point\s on the card.</span>"

///Conscript kit
/obj/item/card/mining_access_card
	name = "mining access card"
	desc = "A small card, that when used on any ID, will add mining access."
	icon_state = "data_1"

/obj/item/card/mining_access_card/afterattack(atom/movable/AM, mob/user, proximity)
	. = ..()
	if(istype(AM, /obj/item/card/id) && proximity)
		var/obj/item/card/id/I = AM
		I.access |=	ACCESS_MINING
		I.access |= ACCESS_MINING_STATION
		I.access |= ACCESS_MECH_MINING
		I.access |= ACCESS_MINERAL_STOREROOM
		I.access |= ACCESS_CARGO
		to_chat(user, "You upgrade [I] with mining access.")
		log_id("[key_name(user)] added mining access to '[I]' using [src] at [AREACOORD(user)].")
		qdel(src)

/obj/item/storage/backpack/duffelbag/mining_conscript
	name = "mining conscription kit"
	desc = "A kit containing everything a crewmember needs to support a shaft miner in the field."

/obj/item/storage/backpack/duffelbag/mining_conscript/PopulateContents()
	new /obj/item/pickaxe/mini(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/clothing/suit/hooded/explorer(src)
	new /obj/item/encryptionkey/headset_cargo(src)
	new /obj/item/clothing/mask/gas/explorer(src)
	new /obj/item/card/mining_access_card(src)
	new /obj/item/card/id/mining(src)
