/**
 * # Clothing Cargo Items
 *
 * All station-standard clothing purchasable through cargo.
 * Sourced from ClothesMate, AutoDrobe, department wardrobes, and standard lockers.
 * Split into: Costumes, Formal Wear, Casual Wear, Collectible Hats,
 * Uniforms & Work Wear, and Shoes & Footwear.
 */

// =============================================================================
// COSTUMES  (AutoDrobe + ClothesMate costume items)
// =============================================================================

/datum/cargo_list/clothing_costumes
	crate_type = /obj/structure/closet/crate
	entries = list(
		// -- Wizard / witch costumes --
		list("path" = /obj/item/staff, "cost" = 120, "max_supply" = 3),
		list("path" = /obj/item/staff/broom, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/wizrobe/fake, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/wizard/fake, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/wizrobe/marisa/fake, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/wizard/marisa/fake, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/costume/witchwig, "cost" = 40, "max_supply" = 3, "small_item" = TRUE),
		// -- Clown costumes --
		list("path" = /obj/item/storage/backpack/clown, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/shoes/clown_shoes, "cost" = 30, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/gas/clown_hat, "cost" = 30, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/gas/sexyclown, "cost" = 30, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/rank/civilian/clown, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/clown/blue, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/clown/green, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/clown/yellow, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/clown/orange, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/clown/purple, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/clown/sexy, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/clown/rainbow, "cost" = 80, "max_supply" = 2),
		list("path" = /obj/item/clothing/under/rank/civilian/clown/jester, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/costume/jester, "cost" = 35, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/firing_pin/clown, "cost" = 500, "max_supply" = 2, "small_item" = TRUE),
		// -- Mime costumes --
		list("path" = /obj/item/clothing/under/rank/civilian/mime, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/mime/sexy, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/mime/skirt, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/mask/gas/mime, "cost" = 30, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/gas/sexymime, "cost" = 30, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/frenchberet, "cost" = 20, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/suspenders, "cost" = 25, "max_supply" = 3),
		list("path" = /obj/item/storage/backpack/mime, "cost" = 60, "max_supply" = 3),
		// -- Animal costumes --
		list("path" = /obj/item/clothing/head/costume/snowman, "cost" = 35, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/costume/snowman, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/costume/chicken, "cost" = 35, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/costume/chickensuit, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/mask/gas/monkeymask, "cost" = 35, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/costume/monkeysuit, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/costume/cardborg, "cost" = 35, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/costume/cardborg, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/costume/xenos, "cost" = 35, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/costume/xenos, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/hooded/ian_costume, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/hooded/carp_costume, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/hooded/bee_costume, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/costume/kitty, "cost" = 35, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/costume/rabbitears, "cost" = 35, "max_supply" = 3, "small_item" = TRUE),
		// -- Animal masks --
		list("path" = /obj/item/clothing/mask/rat, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/rat/bat, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/rat/bee, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/rat/bear, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/rat/raven, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/rat/jackal, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/rat/fox, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/rat/tribal, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/frog, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		// -- Pirate costumes --
		list("path" = /obj/item/clothing/under/costume/pirate, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/costume/pirate, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/costume/pirate, "cost" = 35, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/costume/pirate/bandana, "cost" = 20, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/costume/pirate/captain, "cost" = 100, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/costume/pirate/captain, "cost" = 50, "max_supply" = 2, "small_item" = TRUE),
		// -- Roman costumes --
		list("path" = /obj/item/clothing/head/helmet/roman/fake, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/helmet/roman/legionnaire/fake, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/costume/roman, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/shoes/roman, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/shield/riot/roman/fake, "cost" = 60, "max_supply" = 3),
		// -- Gladiator costumes --
		list("path" = /obj/item/clothing/under/costume/gladiator, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/gladiator, "cost" = 40, "max_supply" = 3, "small_item" = TRUE),
		// -- Mexican / poncho --
		list("path" = /obj/item/clothing/head/costume/sombrero, "cost" = 35, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/costume/sombrero/green, "cost" = 35, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/costume/poncho, "cost" = 50, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/costume/poncho/green, "cost" = 50, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/costume/poncho/red, "cost" = 50, "max_supply" = 3),
		// -- Plague doctor --
		list("path" = /obj/item/clothing/suit/bio_suit/plaguedoctorsuit, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/costume/plague, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/gas/plaguedoctor, "cost" = 40, "max_supply" = 3, "small_item" = TRUE),
		// -- Owl / griffin --
		list("path" = /obj/item/clothing/suit/toggle/owlwings, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/owl, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/mask/gas/owl_mask, "cost" = 35, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/toggle/owlwings/griffinwings, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/griffin, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/shoes/griffin, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/costume/griffin, "cost" = 35, "max_supply" = 3, "small_item" = TRUE),
		// -- Maid costumes --
		list("path" = /obj/item/clothing/head/costume/maidheadband, "cost" = 15, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/costume/maid, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/gloves/maid, "cost" = 20, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/maid, "cost" = 15, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/rank/civilian/janitor/maid, "cost" = 60, "max_supply" = 3),
		// -- Schoolgirl --
		list("path" = /obj/item/clothing/under/costume/schoolgirl, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/schoolgirl/red, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/schoolgirl/green, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/schoolgirl/orange, "cost" = 60, "max_supply" = 3),
		// -- Singer costumes --
		list("path" = /obj/item/clothing/shoes/singery, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/costume/singer/yellow, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/shoes/singerb, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/costume/singer/blue, "cost" = 60, "max_supply" = 3),
		// -- Dracula --
		list("path" = /obj/item/clothing/suit/costume/dracula, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/draculass, "cost" = 60, "max_supply" = 3),
		// -- Joker --
		list("path" = /obj/item/clothing/under/costume/joker, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/costume/joker, "cost" = 75, "max_supply" = 3),
		// -- Villain --
		list("path" = /obj/item/clothing/under/costume/villain, "cost" = 60, "max_supply" = 3),
		// -- Pharaoh --
		list("path" = /obj/item/clothing/head/costume/pharaoh, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		// -- Yukata / kimono --
		list("path" = /obj/item/clothing/under/costume/yukata, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/yukata/green, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/yukata/white, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/kimono, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/kimono/red, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/kimono/purple, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/shoes/sandal/alt, "cost" = 20, "max_supply" = 3, "small_item" = TRUE),
		// -- Miscellaneous costumes --
		list("path" = /obj/item/clothing/suit/toggle/labcoat/mad, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/costume/gothcoat, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/costume/imperium_monk, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/mask/gas/cyborg, "cost" = 35, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/costume/whitedress, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/mask/joy, "cost" = 15, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/costume/cueball, "cost" = 35, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/costume/delinquent, "cost" = 35, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/fakemoustache, "cost" = 10, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/wig/random, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/wig/natural, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/costume/ianshirt, "cost" = 50, "max_supply" = 3),
		list("path" = /obj/item/clothing/glasses/cold, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/glasses/heat, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/cane, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		// -- Jacket costumes --
		list("path" = /obj/item/clothing/suit/jacket/undergroundserpents, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/jacket/lieutenant, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/jacket/teenbiker, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/jacket/driver, "cost" = 75, "max_supply" = 3),
		// -- Chapel costumes --
		list("path" = /obj/item/clothing/suit/chaplainsuit/holidaypriest, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/chaplainsuit/whiterobe, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/hooded/hastur, "cost" = 60, "max_supply" = 3),
		// -- Mech suits (costume) --
		list("path" = /obj/item/clothing/under/costume/mech_suit, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/mech_suit/white, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/mech_suit/blue, "cost" = 60, "max_supply" = 3),
	)

// =============================================================================
// FORMAL WEAR  (LawDrobe, ClothesMate suits, DetDrobe formal, BarDrobe formal)
// =============================================================================

/datum/cargo_list/clothing_formal
	crate_type = /obj/structure/closet/crate
	entries = list(
		// -- Suits --
		list("path" = /obj/item/clothing/under/suit/charcoal, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/navy, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/burgundy, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/checkered, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/tan, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/black, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/black/skirt, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/black_really, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/black_really/skirt, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/white, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/sl, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/relaxed, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/waiter, "cost" = 50, "max_supply" = 3),
		// -- Dresses --
		list("path" = /obj/item/clothing/under/dress/blacktango, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/dress/redeveninggown, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/dress/sundress, "cost" = 50, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/dress/striped, "cost" = 50, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/dress/sailor, "cost" = 50, "max_supply" = 3),
		// -- Lawyer outfits --
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/bluesuit, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/bluesuit/skirt, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/toggle/lawyer, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/purpsuit, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/purpsuit/skirt, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/toggle/lawyer/purple, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/toggle/lawyer/black, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/female, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/female/skirt, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/blue, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/blue/skirt, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/red, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/red/skirt, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/black, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/black/skirt, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/accessory/lawyers_badge, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		// -- Aristocrat jackets --
		list("path" = /obj/item/clothing/suit/jacket/aristocrat, "cost" = 120, "max_supply" = 2),
		list("path" = /obj/item/clothing/suit/jacket/aristocrat/red, "cost" = 120, "max_supply" = 2),
		list("path" = /obj/item/clothing/suit/jacket/aristocrat/brown, "cost" = 120, "max_supply" = 2),
		list("path" = /obj/item/clothing/suit/jacket/aristocrat/blue, "cost" = 120, "max_supply" = 2),
		// -- Formal misc --
		list("path" = /obj/item/clothing/under/misc/assistantformal, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/misc/burial, "cost" = 50, "max_supply" = 5, "small_item" = TRUE),
		// -- Accessories --
		list("path" = /obj/item/clothing/accessory/waistcoat, "cost" = 30, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/tie/blue, "cost" = 10, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/tie/red, "cost" = 10, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/tie/black, "cost" = 10, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/tie/horrible, "cost" = 10, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/glasses/monocle, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		// -- Formal hats --
		list("path" = /obj/item/clothing/head/hats/bowler, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/fedora, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/flatcap, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beret, "cost" = 20, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beret/black, "cost" = 20, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/hats/tophat, "cost" = 30, "max_supply" = 3, "small_item" = TRUE),
		// -- Formal shoes --
		list("path" = /obj/item/clothing/shoes/laceup, "cost" = 30, "max_supply" = 5, "small_item" = TRUE),
		// -- Leather jackets --
		list("path" = /obj/item/clothing/suit/jacket/leather, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/jacket/leather/overcoat, "cost" = 100, "max_supply" = 3),
	)

/datum/cargo_list/clothing_formal_dept
	crate_type = /obj/structure/closet/crate/secure
	entries = list(
		list("path" = /obj/item/clothing/suit/jacket/officer/blue, "cost" = 100, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/beret/sec/navyofficer, "cost" = 40, "max_supply" = 2, "access_budget" = ACCESS_SECURITY, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/rank/security/warden/formal, "cost" = 100, "max_supply" = 1, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/suit/jacket/warden/tan, "cost" = 100, "max_supply" = 1, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/beret/sec/navywarden, "cost" = 40, "max_supply" = 1, "access_budget" = ACCESS_SECURITY, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/rank/security/head_of_security/formal, "cost" = 100, "max_supply" = 1, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/suit/jacket/hos/blue, "cost" = 100, "max_supply" = 1, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/hats/hos/beret/navyhos, "cost" = 40, "max_supply" = 1, "access_budget" = ACCESS_SECURITY, "small_item" = TRUE),
	)

// =============================================================================
// CASUAL WEAR  (ClothesMate casual clothing, hoodies, everyday wear)
// =============================================================================

/datum/cargo_list/clothing_casual
	crate_type = /obj/structure/closet/crate
	entries = list(
		// -- Pants & jeans --
		list("path" = /obj/item/clothing/under/pants/jeans, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/pants/classicjeans, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/pants/blackjeans, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/pants/mustangjeans, "cost" = 50, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/pants/khaki, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/pants/white, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/pants/red, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/pants/black, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/pants/tan, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/pants/camo, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/pants/track, "cost" = 35, "max_supply" = 5),
		// -- Skirts --
		list("path" = /obj/item/clothing/under/dress/skirt, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/dress/skirt/blue, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/dress/skirt/red, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/dress/skirt/purple, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/dress/skirt/plaid, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/dress/skirt/plaid/blue, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/dress/skirt/plaid/green, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/dress/skirt/plaid/purple, "cost" = 35, "max_supply" = 5),
		// -- Other under --
		list("path" = /obj/item/clothing/under/misc/overalls, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/costume/kilt, "cost" = 50, "max_supply" = 3),
		// -- Hoodies --
		list("path" = /obj/item/clothing/suit/hooded/hoodie, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/hoodie/blue, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/hoodie/green, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/hoodie/orange, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/hoodie/pink, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/hoodie/red, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/hoodie/black, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/hoodie/yellow, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/hoodie/darkblue, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/hoodie/teal, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/hoodie/purple, "cost" = 50, "max_supply" = 5),
		// -- Winter coats --
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/old, "cost" = 60, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/white, "cost" = 60, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat, "cost" = 60, "max_supply" = 5),
		// -- Jackets --
		list("path" = /obj/item/clothing/suit/jacket/puffer/vest, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/jacket/puffer, "cost" = 60, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/toggle/softshell, "cost" = 60, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/jacket/letterman, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/jacket/letterman_red, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/jacket/letterman_nanotrasen, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/jacket/miljacket, "cost" = 75, "max_supply" = 3),
		// -- Beanies --
		list("path" = /obj/item/clothing/head/beanie, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/black, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/red, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/green, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/darkblue, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/purple, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/yellow, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/orange, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/cyan, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/christmas, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/striped, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/stripedred, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/stripedblue, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/stripedgreen, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/rasta, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		// -- Casual hats --
		list("path" = /obj/item/clothing/head/cowboy, "cost" = 30, "max_supply" = 3, "small_item" = TRUE),
		// -- Bandanas --
		list("path" = /obj/item/clothing/mask/bandana, "cost" = 10, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/bandana/striped, "cost" = 10, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/bandana/skull, "cost" = 10, "max_supply" = 5, "small_item" = TRUE),
		// -- Scarves --
		list("path" = /obj/item/clothing/neck/scarf, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/black, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/pink, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/red, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/green, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/darkblue, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/purple, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/yellow, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/orange, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/cyan, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/zebra, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/christmas, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/stripedredscarf, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/stripedbluescarf, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/stripedgreenscarf, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/necklace/dope, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		// -- Accessories --
		list("path" = /obj/item/clothing/glasses/regular, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/glasses/regular/jamjar, "cost" = 15, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/glasses/regular/circle, "cost" = 15, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/glasses/sunglasses, "cost" = 40, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/glasses/sunglasses/circle_sunglasses, "cost" = 40, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/glasses/orange, "cost" = 15, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/glasses/red, "cost" = 15, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/gloves/fingerless, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/ears/headphones, "cost" = 30, "max_supply" = 3, "small_item" = TRUE),
		// -- Fanny packs --
		list("path" = /obj/item/storage/belt/fannypack, "cost" = 35, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/storage/belt/fannypack/blue, "cost" = 35, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/storage/belt/fannypack/red, "cost" = 35, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/storage/belt/fannypack/black, "cost" = 35, "max_supply" = 5, "small_item" = TRUE),
		// -- Religious headwear --
		list("path" = /obj/item/clothing/head/chaplain/kippah, "cost" = 10, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/chaplain/taqiyah/red, "cost" = 10, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/chaplain/taqiyah/white, "cost" = 10, "max_supply" = 5, "small_item" = TRUE),
	)

// =============================================================================
// SHOES & FOOTWEAR  (ClothesMate shoes, all standard footwear)
// =============================================================================

/datum/cargo_list/clothing_shoes
	crate_type = /obj/structure/closet/crate
	small_item = TRUE
	entries = list(
		// -- Sneakers --
		list("path" = /obj/item/clothing/shoes/sneakers/black, "cost" = 20, "max_supply" = 8),
		list("path" = /obj/item/clothing/shoes/sneakers/brown, "cost" = 20, "max_supply" = 8),
		list("path" = /obj/item/clothing/shoes/sneakers/yellow, "cost" = 20, "max_supply" = 8),
		list("path" = /obj/item/clothing/shoes/sneakers/green, "cost" = 20, "max_supply" = 8),
		list("path" = /obj/item/clothing/shoes/sneakers/blue, "cost" = 20, "max_supply" = 8),
		list("path" = /obj/item/clothing/shoes/sneakers/purple, "cost" = 20, "max_supply" = 8),
		list("path" = /obj/item/clothing/shoes/sneakers/red, "cost" = 20, "max_supply" = 8),
		list("path" = /obj/item/clothing/shoes/sneakers/orange, "cost" = 20, "max_supply" = 8),
		list("path" = /obj/item/clothing/shoes/sneakers/white, "cost" = 20, "max_supply" = 8),
		// -- Boots --
		list("path" = /obj/item/clothing/shoes/winterboots, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/shoes/jackboots, "cost" = 60, "max_supply" = 5),
		list("path" = /obj/item/clothing/shoes/jackboots_replica, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/shoes/jackboots_replica/white, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/clothing/shoes/workboots, "cost" = 40, "max_supply" = 5),
		// -- Sandals --
		list("path" = /obj/item/clothing/shoes/sandal, "cost" = 15, "max_supply" = 5),
		// -- Galoshes --
		list("path" = /obj/item/clothing/shoes/galoshes, "cost" = 400, "max_supply" = 3),
	)

// =============================================================================
// COLLECTIBLE HATS
// =============================================================================

/datum/cargo_list/clothing_collectible
	crate_type = /obj/structure/closet/crate
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/clothing/head/collectable/chef, "cost" = 100, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/paper, "cost" = 100, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/tophat, "cost" = 100, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/captain, "cost" = 100, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/beret, "cost" = 100, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/welding, "cost" = 100, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/flatcap, "cost" = 100, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/pirate, "cost" = 100, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/kitty, "cost" = 100, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/rabbitears, "cost" = 100, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/wizard, "cost" = 100, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/hardhat, "cost" = 100, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/HoS, "cost" = 100, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/HoP, "cost" = 100, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/thunderdome, "cost" = 100, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/swat, "cost" = 100, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/slime, "cost" = 100, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/police, "cost" = 100, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/xenom, "cost" = 100, "max_supply" = 1),
		list("path" = /obj/item/clothing/head/collectable/petehat, "cost" = 100, "max_supply" = 1),
	)

// =============================================================================
// UNIFORMS & WORK WEAR  (Department-specific clothing from wardrobes)
// =============================================================================

/datum/cargo_list/clothing_uniforms
	crate_type = /obj/structure/closet/crate
	entries = list(
		// -- General work wear --
		list("path" = /obj/item/clothing/suit/apron, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/apron/overalls, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/apron/purple_bartender, "cost" = 35, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/toggle/labcoat, "cost" = 60, "max_supply" = 6),
		list("path" = /obj/item/clothing/suit/toggle/chef, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/utility/chefhat, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/accessory/pocketprotector, "cost" = 10, "max_supply" = 8, "small_item" = TRUE),
		list("path" = /obj/item/clothing/gloves/color/black, "cost" = 25, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/costume/nursehat, "cost" = 20, "max_supply" = 5, "small_item" = TRUE),
		// -- Civilian / service uniforms --
		list("path" = /obj/item/clothing/under/rank/civilian/bartender, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/bartender/purple, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/bartender/skirt, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/chef, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/chef/skirt, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/altchef, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/hydroponics, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/hydroponics/skirt, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/janitor, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/janitor/skirt, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/chaplain, "cost" = 75, "max_supply" = 2),
		list("path" = /obj/item/clothing/under/rank/civilian/chaplain/skirt, "cost" = 75, "max_supply" = 2),
		list("path" = /obj/item/clothing/under/rank/civilian/curator, "cost" = 75, "max_supply" = 2),
		list("path" = /obj/item/clothing/under/rank/civilian/curator/skirt, "cost" = 75, "max_supply" = 2),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/hydro, "cost" = 60, "max_supply" = 3),
		list("path" = /obj/item/clothing/accessory/armband/hydro, "cost" = 10, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/bandana/striped/botany, "cost" = 10, "max_supply" = 4, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/bandana/purple, "cost" = 10, "max_supply" = 4, "small_item" = TRUE),
		// -- Soft caps --
		list("path" = /obj/item/clothing/head/soft, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/soft/black, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/soft/purple, "cost" = 15, "max_supply" = 5, "small_item" = TRUE),
		// -- Chaplain robes --
		list("path" = /obj/item/clothing/suit/chaplainsuit/nun, "cost" = 60, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/chaplain/nun_hood, "cost" = 25, "max_supply" = 2, "small_item" = TRUE),
	)

/datum/cargo_list/clothing_uniforms_dept
	crate_type = /obj/structure/closet/crate/secure
	entries = list(
		// -- Department labcoats --
		list("path" = /obj/item/clothing/suit/toggle/labcoat/science, "cost" = 60, "max_supply" = 4, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/clothing/suit/toggle/labcoat/chemist, "cost" = 60, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/suit/toggle/labcoat/genetics, "cost" = 60, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/suit/toggle/labcoat/virologist, "cost" = 60, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/suit/toggle/labcoat/paramedic, "cost" = 60, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		// -- Security uniforms --
		list("path" = /obj/item/clothing/under/rank/security/officer, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/rank/security/officer/skirt, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/rank/security/officer/white, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/rank/security/officer/grey, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/rank/security/officer/blueshirt, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/rank/security/officer/corporate, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/rank/security/detective, "cost" = 75, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/rank/security/detective/skirt, "cost" = 75, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/rank/security/detective/grey, "cost" = 75, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/rank/security/detective/grey/skirt, "cost" = 75, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/beret/sec, "cost" = 25, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/beret/corpsec, "cost" = 25, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/soft/sec, "cost" = 25, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/mask/bandana/striped/security, "cost" = 10, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/security, "cost" = 60, "max_supply" = 4, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/detective, "cost" = 60, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		// -- Medical uniforms --
		list("path" = /obj/item/clothing/under/rank/medical/doctor, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/doctor/skirt, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/doctor/blue, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/doctor/green, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/doctor/purple, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/doctor/nurse, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/paramedic, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/paramedic/skirt, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/chemist, "cost" = 75, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/chemist/skirt, "cost" = 75, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/geneticist, "cost" = 75, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/geneticist/skirt, "cost" = 75, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/virologist, "cost" = 75, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/virologist/skirt, "cost" = 75, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/head/beret/medical, "cost" = 25, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/head/beret/medical/paramedic, "cost" = 25, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/head/soft/paramedic, "cost" = 25, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/mask/bandana/striped/medical, "cost" = 10, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/medical, "cost" = 60, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/chemist, "cost" = 60, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/geneticist, "cost" = 60, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/virologist, "cost" = 60, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		// -- Engineering uniforms --
		list("path" = /obj/item/clothing/under/rank/engineering/engineer, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/clothing/under/rank/engineering/engineer/hazard, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/clothing/under/rank/engineering/engineer/skirt, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/clothing/under/rank/engineering/atmospheric_technician, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/clothing/under/rank/engineering/atmospheric_technician/skirt, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/clothing/head/beret/engi, "cost" = 25, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/clothing/head/beret/atmos, "cost" = 25, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/clothing/mask/bandana/striped/engineering, "cost" = 10, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/engineering, "cost" = 60, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/engineering/atmos, "cost" = 60, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		// -- Science uniforms --
		list("path" = /obj/item/clothing/under/rank/rnd/scientist, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/clothing/under/rank/rnd/scientist/skirt, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/clothing/under/rank/rnd/roboticist, "cost" = 75, "max_supply" = 3, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/clothing/under/rank/rnd/roboticist/skirt, "cost" = 75, "max_supply" = 3, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/clothing/under/rank/rnd/roboticist/retro, "cost" = 75, "max_supply" = 3, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/clothing/head/beret/science, "cost" = 25, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/clothing/head/cowboy/science, "cost" = 30, "max_supply" = 3, "small_item" = TRUE, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/clothing/mask/bandana/striped/science, "cost" = 10, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/science, "cost" = 60, "max_supply" = 4, "access_budget" = ACCESS_RESEARCH),
		// -- Cargo uniforms --
		list("path" = /obj/item/clothing/under/rank/cargo/tech, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_CARGO),
		list("path" = /obj/item/clothing/under/rank/cargo/tech/skirt, "cost" = 75, "max_supply" = 4, "access_budget" = ACCESS_CARGO),
		list("path" = /obj/item/clothing/under/rank/cargo/miner, "cost" = 75, "max_supply" = 3, "access_budget" = ACCESS_CARGO),
		list("path" = /obj/item/clothing/head/soft/cargo, "cost" = 25, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_CARGO),
		list("path" = /obj/item/clothing/head/beret/cargo, "cost" = 25, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_CARGO),
		list("path" = /obj/item/clothing/mask/bandana/striped/cargo, "cost" = 10, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_CARGO),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/cargo, "cost" = 60, "max_supply" = 4, "access_budget" = ACCESS_CARGO),
		list("path" = /obj/item/clothing/head/costume/mailman, "cost" = 25, "max_supply" = 3, "small_item" = TRUE, "access_budget" = ACCESS_CARGO),
		list("path" = /obj/item/clothing/under/misc/mailman, "cost" = 50, "max_supply" = 3, "access_budget" = ACCESS_CARGO),
		list("path" = /obj/item/clothing/under/misc/mailman/skirt, "cost" = 50, "max_supply" = 3, "access_budget" = ACCESS_CARGO),
	)

// =============================================================================
// BACKPACKS & BAGS (all standard department and civilian backpacks)
// =============================================================================

/datum/cargo_list/clothing_backpacks
	crate_type = /obj/structure/closet/crate
	entries = list(
		// -- Civilian / service --
		list("path" = /obj/item/storage/backpack/botany, "cost" = 50, "max_supply" = 3),
		list("path" = /obj/item/storage/backpack/satchel/hyd, "cost" = 50, "max_supply" = 3),
		list("path" = /obj/item/storage/backpack/satchel/explorer, "cost" = 50, "max_supply" = 3),
		list("path" = /obj/item/storage/backpack/cultpack, "cost" = 60, "max_supply" = 2),
		list("path" = /obj/item/storage/bag/books, "cost" = 30, "max_supply" = 3, "small_item" = TRUE),
	)

/datum/cargo_list/clothing_backpacks_dept
	crate_type = /obj/structure/closet/crate/secure
	entries = list(
		// -- Security --
		list("path" = /obj/item/storage/backpack/security, "cost" = 60, "max_supply" = 4, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/storage/backpack/satchel/sec, "cost" = 60, "max_supply" = 4, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/storage/backpack/duffelbag/sec, "cost" = 60, "max_supply" = 4, "access_budget" = ACCESS_SECURITY),
		// -- Medical --
		list("path" = /obj/item/storage/backpack/medic, "cost" = 60, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/storage/backpack/satchel/med, "cost" = 60, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/storage/backpack/duffelbag/med, "cost" = 60, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/storage/backpack/chemistry, "cost" = 60, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/storage/backpack/satchel/chem, "cost" = 60, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/storage/backpack/genetics, "cost" = 60, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/storage/backpack/satchel/gen, "cost" = 60, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/storage/backpack/virology, "cost" = 60, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/storage/backpack/satchel/vir, "cost" = 60, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		// -- Engineering --
		list("path" = /obj/item/storage/backpack/industrial, "cost" = 60, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/storage/backpack/satchel/eng, "cost" = 60, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/storage/backpack/duffelbag/engineering, "cost" = 60, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		// -- Science --
		list("path" = /obj/item/storage/backpack/science, "cost" = 60, "max_supply" = 4, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/storage/backpack/satchel/tox, "cost" = 60, "max_supply" = 4, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/storage/backpack/duffelbag/science, "cost" = 60, "max_supply" = 4, "access_budget" = ACCESS_RESEARCH),
		// -- Cargo --
		list("path" = /obj/item/storage/backpack/satchel/mail, "cost" = 50, "max_supply" = 3, "access_budget" = ACCESS_CARGO),
	)
