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
	entries = list(
		// -- Wizard / witch costumes --
		list("path" = /obj/item/staff, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/staff/broom, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/wizrobe/fake, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/wizard/fake, "cost" = 200, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/wizrobe/marisa/fake, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/wizard/marisa/fake, "cost" = 200, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/costume/witchwig, "cost" = 100, "max_supply" = 3, "small_item" = TRUE),
		// -- Clown costumes --
		list("path" = /obj/item/storage/backpack/clown, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/shoes/clown_shoes, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/gas/clown_hat, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/gas/sexyclown, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/rank/civilian/clown, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/clown/blue, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/clown/green, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/clown/yellow, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/clown/orange, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/clown/purple, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/clown/sexy, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/clown/rainbow, "cost" = 150, "max_supply" = 2),
		list("path" = /obj/item/clothing/under/rank/civilian/clown/jester, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/costume/jester, "cost" = 75, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/firing_pin/clown, "cost" = 500, "max_supply" = 2, "small_item" = TRUE),
		// -- Mime costumes --
		list("path" = /obj/item/clothing/under/rank/civilian/mime, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/mime/sexy, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/mime/skirt, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/mask/gas/mime, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/gas/sexymime, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/frenchberet, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/suspenders, "cost" = 50, "max_supply" = 3),
		list("path" = /obj/item/storage/backpack/mime, "cost" = 100, "max_supply" = 3),
		// -- Animal costumes --
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
		list("path" = /obj/item/clothing/head/costume/kitty, "cost" = 75, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/costume/rabbitears, "cost" = 75, "max_supply" = 3, "small_item" = TRUE),
		// -- Animal masks --
		list("path" = /obj/item/clothing/mask/rat, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/rat/bat, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/rat/bee, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/rat/bear, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/rat/raven, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/rat/jackal, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/rat/fox, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/rat/tribal, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/frog, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		// -- Pirate costumes --
		list("path" = /obj/item/clothing/under/costume/pirate, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/costume/pirate, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/costume/pirate, "cost" = 75, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/costume/pirate/bandana, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/costume/pirate/captain, "cost" = 150, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/costume/pirate/captain, "cost" = 100, "max_supply" = 2, "small_item" = TRUE),
		// -- Roman costumes --
		list("path" = /obj/item/clothing/head/helmet/roman/fake, "cost" = 100, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/helmet/roman/legionnaire/fake, "cost" = 100, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/costume/roman, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/shoes/roman, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/shield/riot/roman/fake, "cost" = 100, "max_supply" = 3),
		// -- Gladiator costumes --
		list("path" = /obj/item/clothing/under/costume/gladiator, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/helmet/gladiator, "cost" = 75, "max_supply" = 3, "small_item" = TRUE),
		// -- Mexican / poncho --
		list("path" = /obj/item/clothing/head/costume/sombrero, "cost" = 75, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/costume/sombrero/green, "cost" = 75, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/costume/poncho, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/costume/poncho/green, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/costume/poncho/red, "cost" = 75, "max_supply" = 3),
		// -- Plague doctor --
		list("path" = /obj/item/clothing/suit/bio_suit/plaguedoctorsuit, "cost" = 150, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/costume/plague, "cost" = 100, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/gas/plaguedoctor, "cost" = 75, "max_supply" = 3, "small_item" = TRUE),
		// -- Owl / griffin --
		list("path" = /obj/item/clothing/suit/toggle/owlwings, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/owl, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/mask/gas/owl_mask, "cost" = 75, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/toggle/owlwings/griffinwings, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/griffin, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/shoes/griffin, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/costume/griffin, "cost" = 75, "max_supply" = 3, "small_item" = TRUE),
		// -- Maid costumes --
		list("path" = /obj/item/clothing/head/costume/maidheadband, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/costume/maid, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/gloves/maid, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/maid, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/rank/civilian/janitor/maid, "cost" = 100, "max_supply" = 3),
		// -- Schoolgirl --
		list("path" = /obj/item/clothing/under/costume/schoolgirl, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/schoolgirl/red, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/schoolgirl/green, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/schoolgirl/orange, "cost" = 100, "max_supply" = 3),
		// -- Singer costumes --
		list("path" = /obj/item/clothing/shoes/singery, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/costume/singer/yellow, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/shoes/singerb, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/costume/singer/blue, "cost" = 100, "max_supply" = 3),
		// -- Dracula --
		list("path" = /obj/item/clothing/suit/costume/dracula, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/draculass, "cost" = 100, "max_supply" = 3),
		// -- Joker --
		list("path" = /obj/item/clothing/under/costume/joker, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/costume/joker, "cost" = 100, "max_supply" = 3),
		// -- Villain --
		list("path" = /obj/item/clothing/under/costume/villain, "cost" = 100, "max_supply" = 3),
		// -- Pharaoh --
		list("path" = /obj/item/clothing/head/costume/pharaoh, "cost" = 100, "max_supply" = 3, "small_item" = TRUE),
		// -- Yukata / kimono --
		list("path" = /obj/item/clothing/under/costume/yukata, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/yukata/green, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/yukata/white, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/kimono, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/kimono/red, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/kimono/purple, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/shoes/sandal/alt, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		// -- Miscellaneous costumes --
		list("path" = /obj/item/clothing/suit/toggle/labcoat/mad, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/costume/gothcoat, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/costume/imperium_monk, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/mask/gas/cyborg, "cost" = 75, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/costume/whitedress, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/mask/joy, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/costume/cueball, "cost" = 75, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/costume/delinquent, "cost" = 75, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/fakemoustache, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/wig/random, "cost" = 50, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/wig/natural, "cost" = 50, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/suit/costume/ianshirt, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/glasses/cold, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/glasses/heat, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/cane, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		// -- Jacket costumes --
		list("path" = /obj/item/clothing/suit/jacket/undergroundserpents, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/jacket/lieutenant, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/jacket/teenbiker, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/jacket/driver, "cost" = 100, "max_supply" = 3),
		// -- Chapel costumes (non-access) --
		list("path" = /obj/item/clothing/suit/chaplainsuit/holidaypriest, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/chaplainsuit/whiterobe, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/hooded/hastur, "cost" = 100, "max_supply" = 3),
		// -- Mech suits (costume) --
		list("path" = /obj/item/clothing/under/costume/mech_suit, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/mech_suit/white, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/costume/mech_suit/blue, "cost" = 100, "max_supply" = 3),
	)

// =============================================================================
// FORMAL WEAR  (LawDrobe, ClothesMate suits, DetDrobe formal, BarDrobe formal)
// =============================================================================

/datum/cargo_list/clothing_formal
	entries = list(
		// -- Suits --
		list("path" = /obj/item/clothing/under/suit/charcoal, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/navy, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/burgundy, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/checkered, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/tan, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/black, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/black/skirt, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/black_really, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/black_really/skirt, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/white, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/sl, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/relaxed, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/suit/waiter, "cost" = 75, "max_supply" = 3),
		// -- Dresses --
		list("path" = /obj/item/clothing/under/dress/blacktango, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/dress/redeveninggown, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/dress/sundress, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/dress/striped, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/dress/sailor, "cost" = 75, "max_supply" = 3),
		// -- Lawyer outfits --
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/bluesuit, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/bluesuit/skirt, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/toggle/lawyer, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/purpsuit, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/purpsuit/skirt, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/toggle/lawyer/purple, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/toggle/lawyer/black, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/female, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/female/skirt, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/blue, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/blue/skirt, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/red, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/red/skirt, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/black, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/lawyer/black/skirt, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/accessory/lawyers_badge, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		// -- Aristocrat jackets --
		list("path" = /obj/item/clothing/suit/jacket/aristocrat, "cost" = 150, "max_supply" = 2),
		list("path" = /obj/item/clothing/suit/jacket/aristocrat/red, "cost" = 150, "max_supply" = 2),
		list("path" = /obj/item/clothing/suit/jacket/aristocrat/brown, "cost" = 150, "max_supply" = 2),
		list("path" = /obj/item/clothing/suit/jacket/aristocrat/blue, "cost" = 150, "max_supply" = 2),
		// -- Formal misc --
		list("path" = /obj/item/clothing/under/misc/assistantformal, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/misc/burial, "cost" = 100, "max_supply" = 5, "small_item" = TRUE),
		// -- Accessories --
		list("path" = /obj/item/clothing/accessory/waistcoat, "cost" = 50, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/tie/blue, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/tie/red, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/tie/black, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/tie/horrible, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/glasses/monocle, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		// -- Formal hats --
		list("path" = /obj/item/clothing/head/hats/bowler, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/fedora, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/flatcap, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beret, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beret/black, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/hats/tophat, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		// -- Formal shoes --
		list("path" = /obj/item/clothing/shoes/laceup, "cost" = 50, "max_supply" = 5, "small_item" = TRUE),
		// -- Detective formal --
		list("path" = /obj/item/clothing/suit/jacket/det_suit, "cost" = 150, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/suit/jacket/det_suit/dark, "cost" = 150, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/suit/jacket/det_suit/noir, "cost" = 150, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/fedora/det_hat, "cost" = 75, "max_supply" = 2, "small_item" = TRUE, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/fedora/det_hat/noir, "cost" = 75, "max_supply" = 2, "small_item" = TRUE, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/neck/tie/detective, "cost" = 50, "max_supply" = 2, "small_item" = TRUE, "access_budget" = ACCESS_SECURITY),
		// -- Security formal --
		list("path" = /obj/item/clothing/under/rank/security/officer/formal, "cost" = 150, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/suit/jacket/officer/blue, "cost" = 150, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/beret/sec/navyofficer, "cost" = 75, "max_supply" = 2, "access_budget" = ACCESS_SECURITY, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/rank/security/warden/formal, "cost" = 150, "max_supply" = 1, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/suit/jacket/warden/tan, "cost" = 150, "max_supply" = 1, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/beret/sec/navywarden, "cost" = 75, "max_supply" = 1, "access_budget" = ACCESS_SECURITY, "small_item" = TRUE),
		list("path" = /obj/item/clothing/under/rank/security/head_of_security/formal, "cost" = 150, "max_supply" = 1, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/suit/jacket/hos/blue, "cost" = 150, "max_supply" = 1, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/hats/hos/beret/navyhos, "cost" = 75, "max_supply" = 1, "access_budget" = ACCESS_SECURITY, "small_item" = TRUE),
		// -- Leather jackets --
		list("path" = /obj/item/clothing/suit/jacket/leather, "cost" = 150, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/jacket/leather/overcoat, "cost" = 150, "max_supply" = 3),
	)

// =============================================================================
// CASUAL WEAR  (ClothesMate casual clothing, hoodies, everyday wear)
// =============================================================================

/datum/cargo_list/clothing_casual
	entries = list(
		// -- Pants & jeans --
		list("path" = /obj/item/clothing/under/pants/jeans, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/pants/classicjeans, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/pants/blackjeans, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/pants/mustangjeans, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/pants/khaki, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/pants/white, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/pants/red, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/pants/black, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/pants/tan, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/pants/camo, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/pants/track, "cost" = 50, "max_supply" = 5),
		// -- Skirts --
		list("path" = /obj/item/clothing/under/dress/skirt, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/dress/skirt/blue, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/dress/skirt/red, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/dress/skirt/purple, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/dress/skirt/plaid, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/dress/skirt/plaid/blue, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/dress/skirt/plaid/green, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/dress/skirt/plaid/purple, "cost" = 50, "max_supply" = 5),
		// -- Other under --
		list("path" = /obj/item/clothing/under/misc/overalls, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/under/costume/kilt, "cost" = 75, "max_supply" = 3),
		// -- Hoodies --
		list("path" = /obj/item/clothing/suit/hooded/hoodie, "cost" = 75, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/hoodie/blue, "cost" = 75, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/hoodie/green, "cost" = 75, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/hoodie/orange, "cost" = 75, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/hoodie/pink, "cost" = 75, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/hoodie/red, "cost" = 75, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/hoodie/black, "cost" = 75, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/hoodie/yellow, "cost" = 75, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/hoodie/darkblue, "cost" = 75, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/hoodie/teal, "cost" = 75, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/hoodie/purple, "cost" = 75, "max_supply" = 5),
		// -- Winter coats --
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/old, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/white, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat, "cost" = 100, "max_supply" = 5),
		// -- Jackets --
		list("path" = /obj/item/clothing/suit/jacket/puffer/vest, "cost" = 75, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/jacket/puffer, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/toggle/softshell, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/jacket/letterman, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/jacket/letterman_red, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/jacket/letterman_nanotrasen, "cost" = 150, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/jacket/miljacket, "cost" = 100, "max_supply" = 3),
		// -- Beanies --
		list("path" = /obj/item/clothing/head/beanie, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/black, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/red, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/green, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/darkblue, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/purple, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/yellow, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/orange, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/cyan, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/christmas, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/striped, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/stripedred, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/stripedblue, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/stripedgreen, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/beanie/rasta, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		// -- Casual hats --
		list("path" = /obj/item/clothing/head/cowboy, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		// -- Bandanas --
		list("path" = /obj/item/clothing/mask/bandana, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/bandana/striped, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/bandana/skull, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		// -- Scarves --
		list("path" = /obj/item/clothing/neck/scarf, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/black, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/pink, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/red, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/green, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/darkblue, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/purple, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/yellow, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/orange, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/cyan, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/zebra, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/scarf/christmas, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/stripedredscarf, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/stripedbluescarf, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/stripedgreenscarf, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/necklace/dope, "cost" = 75, "max_supply" = 3, "small_item" = TRUE),
		// -- Accessories --
		list("path" = /obj/item/clothing/glasses/regular, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/glasses/regular/jamjar, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/glasses/regular/circle, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/glasses/sunglasses, "cost" = 50, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/glasses/sunglasses/circle_sunglasses, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/glasses/orange, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/glasses/red, "cost" = 25, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/gloves/fingerless, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/ears/headphones, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/neck/petcollar, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		// -- Fanny packs --
		list("path" = /obj/item/storage/belt/fannypack, "cost" = 50, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/storage/belt/fannypack/blue, "cost" = 50, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/storage/belt/fannypack/red, "cost" = 50, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/storage/belt/fannypack/black, "cost" = 50, "max_supply" = 5, "small_item" = TRUE),
		// -- Religious headwear --
		list("path" = /obj/item/clothing/head/chaplain/kippah, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/chaplain/taqiyah/red, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/chaplain/taqiyah/white, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
	)

// =============================================================================
// SHOES & FOOTWEAR  (ClothesMate shoes, all standard footwear)
// =============================================================================

/datum/cargo_list/clothing_shoes
	small_item = TRUE
	entries = list(
		// -- Sneakers --
		list("path" = /obj/item/clothing/shoes/sneakers/black, "cost" = 25, "max_supply" = 8),
		list("path" = /obj/item/clothing/shoes/sneakers/brown, "cost" = 25, "max_supply" = 8),
		list("path" = /obj/item/clothing/shoes/sneakers/yellow, "cost" = 25, "max_supply" = 8),
		list("path" = /obj/item/clothing/shoes/sneakers/green, "cost" = 25, "max_supply" = 8),
		list("path" = /obj/item/clothing/shoes/sneakers/blue, "cost" = 25, "max_supply" = 8),
		list("path" = /obj/item/clothing/shoes/sneakers/purple, "cost" = 25, "max_supply" = 8),
		list("path" = /obj/item/clothing/shoes/sneakers/red, "cost" = 25, "max_supply" = 8),
		list("path" = /obj/item/clothing/shoes/sneakers/orange, "cost" = 25, "max_supply" = 8),
		list("path" = /obj/item/clothing/shoes/sneakers/white, "cost" = 25, "max_supply" = 8),
		// -- Boots --
		list("path" = /obj/item/clothing/shoes/winterboots, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/shoes/jackboots, "cost" = 75, "max_supply" = 5),
		list("path" = /obj/item/clothing/shoes/jackboots_replica, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/shoes/jackboots_replica/white, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/shoes/workboots, "cost" = 50, "max_supply" = 5),
		// -- Sandals --
		list("path" = /obj/item/clothing/shoes/sandal, "cost" = 25, "max_supply" = 5),
		// -- Galoshes --
		list("path" = /obj/item/clothing/shoes/galoshes, "cost" = 300, "max_supply" = 3),
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
// UNIFORMS & WORK WEAR  (Department-specific clothing from wardrobes)
// =============================================================================

/datum/cargo_list/clothing_uniforms
	entries = list(
		// -- General work wear --
		list("path" = /obj/item/clothing/suit/hazardvest, "cost" = 75, "max_supply" = 6),
		list("path" = /obj/item/clothing/suit/apron, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/apron/overalls, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/apron/chef, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/apron/surgical, "cost" = 75, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/apron/purple_bartender, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/clothing/suit/toggle/labcoat, "cost" = 100, "max_supply" = 6),
		list("path" = /obj/item/clothing/suit/toggle/labcoat/science, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/clothing/suit/toggle/labcoat/chemist, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/suit/toggle/labcoat/genetics, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/suit/toggle/labcoat/virologist, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/suit/toggle/labcoat/paramedic, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/suit/toggle/chef, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/utility/chefhat, "cost" = 50, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/surgical, "cost" = 25, "max_supply" = 8, "small_item" = TRUE),
		list("path" = /obj/item/clothing/accessory/pocketprotector, "cost" = 25, "max_supply" = 8, "small_item" = TRUE),
		list("path" = /obj/item/clothing/gloves/color/latex, "cost" = 50, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/clothing/gloves/color/latex/nitrile, "cost" = 50, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/clothing/gloves/color/black, "cost" = 50, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/costume/nursehat, "cost" = 50, "max_supply" = 5, "small_item" = TRUE),
		// -- Security uniforms --
		list("path" = /obj/item/clothing/under/rank/security/officer, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/rank/security/officer/skirt, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/rank/security/officer/white, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/rank/security/officer/grey, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/rank/security/officer/blueshirt, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/rank/security/officer/corporate, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/rank/security/detective, "cost" = 100, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/rank/security/detective/skirt, "cost" = 100, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/rank/security/detective/grey, "cost" = 100, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/under/rank/security/detective/grey/skirt, "cost" = 100, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/beret/sec, "cost" = 50, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/beret/corpsec, "cost" = 50, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/head/soft/sec, "cost" = 50, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/mask/bandana/striped/security, "cost" = 25, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/security, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/detective, "cost" = 100, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		// -- Medical uniforms --
		list("path" = /obj/item/clothing/under/rank/medical/doctor, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/doctor/skirt, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/doctor/blue, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/doctor/green, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/doctor/purple, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/doctor/nurse, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/paramedic, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/paramedic/skirt, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/chemist, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/chemist/skirt, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/geneticist, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/geneticist/skirt, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/virologist, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/under/rank/medical/virologist/skirt, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/head/beret/medical, "cost" = 50, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/head/beret/medical/paramedic, "cost" = 50, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/head/soft/paramedic, "cost" = 50, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/mask/bandana/striped/medical, "cost" = 25, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/medical, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/chemist, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/geneticist, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/virologist, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		// -- Engineering uniforms --
		list("path" = /obj/item/clothing/under/rank/engineering/engineer, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/clothing/under/rank/engineering/engineer/hazard, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/clothing/under/rank/engineering/engineer/skirt, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/clothing/under/rank/engineering/atmospheric_technician, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/clothing/under/rank/engineering/atmospheric_technician/skirt, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/clothing/head/beret/engi, "cost" = 50, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/clothing/head/beret/atmos, "cost" = 50, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/clothing/mask/bandana/striped/engineering, "cost" = 25, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/engineering, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/engineering/atmos, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		// -- Science uniforms --
		list("path" = /obj/item/clothing/under/rank/rnd/scientist, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/clothing/under/rank/rnd/scientist/skirt, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/clothing/under/rank/rnd/roboticist, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/clothing/under/rank/rnd/roboticist/skirt, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/clothing/under/rank/rnd/roboticist/retro, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/clothing/head/beret/science, "cost" = 50, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/clothing/head/cowboy/science, "cost" = 50, "max_supply" = 3, "small_item" = TRUE, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/clothing/mask/bandana/striped/science, "cost" = 25, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/science, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_RESEARCH),
		// -- Cargo uniforms --
		list("path" = /obj/item/clothing/under/rank/cargo/tech, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_CARGO),
		list("path" = /obj/item/clothing/under/rank/cargo/tech/skirt, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_CARGO),
		list("path" = /obj/item/clothing/under/rank/cargo/miner, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_CARGO),
		list("path" = /obj/item/clothing/head/soft/cargo, "cost" = 50, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_CARGO),
		list("path" = /obj/item/clothing/head/beret/cargo, "cost" = 50, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_CARGO),
		list("path" = /obj/item/clothing/mask/bandana/striped/cargo, "cost" = 25, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_CARGO),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/cargo, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_CARGO),
		list("path" = /obj/item/clothing/head/costume/mailman, "cost" = 50, "max_supply" = 3, "small_item" = TRUE, "access_budget" = ACCESS_CARGO),
		list("path" = /obj/item/clothing/under/misc/mailman, "cost" = 75, "max_supply" = 3, "access_budget" = ACCESS_CARGO),
		list("path" = /obj/item/clothing/under/misc/mailman/skirt, "cost" = 75, "max_supply" = 3, "access_budget" = ACCESS_CARGO),
		// -- Civilian / service uniforms --
		list("path" = /obj/item/clothing/under/rank/civilian/bartender, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/bartender/purple, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/bartender/skirt, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/chef, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/chef/skirt, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/altchef, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/hydroponics, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/hydroponics/skirt, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/janitor, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/janitor/skirt, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/under/rank/civilian/chaplain, "cost" = 100, "max_supply" = 2),
		list("path" = /obj/item/clothing/under/rank/civilian/chaplain/skirt, "cost" = 100, "max_supply" = 2),
		list("path" = /obj/item/clothing/under/rank/civilian/curator, "cost" = 100, "max_supply" = 2),
		list("path" = /obj/item/clothing/under/rank/civilian/curator/skirt, "cost" = 100, "max_supply" = 2),
		list("path" = /obj/item/clothing/suit/hooded/wintercoat/hydro, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/head/cowboy, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/clothing/accessory/armband/hydro, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/bandana/striped/botany, "cost" = 25, "max_supply" = 4, "small_item" = TRUE),
		list("path" = /obj/item/clothing/mask/bandana/purple, "cost" = 25, "max_supply" = 4, "small_item" = TRUE),
		// -- Soft caps --
		list("path" = /obj/item/clothing/head/soft, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/soft/black, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/soft/purple, "cost" = 25, "max_supply" = 5, "small_item" = TRUE),
		// -- Chaplain robes --
		list("path" = /obj/item/clothing/suit/chaplainsuit/nun, "cost" = 100, "max_supply" = 2),
		list("path" = /obj/item/clothing/head/chaplain/nun_hood, "cost" = 50, "max_supply" = 2, "small_item" = TRUE),
	)

// =============================================================================
// BACKPACKS & BAGS (all standard department and civilian backpacks)
// =============================================================================

/datum/cargo_list/clothing_backpacks
	entries = list(
		// -- Security --
		list("path" = /obj/item/storage/backpack/security, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/storage/backpack/satchel/sec, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/storage/backpack/duffelbag/sec, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_SECURITY),
		// -- Medical --
		list("path" = /obj/item/storage/backpack/medic, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/storage/backpack/satchel/med, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/storage/backpack/duffelbag/med, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/storage/backpack/chemistry, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/storage/backpack/satchel/chem, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/storage/backpack/genetics, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/storage/backpack/satchel/gen, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/storage/backpack/virology, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/storage/backpack/satchel/vir, "cost" = 100, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		// -- Engineering --
		list("path" = /obj/item/storage/backpack/industrial, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/storage/backpack/satchel/eng, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/storage/backpack/duffelbag/engineering, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		// -- Science --
		list("path" = /obj/item/storage/backpack/science, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/storage/backpack/satchel/tox, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/storage/backpack/duffelbag/science, "cost" = 100, "max_supply" = 4, "access_budget" = ACCESS_RESEARCH),
		// -- Cargo --
		list("path" = /obj/item/storage/backpack/satchel/mail, "cost" = 75, "max_supply" = 3, "access_budget" = ACCESS_CARGO),
		// -- Civilian / service --
		list("path" = /obj/item/storage/backpack/botany, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/storage/backpack/satchel/hyd, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/storage/backpack/satchel/explorer, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/storage/backpack/cultpack, "cost" = 100, "max_supply" = 2),
		list("path" = /obj/item/storage/bag/books, "cost" = 50, "max_supply" = 3, "small_item" = TRUE),
	)
