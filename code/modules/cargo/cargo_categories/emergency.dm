/**
 * # Emergency Cargo Items
 *
 * Individual items orderable under the "Emergency" category.
 */

/datum/cargo_item/emergency
	category = "Emergency"

/datum/cargo_item/emergency/oxygen_tank
	name = "Emergency Oxygen Tank"
	item_path = /obj/item/tank/internals/emergency_oxygen
	cost = 200
	max_supply = 10
	small_item = TRUE

/datum/cargo_item/emergency/breath_mask
	name = "Breath Mask"
	item_path = /obj/item/clothing/mask/breath
	cost = 150
	max_supply = 10
	small_item = TRUE

/datum/cargo_item/emergency/biosuit
	name = "Biosuit"
	desc = "A level-3 biohazard suit."
	item_path = /obj/item/clothing/suit/bio_suit
	cost = 500
	max_supply = 5

/datum/cargo_item/emergency/biohood
	name = "Bio Hood"
	desc = "A level-3 biohazard hood."
	item_path = /obj/item/clothing/head/bio_hood
	cost = 400
	max_supply = 5
	small_item = TRUE
