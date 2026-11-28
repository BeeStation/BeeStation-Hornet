///////////////////////////////////
//////////Autolathe Designs ///////
///////////////////////////////////

/datum/design/bucket
	name = "Bucket"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 200)
	build_path = /obj/item/reagent_containers/cup/bucket
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_JANITORIAL)
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/mop
	name = "Mop"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/mop
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_JANITORIAL)
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/broom
	name = "Push Broom"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/pushbroom
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_JANITORIAL)
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/crowbar
	name = "Pocket Crowbar"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50)
	build_path = /obj/item/crowbar
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/flashlight
	name = "Flashlight"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 20)
	build_path = /obj/item/flashlight
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)

/datum/design/extinguisher
	name = "Fire Extinguisher"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 90)
	build_path = /obj/item/extinguisher
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)

/datum/design/pocketfireextinguisher
	name = "Pocket Fire Extinguisher"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 40)
	build_path = /obj/item/extinguisher/mini
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)

/datum/design/multitool
	name = "Multitool"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 20)
	build_path = /obj/item/multitool
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/analyzer
	name = "Analyzer"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 30, /datum/material/glass = 20)
	build_path = /obj/item/analyzer
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/tscanner
	name = "T-Ray Scanner"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 150)
	build_path = /obj/item/t_scanner
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/weldingtool
	name = "Welding Tool"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 70, /datum/material/glass = 20)
	build_path = /obj/item/weldingtool
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/mini_weldingtool
	name = "Emergency Welding Tool"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 30, /datum/material/glass = 10)
	build_path = /obj/item/weldingtool/mini
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)

/datum/design/screwdriver
	name = "Screwdriver"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 75)
	build_path = /obj/item/screwdriver
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/wirecutters
	name = "Wirecutters"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 80)
	build_path = /obj/item/wirecutters
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/wrench
	name = "Wrench"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 150)
	build_path = /obj/item/wrench
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/plunger
	name = "Plunger"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 150)
	build_path = /obj/item/plunger
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_JANITORIAL)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/welding_helmet
	name = "Welding Helmet"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 1750, /datum/material/glass = 400)
	build_path = /obj/item/clothing/head/utility/welding
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_ENGINEERING)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/cable_coil
	name = "Cable Coil (x5)"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 25)
	build_path = /obj/item/stack/cable_coil/five
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/toolbox
	name = "Toolbox"
	build_type = AUTOLATHE
	materials = list(MAT_CATEGORY_RIGID = 500)
	build_path = /obj/item/storage/toolbox
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)

/datum/design/apc_board
	name = "APC Module"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/glass = 100)
	build_path = /obj/item/electronics/apc
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ELECTRONICS)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/airlock_board
	name = "Airlock Electronics"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 50)
	build_path = /obj/item/electronics/airlock
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ELECTRONICS)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/firelock_board
	name = "Firelock Circuitry"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 50)
	build_path = /obj/item/electronics/firelock
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ELECTRONICS)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/airalarm_electronics
	name = "Air Alarm Electronics"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 50)
	build_path = /obj/item/electronics/airalarm
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ELECTRONICS)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/firealarm_electronics
	name = "Fire Alarm Electronics"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 50)
	build_path = /obj/item/electronics/firealarm
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ELECTRONICS)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/camera
	name = "Camera"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 100)
	build_path = /obj/item/camera
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_MEDIA)

/datum/design/camera_film
	name = "Camera Film Cartridge"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 10, /datum/material/glass = 10)
	build_path = /obj/item/camera_film
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_MEDIA)

/datum/design/earmuffs
	name = "Earmuffs"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/clothing/ears/earmuffs
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_SUPPLY)

/datum/design/pipe_painter
	name = "Pipe Painter"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2000)
	build_path = /obj/item/pipe_painter
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/airlock_painter
	name = "Airlock Painter"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 50)
	build_path = /obj/item/airlock_painter
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/airlock_painter/decal/tile
	name = "Tile Sprayer"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 50)
	build_path = /obj/item/airlock_painter/decal/tile
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SERVICE

/datum/design/emergency_oxygen
	name = "Emergency Oxygen Tank"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 500)
	build_path = /obj/item/tank/internals/emergency_oxygen/empty
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_GAS_TANKS)

/datum/design/emergency_oxygen_engi
	name = "Extended-Capacity Emergency Oxygen Tank"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 750)
	build_path = /obj/item/tank/internals/emergency_oxygen/engi/empty
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_GAS_TANKS)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_CARGO

/datum/design/plasmaman_tank
	name = "Extended-Capacity Plasmaman Tank"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 3200)
	build_path = /obj/item/tank/internals/plasmaman/empty
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_GAS_TANKS)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_CARGO

/datum/design/plasmaman_tank_belt
	name = "Plasmaman Belt Tank"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 800)
	build_path = /obj/item/tank/internals/plasmaman/belt/empty
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_GAS_TANKS)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_CARGO

/datum/design/iron
	name = "Iron"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/iron
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MATERIAL)

/datum/design/glass
	name = "Glass"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/glass
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MATERIAL)

/datum/design/rglass
	name = "Reinforced Glass"
	build_type = AUTOLATHE | SMELTER | PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/rglass
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MATERIAL)

/datum/design/rods
	name = "Iron Rod"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/stack/rods
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MATERIAL)

/datum/design/rcd_ammo
	name = "Compressed Matter Cartridge"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 12000, /datum/material/glass = 8000)
	build_path = /obj/item/rcd_ammo
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MATERIAL)

/datum/design/kitchen_knife
	name = "Kitchen Knife"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 12000)
	build_path = /obj/item/knife/kitchen
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_DINNERWARE)

/datum/design/fork
	name = "Fork"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 80)
	build_path = /obj/item/kitchen/fork
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_DINNERWARE)

/datum/design/spoon
	name = "Spoon"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 80)
	build_path = /obj/item/kitchen/spoon
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_DINNERWARE)

/datum/design/tray
	name = "Serving Tray"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 3000)
	build_path = /obj/item/storage/bag/tray
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_DINNERWARE)

/datum/design/plate
	name = "Plate"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 3500)
	build_path = /obj/item/plate
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_DINNERWARE)

/datum/design/bowl
	name = "Bowl"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = 500)
	build_path = /obj/item/reagent_containers/cup/bowl
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_DINNERWARE)

/datum/design/drinking_glass
	name = "Drinking Glass"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = 500)
	build_path = /obj/item/reagent_containers/cup/glass/drinkingglass
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_DINNERWARE)

/datum/design/shot_glass
	name = "Shot Glass"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = 100)
	build_path = /obj/item/reagent_containers/cup/glass/drinkingglass/shotglass
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_DINNERWARE)

/datum/design/shaker
	name = "Shaker"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1500)
	build_path = /obj/item/reagent_containers/cup/glass/shaker
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_DINNERWARE)

/datum/design/cultivator
	name = "Cultivator"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron=50)
	build_path = /obj/item/cultivator
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_BOTANY)
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/plant_analyzer
	name = "Plant Analyzer"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 30, /datum/material/glass = 20)
	build_path = /obj/item/plant_analyzer
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_BOTANY)
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/shovel
	name = "Shovel"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50)
	build_path = /obj/item/shovel
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_BOTANY)
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/spade
	name = "Spade"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50)
	build_path = /obj/item/shovel/spade
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_BOTANY)
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/hatchet
	name = "Hatchet"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 15000)
	build_path = /obj/item/hatchet
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_BOTANY)
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/foilhat
	name = "Tinfoil Hat"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 5500)
	build_path = /obj/item/clothing/head/costume/foilhat
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_TOYS)

/datum/design/blood_filter
	name = "Blood Filter"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 1500, /datum/material/silver = 500)
	build_path = /obj/item/blood_filter
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MEDICAL)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/scalpel
	name = "Scalpel"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 1000)
	build_path = /obj/item/scalpel
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MEDICAL)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/circular_saw
	name = "Circular Saw"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 6000)
	build_path = /obj/item/circular_saw
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MEDICAL)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/surgicaldrill
	name = "Surgical Drill"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 6000)
	build_path = /obj/item/surgicaldrill
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MEDICAL)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/retractor
	name = "Retractor"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 6000, /datum/material/glass = 3000)
	build_path = /obj/item/retractor
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MEDICAL)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/cautery
	name = "Cautery"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 750)
	build_path = /obj/item/cautery
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MEDICAL)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/hemostat
	name = "Hemostat"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2500)
	build_path = /obj/item/hemostat
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MEDICAL)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/beaker
	name = "Beaker"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/glass = 500)
	build_path = /obj/item/reagent_containers/cup/beaker
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MEDICAL + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SERVICE

/datum/design/large_beaker
	name = "Large Beaker"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/glass = 2500)
	build_path = /obj/item/reagent_containers/cup/beaker/large
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MEDICAL + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SERVICE

/datum/design/healthanalyzer
	name = "Health Analyzer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 50)
	build_path = /obj/item/healthanalyzer
	category = list(RND_CATEGORY_MEDICAL + RND_SUBCATEGORY_MEDICAL_TOOLS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/pillbottle
	name = "Pill Bottle"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 20, /datum/material/glass = 100)
	build_path = /obj/item/storage/pill_bottle
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MEDICAL + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/hacksaw
	name = "Hacksaw"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron=12000)
	build_path = /obj/item/hacksaw
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MEDICAL)

/datum/design/beanbag_slug
	name = "Beanbag Slug"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/ammo_casing/shotgun/beanbag
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_SECURITY + RND_SUBCATEGORY_SECURITY_AMMO)

/datum/design/rubbershot
	name = "Rubber Shot"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 4000)
	build_path = /obj/item/ammo_casing/shotgun/rubbershot
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_SECURITY + RND_SUBCATEGORY_SECURITY_AMMO)

/datum/design/c38b
	name = "Speed Loader (.38 Rubber)"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 16000)
	build_path = /obj/item/ammo_box/c38/match/bouncy
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_SECURITY + RND_SUBCATEGORY_SECURITY_AMMO)

/datum/design/recorder
	name = "Universal Recorder"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 60, /datum/material/glass = 30)
	build_path = /obj/item/taperecorder/empty
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_MEDIA)

/datum/design/tape
	name = "Cassette Tape"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 20, /datum/material/glass = 5)
	build_path = /obj/item/tape/random
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_MEDIA)

/datum/design/igniter
	name = "Igniter"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 50)
	build_path = /obj/item/assembly/igniter
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_ASSEMBLIES)

/datum/design/signaler
	name = "Remote Signaling Device"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 400, /datum/material/glass = 120)
	build_path = /obj/item/assembly/signaler
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TELECOMMS)

/datum/design/radio_headset
	name = "Radio Headset"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 75)
	build_path = /obj/item/radio/headset
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TELECOMMS)

/datum/design/bounced_radio
	name = "Station Bounced Radio"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 75, /datum/material/glass = 25)
	build_path = /obj/item/radio/off
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TELECOMMS)

/datum/design/intercom_frame
	name = "Intercom Frame"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 75, /datum/material/glass = 25)
	build_path = /obj/item/wallframe/intercom
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TELECOMMS)

/datum/design/infrared_emitter
	name = "Infrared Emitter"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500)
	build_path = /obj/item/assembly/infra
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_ASSEMBLIES)

/datum/design/health_sensor
	name = "Health Sensor"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 800, /datum/material/glass = 200)
	build_path = /obj/item/assembly/health
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_ASSEMBLIES)

/datum/design/timer
	name = "Timer"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 50)
	build_path = /obj/item/assembly/timer
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_ASSEMBLIES)

/datum/design/voice_analyser
	name = "Voice Analyser"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 50)
	build_path = /obj/item/assembly/voice
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_ASSEMBLIES)

/datum/design/light_tube
	name = "Light Tube"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = 100)
	build_path = /obj/item/light/tube
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_LIGHTING)

/datum/design/light_bulb
	name = "Light Bulb"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = 100)
	build_path = /obj/item/light/bulb
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_LIGHTING)

/datum/design/camera_assembly
	name = "Camera Assembly"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 400, /datum/material/glass = 250)
	build_path = /obj/item/wallframe/camera
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MOUNTS)

/datum/design/newscaster_frame
	name = "Newscaster Frame"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 14000, /datum/material/glass = 8000)
	build_path = /obj/item/wallframe/newscaster
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MOUNTS)

/datum/design/syringe
	name = "Syringe"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 10, /datum/material/glass = 20)
	build_path = /obj/item/reagent_containers/syringe
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MEDICAL + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/dropper
	name = "Dropper"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 10, /datum/material/glass = 30)
	build_path = /obj/item/reagent_containers/dropper
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MEDICAL + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/prox_sensor
	name = "Proximity Sensor"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 800, /datum/material/glass = 200)
	build_path = /obj/item/assembly/prox_sensor
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_ASSEMBLIES)

/datum/design/foam_dart
	name = "Box of Foam Darts"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500)
	build_path = /obj/item/ammo_box/foambox
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_TOYS)

//hacked autolathe recipes
/datum/design/flamethrower
	name = "Flamethrower"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500)
	build_path = /obj/item/flamethrower/full
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_SECURITY + RND_SUBCATEGORY_SECURITY_WEAPON_PARTS)

/datum/design/electropack
	name = "Electropack"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2500)
	build_path = /obj/item/electropack
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)

/datum/design/large_welding_tool
	name = "Industrial Welding Tool"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 70, /datum/material/glass = 60)
	build_path = /obj/item/weldingtool/largetank
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)

/datum/design/handcuffs
	name = "Handcuffs"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500)
	build_path = /obj/item/restraints/handcuffs
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_SECURITY + RND_SUBCATEGORY_SECURITY_GEAR)

/datum/design/receiver
	name = "Modular Receiver"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 15000)
	build_path = /obj/item/weaponcrafting/receiver
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_SECURITY + RND_SUBCATEGORY_SECURITY_WEAPON_PARTS)

/datum/design/shotgun_slug
	name = "Shotgun Slug"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/copper = 500)
	build_path = /obj/item/ammo_casing/shotgun
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_SECURITY + RND_SUBCATEGORY_SECURITY_AMMO)

/datum/design/buckshot_shell
	name = "Buckshot Shell"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/copper = 500)
	build_path = /obj/item/ammo_casing/shotgun/buckshot
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_SECURITY + RND_SUBCATEGORY_SECURITY_AMMO)

/datum/design/buckshot_armour_shell
	name = "Armour-Piercing Buckshot Shell"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/gold = 500)
	build_path = /obj/item/ammo_casing/shotgun/buckshot/armour_piercing
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_SECURITY + RND_SUBCATEGORY_SECURITY_AMMO)

/datum/design/shotgun_dart
	name = "Shotgun Dart"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/silver = 2000)
	build_path = /obj/item/ammo_casing/shotgun/dart
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_SECURITY + RND_SUBCATEGORY_SECURITY_AMMO)

/datum/design/incendiary_slug
	name = "Incendiary Slug"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/plasma = 500)
	build_path = /obj/item/ammo_casing/shotgun/incendiary
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_SECURITY + RND_SUBCATEGORY_SECURITY_AMMO)

/datum/design/riot_dart
	name = "Foam Riot Dart"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1000) //Discount for making individually - no box = less metal!
	build_path = /obj/item/ammo_casing/caseless/foam_dart/riot
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_SECURITY + RND_SUBCATEGORY_SECURITY_AMMO)

/datum/design/riot_darts
	name = "Foam Riot Dart Box"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 50000) //Comes with 40 darts
	build_path = /obj/item/ammo_box/foambox/riot
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_SECURITY + RND_SUBCATEGORY_SECURITY_AMMO)

/datum/design/a357
	name = ".357 Casing"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 4000)
	build_path = /obj/item/ammo_casing/a357
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_SECURITY + RND_SUBCATEGORY_SECURITY_AMMO)

/datum/design/c10mm
	name = "Ammo Box (10mm)"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 30000)
	build_path = /obj/item/ammo_box/c10mm
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_SECURITY + RND_SUBCATEGORY_SECURITY_AMMO)

/datum/design/c45
	name = "Ammo Box (.45)"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 30000)
	build_path = /obj/item/ammo_box/c45
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_SECURITY + RND_SUBCATEGORY_SECURITY_AMMO)

/datum/design/c9mm
	name = "Ammo Box (9mm)"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 30000)
	build_path = /obj/item/ammo_box/c9mm
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_SECURITY + RND_SUBCATEGORY_SECURITY_AMMO)

/datum/design/c38
	name = "Speed Loader (.38)"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 20000)
	build_path = /obj/item/ammo_box/c38
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_SECURITY + RND_SUBCATEGORY_SECURITY_AMMO)

/datum/design/cleaver
	name = "Butcher's Cleaver"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 18000)
	build_path = /obj/item/knife/butcher
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_DINNERWARE)

/datum/design/spraycan
	name = "Spraycan"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/glass = 100)
	build_path = /obj/item/toy/crayon/spraycan
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_JANITORIAL)

/datum/design/dest_tagger
	name = "Destination Tagger"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 250, /datum/material/glass = 125)
	build_path = /obj/item/dest_tagger
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ELECTRONICS)

/datum/design/salestagger
	name = "Sales Tagger"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 700, /datum/material/glass = 200)
	build_path = /obj/item/sales_tagger
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ELECTRONICS)
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SERVICE

/datum/design/handlabeler
	name = "Hand Labeler"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 150, /datum/material/glass = 125)
	build_path = /obj/item/hand_labeler
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ELECTRONICS)

/datum/design/geiger
	name = "Geiger Counter"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 150, /datum/material/glass = 150)
	build_path = /obj/item/geiger_counter
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)

/datum/design/turret_control_frame
	name = "Turret Control Frame"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 12000)
	build_path = /obj/item/wallframe/turret_control
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MOUNTS)

/datum/design/conveyor_belt
	name = "Conveyor Belt"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 3000)
	build_path = /obj/item/stack/conveyor
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ELECTRONICS)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/conveyor_switch
	name = "Conveyor Belt Switch"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 450, /datum/material/glass = 190)
	build_path = /obj/item/conveyor_switch_construct
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ELECTRONICS)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/laptop
	name = "Laptop Frame"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 1000)
	build_path = /obj/item/modular_computer/laptop
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MODULAR_COMPUTERS + RND_SUBCATEGORY_MODULAR_COMPUTERS_FRAMES)

/datum/design/tablet
	name = "Tablet Frame"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	build_path = /obj/item/modular_computer/tablet
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MODULAR_COMPUTERS + RND_SUBCATEGORY_MODULAR_COMPUTERS_FRAMES)

/datum/design/slime_scanner
	name = "Slime Scanner"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 200)
	build_path = /obj/item/slime_scanner
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SCIENCE)

/datum/design/pet_carrier
	name = "Pet Carrier"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 7500, /datum/material/glass = 100)
	build_path = /obj/item/pet_carrier
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_SUPPLY)

/datum/design/miniature_power_cell
	name = "Light Fixture Battery"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = 20)
	build_path = /obj/item/stock_parts/cell/emergency_light
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ELECTRONICS)

/datum/design/package_wrap
	name = "Package Wrapping"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/glass = 200)
	build_path = /obj/item/stack/package_wrap
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_SUPPLY, RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SERVICE)

/datum/design/holodisk
	name = "Holodisk"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/glass = 100)
	build_path = /obj/item/disk/holodisk
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_MEDIA)

/datum/design/circuit
	name = "Blue Circuit Tile"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/stack/tile/circuit
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_TILES)

/datum/design/circuitgreen
	name = "Green Circuit Tile"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/stack/tile/circuit/green
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_TILES)

/datum/design/circuitred
	name = "Red Circuit Tile"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/stack/tile/circuit/red
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_TILES)

/datum/design/price_tagger
	name = "Price Tagger"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1500, /datum/material/glass = 500)
	build_path = /obj/item/price_tagger
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_SUPPLY)

/datum/design/custom_vendor_refill
	name = "Custom Vendor Refill"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2000)
	build_path = /obj/item/vending_refill/custom
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_SUPPLY)

/datum/design/custom_vendor_board
	name = "Custom Vendor Machine Board"
	build_type = AUTOLATHE
	build_path = /obj/item/circuitboard/machine/vendor
	materials = list(/datum/material/iron = 100, /datum/material/glass = 100)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_SUPPLY)

/datum/design/toygun
	name = "Cap Gun"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/glass = 50)
	build_path = /obj/item/toy/gun
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_TOYS)

/datum/design/capbox
	name = "Box of Cap Gun Shots"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 20, /datum/material/glass = 5)
	build_path = /obj/item/toy/ammo/gun
	category = list(RND_CATEGORY_HACKED, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_TOYS)

/datum/design/ducts
	name = "Fluid Ducts"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500)
	build_path = /obj/item/stack/ducts
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MACHINERY)

/datum/design/airlock_painter/decal
	name = "Decal Painter"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 50)
	build_path = /obj/item/airlock_painter/decal
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)

/datum/design/cautionsign
	name = "Wet Floor Sign"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 50)
	build_path = /obj/item/clothing/suit/caution
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_SUPPLY)

/datum/design/control
	name = "Blast Door Controller"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/glass = 50)
	build_path = /obj/item/assembly/control
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MISC + RND_SUBCATEGORY_MISC_ASSEMBLIES)

/datum/design/digital_clock_frame
	name = "Digital Clock Frame"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 700, /datum/material/glass = 400)
	build_path = /obj/item/wallframe/digital_clock
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MOUNTS)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SERVICE

/datum/design/potion
	name = "Potion Bottle"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = 500)
	build_path = /obj/item/reagent_containers/cup/bottle/big_potion
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MEDICAL + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/small_potion
	name = "Small Potion Bottle"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = 200)
	build_path = /obj/item/reagent_containers/cup/bottle/small_potion
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MEDICAL + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/vial
	name = "Potion Vial"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = 100)
	build_path = /obj/item/reagent_containers/cup/bottle/vial
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_MEDICAL + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/duct_tape
	name = "Duct Tape"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/plastic = 200)
	build_path = /obj/item/stack/sticky_tape/duct
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SERVICE
