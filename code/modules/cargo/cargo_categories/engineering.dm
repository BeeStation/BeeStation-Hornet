/**
 * # Engineering Cargo Items
 *
 * Individual items orderable under the "Engineering" category.
 */

/datum/cargo_item/engineering
	category = "Engineering"
	access_budget = ACCESS_ENGINE_EQUIP

// --- Tools ---

/datum/cargo_item/engi_tools
	category = "Tools - Engineering"

/datum/cargo_item/engi_tools/toolbox_electrical
	name = "Electrical Toolbox"
	item_path = /obj/item/storage/toolbox/electrical
	cost = 250
	max_supply = 2
	small_item = TRUE

/datum/cargo_item/engi_tools/toolbox_mechanical
	name = "Mechanical Toolbox"
	item_path = /obj/item/storage/toolbox/mechanical
	cost = 250
	max_supply = 2
	small_item = TRUE

// Individual engineering tools available from cargo
/datum/cargo_item/engi_tools/screwdriver
	name = "Screwdriver"
	item_path =  /obj/item/screwdriver
	cost = 7
	max_supply = 8
	small_item = TRUE

/datum/cargo_item/engi_tools/wrench
	name = "Wrench"
	item_path = /obj/item/wrench
	cost = 10
	max_supply = 8
	small_item = TRUE

/datum/cargo_item/engi_tools/weldingtool
	name = "Welding Tool"
	item_path = /obj/item/weldingtool
	cost = 40
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/engi_tools/crowbar
	name = "Crowbar"
	item_path = /obj/item/crowbar
	cost = 12
	max_supply = 8
	small_item = TRUE

/datum/cargo_item/engi_tools/wirecutters
	name = "Wirecutters"
	item_path = /obj/item/wirecutters
	cost = 10
	max_supply = 8
	small_item = TRUE

/datum/cargo_item/engi_tools/multitool
	name = "Multitool"
	item_path = /obj/item/multitool
	cost = 75
	max_supply = 2
	small_item = TRUE

/datum/cargo_item/engi_tools/t_scanner
	name = "T-Scanner"
	item_path = /obj/item/t_scanner
	cost = 150
	max_supply = 1
	small_item = TRUE

/**
 * # Engineering Materials Cargo Items
 *
 */
/datum/cargo_item/engi_mats
	category = "Materials - Engineering"
	access_budget = ACCESS_ENGINE_EQUIP

/datum/cargo_item/engi_mats/metal
	name = "Metal Sheets (50)"
	item_path = /obj/item/stack/sheet/iron/fifty
	cost = 500
	max_supply = 10
	crate_type = /obj/structure/closet/crate/engineering

/datum/cargo_item/engi_mats/glass
	name = "Glass Sheets (50)"
	item_path = /obj/item/stack/sheet/glass/fifty
	cost = 500
	max_supply = 10
	crate_type = /obj/structure/closet/crate/engineering
