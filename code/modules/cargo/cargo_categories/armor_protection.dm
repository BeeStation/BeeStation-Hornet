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
		list("path" = /obj/item/clothing/suit/armor/vest/blueshirt, "cost" = 600, "max_supply" = 4),
		list("path" = /obj/item/clothing/suit/armor/vest/det_suit, "cost" = 550, "max_supply" = 2, "access" = ACCESS_FORENSICS_LOCKERS),
		// -- Officer / command armors --
		// Warden/HoS/Captain armors: $700–$1200, scaling with rank & protection
		list("path" = /obj/item/clothing/suit/armor/vest/warden, "cost" = 700, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/suit/armor/vest/warden/alt, "cost" = 700, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/suit/armor/vest/leather, "cost" = 800, "max_supply" = 2, "access" = ACCESS_HOS, "access_budget" = ACCESS_HOS),
		list("path" = /obj/item/clothing/suit/armor/hos, "cost" = 1000, "max_supply" = 1, "access" = ACCESS_HOS, "access_budget" = ACCESS_HOS),
		list("path" = /obj/item/clothing/suit/armor/hos/trenchcoat, "cost" = 1000, "max_supply" = 1, "access" = ACCESS_HOS, "access_budget" = ACCESS_HOS),
		list("path" = /obj/item/clothing/suit/armor/vest/capcarapace, "cost" = 1200, "max_supply" = 1, "access" = ACCESS_CAPTAIN, "access_budget" = ACCESS_CAPTAIN),
		list("path" = /obj/item/clothing/suit/armor/vest/capcarapace/jacket, "cost" = 1000, "max_supply" = 1, "access" = ACCESS_CAPTAIN, "access_budget" = ACCESS_CAPTAIN),
		list("path" = /obj/item/clothing/suit/armor/vest/capcarapace/captains_formal, "cost" = 1000, "max_supply" = 1, "access" = ACCESS_CAPTAIN, "access_budget" = ACCESS_CAPTAIN),
		// -- Heavy / armory-grade armor --
		// Bulletproof is same tier as riot; laserproof is rarer/better; SWAT is top-tier
		list("path" = /obj/item/clothing/suit/armor/bulletproof, "cost" = 1500, "max_supply" = 4, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/suit/armor/laserproof, "cost" = 2000, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/suit/armor/riot, "cost" = 1500, "max_supply" = 4, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/suit/space/swat, "cost" = 2500, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		// -- Gloves & belts --
		// Tackler gloves: Considered purchase ($200); combat/krav maga: Significant ($400–$600)
		list("path" = /obj/item/clothing/gloves/tackler, "cost" = 200, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/clothing/gloves/tackler/combat, "cost" = 400, "max_supply" = 4, "small_item" = TRUE, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/gloves/krav_maga, "cost" = 600, "max_supply" = 2, "small_item" = TRUE, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/storage/belt/military/assault, "cost" = 500, "max_supply" = 4, "small_item" = TRUE, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
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
		// Helmets: roughly half the cost of the matching body armor
		// Standard sec helmet = $300 (Considered purchase)
		list("path" = /obj/item/clothing/head/helmet/sec, "cost" = 300, "max_supply" = 6),
		list("path" = /obj/item/clothing/head/helmet/alt, "cost" = 350, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/blueshirt, "cost" = 400, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/toggleable/justice, "cost" = 400, "max_supply" = 2),
		// -- Armory helmets --
		// Riot helmet pairs with $1,500 riot suit — helmet ~$800
		list("path" = /obj/item/clothing/head/helmet/toggleable/riot, "cost" = 800, "max_supply" = 4, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/head/helmet/swat/nanotrasen, "cost" = 1000, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		// -- Shields --
		list("path" = /obj/item/shield/riot, "cost" = 1500, "max_supply" = 4, "small_item" = FALSE, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/shield/riot/tele, "cost" = 800, "max_supply" = 4, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
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
		// Barricade: cheap consumable, ~3 paychecks for a Medium worker
		list("path" = /obj/item/security_barricade, "cost" = 150, "max_supply" = 10),
		// Wall flash box: Considered purchase
		list("path" = /obj/item/storage/box/wall_flash, "cost" = 250, "max_supply" = 6),
		// Deployable barricade capsule: Major purchase, armory-grade
		list("path" = /obj/item/survivalcapsule/barricade, "cost" = 1000, "max_supply" = 4, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		// Checkpoint capsule: Major purchase, armory-grade
		list("path" = /obj/item/survivalcapsule/capsule_checkpoint, "cost" = 1500, "max_supply" = 3, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		// Bluespace anchor: Capital expenditure — unique powerful item
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
		// Standard colors at $100; specialty (red/white foreman) at $150; atmos-rated at $250
		list("path" = /obj/item/clothing/head/utility/hardhat, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/clothing/head/utility/hardhat/orange, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/clothing/head/utility/hardhat/red, "cost" = 150, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/utility/hardhat/white, "cost" = 150, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/utility/hardhat/dblue, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/clothing/head/utility/hardhat/atmos, "cost" = 250, "max_supply" = 3),
		// -- Welding hard hats --
		// Welding variants: slight premium for the built-in visor ($150–$200)
		list("path" = /obj/item/clothing/head/utility/hardhat/welding, "cost" = 150, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/utility/hardhat/welding/orange, "cost" = 150, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/utility/hardhat/welding/white, "cost" = 200, "max_supply" = 3),
		// -- Gas masks & breath masks --
		list("path" = /obj/item/clothing/mask/gas, "cost" = 50, "max_supply" = 10),
		list("path" = /obj/item/clothing/mask/gas/welding, "cost" = 150, "max_supply" = 5),
		list("path" = /obj/item/clothing/mask/breath, "cost" = 25, "max_supply" = 10),
	)

// Bio suits, civilian bomb suits, fire suits, and radiation suits.
// Engineering crate: bulky full-body hazard protection for civilian use.
/datum/cargo_list/armor_hazard_suits
	crate_type = /obj/structure/closet/crate/engineering
	entries = list(
		// -- Bio suits --
		// Split: body $600, hood $400
		list("path" = /obj/item/clothing/suit/bio_suit, "cost" = 600, "max_supply" = 5),
		list("path" = /obj/item/clothing/head/bio_hood, "cost" = 400, "max_supply" = 5, "small_item" = TRUE),
		// -- Bomb suits --
		// Civilian bomb suit: slightly less than bio suit (~$600 full set)
		list("path" = /obj/item/clothing/suit/utility/bomb_suit, "cost" = 400, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/utility/bomb_hood, "cost" = 250, "max_supply" = 3, "small_item" = TRUE),
		// -- Fire suits --
		// Standard firefighter: $300 (Considered purchase); Atmos-rated: $600 (Significant)
		list("path" = /obj/item/clothing/suit/utility/fire/firefighter, "cost" = 300, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/utility/fire/atmos, "cost" = 600, "max_supply" = 2, "access_budget" = ACCESS_ATMOSPHERICS),
		// -- Radiation suits --
		// Rad suit: ~$550 full set (Significant investment)
		list("path" = /obj/item/clothing/suit/utility/radiation, "cost" = 350, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/utility/radiation, "cost" = 200, "max_supply" = 4, "small_item" = TRUE),
	)

// Security-restricted hazard gear: security bomb suits and armory-grade gas masks.
// Secure gear crate: requires security budget access to purchase.
/datum/cargo_list/armor_hazard_security
	access_budget = ACCESS_SECURITY
	small_item = TRUE
	crate_type = /obj/structure/closet/crate/secure/gear
	entries = list(
		// -- Security bomb suits --
		// Security-grade bomb suit: premium over civilian ($500 body + $300 hood = $800 set)
		list("path" = /obj/item/clothing/suit/utility/bomb_suit/security, "cost" = 500, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/clothing/head/utility/bomb_hood/security, "cost" = 300, "max_supply" = 2),
		// -- Security gas masks --
		// Sechailer: standard issue, Considered purchase; SWAT variant: Significant
		list("path" = /obj/item/clothing/mask/gas/sechailer, "cost" = 100, "max_supply" = 6),
		list("path" = /obj/item/clothing/mask/gas/sechailer/swat, "cost" = 350, "max_supply" = 4, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
	)

// =============================================================================
// PLASMAMAN SUITS & HELMETS
// =============================================================================

/datum/cargo_list/armor_plasmaman
	small_item = TRUE
	crate_type = /obj/structure/closet/crate/secure/gear
	entries = list(
		// -- Envirosuits (jumpsuits) --
		// Plasmaman envirosuits are essential life-support — priced as Significant investments
		// Base civilian: $400; Department-specific: $500; Command/specialist: $700–$800
		list("path" = /obj/item/clothing/under/plasmaman, "cost" = 400, "max_supply" = 4, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/security, "cost" = 500, "max_supply" = 3, "small_item" = FALSE, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/plasmaman/security/warden, "cost" = 600, "max_supply" = 2, "small_item" = FALSE, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/under/plasmaman/security/hos, "cost" = 800, "max_supply" = 1, "small_item" = FALSE, "access" = ACCESS_HOS, "access_budget" = ACCESS_HOS),
		list("path" = /obj/item/clothing/under/plasmaman/security/secmed, "cost" = 500, "max_supply" = 2, "small_item" = FALSE, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/plasmaman/medical, "cost" = 400, "max_supply" = 4, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/paramedic, "cost" = 400, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/viro, "cost" = 400, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/chemist, "cost" = 400, "max_supply" = 3, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/genetics, "cost" = 400, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/cmo, "cost" = 700, "max_supply" = 1, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/science, "cost" = 400, "max_supply" = 3, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/robotics, "cost" = 400, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/rd, "cost" = 700, "max_supply" = 1, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/engineering, "cost" = 500, "max_supply" = 4, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/engineering/atmospherics, "cost" = 500, "max_supply" = 3, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/engineering/ce, "cost" = 700, "max_supply" = 1, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/cargo, "cost" = 400, "max_supply" = 4, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/mailman, "cost" = 400, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/mining, "cost" = 400, "max_supply" = 4, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/exploration, "cost" = 500, "max_supply" = 3, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/botany, "cost" = 400, "max_supply" = 3, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/chef, "cost" = 400, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/janitor, "cost" = 400, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/chaplain, "cost" = 400, "max_supply" = 1, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/curator, "cost" = 400, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/enviroslacks, "cost" = 400, "max_supply" = 3, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/tux, "cost" = 500, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/gold, "cost" = 1500, "max_supply" = 1, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/command, "cost" = 800, "max_supply" = 1, "small_item" = FALSE, "access" = ACCESS_CAPTAIN, "access_budget" = ACCESS_CAPTAIN),
		list("path" = /obj/item/clothing/under/plasmaman/hop, "cost" = 700, "max_supply" = 1, "small_item" = FALSE, "access" = ACCESS_HOP, "access_budget" = ACCESS_HOP),
		list("path" = /obj/item/clothing/under/plasmaman/mime, "cost" = 400, "max_supply" = 1, "small_item" = FALSE),
		list("path" = /obj/item/clothing/under/plasmaman/honk, "cost" = 400, "max_supply" = 1, "small_item" = FALSE),
		// -- EVA plasma envirosuit --
		list("path" = /obj/item/clothing/suit/space/eva/plasmaman, "cost" = 1500, "max_supply" = 4, "small_item" = FALSE),
		// -- Default helmets (Mk.I) --
		// Base helmet: $500; department variants: $500–$600; command: $800–$900
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman, "cost" = 500, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/security, "cost" = 600, "max_supply" = 3, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/security/warden, "cost" = 700, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/security/hos, "cost" = 900, "max_supply" = 1, "access" = ACCESS_HOS, "access_budget" = ACCESS_HOS),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/security/secmed, "cost" = 600, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/medical, "cost" = 500, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/paramedic, "cost" = 500, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/viro, "cost" = 500, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/chemist, "cost" = 500, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/genetics, "cost" = 500, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/cmo, "cost" = 800, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/science, "cost" = 500, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/robotics, "cost" = 500, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/rd, "cost" = 800, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/engineering, "cost" = 600, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/engineering/atmospherics, "cost" = 600, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/engineering/ce, "cost" = 800, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/cargo, "cost" = 500, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mailman, "cost" = 500, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mining, "cost" = 500, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/exploration, "cost" = 600, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/botany, "cost" = 500, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/janitor, "cost" = 500, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/chaplain, "cost" = 500, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/curator, "cost" = 500, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/white, "cost" = 500, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/bartender, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/gold, "cost" = 1800, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/command, "cost" = 900, "max_supply" = 1, "access" = ACCESS_CAPTAIN, "access_budget" = ACCESS_CAPTAIN),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/hop, "cost" = 800, "max_supply" = 1, "access" = ACCESS_HOP, "access_budget" = ACCESS_HOP),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mime, "cost" = 500, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/honk, "cost" = 500, "max_supply" = 1),
		// -- Mk.II helmets --
		// Mk.II: $100 premium over Mk.I across the board
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2, "cost" = 600, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/security, "cost" = 700, "max_supply" = 3, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/security/warden, "cost" = 800, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/security/hos, "cost" = 1000, "max_supply" = 1, "access" = ACCESS_HOS, "access_budget" = ACCESS_HOS),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/security/secmed, "cost" = 700, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/medical, "cost" = 600, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/paramedic, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/viro, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/chemist, "cost" = 600, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/genetics, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/cmo, "cost" = 900, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/science, "cost" = 600, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/robotics, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/rd, "cost" = 900, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/engineering, "cost" = 700, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/engineering/atmospherics, "cost" = 700, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/engineering/ce, "cost" = 900, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/cargo, "cost" = 600, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/mailman, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/mining, "cost" = 600, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/exploration, "cost" = 700, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/botany, "cost" = 600, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/janitor, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/chaplain, "cost" = 600, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/white, "cost" = 600, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/bartender, "cost" = 700, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/gold, "cost" = 2000, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/command, "cost" = 1000, "max_supply" = 1, "access" = ACCESS_CAPTAIN, "access_budget" = ACCESS_CAPTAIN),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/hop, "cost" = 900, "max_supply" = 1, "access" = ACCESS_HOP, "access_budget" = ACCESS_HOP),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/mime, "cost" = 600, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/clown, "cost" = 600, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/commander, "cost" = 1200, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/official, "cost" = 1000, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/mark2/intern, "cost" = 700, "max_supply" = 2),
		// -- Protective helmets --
		// Protective: same price as Mk.II (equivalent tier upgrade)
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective, "cost" = 600, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/security, "cost" = 700, "max_supply" = 3, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/security/warden, "cost" = 800, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/security/hos, "cost" = 1000, "max_supply" = 1, "access" = ACCESS_HOS, "access_budget" = ACCESS_HOS),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/security/secmed, "cost" = 700, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/medical, "cost" = 600, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/paramedic, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/viro, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/chemist, "cost" = 600, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/genetics, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/cmo, "cost" = 900, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/science, "cost" = 600, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/robotics, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/rd, "cost" = 900, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/engineering, "cost" = 700, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/engineering/atmospherics, "cost" = 700, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/engineering/ce, "cost" = 900, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/cargo, "cost" = 600, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/mailman, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/mining, "cost" = 600, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/exploration, "cost" = 700, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/botany, "cost" = 600, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/janitor, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/chaplain, "cost" = 600, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/white, "cost" = 600, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/bartender, "cost" = 700, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/gold, "cost" = 2000, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/command, "cost" = 1000, "max_supply" = 1, "access" = ACCESS_CAPTAIN, "access_budget" = ACCESS_CAPTAIN),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/hop, "cost" = 900, "max_supply" = 1, "access" = ACCESS_HOP, "access_budget" = ACCESS_HOP),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/commander, "cost" = 1200, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/official, "cost" = 1000, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/helmet/space/plasmaman/protective/intern, "cost" = 700, "max_supply" = 2),
	)
