//How to balance this table
//-------------------------
//The total added weight of all the entries should be (roughly) equal to the total number of lootdrops
//(take in account those that spawn more than one object!)
//
//While this is random, probabilities tells us that item distribution will have a tendency to look like
//the content of the weighted table that created them.
//The less lootdrops, the less even the distribution.
//
//If you want to give items a weight <1 you can multiply all the weights by 10
//
//the "" entry will spawn nothing, if you increase this value,
//ensure that you balance it with more spawn points

//table data:
//-----------
//aft maintenance: 		24 items, 18 spots 2 extra (28/08/2014)
//asmaint: 				16 items, 11 spots 0 extra (08/08/2014)
//asmaint2:			 	36 items, 26 spots 2 extra (28/08/2014)
//fpmaint:				5  items,  4 spots 0 extra (08/08/2014)
//fpmaint2:				12 items, 11 spots 2 extra (28/08/2014)
//fsmaint:				0  items,  0 spots 0 extra (08/08/2014)
//fsmaint2:				40 items, 27 spots 5 extra (28/08/2014)
//maintcentral:			2  items,  2 spots 0 extra (08/08/2014)
//port:					5  items,  5 spots 0 extra (08/08/2014)

GLOBAL_LIST_INIT(maintenance_loot, list(
	/obj/effect/spawner/lootdrop/gloves = 8,
	/obj/effect/spawner/lootdrop/glowstick = 4,
	/obj/item/airlock_painter = 1,
	/obj/item/airlock_painter/decal = 1,
	/obj/item/airlock_painter/decal/tile = 1,
	/obj/item/assembly/igniter = 2,
	/obj/item/assembly/infra = 1,
	/obj/item/assembly/mousetrap = 2,
	/obj/item/assembly/prox_sensor = 4,
	/obj/item/assembly/signaler = 2,
	/obj/item/assembly/timer = 3,
	/obj/item/bodybag = 1,
	/obj/item/book/manual/wiki/engineering_construction = 1,
	/obj/item/book/manual/wiki/engineering_hacking = 1,
	/obj/item/clothing/glasses/meson = 2,
	/obj/item/clothing/glasses/sunglasses/advanced = 1,
	/obj/item/clothing/gloves/color/fyellow = 1,
	/obj/item/clothing/head/cone = 1,
	/obj/item/clothing/head/cone = 2,
	/obj/item/clothing/head/utility/hardhat = 1,
	/obj/item/clothing/head/utility/hardhat/red = 1,
	/obj/item/clothing/head/hats/tophat = 1,
	/obj/item/clothing/head/costume/ushanka = 1,
	/obj/item/clothing/head/utility/welding = 1,
	/obj/item/clothing/mask/gas/old = 15,		//greytide
	/obj/item/clothing/shoes/laceup = 1,
	/obj/item/clothing/suit/hazardvest = 1,
	/obj/item/clothing/suit/hooded/flashsuit = 2,
	/obj/item/clothing/under/misc/vice_officer = 1,
	/obj/item/coin/silver = 1,
	/obj/item/coin/twoheaded = 1,
	/obj/item/crowbar = 1,
	/obj/item/crowbar/red = 1,
	/obj/item/extinguisher = 11,
	/obj/item/flashlight = 4,
	/obj/item/flashlight/pen = 1,
	/obj/item/geiger_counter = 3,
	/obj/item/grenade/smokebomb = 2,
	/obj/item/hand_labeler = 1,
	/obj/item/multitool = 2,
	/obj/item/paper/crumpled = 1,
	/obj/item/pen = 1,
	/obj/item/pen/screwdriver = 8,
	/obj/item/poster/random_contraband = 1,
	/obj/item/poster/random_official = 1,
	/obj/item/radio/headset = 1,
	/obj/item/radio/off = 2,
	/obj/item/reagent_containers/cup/glass/bottle/homemaderum = 1,
	/obj/item/food/canned/peaches/maint = 1,
	/obj/item/food/grown/citrus/orange = 1,
	/obj/item/food/grown/flower/poppy = 10,
	/obj/item/reagent_containers/cup/rag = 3,
	/obj/item/reagent_containers/pill/floorpill = 4,
	/obj/item/reagent_containers/spray/pestspray = 1,
	/obj/item/reagent_containers/syringe/used = 4,
	/obj/item/screwdriver = 3,
	/obj/item/stack/cable_coil/random = 4,
	/obj/item/stack/cable_coil/random/five = 6,
	/obj/item/stack/medical/bruise_pack = 1,
	/obj/item/stack/rods/fifty = 1,
	/obj/item/stack/rods/ten = 9,
	/obj/item/stack/rods/twenty = 1,
	/obj/item/stack/sheet/cardboard = 2,
	/obj/item/stack/sheet/iron/twenty = 1,
	/obj/item/stack/sheet/mineral/plasma = 1,
	/obj/item/stack/sheet/rglass = 1,
	/obj/item/stack/sticky_tape = 1,
	/obj/item/stock_parts/cell = 3,
	/obj/item/storage/belt/utility = 2,
	/obj/item/storage/box = 2,
	/obj/item/storage/box/cups = 1,
	/obj/item/storage/box/donkpockets = 1,
	/obj/item/storage/box/hug/medical = 1,
	/obj/item/storage/box/lights/mixed = 3,
	/obj/item/storage/fancy/cigarettes/dromedaryco = 1,
	/obj/item/storage/secure/briefcase = 3,
	/obj/item/storage/toolbox/artistic = 2,
	/obj/item/storage/toolbox/mechanical = 1,
	/obj/item/t_scanner = 5,
	/obj/item/tank/internals/emergency_oxygen = 2,
	/obj/item/throwing_star/toy = 1,
	/obj/item/toy/eightball = 1,
	/obj/item/vending_refill/cola = 1,
	/obj/item/weaponcrafting/receiver = 2,
	/obj/item/weldingtool = 3,
	/obj/item/wirecutters = 1,
	/obj/item/wrench = 4,
	/obj/item/reagent_containers/cup/glass/bottle/homemaderum = 1,
	/obj/item/xenoartifact/maint = 1,
	/obj/item/paper_reader = 1,
	/obj/item/clothing/gloves/tackler/offbrand = 1,
))
