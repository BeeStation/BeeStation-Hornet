/**
 * # Tools Cargo Items
 *
 * Hand tools, engineering tools, hydroponics tools, janitorial tools, and utility items.
 * Split into Hand Tools, Engineering Tools, Janitorial, Hydroponics Tools, and Forensics.
 */

// =============================================================================
// HAND TOOLS
// =============================================================================

/datum/cargo_item/tools_hand
	category = "Tools"
	subcategory = "Hand Tools"

/datum/cargo_item/tools_hand/screwdriver
	name = "Screwdriver"
	item_path = /obj/item/screwdriver
	cost = 7
	max_supply = 8
	small_item = TRUE

/datum/cargo_item/tools_hand/wrench
	name = "Wrench"
	item_path = /obj/item/wrench
	cost = 10
	max_supply = 8
	small_item = TRUE

/datum/cargo_item/tools_hand/weldingtool
	name = "Welding Tool"
	item_path = /obj/item/weldingtool
	cost = 40
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/tools_hand/crowbar
	name = "Crowbar"
	item_path = /obj/item/crowbar
	cost = 12
	max_supply = 8
	small_item = TRUE

/datum/cargo_item/tools_hand/wirecutters
	name = "Wirecutters"
	item_path = /obj/item/wirecutters
	cost = 10
	max_supply = 8
	small_item = TRUE

/datum/cargo_item/tools_hand/multitool
	name = "Multitool"
	item_path = /obj/item/multitool
	cost = 75
	max_supply = 2
	small_item = TRUE

/datum/cargo_item/tools_hand/t_scanner
	name = "T-Scanner"
	item_path = /obj/item/t_scanner
	cost = 150
	max_supply = 1
	small_item = TRUE

/datum/cargo_item/tools_hand/toolbox_electrical
	name = "Electrical Toolbox"
	item_path = /obj/item/storage/toolbox/electrical
	cost = 250
	max_supply = 2
	small_item = TRUE

/datum/cargo_item/tools_hand/toolbox_mechanical
	name = "Mechanical Toolbox"
	item_path = /obj/item/storage/toolbox/mechanical
	cost = 250
	max_supply = 2
	small_item = TRUE

// =============================================================================
// ENGINEERING TOOLS
// =============================================================================

/datum/cargo_item/tools_engineering
	category = "Tools"
	subcategory = "Engineering Tools"
	access_budget = ACCESS_ENGINE_EQUIP

/datum/cargo_item/tools_engineering/utility_belt
	name = "Utility Belt"
	item_path = /obj/item/storage/belt/utility
	cost = 350
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/tools_engineering/hardhat
	name = "Hard Hat"
	item_path = /obj/item/clothing/head/utility/hardhat
	cost = 50
	max_supply = 6
	small_item = TRUE

/datum/cargo_item/tools_engineering/welding_helmet
	name = "Welding Helmet"
	item_path = /obj/item/clothing/head/utility/welding
	cost = 100
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/tools_engineering/meson
	name = "Meson Goggles"
	item_path = /obj/item/clothing/glasses/meson/engine
	cost = 300
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/tools_engineering/insulated_gloves
	name = "Insulated Gloves"
	item_path = /obj/item/clothing/gloves/color/yellow
	cost = 500
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/tools_engineering/sealant
	name = "Sealant"
	item_path = /obj/item/sealant
	cost = 150
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/tools_engineering/inducer
	name = "Inducer"
	item_path = /obj/item/inducer
	cost = 800
	max_supply = 2
	small_item = TRUE

/datum/cargo_item/tools_engineering/rcd
	name = "Rapid Construction Device"
	item_path = /obj/item/construction/rcd
	cost = 1500
	max_supply = 2
	small_item = TRUE

/datum/cargo_item/tools_engineering/rcd_ammo
	name = "RCD Ammo Cartridge"
	item_path = /obj/item/rcd_ammo
	cost = 300
	max_supply = 6
	small_item = TRUE

// =============================================================================
// JANITORIAL TOOLS
// =============================================================================

/datum/cargo_item/tools_janitor
	category = "Tools"
	subcategory = "Janitorial"
	access_budget = ACCESS_JANITOR

/datum/cargo_item/tools_janitor/mop
	name = "Mop"
	item_path = /obj/item/mop
	cost = 50
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/tools_janitor/bucket
	name = "Bucket"
	item_path = /obj/item/reagent_containers/cup/bucket
	cost = 30
	max_supply = 6
	small_item = TRUE

/datum/cargo_item/tools_janitor/pushbroom
	name = "Push Broom"
	item_path = /obj/item/pushbroom
	cost = 50
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/tools_janitor/trash_bag
	name = "Trash Bag"
	item_path = /obj/item/storage/bag/trash
	cost = 30
	max_supply = 6
	small_item = TRUE

/datum/cargo_item/tools_janitor/spray_cleaner
	name = "Space Cleaner Spray"
	item_path = /obj/item/reagent_containers/spray/cleaner
	cost = 75
	max_supply = 5
	small_item = TRUE

/datum/cargo_item/tools_janitor/wet_sign
	name = "Wet Floor Sign"
	item_path = /obj/item/clothing/suit/caution
	cost = 20
	max_supply = 6
	small_item = TRUE

/datum/cargo_item/tools_janitor/cleaner_grenade
	name = "Cleaning Grenade"
	item_path = /obj/item/grenade/chem_grenade/cleaner
	cost = 150
	max_supply = 6
	small_item = TRUE

/datum/cargo_item/tools_janitor/noslip_tiles
	name = "Non-Slip Floor Tiles (30)"
	item_path = /obj/item/stack/tile/noslip/thirty
	cost = 500
	max_supply = 6

/datum/cargo_item/tools_janitor/janicart
	name = "Janitorial Cart"
	item_path = /obj/structure/janitorialcart
	cost = 700
	max_supply = 2
	crate_type = /obj/structure/closet/crate/large

/datum/cargo_item/tools_janitor/watertank
	name = "Janitor Backpack Water Tank"
	item_path = /obj/item/watertank/janitor
	cost = 1500
	max_supply = 2

// =============================================================================
// HYDROPONICS TOOLS
// =============================================================================

/datum/cargo_item/tools_hydro
	category = "Tools"
	subcategory = "Hydroponics Tools"
	access_budget = ACCESS_HYDROPONICS

/datum/cargo_item/tools_hydro/hatchet
	name = "Hatchet"
	item_path = /obj/item/hatchet
	cost = 50
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/tools_hydro/cultivator
	name = "Cultivator"
	item_path = /obj/item/cultivator
	cost = 30
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/tools_hydro/plant_analyzer
	name = "Plant Analyzer"
	item_path = /obj/item/plant_analyzer
	cost = 50
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/tools_hydro/plantbgone
	name = "Plant-B-Gone Spray"
	item_path = /obj/item/reagent_containers/spray/plantbgone
	cost = 75
	max_supply = 6
	small_item = TRUE

/datum/cargo_item/tools_hydro/botanic_gloves
	name = "Botanical Leather Gloves"
	item_path = /obj/item/clothing/gloves/botanic_leather
	cost = 100
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/tools_hydro/watertank
	name = "Hydroponics Water Tank"
	item_path = /obj/item/watertank
	cost = 1000
	max_supply = 2

// =============================================================================
// FORENSICS & DETECTION
// =============================================================================

/datum/cargo_item/tools_forensics
	category = "Tools"
	subcategory = "Forensics & Detection"
	access_budget = ACCESS_SECURITY

/datum/cargo_item/tools_forensics/detective_scanner
	name = "Detective Scanner"
	item_path = /obj/item/detective_scanner
	cost = 400
	max_supply = 2
	small_item = TRUE

/datum/cargo_item/tools_forensics/healthanalyzer
	name = "Health Analyzer"
	item_path = /obj/item/healthanalyzer
	cost = 200
	max_supply = 4
	small_item = TRUE
	access_budget = ACCESS_MEDICAL

/datum/cargo_item/tools_forensics/geiger
	name = "Geiger Counter"
	item_path = /obj/item/geiger_counter
	cost = 100
	max_supply = 4
	small_item = TRUE
	access_budget = FALSE

/datum/cargo_item/tools_forensics/export_scanner
	name = "Export Scanner"
	item_path = /obj/item/export_scanner
	cost = 100
	max_supply = 3
	small_item = TRUE
	access_budget = FALSE

// =============================================================================
// CARGO & SERVICE TOOLS
// =============================================================================

/datum/cargo_item/tools_cargo
	category = "Tools"
	subcategory = "Cargo & Service"

/datum/cargo_item/tools_cargo/stamp
	name = "Rubber Stamp"
	item_path = /obj/item/stamp
	cost = 30
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/tools_cargo/stamp_denied
	name = "Denied Stamp"
	item_path = /obj/item/stamp/denied
	cost = 30
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/tools_cargo/dest_tagger
	name = "Destination Tagger"
	item_path = /obj/item/dest_tagger
	cost = 50
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/tools_cargo/hand_labeler
	name = "Hand Labeler"
	item_path = /obj/item/hand_labeler
	cost = 50
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/tools_cargo/package_wrap
	name = "Package Wrapping"
	item_path = /obj/item/stack/package_wrap
	cost = 30
	max_supply = 6
	small_item = TRUE

/datum/cargo_item/tools_cargo/lightbulbs
	name = "Light Bulb Box"
	item_path = /obj/item/storage/box/lights/mixed
	cost = 100
	max_supply = 8
	small_item = TRUE

/datum/cargo_item/tools_cargo/minerkit
	name = "Mining Conscription Kit"
	item_path = /obj/item/storage/backpack/duffelbag/mining_conscript
	cost = 2000
	max_supply = 2
	access_budget = ACCESS_MINING

// =============================================================================
// TOOL PACKS (CRATES)
// =============================================================================

/datum/cargo_crate/tools
	category = "Tools"
	subcategory = "Tool Packs"

/datum/cargo_crate/tools/janitor
	name = "Janitorial Supplies Crate"
	desc = "Contains a full set of janitorial supplies."
	cost = 1500
	max_supply = 2
	access_budget = ACCESS_JANITOR
	contains = list(
		/obj/item/reagent_containers/cup/bucket,
		/obj/item/reagent_containers/cup/bucket,
		/obj/item/reagent_containers/cup/bucket,
		/obj/item/mop,
		/obj/item/pushbroom,
		/obj/item/clothing/suit/caution,
		/obj/item/clothing/suit/caution,
		/obj/item/clothing/suit/caution,
		/obj/item/storage/bag/trash,
		/obj/item/reagent_containers/spray/cleaner,
		/obj/item/reagent_containers/cup/rag,
		/obj/item/grenade/chem_grenade/cleaner,
		/obj/item/grenade/chem_grenade/cleaner,
		/obj/item/grenade/chem_grenade/cleaner,
	)

/datum/cargo_crate/tools/forensics
	name = "Forensics Crate"
	desc = "Contains a detective scanner, evidence bags, camera, tape recorder, chalk, and a hat."
	cost = 2000
	max_supply = 2
	access_budget = ACCESS_SECURITY
	contains = list(
		/obj/item/detective_scanner,
		/obj/item/storage/box/evidence,
		/obj/item/camera/detective,
		/obj/item/taperecorder,
		/obj/item/toy/crayon/white,
		/obj/item/clothing/head/fedora/det_hat,
	)
	crate_type = /obj/structure/closet/crate/secure/gear

/datum/cargo_crate/tools/hydro_supplies
	name = "Hydroponics Supply Crate"
	desc = "Contains Plant-B-Gone sprays, ammonia bottles, a hatchet, cultivator, plant analyzer, gloves, apron, and gene disks."
	cost = 1500
	max_supply = 2
	access_budget = ACCESS_HYDROPONICS
	contains = list(
		/obj/item/reagent_containers/spray/plantbgone,
		/obj/item/reagent_containers/spray/plantbgone,
		/obj/item/reagent_containers/cup/bottle/ammonia,
		/obj/item/reagent_containers/cup/bottle/ammonia,
		/obj/item/hatchet,
		/obj/item/cultivator,
		/obj/item/plant_analyzer,
		/obj/item/clothing/gloves/botanic_leather,
		/obj/item/clothing/suit/apron,
		/obj/item/storage/box/disks_plantgene,
	)
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/cargo_crate/tools/minerkit
	name = "Mining Conscription Kit"
	desc = "A duffelbag containing mining equipment for conscripted miners."
	cost = 2000
	max_supply = 2
	access_budget = ACCESS_MINING
	contains = list(/obj/item/storage/backpack/duffelbag/mining_conscript)
