//as of:12/22/2025:
//boxstation: ~168 maintenance spawners = (89 flat base + variable random-maint spawners)
//cardinalstation: ~132 maintenance spawners = (77 flat base + variable random-maint spawners)
//deltastation: ~228 maintenance spawners = (134 flat base + variable random-maint spawners)
//echostation: ~137 maintenance spawners = (76 flat base + variable random-maint spawners)
//flandstation: 243~ maintenance spawners = (162 flat base + variable random-maint spawners)
//kilostation: ~ maintenance spawners = (70 flat base + variable random-maint spawners)
//radstation: ~138 maintenance spawners = (92 flat base + variable random-maint spawners)
//metastation: ~194 maintenance spawners = (129 flat base + variable random-maint spawners)

//how to balance maint loot spawns:
// 1) Ensure each category has items of approximately the same power level
// 2) Tune weight of each category until average power of a maint loot spawn is acceptable
// 3) Mapping considerations - Loot value should scale with difficulty of acquisition, or an assistaint will run through collecting free gear with no risk

//goal of maint loot:
// 1) Provide random equipment to people who take effort to crawl maint
// 2) Create memorable moments with very rare, crazy items

//Loot tables

GLOBAL_LIST_INIT(trash_loot, list(//junk: useless, very easy to get, or ghetto chemistry items
	list(//trash
		/obj/item/trash/can = 1,
		/obj/item/trash/candy = 1,
		/obj/item/trash/cheesie = 1,
		/obj/item/trash/chips = 1,
		/obj/item/trash/pistachios = 1,
		/obj/item/trash/popcorn = 1,
		/obj/item/trash/raisins = 1,
		/obj/item/trash/sosjerky = 1,
		/obj/item/trash/candle = 1,

		/obj/item/c_tube = 1,
		/obj/item/disk/data = 1,
		/obj/item/folder/yellow = 1,
		/obj/item/hand_labeler = 1,
		/obj/item/paper = 1,
		/obj/item/paper/crumpled = 1,
		/obj/item/pen = 1,
		/obj/item/poster/random_contraband = 1,
		/obj/item/poster/random_official = 1,
		/obj/item/stack/sheet/cardboard = 1,
		/obj/item/storage/box = 1,

		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/camera = 1,
		/obj/item/camera_film = 1,
		/obj/item/cigbutt = 1,
		/obj/item/coin/silver = 1,
		/obj/item/food/urinalcake = 1,
		/obj/item/light/bulb = 1,
		/obj/item/light/tube = 1,
		/obj/item/reagent_containers/cup/glass/drinkingglass = 1,

		/obj/item/airlock_painter = 1,
		/obj/item/airlock_painter/decal = 2,
		/obj/item/clothing/mask/breath = 1,
		/obj/item/rack_parts = 1,
		/obj/item/shard = 1,

		/obj/item/reagent_containers/pill/floorpill = 3,
		/obj/item/toy/eightball = 1,
		) = 8,

	list(//tier 1 stock parts
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/matter_bin = 1,
		) = 1,
	))



GLOBAL_LIST_INIT(common_loot, list( //common: basic items
	list(//tools
		/obj/item/analyzer = 1,
		/obj/item/crowbar = 1,
		/obj/item/geiger_counter = 1,
		/obj/item/mop = 1,
		/obj/item/pushbroom = 1,
		/obj/item/reagent_containers/cup/bucket = 1,
		/obj/item/screwdriver = 1,
		/obj/item/t_scanner = 1,
		/obj/item/toy/crayon/spraycan = 1,
		/obj/item/weldingtool = 1,
		/obj/item/wirecutters = 1,
		/obj/item/wrench = 1,
		) = 1,

	list(//equipment
		/obj/effect/spawner/random/clothing/gloves = 1,
		/obj/item/clothing/glasses/meson = 1,
		/obj/item/clothing/glasses/science = 1,
		/obj/item/clothing/gloves/color/black = 1,
		/obj/item/clothing/gloves/color/fyellow = 1,
		/obj/item/clothing/mask/gas = 1,
		/obj/item/clothing/shoes/sneakers/black = 1,
		/obj/item/clothing/suit/hazardvest = 1,
		/obj/item/clothing/suit/toggle/labcoat = 1,
		/obj/item/clothing/under/color/grey = 1,
		/obj/item/radio/headset = 1,
		/obj/item/storage/backpack = 1,
		/obj/item/storage/belt/fannypack = 1,
		/obj/item/storage/wallet/random = 1,
		) = 1,

	list(//construction and crafting
		/obj/item/sign_backing = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/rods = 1,
		/obj/item/stack/sheet/iron/twenty = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
		/obj/item/stock_parts/cell = 1,
		/obj/effect/spawner/random/engineering/vending_restock = 1,
		//assemblies
		/obj/item/assembly/health = 1,
		/obj/item/assembly/igniter = 1,
		/obj/item/assembly/infra = 1,
		/obj/item/assembly/mousetrap = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/assembly/signaler = 1,
		/obj/item/assembly/timer = 1,
		/obj/item/stack/package_wrap = 1,
		/obj/item/stack/wrapping_paper = 1,
		) = 1,

	list(//medical and chemicals
		/obj/item/grenade/chem_grenade/cleaner = 1,
		/obj/item/reagent_containers/cup/beaker = 1,
		/obj/item/reagent_containers/cup/rag = 1,
		/obj/item/reagent_containers/syringe = 1,
		/obj/item/storage/box/matches = 1,
		/obj/item/storage/fancy/cigarettes/dromedaryco = 1,
		) = 1,

	list(//food
		/obj/item/reagent_containers/cup/glass/bottle/beer = 1,
		/obj/item/reagent_containers/cup/glass/coffee = 1,
		) = 1,

	list(//misc
		/obj/item/bodybag = 1,
		/obj/item/extinguisher = 1,
		/obj/item/grenade/smokebomb = 1,
		/obj/item/radio/off = 1,
		/obj/item/stack/spacecash/c10 = 1,
		/obj/item/stack/sticky_tape = 1,
		/obj/item/tank/internals/emergency_oxygen = 1,
		/obj/item/paper_reader = 1,

		//light sources
		/obj/effect/spawner/random/decoration/glowstick = 1,
		/obj/item/clothing/head/utility/hardhat/red = 1,
		/obj/item/flashlight = 1,
		/obj/item/flashlight/flare = 1,
		) = 1,
	))



GLOBAL_LIST_INIT(uncommon_loot, list(//uncommon: useful items
	list(//tools
		/obj/item/grenade/iedcasing = 1,
		/obj/item/hatchet = 1,
		/obj/item/melee/baton/security/cattleprod = 1,
		/obj/item/multitool = 1,
		/obj/item/pen/fountain = 1,
		/obj/item/pen/screwdriver = 1,
		/obj/item/restraints/handcuffs/cable = 1,
		/obj/item/restraints/legcuffs/bola = 1,
		/obj/item/spear = 1,
		/obj/item/weldingtool/largetank = 1,
		) = 8,

	list(//equipment
		/obj/item/clothing/ears/earmuffs = 1,
		/obj/item/clothing/glasses/hud/diagnostic = 1,
		/obj/item/clothing/glasses/hud/health = 1,
		/obj/item/clothing/glasses/welding = 1,
		/obj/item/clothing/gloves/tackler/offbrand = 1,
		/obj/item/clothing/head/helmet/old = 1,
		/obj/item/clothing/head/utility/welding = 1,
		/obj/item/clothing/mask/muzzle = 1,
		/obj/item/clothing/suit/armor/vest/old = 1,
		/obj/item/storage/belt/medical = 1,
		/obj/item/storage/belt/utility = 1,
		/obj/item/pen/screwdriver = 1,
		) = 8,

	list(//construction and crafting
		/obj/item/beacon = 1,
		/obj/item/stack/sheet/wood/fifty = 1,
		/obj/item/stock_parts/cell/high = 1,
		/obj/item/storage/box/clown = 1,
		/obj/item/weaponcrafting/receiver = 1,
		) = 8,

	list(//medical and chemicals
		list(//basic healing items
			/obj/item/stack/medical/gauze = 1,
			/obj/item/stack/medical/ointment = 1,
			/obj/item/stack/medical/bruise_pack = 1,
			) = 4,
		list(//medical chems
			/obj/item/reagent_containers/cup/bottle/charcoal = 1,
			/obj/item/reagent_containers/hypospray/medipen = 1,
			/obj/item/reagent_containers/syringe/perfluorodecalin = 1,
			) = 4,
		list(//drinks
			/obj/item/reagent_containers/cup/glass/bottle/vodka = 1,
			/obj/item/reagent_containers/cup/glass/drinkingglass/filled/nuka_cola = 1,
			/obj/item/reagent_containers/cup/soda_cans/grey_bull = 1,
			/obj/item/reagent_containers/cup/glass/bottle/homemaderum = 1,
			) = 4,
		list(//sprayers
			/obj/item/reagent_containers/spray = 1,
			/obj/item/watertank = 1,
			/obj/item/watertank/janitor = 1,
			) = 4,
		) = 8,

	list(//food
		/obj/item/food/canned/peaches/maint = 1,
		/obj/item/storage/box/donkpockets = 1,
		/obj/item/food/grown/flower/poppy = 5, //Heretics
		list(//Donk Varieties
			/obj/item/storage/box/donkpockets/donkpocketberry = 1,
			/obj/item/storage/box/donkpockets/donkpockethonk = 1,
			/obj/item/storage/box/donkpockets/donkpocketpizza = 1,
			/obj/item/storage/box/donkpockets/donkpocketspicy = 1,
			/obj/item/storage/box/donkpockets/donkpocketteriyaki = 1,
			) = 1,
		/obj/item/food/monkeycube = 1,
		) = 8,

	list(//xenoartifacts
		/obj/item/xenoartifact/maint = 1
		) = 6,

	list(//modsuits
		/obj/effect/spawner/random/mod/maint = 3,
		/obj/item/mod/construction/broken_core = 1,
		) = 4,

	list(//music
		/obj/item/instrument/accordion = 5,
		/obj/item/instrument/banjo = 5,
		/obj/item/instrument/bikehorn = 2,
		/obj/item/instrument/eguitar = 5,
		/obj/item/instrument/glockenspiel = 5,
		/obj/item/instrument/guitar = 5,
		/obj/item/instrument/harmonica = 5,
		/obj/item/instrument/musicalmoth = 1,
		/obj/item/instrument/recorder = 5,
		/obj/item/instrument/saxophone = 5,
		/obj/item/instrument/trombone = 5,
		/obj/item/instrument/trumpet = 5,
		/obj/item/instrument/violin = 5,
		/obj/item/instrument/violin/golden = 2,
		) = 2,

	list(//fakeout items, keep this list at low relative weight
		/obj/item/clothing/shoes/jackboots = 1,
		/obj/item/dice/d20 = 1, //To balance out the stealth die of fates in oddities
		) = 1,
))

GLOBAL_LIST_INIT(rarity_loot, list(//rare: really good items
	list(//tools
		/obj/item/assembly/flash/memorizer = 1,
		/obj/item/flashlight/flashdark = 1,
		/obj/item/knife/kitchen = 1,
		/obj/item/melee/baton/security/cattleprod/teleprod = 1,
		/obj/item/restraints/handcuffs = 1,
		/obj/item/shield/buckler = 1,
		/obj/item/throwing_star = 1,
		/obj/item/weldingtool/hugetank = 1,
		) = 1,

	list(//equipment
		/obj/item/clothing/glasses/hud/security = 1,
		/obj/item/clothing/glasses/sunglasses = 1,
		/obj/item/clothing/gloves/color/yellow = 1,
		/obj/item/clothing/gloves/tackler/combat = 1,
		/obj/item/clothing/head/helmet/toggleable/justice = 1,
		/obj/item/storage/belt/military/assault = 1,
		/obj/item/storage/belt/security = 1,
		) = 1,

	list(//paint
		/obj/item/paint/anycolor = 1,
		/obj/item/paint/black = 1,
		/obj/item/paint/blue = 1,
		/obj/item/paint/green = 1,
		/obj/item/paint/paint_remover = 1,
		/obj/item/paint/red = 1,
		/obj/item/paint/violet = 1,
		/obj/item/paint/white = 1,
		/obj/item/paint/yellow = 1,
		) = 1,

	list(//medical and chemicals
		list(//medkits
			/obj/item/storage/box/hug/medical = 1,
			/obj/item/storage/firstaid/regular = 1,
			) = 1,
		list(//medical chems
			/obj/item/reagent_containers/hypospray/medipen/oxandrolone = 1,
			/obj/item/reagent_containers/hypospray/medipen/salacid = 1,
			/obj/item/reagent_containers/hypospray/medipen/pumpup = 1,
			/obj/item/reagent_containers/syringe/contraband/methamphetamine = 1,
			) = 1,
		) = 1,

	list(//misc
		/obj/item/disk/nuclear/fake = 1,
		) = 1,

))



GLOBAL_LIST_INIT(oddity_loot, list(//oddity: strange or crazy items
		/obj/effect/rune/teleport = 1,
		/obj/item/clothing/head/helmet/abductor = 1,
		/obj/item/clothing/shoes/jackboots/fast = 1,
		/obj/item/clothing/suit/armor/reactive/table = 1,
		/obj/item/dice/d20/fate/stealth/cursed = 1, //Only rolls 1
		/obj/item/dice/d20/fate/stealth/one_use = 1, //Looks like a d20, keep the d20 in the uncommon pool.
		/obj/item/shadowcloak = 1,
		/obj/item/spear/grey_tide = 1,
		/obj/item/storage/box/donkpockets/donkpocketgondola = 1,
		list(//music
			/obj/item/instrument/saxophone/spectral = 1,
			/obj/item/instrument/trombone/spectral = 1,
			/obj/item/instrument/trumpet/spectral = 1,
			) = 1,
		//obj/item/toy/cards/deck/tarot/haunted = 1,
	))

//Maintenance loot spawner pools
#define MAINT_TRASH_WEIGHT 4500
#define MAINT_COMMON_WEIGHT 4500
#define MAINT_UNCOMMON_WEIGHT 900
#define MAINT_RARITY_WEIGHT 99
#define MAINT_ODDITY_WEIGHT 1 //1 out of 10,000 would give metastation (180 spawns) a 2 in 111 chance of spawning an oddity per round, similar to xeno egg
#define MAINT_HOLIDAY_WEIGHT 3500 // When holiday loot is enabled, it'll give every loot item a 25% chance of being a holiday item

//Loot pool used by default maintenance loot spawners
GLOBAL_LIST_INIT(maintenance_loot, list(
	GLOB.trash_loot = MAINT_TRASH_WEIGHT,
	GLOB.common_loot = MAINT_COMMON_WEIGHT,
	GLOB.uncommon_loot = MAINT_UNCOMMON_WEIGHT,
	GLOB.rarity_loot = MAINT_RARITY_WEIGHT,
	GLOB.oddity_loot = MAINT_ODDITY_WEIGHT,
	))

//Loot pool that is copied from maint loot but doesn't get changed due to holidays
GLOBAL_LIST_INIT(dumpster_loot, GLOB.maintenance_loot.Copy())
