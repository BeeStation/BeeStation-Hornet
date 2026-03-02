/**
 * # Contraband Cargo Crates
 *
 * All contraband cargo entries consolidated into one file.
 * Includes illicit goods, syndicate surplus, and special ops supplies.
 */

// =============================================================================
// CONTRABAND CRATES
// =============================================================================

/datum/cargo_crate/contraband

/datum/cargo_crate/contraband/goods
	name = "Contraband Crate"
	cost = 5000
	max_supply = 1
	contraband = TRUE
	contains = list(
		/obj/item/poster/random_contraband,
		/obj/item/poster/random_contraband,
		/obj/item/food/grown/cannabis,
		/obj/item/food/grown/cannabis/rainbow,
		/obj/item/food/grown/cannabis/white,
		/obj/item/storage/pill_bottle/zoom,
		/obj/item/storage/pill_bottle/happy,
		/obj/item/storage/pill_bottle/lsd,
		/obj/item/storage/pill_bottle/aranesp,
		/obj/item/storage/pill_bottle/stimulant,
		/obj/item/toy/cards/deck/syndicate,
		/obj/item/reagent_containers/cup/glass/bottle/absinthe,
		/obj/item/clothing/under/syndicate/tacticool,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate,
		/obj/item/storage/fancy/cigarettes/cigpack_shadyjims,
		/obj/item/clothing/mask/gas/syndicate,
		/obj/item/clothing/neck/necklace/dope,
		/obj/item/vending_refill/donksoft,
		/obj/item/clothing/neck/cloak/fakehalo,
	)

/datum/cargo_crate/contraband/specialops
	name = "Special Ops Supplies"
	cost = 5000
	max_supply = 1
	contraband = TRUE
	contains = list(
		/obj/item/storage/box/emps,
		/obj/item/grenade/smokebomb,
		/obj/item/grenade/smokebomb,
		/obj/item/grenade/smokebomb,
		/obj/item/pen/paralytic,
		/obj/item/grenade/chem_grenade/incendiary,
	)
	crate_type = /obj/structure/closet/crate/internals

/datum/cargo_crate/contraband/syndieclothes
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

/datum/cargo_crate/contraband/syndicate
	name = "Syndicate Surplus Crate"
	cost = 20000
	max_supply = 1
	contraband = TRUE
	contains = list()
	crate_type = /obj/structure/closet/crate/internals

/datum/cargo_crate/contraband/syndicate/fill(obj/structure/closet/crate/C)
