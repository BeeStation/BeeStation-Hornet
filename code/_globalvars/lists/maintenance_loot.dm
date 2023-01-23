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
// i.e.) `/obj/item/bodybag = 1` to `/obj/item/bodybag = 10`
// note: check everything that adjusts GLOB.maintenance_loot
// i.e. `GLOB.maintenance_loot += list(something_old = 1)` we need to change this to 10 as well
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

/*
https://docs.google.com/spreadsheets/d/1tYX1OVJKP0U6Dp3HFmOuL6NEoHT1uNCEASaEqQmTRGQ/edit#gid=0
use this excel to calculate random chance precisely
*/

GLOBAL_LIST_INIT(maintenance_loot, list(
	/obj/item/bodybag = 10,
	/obj/item/clothing/glasses/meson = 20,
	/obj/item/clothing/glasses/sunglasses/advanced = 10,
	/obj/item/clothing/gloves/color/fyellow = 10,
	/obj/item/clothing/head/hardhat = 10,
	/obj/item/clothing/head/hardhat/red = 10,
	/obj/item/clothing/head/that = 10,
	/obj/item/clothing/head/ushanka = 10,
	/obj/item/clothing/head/welding = 10,
	/obj/item/clothing/mask/gas/old = 150,		//greytide
	/obj/item/clothing/suit/hazardvest = 10,
	/obj/item/clothing/under/misc/vice_officer = 10,
	/obj/item/clothing/suit/hooded/flashsuit = 20,
	/obj/item/assembly/prox_sensor = 40,
	/obj/item/assembly/timer = 30,
	/obj/item/flashlight = 40,
	/obj/item/flashlight/pen = 10,
	/obj/effect/spawner/lootdrop/glowstick = 40,
	/obj/item/multitool = 20,
	/obj/item/radio/off = 20,
	/obj/item/t_scanner = 50,
	/obj/item/airlock_painter = 10,
	/obj/item/airlock_painter/decal = 10,
	/obj/item/airlock_painter/decal/tile = 10,
	/obj/item/stack/cable_coil/random = 40,
	/obj/item/stack/cable_coil/random/five = 60,
	/obj/item/stack/medical/bruise_pack = 10,
	/obj/item/stack/rods/ten = 90,
	/obj/item/stack/rods/twentyfive = 10,
	/obj/item/stack/rods/fifty = 10,
	/obj/item/stack/sheet/cardboard = 20,
	/obj/item/stack/sheet/iron/twenty = 10,
	/obj/item/stack/sheet/mineral/plasma = 10,
	/obj/item/stack/sheet/rglass = 10,
	/obj/item/book/manual/wiki/engineering_construction = 10,
	/obj/item/book/manual/wiki/engineering_hacking = 10,
	/obj/item/clothing/head/cone = 10,
	/obj/item/coin/silver = 10,
	/obj/item/coin/twoheaded = 10,
	/obj/item/poster/random_contraband = 10,
	/obj/item/poster/random_official = 10,
	/obj/item/crowbar = 10,
	/obj/item/crowbar/red = 10,
	/obj/item/extinguisher = 110,
	/obj/item/stack/sticky_tape = 10,
	/obj/item/hand_labeler = 10,
	/obj/item/paper/crumpled = 10,
	/obj/item/pen = 10,
	/obj/item/reagent_containers/spray/pestspray = 10,
	/obj/item/reagent_containers/glass/rag = 30,
	/obj/item/stock_parts/cell = 30,
	/obj/item/storage/belt/utility = 20,
	/obj/item/storage/box = 20,
	/obj/item/storage/box/cups = 10,
	/obj/item/storage/box/donkpockets = 10,
	/obj/item/storage/box/lights/mixed = 30,
	/obj/item/storage/box/hug/medical = 10,
	/obj/item/storage/fancy/cigarettes/dromedaryco = 10,
	/obj/item/storage/toolbox/mechanical = 10,
	/obj/item/screwdriver = 30,
	/obj/item/tank/internals/emergency_oxygen = 20,
	/obj/item/vending_refill/cola = 10,
	/obj/item/weldingtool = 30,
	/obj/item/wirecutters = 10,
	/obj/item/wrench = 40,
	/obj/item/relic = 30,
	/obj/item/weaponcrafting/receiver = 20,
	/obj/item/clothing/head/cone = 20,
	/obj/item/grenade/smokebomb = 20,
	/obj/item/geiger_counter = 30,
	/obj/item/reagent_containers/food/snacks/grown/citrus/orange = 10,
	/obj/item/radio/headset = 10,
	/obj/item/assembly/infra = 10,
	/obj/item/assembly/igniter = 20,
	/obj/item/assembly/signaler = 20,
	/obj/item/assembly/mousetrap = 20,
	/obj/item/reagent_containers/syringe/used = 40,
	/obj/effect/spawner/lootdrop/gloves = 80,
	/obj/item/clothing/shoes/laceup = 10,
	/obj/item/storage/secure/briefcase = 30,
	/obj/item/storage/toolbox/artistic = 20,
	/obj/item/toy/eightball = 10,
	/obj/item/reagent_containers/pill/floorpill = 40,
	/obj/item/reagent_containers/food/snacks/canned/peaches/maint = 10,
	/obj/item/reagent_containers/food/drinks/bottle/homemaderum = 10,
	/obj/item/reagent_containers/food/snacks/grown/poppy = 100,
	/obj/item/throwing_star = 10,
	/obj/item/xenoartifact/maint = 10,
	/obj/item/pen/screwdriver = 80,
	/obj/item/computer_hardware/hard_drive/role/random_maint_spawn = 20,
	/obj/item/storage/box/syndie_kit/random_fake = 1
	))
