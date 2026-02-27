/**
 * # Armor & Protection Cargo Items
 *
 * Protective gear: body armor, helmets, shields, space suits, hazard protection.
 * Split into Body Armor, Helmets & Shields, Space & EVA, and Hazard Protection.
 */

// =============================================================================
// BODY ARMOR
// =============================================================================

/datum/cargo_item/armor_body
	category = "Armor & Protection"
	subcategory = "Body Armor"
	access_budget = ACCESS_SECURITY

/datum/cargo_item/armor_body/armor_vest
	name = "Armor Vest"
	item_path = /obj/item/clothing/suit/armor/vest
	cost = 500
	max_supply = 6

/datum/cargo_item/armor_body/bulletproof_vest
	name = "Bulletproof Vest"
	item_path = /obj/item/clothing/suit/armor/bulletproof
	cost = 1500
	max_supply = 4
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

/datum/cargo_item/armor_body/laserproof_vest
	name = "Ablative Armor Vest"
	item_path = /obj/item/clothing/suit/armor/laserproof
	cost = 2500
	max_supply = 2
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

/datum/cargo_item/armor_body/riot_suit
	name = "Riot Suit"
	item_path = /obj/item/clothing/suit/armor/riot
	cost = 1500
	max_supply = 4
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

// =============================================================================
// HELMETS & SHIELDS
// =============================================================================

/datum/cargo_item/armor_head
	category = "Armor & Protection"
	subcategory = "Helmets & Shields"
	access_budget = ACCESS_SECURITY

/datum/cargo_item/armor_head/helmet
	name = "Security Helmet"
	item_path = /obj/item/clothing/head/helmet/sec
	cost = 300
	max_supply = 6
	small_item = TRUE

/datum/cargo_item/armor_head/riot_helmet
	name = "Riot Helmet"
	item_path = /obj/item/clothing/head/helmet/toggleable/riot
	cost = 1200
	max_supply = 4
	small_item = TRUE
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

/datum/cargo_item/armor_head/justice_helmet
	name = "Justice Helmet"
	item_path = /obj/item/clothing/head/helmet/toggleable/justice
	cost = 500
	max_supply = 2
	small_item = TRUE

/datum/cargo_item/armor_head/riot_shield
	name = "Riot Shield"
	item_path = /obj/item/shield/riot
	cost = 1500
	max_supply = 4
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

/datum/cargo_item/armor_head/barrier
	name = "Security Barrier"
	item_path = /obj/item/security_barricade
	cost = 200
	max_supply = 10
	small_item = TRUE

/datum/cargo_item/armor_head/wall_flash_box
	name = "Wall Flash Unit"
	item_path = /obj/item/storage/box/wall_flash
	cost = 350
	max_supply = 6
	small_item = TRUE

/datum/cargo_item/armor_head/exileimp_box
	name = "Exile Implant Kit"
	item_path = /obj/item/storage/box/exileimp
	cost = 2500
	max_supply = 1
	small_item = TRUE
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

/datum/cargo_item/armor_head/mindshield_lockbox
	name = "Mindshield Implant Lockbox"
	item_path = /obj/item/storage/lockbox/loyalty
	cost = 3500
	max_supply = 2
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

/datum/cargo_item/armor_head/barricade_capsule
	name = "Barricade Capsule"
	item_path = /obj/item/survivalcapsule/barricade
	cost = 1200
	max_supply = 4
	small_item = TRUE
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

/datum/cargo_item/armor_head/checkpoint_capsule
	name = "Checkpoint Capsule"
	item_path = /obj/item/survivalcapsule/capsule_checkpoint
	cost = 1500
	max_supply = 3
	small_item = TRUE
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

/datum/cargo_item/armor_head/bluespace_anchor
	name = "Bluespace Anchor"
	item_path = /obj/item/bluespace_anchor
	cost = 3000
	max_supply = 1
	small_item = TRUE
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

// =============================================================================
// SPACE & EVA SUITS
// =============================================================================

/datum/cargo_item/armor_space
	category = "Armor & Protection"
	subcategory = "Space & EVA"

/datum/cargo_item/armor_space/space_suit
	name = "Space Suit"
	item_path = /obj/item/clothing/suit/space
	cost = 2000
	max_supply = 4

/datum/cargo_item/armor_space/space_helmet
	name = "Space Helmet"
	item_path = /obj/item/clothing/head/helmet/space
	cost = 1000
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/armor_space/plasmaman_eva_suit
	name = "Plasmaman EVA Suit"
	item_path = /obj/item/clothing/suit/space/eva/plasmaman
	cost = 1500
	max_supply = 3

/datum/cargo_item/armor_space/plasmaman_eva_helmet
	name = "Plasmaman EVA Helmet"
	item_path = /obj/item/clothing/head/helmet/space/plasmaman
	cost = 1000
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/armor_space/plasmaman_envirosuit
	name = "Plasmaman Envirosuit"
	item_path = /obj/item/clothing/under/plasmaman
	cost = 500
	max_supply = 4

/datum/cargo_item/armor_space/plasmaman_tank
	name = "Plasmaman Belt Tank"
	item_path = /obj/item/tank/internals/plasmaman/belt/full
	cost = 300
	max_supply = 4
	small_item = TRUE

// =============================================================================
// HAZARD PROTECTION
// =============================================================================

/datum/cargo_item/armor_hazard
	category = "Armor & Protection"
	subcategory = "Hazard Protection"

/datum/cargo_item/armor_hazard/biosuit
	name = "Biosuit"
	desc = "A level-3 biohazard suit."
	item_path = /obj/item/clothing/suit/bio_suit
	cost = 500
	max_supply = 5

/datum/cargo_item/armor_hazard/biohood
	name = "Bio Hood"
	desc = "A level-3 biohazard hood."
	item_path = /obj/item/clothing/head/bio_hood
	cost = 500
	max_supply = 5
	small_item = TRUE

/datum/cargo_item/armor_hazard/bomb_suit
	name = "Bomb Suit"
	desc = "A suit designed for safe handling of explosive devices."
	item_path = /obj/item/clothing/suit/utility/bomb_suit
	cost = 400
	max_supply = 3

/datum/cargo_item/armor_hazard/bomb_hood
	name = "Bomb Hood"
	desc = "A protective hood for bomb disposal."
	item_path = /obj/item/clothing/head/utility/bomb_hood
	cost = 300
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/armor_hazard/fire_suit
	name = "Firefighter Suit"
	desc = "A suit designed for firefighting operations."
	item_path = /obj/item/clothing/suit/utility/fire/firefighter
	cost = 400
	max_supply = 5

/datum/cargo_item/armor_hazard/rad_suit
	name = "Radiation Suit"
	item_path = /obj/item/clothing/suit/utility/radiation
	cost = 400
	max_supply = 4

/datum/cargo_item/armor_hazard/rad_hood
	name = "Radiation Hood"
	item_path = /obj/item/clothing/head/utility/radiation
	cost = 300
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/armor_hazard/gas_mask
	name = "Gas Mask"
	item_path = /obj/item/clothing/mask/gas
	cost = 50
	max_supply = 10
	small_item = TRUE

/datum/cargo_item/armor_hazard/sechailer
	name = "Hailer Gas Mask"
	item_path = /obj/item/clothing/mask/gas/sechailer
	cost = 150
	max_supply = 6
	small_item = TRUE
	access_budget = ACCESS_SECURITY

// =============================================================================
// ARMOR & PROTECTION CRATES
// =============================================================================

/datum/cargo_crate/armor
	category = "Armor & Protection"
	subcategory = "Armor Packs"
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/cargo_crate/armor/swat
	name = "SWAT Equipment Crate"
	desc = "Contains two full sets of SWAT gear: helmets, suits, masks, belts, and gloves."
	cost = 10000
	max_supply = 1
	contains = list(
		/obj/item/clothing/head/helmet/swat/nanotrasen,
		/obj/item/clothing/head/helmet/swat/nanotrasen,
		/obj/item/clothing/suit/space/swat,
		/obj/item/clothing/suit/space/swat,
		/obj/item/clothing/mask/gas/sechailer/swat,
		/obj/item/clothing/mask/gas/sechailer/swat,
		/obj/item/storage/belt/military/assault,
		/obj/item/storage/belt/military/assault,
		/obj/item/clothing/gloves/tackler/combat,
		/obj/item/clothing/gloves/tackler/combat,
	)

/datum/cargo_crate/armor/implants
	name = "Chemical Implant Kit"
	cost = 2000
	max_supply = 2
	small_item = TRUE
	contains = list(/obj/item/storage/box/chemimp)

/datum/cargo_crate/armor/exileimp
	name = "Exile Implant Kit"
	cost = 2500
	max_supply = 1
	contains = list(/obj/item/storage/box/exileimp)

/datum/cargo_crate/armor/mindshield
	name = "Mindshield Implant Lockbox"
	cost = 3500
	max_supply = 2
	contains = list(/obj/item/storage/lockbox/loyalty)

/datum/cargo_crate/armor/bluespace_anchor
	name = "Bluespace Anchor"
	cost = 3000
	max_supply = 1
	contains = list(/obj/item/bluespace_anchor)

// --- Contraband Armor ---

/datum/cargo_crate/armor/syndieclothes
	name = "Syndicate Surplus Clothing"
	desc = "A crate of surplus Syndicate-style tactical clothing and armor."
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
