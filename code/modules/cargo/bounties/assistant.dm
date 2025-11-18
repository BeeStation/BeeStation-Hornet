/datum/bounty/item/assistant/scooter
	name = "Scooter"
	description = "Nanotrasen has determined walking to be wasteful. Ship a scooter to CentCom to speed operations up."
	reward = 1080 // the mat hoffman
	wanted_types = list(
		/obj/vehicle/ridden/scooter = TRUE,
	)
	include_subtypes = FALSE

/datum/bounty/item/assistant/skateboard
	name = "Skateboard"
	description = "Nanotrasen has determined walking to be wasteful. Ship a skateboard to CentCom to speed operations up."
	reward = 900 // the tony hawk
	wanted_types = list(
		/obj/vehicle/ridden/scooter/skateboard = TRUE,
		/obj/item/melee/skateboard = TRUE,
	)

/datum/bounty/item/assistant/stunprod
	name = "Stunprod"
	description = "CentCom demands a stunprod to use against dissidents. Craft one, then ship it."
	reward = 1300
	wanted_types = list(
		/obj/item/melee/baton/cattleprod = TRUE,
	)

/datum/bounty/item/assistant/soap
	name = "Soap"
	description = "Soap has gone missing from CentCom's bathrooms and nobody knows who took it. Replace it and be the hero CentCom needs."
	reward = 2000
	required_count = 3
	wanted_types = list(
		/obj/item/soap = TRUE,
	)

/datum/bounty/item/assistant/spear
	name = "Spears"
	description = "CentCom's security forces are going through budget cuts. You will be paid if you ship a set of spears."
	reward = 2000
	required_count = 5
	wanted_types = list(
		/obj/item/spear = TRUE,
	)

/datum/bounty/item/assistant/toolbox
	name = "Toolboxes"
	description = "There's an absence of robustness at Central Command. Hurry up and ship some toolboxes as a solution."
	reward = 2000
	required_count = 6
	wanted_types = list(
		/obj/item/storage/toolbox = TRUE,
	)

/datum/bounty/item/assistant/statue
	name = "Statue"
	description = "Central Command would like to commision an artsy statue for the lobby. Ship one out, when possible."
	reward = 2000
	wanted_types = list(
		/obj/structure/statue = TRUE,
	)

/datum/bounty/item/assistant/clown_box
	name = "Clown Box"
	description = "The universe needs laughter. Stamp cardboard with a clown stamp and ship it out."
	reward = 1500
	wanted_types = list(
		/obj/item/storage/box/clown = TRUE,
	)

/datum/bounty/item/assistant/cheesiehonkers
	name = "Cheesie Honkers"
	description = "Apparently the company that makes Cheesie Honkers is going out of business soon. CentCom wants to stock up before it happens!"
	reward = 1200
	required_count = 3
	wanted_types = list(
		/obj/item/food/cheesiehonkers = TRUE,
	)

/datum/bounty/item/assistant/baseball_bat
	name = "Baseball Bat"
	description = "Baseball fever is going on at CentCom! Be a dear and ship them some baseball bats, so that management can live out their childhood dream."
	reward = 2000
	required_count = 5
	wanted_types = list(
		/obj/item/melee/baseball_bat = TRUE,
	)

/datum/bounty/item/assistant/extendohand
	name = "Extendo-Hand"
	description = "Commander Betsy is getting old, and can't bend over to get the telescreen remote anymore. Management has requested an extendo-hand to help her out."
	reward = 2500
	wanted_types = list(
		/obj/item/extendohand = TRUE,
	)

/datum/bounty/item/assistant/donut
	name = "Donuts"
	description = "CentCom's security forces are facing heavy losses against the Syndicate. Ship donuts to raise morale."
	reward = 3000
	required_count = 10
	wanted_types = list(
		/obj/item/food/donut = TRUE,
	)

/datum/bounty/item/assistant/donkpocket
	name = "Donk-Pockets"
	description = "Consumer safety recall: Warning. Donk-Pockets manufactured in the past year contain hazardous lizard biomatter. Return units to CentCom immediately."
	reward = 3000
	required_count = 10
	wanted_types = list(
		/obj/item/food/donkpocket = TRUE,
	)

/datum/bounty/item/assistant/briefcase
	name = "Briefcase"
	description = "Central Command will be holding a business convention this year. Ship a few briefcases in support."
	reward = 2500
	required_count = 5
	wanted_types = list(
		/obj/item/storage/briefcase = TRUE,
		/obj/item/storage/secure/briefcase = TRUE,
	)

/datum/bounty/item/assistant/sunglasses
	name = "Sunglasses"
	description = "A famous blues duo is passing through the sector, but they've lost their shades and they can't perform. Ship new sunglasses to CentCom to rectify this."
	reward = 3000
	required_count = 2
	wanted_types = list(
		/obj/item/clothing/glasses/sunglasses = TRUE,
	)

/datum/bounty/item/assistant/monkey_hide
	name = "Monkey Hide"
	description = "One of the scientists at CentCom is interested in testing products on monkey skin. Your mission is to acquire monkey's hide and ship it."
	reward = 1500
	wanted_types = list(
		/obj/item/stack/sheet/animalhide/monkey = TRUE,
	)

/datum/bounty/item/assistant/shard
	name = "Shards"
	description = "A killer clown has been stalking CentCom, and staff have been unable to catch her because she's not wearing shoes. Please ship some shards so that a booby trap can be constructed."
	reward = 1500
	required_count = 15
	wanted_types = list(
		/obj/item/shard = TRUE,
	)

/datum/bounty/item/assistant/comfy_chair
	name = "Comfy Chairs"
	description = "Commander Pat is unhappy with his chair. He claims it hurts his back. Ship some alternatives out to humor him."
	reward = 1500
	required_count = 5
	wanted_types = list(
		/obj/structure/chair/fancy/comfy = TRUE,
	)

/datum/bounty/item/assistant/poppy
	name = "Poppies"
	description = "Commander Zot really wants to sweep Security Officer Olivia off her feet. Send a shipment of Poppies - her favorite flower - and he'll happily reward you."
	reward = 1000
	required_count = 3
	wanted_types = list(
		/obj/item/food/grown/flower/poppy = TRUE,
	)
	include_subtypes = FALSE

/datum/bounty/item/assistant/shadyjims
	name = "Shady Jim's"
	description = "There's an irate officer at CentCom demanding that he receive a box of Shady Jim's cigarettes. Please ship one. He's starting to make threats."
	reward = 500
	wanted_types = list(
		/obj/item/storage/fancy/cigarettes/cigpack_shadyjims = TRUE,
	)

/datum/bounty/item/assistant/potted_plants
	name = "Potted Plants"
	description = "Central Command is looking to commission a new BirdBoat-class station. You've been ordered to supply the potted plants."
	reward = 2000
	required_count = 8
	wanted_types = list(
		/obj/item/kirbyplants = TRUE,
	)

/datum/bounty/item/assistant/earmuffs
	name = "Earmuffs"
	description = "Central Command is getting tired of your station's messages. They've ordered that you ship some earmuffs to lessen the annoyance."
	reward = 1000
	wanted_types = list(
		/obj/item/clothing/ears/earmuffs = TRUE,
	)

/datum/bounty/item/assistant/handcuffs
	name = "Handcuffs"
	description = "A large influx of escaped convicts have arrived at Central Command. Now is the perfect time to ship out spare handcuffs (or restraints)."
	reward = 1000
	required_count = 5
	wanted_types = list(
		/obj/item/restraints/handcuffs = TRUE,
	)

/datum/bounty/item/assistant/monkey_cubes
	name = "Monkey Cubes"
	description = "Due to a recent genetics accident, Central Command is in serious need of monkeys. Your mission is to ship monkey cubes."
	reward = 2000
	required_count = 3
	wanted_types = list(
		/obj/item/food/monkeycube = TRUE,
	)

/datum/bounty/item/assistant/chainsaw
	name = "Chainsaw"
	description = "The chef at CentCom is having trouble butchering her animals. She requests one chainsaw, please."
	reward = 2500
	wanted_types = list(
		/obj/item/chainsaw = TRUE,
	)

/datum/bounty/item/assistant/ied
	name = "IED"
	description = "Nanotrasen's maximum security prison at CentCom is undergoing personnel training. Ship a handful of IEDs to serve as a training tools."
	reward = 2000
	required_count = 3
	wanted_types = list(
		/obj/item/grenade/iedcasing = TRUE,
	)

/datum/bounty/item/assistant/bonfire
	name = "Lit Bonfire"
	description = "Portable thermomachines are malfunctioning and the cargo crew of Central Command is starting to feel cold. Ship a lit bonfire to warm them up."
	reward = 5000
	wanted_types = list(
		/obj/structure/bonfire = TRUE,
	)

/datum/bounty/item/assistant/bonfire/applies_to(obj/O)
	if(!..())
		return FALSE
	var/obj/structure/bonfire/B = O
	return !!B.burning

/datum/bounty/item/assistant/corgimeat
	name = "Raw Corgi Meat"
	description = "The Syndicate recently stole all of CentCom's Corgi meat. Ship out a replacement immediately."
	reward = 3000
	wanted_types = list(
		/obj/item/food/meat/slab/corgi = TRUE,
	)

/datum/bounty/item/assistant/corgifarming
	name = "Corgi Hides"
	description = "Admiral Weinstein's space yacht needs new upholstery. A dozen Corgi furs should do just fine."
	reward = 30000 //that's a lot of dead dogs
	required_count = 12
	wanted_types = list(
		/obj/item/stack/sheet/animalhide/corgi = TRUE,
	)

/datum/bounty/item/assistant/action_figures
	name = "Action Figures"
	description = "The vice president's son saw an ad for action figures on the telescreen and now he won't shut up about them. Ship some to ease his complaints."
	reward = 4000
	required_count = 5
	wanted_types = list(
		/obj/item/toy/figure = TRUE,
	)

/datum/bounty/item/assistant/tail_whip
	name = "Nine Tails whip"
	description = "Commander Jackson is looking for a fine addition to her exotic weapons collection. She will reward you handsomely for either a Cat or Liz o' Nine Tails."
	reward = 4000
	wanted_types = list(
		/obj/item/melee/chainofcommand/tailwhip = TRUE,
	)

/datum/bounty/item/assistant/dead_mice
	name = "Dead Mice"
	description = "Station 14 ran out of freeze-dried mice. Ship some fresh ones so their janitor doesn't go on strike."
	reward = 5000
	required_count = 5
	wanted_types = list(
		/obj/item/food/deadmouse = TRUE,
	)
