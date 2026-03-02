/**
 * # Clothing Cargo Items
 *
 * Costumes, formal wear, uniforms, and collectible hats.
 * Split into Costumes, Formal Wear, Collectible Hats, and Uniforms & Accessories.
 */

// =============================================================================
// COSTUMES
// =============================================================================

/datum/cargo_list/clothing_costumes
	entries = list(
		list("path" = /obj/item/staff, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/wizrobe/fake, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/wizard/fake, "cost" = 200, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/storage/backpack/clown, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/shoes/clown_shoes, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/gas/clown_hat, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/rank/civilian/clown, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/firing_pin/clown, "cost" = 500, "max_supply" = 2, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/rank/civilian/mime, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/mask/gas/mime, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/frenchberet, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/suspenders, "cost" = 50, "max_supply" = 3),
		list("path" = /obj/item/storage/backpack/mime, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/costume/snowman, "cost" = 75, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/costume/snowman, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/costume/chicken, "cost" = 75, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/costume/chickensuit, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/mask/gas/monkeymask, "cost" = 75, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/costume/monkeysuit, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/costume/cardborg, "cost" = 75, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/costume/cardborg, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/costume/xenos, "cost" = 75, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/costume/xenos, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/hooded/ian_costume, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/hooded/carp_costume, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/hooded/bee_costume, "cost" = 100, "max_supply" = 3),
	)

// =============================================================================
// FORMAL WEAR
// =============================================================================

/datum/cargo_list/clothing_formal
	entries = list(
		list("path" = /obj/item/clothing/under/dress/blacktango, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/misc/assistantformal, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/bluesuit, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/toggle/lawyer, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/purpsuit, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/toggle/lawyer/purple, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/toggle/lawyer/black, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/accessory/waistcoat, "cost" = 50, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/tie/blue, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/tie/red, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/tie/black, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/hats/bowler, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/fedora, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/flatcap, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beret, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/hats/tophat, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/shoes/laceup, "cost" = 50, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/suit/charcoal, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/navy, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/burgundy, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/checkered, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/tan, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/misc/burial, "cost" = 100, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/rank/security/officer/formal, "cost" = 150, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/suit/jacket/officer/blue, "cost" = 150, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/beret/sec/navyofficer, "cost" = 75, "max_supply" = 2, "access_budget" = ACCESS_SECURITY, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/rank/security/warden/formal, "cost" = 150, "max_supply" = 1, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/suit/jacket/warden/tan, "cost" = 150, "max_supply" = 1, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/beret/sec/navywarden, "cost" = 75, "max_supply" = 1, "access_budget" = ACCESS_SECURITY, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/rank/security/head_of_security/formal, "cost" = 150, "max_supply" = 1, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/suit/jacket/hos/blue, "cost" = 150, "max_supply" = 1, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/hats/hos/beret/navyhos, "cost" = 75, "max_supply" = 1, "access_budget" = ACCESS_SECURITY, "small_item" = TRUE),
	)

// =============================================================================
// COLLECTIBLE HATS
// =============================================================================

/datum/cargo_list/clothing_collectible
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/clothing/head/collectable/chef, "cost" = 150, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/paper, "cost" = 150, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/tophat, "cost" = 150, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/captain, "cost" = 150, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/beret, "cost" = 150, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/welding, "cost" = 150, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/flatcap, "cost" = 150, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/pirate, "cost" = 150, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/kitty, "cost" = 150, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/rabbitears, "cost" = 150, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/wizard, "cost" = 150, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/hardhat, "cost" = 150, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/HoS, "cost" = 150, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/HoP, "cost" = 150, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/thunderdome, "cost" = 150, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/swat, "cost" = 150, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/slime, "cost" = 150, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/police, "cost" = 150, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/xenom, "cost" = 150, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/petehat, "cost" = 150, "max_supply" = 1),
	)

// =============================================================================
// UNIFORMS & WORK WEAR
// =============================================================================

/datum/cargo_list/clothing_uniforms
	entries = list(
		list("path" = /obj/item/clothing/suit/hazardvest, "cost" = 75, "max_supply" = 6),
		list("path" = /obj/item/clothing/shoes/galoshes, "cost" = 300, "max_supply" = 3),
		list("path" = /obj/item/clothing/gloves/color/latex/nitrile, "cost" = 50, "max_supply" = 6, "small_item" = TRUE),
	)

// =============================================================================
// CLOTHING CRATES
// =============================================================================

/datum/cargo_crate/clothing
