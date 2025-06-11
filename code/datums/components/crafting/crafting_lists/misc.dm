
/// Misc stuff crafting

/datum/crafting_recipe/spooky_camera
	name = "Camera Obscura"
	result = /obj/item/camera/spooky
	time = 1.5 SECONDS
	reqs = list(
		/obj/item/camera = 1,
		/datum/reagent/water/holywater = 10
	)
	parts = list(/obj/item/camera = 1)
	category = CAT_MISC

/datum/crafting_recipe/barbell
	name = "Barbell"
	result = /obj/item/barbell
	time = 2 SECONDS
	reqs = list(
		/obj/item/stack/sheet/iron = 4,
		/obj/item/stack/rods = 2,
	)
	category = CAT_MISC

/datum/crafting_recipe/chestpress
	name = "Chest press handle"
	result = /obj/item/barbell/stacklifting
	time = 2 SECONDS
	reqs = list(
		/obj/item/stack/sheet/iron = 4,
		/obj/item/stack/rods = 2,
	)
	category = CAT_MISC

/datum/crafting_recipe/skateboard
	name = "Skateboard"
	result = /obj/item/melee/skateboard
	time = 6 SECONDS
	reqs = list(
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/rods = 10
	)
	category = CAT_ENTERTAINMENT

/datum/crafting_recipe/scooter
	name = "Scooter"
	result = /obj/vehicle/ridden/scooter
	time = 6.5 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/rods = 12
	)
	category = CAT_ENTERTAINMENT

/datum/crafting_recipe/wheelchair
	name = "Wheelchair"
	result = /obj/vehicle/ridden/wheelchair
	time = 10 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	reqs = list(
		/obj/item/stack/sheet/iron = 4,
		/obj/item/stack/rods = 6
	)
	category = CAT_MISC

/datum/crafting_recipe/motorized_wheelchair
	name = "Motorized Wheelchair"
	result = /obj/vehicle/ridden/wheelchair/motorized
	time = 20 SECONDS
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WRENCH)
	reqs = list(
		/obj/item/stack/sheet/iron = 10,
		/obj/item/stack/rods = 8,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/capacitor = 1
	)
	parts = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/capacitor = 1
	)
	category = CAT_MISC

/datum/crafting_recipe/mousetrap
	name = "Mouse Trap"
	result = /obj/item/assembly/mousetrap
	time = 1 SECONDS
	reqs = list(
		/obj/item/stack/sheet/cardboard = 1,
		/obj/item/stack/rods = 1
	)
	category = CAT_MISC

/datum/crafting_recipe/papersack
	name = "Paper Sack"
	result = /obj/item/storage/box/papersack
	time = 1 SECONDS
	reqs = list(/obj/item/paper = 5)
	category = CAT_MISC

/datum/crafting_recipe/flashlight_eyes
	name = "Flashlight Eyes"
	result = /obj/item/organ/eyes/robotic/flashlight
	time = 1 SECONDS
	reqs = list(
		/obj/item/flashlight = 2,
		/obj/item/restraints/handcuffs/cable = 1
	)
	category = CAT_MISC

/datum/crafting_recipe/paperframes
	name = "Paper Frames"
	result = /obj/item/stack/sheet/paperframes
	result_amount = 5
	time = 1 SECONDS
	reqs = list(
		/obj/item/stack/sheet/wood = 2,
		/obj/item/paper = 10
	)
	category = CAT_MISC

/datum/crafting_recipe/naturalpaper
	name = "Hand-Pressed Paper Bundle"
	result = /obj/item/paper_bin/bundlenatural
	time = 3 SECONDS
	reqs = list(
		/datum/reagent/water = 50,
		/obj/item/stack/sheet/wood = 1
	)
	tool_paths = list(/obj/item/hatchet)
	category = CAT_MISC

/datum/crafting_recipe/toysword
	name = "Toy Sword"
	result = /obj/item/toy/sword
	time = 1 SECONDS
	reqs = list(
		/obj/item/light/bulb = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/plastic = 4
	)
	category = CAT_MISC

/datum/crafting_recipe/blackcarpet
	name = "Black Carpet"
	result = /obj/item/stack/tile/carpet/black
	result_amount = 50
	time = 0.5 SECONDS
	reqs = list(
		/obj/item/stack/tile/carpet = 50,
		/obj/item/toy/crayon/black = 1
	)
	category = CAT_MISC

/datum/crafting_recipe/extendohand
	name = "Extendo-Hand"
	result = /obj/item/extendohand
	time = 1 SECONDS
	reqs = list(
		/obj/item/bodypart/r_arm/robot = 1,
		/obj/item/clothing/gloves/boxing = 1
	)
	category = CAT_MISC

/datum/crafting_recipe/mothplush
	name = "Moth Plushie"
	result = /obj/item/toy/plush/moth
	time = 3 SECONDS
	reqs = list(
		/obj/item/stack/sheet/animalhide/mothroach = 1,
		/obj/item/stack/sheet/cotton/cloth = 3
	)
	category = CAT_MISC

/datum/crafting_recipe/gold_horn
	name = "Golden Bike Horn"
	result = /obj/item/bikehorn/golden
	time = 5 SECONDS
	reqs = list(
		/obj/item/stack/sheet/mineral/bananium = 5,
		/obj/item/bikehorn = 1
	)
	category = CAT_MISC

/datum/crafting_recipe/flash_ducky
	name = "Toy Rubber Duck Mine"
	result = /obj/item/deployablemine/traitor/toy
	time = 2 SECONDS
	reqs = list(
		/obj/item/bikehorn/rubberducky = 1,
		/obj/item/assembly/flash/handheld = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/assembly/prox_sensor
	)
	blacklist = list(/obj/item/assembly/flash/handheld/strong)
	category = CAT_MISC

/datum/crafting_recipe/pressureplate
	name = "Pressure Plate"
	result = /obj/item/pressure_plate
	time = 1 SECONDS
	reqs = list(
		/obj/item/stack/sheet/iron = 1,
		/obj/item/stack/tile/iron = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/assembly/igniter = 1
	)
	category = CAT_MISC

/datum/crafting_recipe/rcl
	name = "Makeshift Rapid Cable Layer"
	result = /obj/item/rcl/ghetto
	time = 4 SECONDS
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WRENCH)
	reqs = list(/obj/item/stack/sheet/iron = 15)
	category = CAT_MISC

/datum/crafting_recipe/aitater
	name = "intelliTater"
	result = /obj/item/aicard/aitater
	time = 3 SECONDS
	tool_behaviors = list(TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/aicard = 1,
		/obj/item/food/grown/potato = 1,
		/obj/item/stack/cable_coil = 5
	)
	category = CAT_MISC

/datum/crafting_recipe/aispook
	name = "intelliLantern"
	result = /obj/item/aicard/aispook
	time = 3 SECONDS
	tool_behaviors = list(TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/aicard = 1,
		/obj/item/food/grown/pumpkin = 1,
		/obj/item/stack/cable_coil = 5
	)
	category = CAT_MISC

/datum/crafting_recipe/ghettojetpack
	name = "Improvised Jetpack"
	result = /obj/item/tank/jetpack/improvised
	time = 7.5 SECONDS //this thing is complex
	tool_behaviors = list(TOOL_WRENCH, TOOL_WELDER, TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/tank/internals/oxygen/red = 2,//red oxygen tank so it looks right
		/obj/item/extinguisher = 1,
		/obj/item/pipe = 3,
		/obj/item/stack/cable_coil = 30
	)
	category = CAT_MISC

/datum/crafting_recipe/multiduct
	name = "Multi-layer duct"
	result = /obj/machinery/duct/multilayered
	time = 2.5 SECONDS
	tool_behaviors = list(TOOL_WELDER)
	reqs = list(/obj/item/stack/ducts = 5)
	category = CAT_MISC

/datum/crafting_recipe/upgraded_gauze
	name = "Improved Gauze"
	result = /obj/item/stack/medical/gauze/adv/one
	time = 1 SECONDS
	reqs = list(
		/obj/item/stack/medical/gauze = 1,
		/datum/reagent/space_cleaner/sterilizine = 10
	)
	category = CAT_MISC

/datum/crafting_recipe/bruise_pack
	name = "Bruise Pack"
	result = /obj/item/stack/medical/bruise_pack/one
	time = 1 SECONDS
	reqs = list(
		/obj/item/stack/medical/gauze = 1,
		/datum/reagent/medicine/styptic_powder = 20
	)
	category = CAT_MISC

/datum/crafting_recipe/burn_pack
	name = "Burn Ointment"
	result = /obj/item/stack/medical/ointment/one
	time = 1 SECONDS
	reqs = list(
		/obj/item/stack/medical/gauze = 1,
		/datum/reagent/medicine/silver_sulfadiazine = 20
	)
	category = CAT_MISC

/datum/crafting_recipe/poppy_pin
	name = "Poppy Pin"
	result = /obj/item/clothing/accessory/poppy_pin
	time = 0.5 SECONDS
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/food/grown/flower/poppy = 1
	)
	category = CAT_MISC

/datum/crafting_recipe/poppy_pin_removal
	name = "Poppy Pin Removal"
	result = /obj/item/food/grown/flower/poppy
	time = 0.5 SECONDS
	reqs = list(/obj/item/clothing/accessory/poppy_pin = 1)
	category = CAT_MISC

/datum/crafting_recipe/paper_cup
	name= "Paper Cup"
	result = /obj/item/reagent_containers/cup/glass/sillycup
	time = 1 SECONDS
	tool_behaviors = list(TOOL_WIRECUTTER)
	reqs = list(/obj/item/paper = 1)
	category = CAT_MISC

/datum/crafting_recipe/paperslip
	name = "Paper Slip"
	result = /obj/item/card/id/paper
	time = 1 SECONDS
	tool_behaviors = list(TOOL_WIRECUTTER)
	reqs = list(/obj/item/paper = 5)
	category = CAT_MISC

/datum/crafting_recipe/basic_lasso
	name= "Basic Lasso"
	result = /obj/item/mob_lasso
	time = 2 SECONDS
	reqs = list(/obj/item/stack/sheet/leather = 5)
	category = CAT_MISC

/datum/crafting_recipe/foldable
	name = "Foldable Chair"
	result = /obj/item/chair/foldable
	time = 4 SECONDS
	tool_behaviors = list(TOOL_WRENCH, TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/stack/rods = 2,
		/obj/item/stack/sheet/plastic = 1
	)
	category = CAT_MISC

/datum/crafting_recipe/chair_fancy
	name = "Fancy Chair"
	result = /obj/item/chair/fancy
	time = 6 SECONDS
	tool_behaviors = list(TOOL_WRENCH, TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/stack/rods = 2,
		/obj/item/chair = 1
	)
	category = CAT_MISC

/// banners

/datum/crafting_recipe/security_banner
	name = "Securistan Banner"
	result = /obj/item/banner/security/mundane
	time = 4 SECONDS
	reqs = list(
		/obj/item/stack/rods = 2,
		/obj/item/clothing/under/rank/security/officer = 1
	)
	category = CAT_MISC

/datum/crafting_recipe/medical_banner
	name = "Meditopia Banner"
	result = /obj/item/banner/medical/mundane
	time = 4 SECONDS
	reqs = list(
		/obj/item/stack/rods = 2,
		/obj/item/clothing/under/rank/medical/doctor = 1
	)
	category = CAT_MISC

/datum/crafting_recipe/science_banner
	name = "Sciencia Banner"
	result = /obj/item/banner/science/mundane
	time = 4 SECONDS
	reqs = list(
		/obj/item/stack/rods = 2,
		/obj/item/clothing/under/rank/rnd/scientist = 1
	)
	category = CAT_MISC

/datum/crafting_recipe/cargo_banner
	name = "Cargonia Banner"
	result = /obj/item/banner/cargo/mundane
	time = 4 SECONDS
	reqs = list(
		/obj/item/stack/rods = 2,
		/obj/item/clothing/under/rank/cargo/tech = 1
	)
	category = CAT_MISC

/datum/crafting_recipe/engineering_banner
	name = "Engitopia Banner"
	result = /obj/item/banner/engineering/mundane
	time = 4 SECONDS
	reqs = list(
		/obj/item/stack/rods = 2,
		/obj/item/clothing/under/rank/engineering/engineer = 1
	)
	category = CAT_MISC

/datum/crafting_recipe/command_banner
	name = "Command Banner"
	result = /obj/item/banner/command/mundane
	time = 4 SECONDS
	reqs = list(
		/obj/item/stack/rods = 2,
		/obj/item/clothing/under/rank/captain/parade = 1
	)
	category = CAT_MISC

/datum/crafting_recipe/picket_sign
	name = "Picket Sign"
	result = /obj/item/picket_sign
	time = 6 SECONDS
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/stack/sheet/cardboard = 2
	)
	category = CAT_MISC
