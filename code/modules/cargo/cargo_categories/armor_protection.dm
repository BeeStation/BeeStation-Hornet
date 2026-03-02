/**
 * # Armor & Protection Cargo Items
 *
 * Protective gear: body armor, helmets, shields, space suits, hazard protection.
 * Split into Body Armor, Helmets & Shields, Space & EVA, and Hazard Protection.
 */

// =============================================================================
// BODY ARMOR
// =============================================================================

/datum/cargo_list/armor_body
	access_budget = ACCESS_SECURITY
	entries = list(
		list("path" = /obj/item/clothing/suit/armor/vest, "cost" = 500, "max_supply" = 6),
		list("path" = /obj/item/clothing/suit/armor/bulletproof, "cost" = 1500, "max_supply" = 4, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/suit/armor/laserproof, "cost" = 2500, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/suit/armor/riot, "cost" = 1500, "max_supply" = 4, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/suit/space/swat, "cost" = 2000, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/gloves/tackler/combat, "cost" = 600, "max_supply" = 4, "small_item" = TRUE, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/storage/belt/military/assault, "cost" = 700, "max_supply" = 4, "small_item" = TRUE, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
	)

// =============================================================================
// HELMETS & SHIELDS
// =============================================================================

/datum/cargo_list/armor_head
	access_budget = ACCESS_SECURITY
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/clothing/head/helmet/sec, "cost" = 300, "max_supply" = 6),
		list("path" = /obj/item/clothing/head/helmet/toggleable/riot, "cost" = 1200, "max_supply" = 4, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/head/helmet/swat/nanotrasen, "cost" = 1200, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/head/helmet/toggleable/justice, "cost" = 500, "max_supply" = 2),
		list("path" = /obj/item/shield/riot, "cost" = 1500, "max_supply" = 4, "small_item" = FALSE, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
	)

// =============================================================================
// FORTIFICATIONS & DEPLOYABLES
// =============================================================================

/datum/cargo_list/armor_deploy
	access_budget = ACCESS_SECURITY
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/security_barricade, "cost" = 200, "max_supply" = 10),
		list("path" = /obj/item/storage/box/wall_flash, "cost" = 350, "max_supply" = 6),
		list("path" = /obj/item/survivalcapsule/barricade, "cost" = 1200, "max_supply" = 4, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/survivalcapsule/capsule_checkpoint, "cost" = 1500, "max_supply" = 3, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/bluespace_anchor, "cost" = 3000, "max_supply" = 1, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
	)

// =============================================================================
// SPACE & EVA SUITS
// =============================================================================

/datum/cargo_list/armor_space
	entries = list(
		list("path" = /obj/item/clothing/suit/space, "cost" = 2000, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space, "cost" = 1000, "max_supply" = 4, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/space/eva/plasmaman, "cost" = 1500, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman, "cost" = 1000, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/plasmaman, "cost" = 500, "max_supply" = 4),
		list("path" = /obj/item/tank/internals/plasmaman/belt/full, "cost" = 300, "max_supply" = 4, "small_item" = TRUE),
	)

// =============================================================================
// HAZARD PROTECTION
// =============================================================================

/datum/cargo_list/armor_hazard
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/clothing/head/utility/hardhat, "cost" = 150, "max_supply" = 5),
		list("path" = /obj/item/clothing/head/utility/hardhat/orange, "cost" = 150, "max_supply" = 5),
		list("path" = /obj/item/clothing/head/utility/hardhat/red, "cost" = 300, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/utility/hardhat/white, "cost" = 300, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/utility/hardhat/dblue, "cost" = 150, "max_supply" = 5),
		list("path" = /obj/item/clothing/head/utility/hardhat/atmos, "cost" = 400, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/utility/hardhat/welding, "cost" = 250, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/utility/hardhat/welding/orange, "cost" = 250, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/utility/hardhat/welding/white, "cost" = 350, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/bio_suit, "cost" = 500, "max_supply" = 5, "small_item" = FALSE),
		list("path" = /obj/item/clothing/head/bio_hood, "cost" = 500, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/utility/bomb_suit, "cost" = 400, "max_supply" = 3, "small_item" = FALSE),
		list("path" = /obj/item/clothing/head/utility/bomb_hood, "cost" = 300, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/utility/fire/firefighter, "cost" = 400, "max_supply" = 5, "small_item" = FALSE),
		list("path" = /obj/item/clothing/suit/utility/radiation, "cost" = 400, "max_supply" = 4, "small_item" = FALSE),
		list("path" = /obj/item/clothing/head/utility/radiation, "cost" = 300, "max_supply" = 4),
		list("path" = /obj/item/clothing/mask/gas, "cost" = 50, "max_supply" = 10),
		list("path" = /obj/item/clothing/mask/gas/sechailer, "cost" = 150, "max_supply" = 6, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/mask/gas/sechailer/swat, "cost" = 500, "max_supply" = 4, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
	)

// =============================================================================
// ARMOR & PROTECTION CRATES
// =============================================================================

/datum/cargo_crate/armor
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon

// --- Contraband Armor ---

/datum/cargo_crate/armor/syndieclothes
	name = "Syndicate Surplus Clothing"
	cost = 6000
	max_supply = 1
	contraband = TRUE
	contains = list(
		/obj/item/clothing/under/syndicate,
		/obj/item/clothing/under/syndicate,
		/obj/item/clothing/under/syndicate,
		/obj/item/clothing/shoes/combat,
		/obj/item/clothing/shoes/combat,
		/obj/item/clothing/shoes/combat,
		/obj/item/clothing/mask/balaclava,
		/obj/item/clothing/mask/balaclava,
		/obj/item/clothing/mask/balaclava,
		/obj/item/clothing/gloves/tackler/combat,
		/obj/item/clothing/gloves/tackler/combat,
		/obj/item/clothing/gloves/tackler/combat,
		/obj/item/clothing/head/hats/hos/beret/syndicate,
		/obj/item/clothing/head/hats/hos/beret/syndicate,
		/obj/item/clothing/head/hats/hos/beret/syndicate,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/clothing/suit/armor/vest,
	)
	crate_type = /obj/structure/closet/crate/internals
