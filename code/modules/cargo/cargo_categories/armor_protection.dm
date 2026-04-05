/**
 * # Armor & Protection Cargo Items
 *
 * Protective gear: body armor, helmets, shields, space suits, hazard protection.
 * Split into Body Armor, Helmets & Shields, Fortifications, Space & EVA,
 * Hazard Protection (head/suits/security), and Plasmaman Suits & Helmets.
 */

// =============================================================================
// BODY ARMOR
// =============================================================================

/datum/cargo_list/armor_body
	access_budget = ACCESS_SECURITY
	crate_type = /obj/structure/closet/crate/secure/gear
	entries = list(
		// -- Standard-issue security vests --
		list("path" = /obj/item/clothing/suit/armor/vest, "cost" = 500, "max_supply" = 6),
		list("path" = /obj/item/clothing/suit/armor/vest/alt, "cost" = 500, "max_supply" = 6),
		list("path" = /obj/item/clothing/suit/armor/vest/blueshirt, "cost" = 700, "max_supply" = 4),
		list("path" = /obj/item/clothing/suit/armor/vest/det_suit, "cost" = 600, "max_supply" = 2, "access" = ACCESS_FORENSICS_LOCKERS),
		// -- Officer / command armors --
		list("path" = /obj/item/clothing/suit/armor/vest/warden, "cost" = 800, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/suit/armor/vest/warden/alt, "cost" = 800, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/suit/armor/vest/leather, "cost" = 900, "max_supply" = 2, "access" = ACCESS_HOS, "access_budget" = ACCESS_HOS),
		list("path" = /obj/item/clothing/suit/armor/hos, "cost" = 1200, "max_supply" = 1, "access" = ACCESS_HOS, "access_budget" = ACCESS_HOS),
		list("path" = /obj/item/clothing/suit/armor/hos/trenchcoat, "cost" = 1200, "max_supply" = 1, "access" = ACCESS_HOS, "access_budget" = ACCESS_HOS),
		list("path" = /obj/item/clothing/suit/armor/vest/capcarapace, "cost" = 1500, "max_supply" = 1, "access" = ACCESS_CAPTAIN, "access_budget" = ACCESS_CAPTAIN),
		list("path" = /obj/item/clothing/suit/armor/vest/capcarapace/jacket, "cost" = 1200, "max_supply" = 1, "access" = ACCESS_CAPTAIN, "access_budget" = ACCESS_CAPTAIN),
		list("path" = /obj/item/clothing/suit/armor/vest/capcarapace/captains_formal, "cost" = 1200, "max_supply" = 1, "access" = ACCESS_CAPTAIN, "access_budget" = ACCESS_CAPTAIN),
		// -- Heavy / armory-grade armor --
		list("path" = /obj/item/clothing/suit/armor/bulletproof, "cost" = 1500, "max_supply" = 4, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/suit/armor/laserproof, "cost" = 2500, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/suit/armor/riot, "cost" = 1500, "max_supply" = 4, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/suit/space/swat, "cost" = 2000, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		// -- Gloves & belts --
		list("path" = /obj/item/clothing/gloves/tackler, "cost" = 400, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/clothing/gloves/tackler/combat, "cost" = 600, "max_supply" = 4, "small_item" = TRUE, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/gloves/krav_maga, "cost" = 800, "max_supply" = 2, "small_item" = TRUE, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/storage/belt/military/assault, "cost" = 700, "max_supply" = 4, "small_item" = TRUE, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
	)

// =============================================================================
// HELMETS & SHIELDS
// =============================================================================

/datum/cargo_list/armor_head
	access_budget = ACCESS_SECURITY
	small_item = TRUE
	crate_type = /obj/structure/closet/crate/secure/gear
	entries = list(
		// -- Standard helmets --
		list("path" = /obj/item/clothing/head/helmet/sec, "cost" = 300, "max_supply" = 6),
		list("path" = /obj/item/clothing/head/helmet/alt, "cost" = 400, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/blueshirt, "cost" = 500, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/toggleable/justice, "cost" = 500, "max_supply" = 2),
		// -- Armory helmets --
		list("path" = /obj/item/clothing/head/helmet/toggleable/riot, "cost" = 1200, "max_supply" = 4, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/head/helmet/swat/nanotrasen, "cost" = 1200, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		// -- Shields --
		list("path" = /obj/item/shield/riot, "cost" = 1500, "max_supply" = 4, "small_item" = FALSE, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/shield/riot/tele, "cost" = 1000, "max_supply" = 4, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/shield/riot/flash, "cost" = 2000, "max_supply" = 2, "small_item" = FALSE, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
	)

// =============================================================================
// FORTIFICATIONS & DEPLOYABLES
// =============================================================================

/datum/cargo_list/armor_deploy
	access_budget = ACCESS_SECURITY
	small_item = TRUE
	crate_type = /obj/structure/closet/crate/secure/gear
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
	crate_type = /obj/structure/closet/crate/large
	entries = list(
		// -- Standard space suits --
		list("path" = /obj/item/clothing/suit/space, "cost" = 2000, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space, "cost" = 1000, "max_supply" = 4, "small_item" = TRUE),
		// -- Lightweight EVA suits --
		list("path" = /obj/item/clothing/suit/space/eva, "cost" = 1500, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/eva, "cost" = 800, "max_supply" = 4, "small_item" = TRUE),
		// -- Emergency suits --
		list("path" = /obj/item/clothing/head/helmet/space/fragile, "cost" = 300, "max_supply" = 6),
		list("path" = /obj/item/clothing/suit/space/fragile, "cost" = 400, "max_supply" = 6),
		// -- Skinsuits --
		list("path" = /obj/item/clothing/suit/space/hardsuit/skinsuit, "cost" = 800, "max_supply" = 12, "small_item" = TRUE),
	)

// =============================================================================
// HAZARD PROTECTION
// =============================================================================

// Hard hats, welding helmets, and general-purpose breath/gas masks.
// Engineering crate: lightweight utility head protection for workers.
/datum/cargo_list/armor_hazard_head
	small_item = TRUE
	crate_type = /obj/structure/closet/crate/engineering
	entries = list(
		// -- Hard hats --
		list("path" = /obj/item/clothing/head/utility/hardhat, "cost" = 150, "max_supply" = 5),
		list("path" = /obj/item/clothing/head/utility/hardhat/orange, "cost" = 150, "max_supply" = 5),
		list("path" = /obj/item/clothing/head/utility/hardhat/red, "cost" = 300, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/utility/hardhat/white, "cost" = 300, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/utility/hardhat/dblue, "cost" = 150, "max_supply" = 5),
		list("path" = /obj/item/clothing/head/utility/hardhat/atmos, "cost" = 400, "max_supply" = 3),
		// -- Welding hard hats --
		list("path" = /obj/item/clothing/head/utility/hardhat/welding, "cost" = 250, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/utility/hardhat/welding/orange, "cost" = 250, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/utility/hardhat/welding/white, "cost" = 350, "max_supply" = 3),
		// -- Gas masks & breath masks --
		list("path" = /obj/item/clothing/mask/gas, "cost" = 50, "max_supply" = 10),
		list("path" = /obj/item/clothing/mask/gas/welding, "cost" = 200, "max_supply" = 5),
		list("path" = /obj/item/clothing/mask/breath, "cost" = 25, "max_supply" = 10),
	)

// Bio suits, civilian bomb suits, fire suits, and radiation suits.
// Engineering crate: bulky full-body hazard protection for civilian use.
/datum/cargo_list/armor_hazard_suits
	crate_type = /obj/structure/closet/crate/engineering
	entries = list(
		// -- Bio suits --
		list("path" = /obj/item/clothing/suit/bio_suit, "cost" = 500, "max_supply" = 5),
		list("path" = /obj/item/clothing/head/bio_hood, "cost" = 500, "max_supply" = 5, "small_item" = TRUE),
		// -- Bomb suits --
		list("path" = /obj/item/clothing/suit/utility/bomb_suit, "cost" = 400, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/utility/bomb_hood, "cost" = 300, "max_supply" = 3, "small_item" = TRUE),
		// -- Fire suits --
		list("path" = /obj/item/clothing/suit/utility/fire/firefighter, "cost" = 400, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/utility/fire/atmos, "cost" = 800, "max_supply" = 2, "access_budget" = ACCESS_ATMOSPHERICS),
		// -- Radiation suits --
		list("path" = /obj/item/clothing/suit/utility/radiation, "cost" = 400, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/utility/radiation, "cost" = 300, "max_supply" = 4, "small_item" = TRUE),
	)

// Security-restricted hazard gear: security bomb suits and armory-grade gas masks.
// Secure gear crate: requires security budget access to purchase.
/datum/cargo_list/armor_hazard_security
	access_budget = ACCESS_SECURITY
	small_item = TRUE
	crate_type = /obj/structure/closet/crate/secure/gear
	entries = list(
		// -- Security bomb suits --
		list("path" = /obj/item/clothing/suit/utility/bomb_suit/security, "cost" = 500, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/clothing/head/utility/bomb_hood/security, "cost" = 400, "max_supply" = 2),
		// -- Security gas masks --
		list("path" = /obj/item/clothing/mask/gas/sechailer, "cost" = 150, "max_supply" = 6),
		list("path" = /obj/item/clothing/mask/gas/sechailer/swat, "cost" = 500, "max_supply" = 4, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
	)

// =============================================================================
// PLASMAMAN SUITS & HELMETS
// =============================================================================

/datum/cargo_list/armor_plasmaman
	small_item = TRUE
	crate_type = /obj/structure/closet/crate/secure/gear
	entries = list(
		// -- Envirosuits (jumpsuits) --
		list("path" = /obj/item/clothing/under/plasmaman, "cost" = 500, "max_supply" = 4, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/security, "cost" = 600, "max_supply" = 3, "small_item" = FALSE, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/plasmaman/security/warden, "cost" = 700, "max_supply" = 2, "small_item" = FALSE, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/under/plasmaman/security/hos, "cost" = 900, "max_supply" = 1, "small_item" = FALSE, "access" = ACCESS_HOS, "access_budget" = ACCESS_HOS),
		list("path" = /obj/item/clothing/under/plasmaman/security/secmed, "cost" = 600, "max_supply" = 2, "small_item" = FALSE, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/plasmaman/medical, "cost" = 500, "max_supply" = 4, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/paramedic, "cost" = 500, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/viro, "cost" = 500, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/chemist, "cost" = 500, "max_supply" = 3, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/genetics, "cost" = 500, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/cmo, "cost" = 800, "max_supply" = 1, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/science, "cost" = 500, "max_supply" = 3, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/robotics, "cost" = 500, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/rd, "cost" = 800, "max_supply" = 1, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/engineering, "cost" = 600, "max_supply" = 4, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/engineering/atmospherics, "cost" = 600, "max_supply" = 3, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/engineering/ce, "cost" = 800, "max_supply" = 1, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/cargo, "cost" = 500, "max_supply" = 4, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/mailman, "cost" = 500, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/mining, "cost" = 500, "max_supply" = 4, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/exploration, "cost" = 600, "max_supply" = 3, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/botany, "cost" = 500, "max_supply" = 3, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/chef, "cost" = 500, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/janitor, "cost" = 500, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/chaplain, "cost" = 500, "max_supply" = 1, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/curator, "cost" = 500, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/enviroslacks, "cost" = 500, "max_supply" = 3, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/tux, "cost" = 600, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/gold, "cost" = 2000, "max_supply" = 1, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/command, "cost" = 900, "max_supply" = 1, "small_item" = FALSE, "access" = ACCESS_CAPTAIN, "access_budget" = ACCESS_CAPTAIN),
		list("path" = /obj/item/clothing/under/plasmaman/hop, "cost" = 800, "max_supply" = 1, "small_item" = FALSE, "access" = ACCESS_HOP, "access_budget" = ACCESS_HOP),
		list("path" = /obj/item/clothing/under/plasmaman/mime, "cost" = 500, "max_supply" = 1, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/honk, "cost" = 500, "max_supply" = 1, "small_item" = FALSE),
		// -- EVA plasma envirosuit --
		list("path" = /obj/item/clothing/suit/space/eva/plasmaman, "cost" = 1500, "max_supply" = 4, "small_item" = FALSE),
		// -- Default helmets (Mk.I) --
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman, "cost" = 600, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/security, "cost" = 700, "max_supply" = 3, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/security/warden, "cost" = 800, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/security/hos, "cost" = 1000, "max_supply" = 1, "access" = ACCESS_HOS, "access_budget" = ACCESS_HOS),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/security/secmed, "cost" = 700, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/medical, "cost" = 600, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/paramedic, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/viro, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/chemist, "cost" = 600, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/genetics, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/cmo, "cost" = 900, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/science, "cost" = 600, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/robotics, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/rd, "cost" = 900, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/engineering, "cost" = 700, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/engineering/atmospherics, "cost" = 700, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/engineering/ce, "cost" = 900, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/cargo, "cost" = 600, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mailman, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mining, "cost" = 600, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/exploration, "cost" = 700, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/botany, "cost" = 600, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/janitor, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/chaplain, "cost" = 600, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/curator, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/white, "cost" = 600, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/bartender, "cost" = 700, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/gold, "cost" = 2200, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/command, "cost" = 1000, "max_supply" = 1, "access" = ACCESS_CAPTAIN, "access_budget" = ACCESS_CAPTAIN),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/hop, "cost" = 900, "max_supply" = 1, "access" = ACCESS_HOP, "access_budget" = ACCESS_HOP),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mime, "cost" = 600, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/honk, "cost" = 600, "max_supply" = 1),
		// -- Mk.II helmets --
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2, "cost" = 700, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/security, "cost" = 800, "max_supply" = 3, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/security/warden, "cost" = 900, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/security/hos, "cost" = 1100, "max_supply" = 1, "access" = ACCESS_HOS, "access_budget" = ACCESS_HOS),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/security/secmed, "cost" = 800, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/medical, "cost" = 700, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/paramedic, "cost" = 700, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/viro, "cost" = 700, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/chemist, "cost" = 700, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/genetics, "cost" = 700, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/cmo, "cost" = 1000, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/science, "cost" = 700, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/robotics, "cost" = 700, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/rd, "cost" = 1000, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/engineering, "cost" = 800, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/engineering/atmospherics, "cost" = 800, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/engineering/ce, "cost" = 1000, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/cargo, "cost" = 700, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/mailman, "cost" = 700, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/mining, "cost" = 700, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/exploration, "cost" = 800, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/botany, "cost" = 700, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/janitor, "cost" = 700, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/chaplain, "cost" = 700, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/white, "cost" = 700, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/bartender, "cost" = 800, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/gold, "cost" = 2400, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/command, "cost" = 1100, "max_supply" = 1, "access" = ACCESS_CAPTAIN, "access_budget" = ACCESS_CAPTAIN),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/hop, "cost" = 1000, "max_supply" = 1, "access" = ACCESS_HOP, "access_budget" = ACCESS_HOP),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/mime, "cost" = 700, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/clown, "cost" = 700, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/commander, "cost" = 1500, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/official, "cost" = 1200, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/intern, "cost" = 800, "max_supply" = 2),
		// -- Protective helmets --
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective, "cost" = 700, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/security, "cost" = 800, "max_supply" = 3, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/security/warden, "cost" = 900, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/security/hos, "cost" = 1100, "max_supply" = 1, "access" = ACCESS_HOS, "access_budget" = ACCESS_HOS),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/security/secmed, "cost" = 800, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/medical, "cost" = 700, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/paramedic, "cost" = 700, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/viro, "cost" = 700, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/chemist, "cost" = 700, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/genetics, "cost" = 700, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/cmo, "cost" = 1000, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/science, "cost" = 700, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/robotics, "cost" = 700, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/rd, "cost" = 1000, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/engineering, "cost" = 800, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/engineering/atmospherics, "cost" = 800, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/engineering/ce, "cost" = 1000, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/cargo, "cost" = 700, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/mailman, "cost" = 700, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/mining, "cost" = 700, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/exploration, "cost" = 800, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/botany, "cost" = 700, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/janitor, "cost" = 700, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/chaplain, "cost" = 700, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/white, "cost" = 700, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/bartender, "cost" = 800, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/gold, "cost" = 2400, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/command, "cost" = 1100, "max_supply" = 1, "access" = ACCESS_CAPTAIN, "access_budget" = ACCESS_CAPTAIN),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/hop, "cost" = 1000, "max_supply" = 1, "access" = ACCESS_HOP, "access_budget" = ACCESS_HOP),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/commander, "cost" = 1500, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/official, "cost" = 1200, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/intern, "cost" = 800, "max_supply" = 2),
	)
