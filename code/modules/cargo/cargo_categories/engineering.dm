/**
 * # Engineering Cargo Items
 *
 * Individual items orderable under the "Engineering" category.
 */

/datum/cargo_item/engineering
	category = "Engineering"
	access_budget = ACCESS_ENGINE_EQUIP

// --- Tools ---

/datum/cargo_item/engineering/toolbox_electrical
	name = "Electrical Toolbox"
	item_path = /obj/item/storage/toolbox/electrical
	cost = 250
	max_supply = 8
	small_item = TRUE

/datum/cargo_item/engineering/toolbox_mechanical
	name = "Mechanical Toolbox"
	item_path = /obj/item/storage/toolbox/mechanical
	cost = 250
	max_supply = 8
	small_item = TRUE

// --- Materials ---

/datum/cargo_item/engineering/metal
	name = "Metal Sheets (50)"
	item_path = /obj/item/stack/sheet/iron/fifty
	cost = 500
	max_supply = 10
	crate_type = /obj/structure/closet/crate/engineering

/datum/cargo_item/engineering/glass
	name = "Glass Sheets (50)"
	item_path = /obj/item/stack/sheet/glass/fifty
	cost = 500
	max_supply = 10
	crate_type = /obj/structure/closet/crate/engineering

// --- Fuel Rods ---

/datum/cargo_item/engineering/fuel_rod
	name = "Uranium Fuel Rod"
	desc = "A nuclear reactor grade fuel rod. Warning: radioactive!"
	item_path = /obj/item/fuel_rod
	cost = 600
	max_supply = 5
	access_budget = ACCESS_ENGINE
	small_item = TRUE
	crate_type = /obj/structure/closet/crate/secure/engineering
