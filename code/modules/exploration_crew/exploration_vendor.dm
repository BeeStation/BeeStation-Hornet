GLOBAL_VAR_INIT(exploration_points, 0)

/obj/machinery/vendor/exploration
	name = "exploration equipment vendor"
	desc = "An equipment vendor for exploration teams. Points are acquired by completing missions and shared between team members."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "mining"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/exploration_equipment_vendor

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

/obj/machinery/vendor/exploration/subtract_points(obj/item/card/id/I, amount)
	GLOB.exploration_points -= amount

/obj/machinery/vendor/exploration/get_points(obj/item/card/id/I)
	if(!(ACCESS_EXPLORATION in I.access))
		return 0
	return GLOB.exploration_points
