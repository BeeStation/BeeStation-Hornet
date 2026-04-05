/**
 * # Miscellaneous Cargo Items
 *
 * Office supplies, art supplies, instruments, religious items, party supplies,
 * smoking products, and other odds & ends.
 * Split into Office Supplies, Arts & Crafts, Instruments, Religious,
 * Party Supplies, and Smoking Products.
 */

// =============================================================================
// OFFICE SUPPLIES
// =============================================================================

/datum/cargo_list/misc_office
	small_item = TRUE
	entries = list(
		// -- Printer supplies --
		list("path" = /obj/item/toner, "cost" = 20, "max_supply" = 10),
		list("path" = /obj/item/toner/large, "cost" = 50, "max_supply" = 8),
		// -- Pens --
		list("path" = /obj/item/pen, "cost" = 5, "max_supply" = 15),
		list("path" = /obj/item/pen/blue, "cost" = 5, "max_supply" = 15),
		list("path" = /obj/item/pen/red, "cost" = 5, "max_supply" = 15),
		list("path" = /obj/item/pen/fourcolor, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/pen/fountain, "cost" = 30, "max_supply" = 6),
		list("path" = /obj/item/pen/brush, "cost" = 25, "max_supply" = 4),
		list("path" = /obj/item/pen/charcoal, "cost" = 10, "max_supply" = 6),
		list("path" = /obj/item/storage/box/fountainpens, "cost" = 200, "max_supply" = 3),
		// -- Paper & folders --
		list("path" = /obj/item/paper_bin, "cost" = 15, "max_supply" = 8),
		list("path" = /obj/item/folder/blue, "cost" = 5, "max_supply" = 10),
		list("path" = /obj/item/folder/red, "cost" = 5, "max_supply" = 10),
		list("path" = /obj/item/folder/yellow, "cost" = 5, "max_supply" = 10),
		list("path" = /obj/item/clipboard, "cost" = 10, "max_supply" = 8),
		list("path" = /obj/item/sticky_note_pile, "cost" = 10, "max_supply" = 8),
		list("path" = /obj/item/stack/wrapping_paper, "cost" = 25, "max_supply" = 6),
		// -- Stamps --
		list("path" = /obj/item/stamp, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/stamp/denied, "cost" = 15, "max_supply" = 6),
		// -- Photography --
		list("path" = /obj/item/camera, "cost" = 60, "max_supply" = 6),
		list("path" = /obj/item/camera_film, "cost" = 25, "max_supply" = 8),
		list("path" = /obj/item/storage/photo_album, "cost" = 30, "max_supply" = 4),
		// -- Labeling & pointers --
		list("path" = /obj/item/hand_labeler, "cost" = 40, "max_supply" = 4),
		list("path" = /obj/item/hand_labeler_refill, "cost" = 10, "max_supply" = 8),
		list("path" = /obj/item/laser_pointer, "cost" = 75, "max_supply" = 4),
		// -- Furniture (non-small) --
		list("path" = /obj/structure/filingcabinet/chestdrawer/wheeled, "cost" = 150, "max_supply" = 4, "small_item" = FALSE),
		list("path" = /obj/structure/desk_bell, "cost" = 15, "max_supply" = 4),
	)

/datum/cargo_crate/misc_office

// =============================================================================
// ARTS & CRAFTS
// =============================================================================

/datum/cargo_list/misc_arts
	small_item = TRUE
	entries = list(
		// -- Painting & drawing --
		list("path" = /obj/item/canvas/nineteen_nineteen, "cost" = 25, "max_supply" = 8),
		list("path" = /obj/item/canvas/twentythree_nineteen, "cost" = 35, "max_supply" = 6),
		list("path" = /obj/item/canvas/twentythree_twentythree, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/canvas/twentyfour_twentyfour, "cost" = 75, "max_supply" = 4),
		list("path" = /obj/item/paint_palette, "cost" = 30, "max_supply" = 6),
		list("path" = /obj/item/wallframe/painting, "cost" = 40, "max_supply" = 8),
		list("path" = /obj/structure/easel, "cost" = 75, "max_supply" = 4, "small_item" = FALSE),
		// -- Crayons & spray --
		list("path" = /obj/item/storage/crayons, "cost" = 25, "max_supply" = 6),
		list("path" = /obj/item/toy/crayon/rainbow, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/toy/crayon/spraycan, "cost" = 20, "max_supply" = 8),
		// -- Stickers --
		list("path" = /obj/item/vending_refill/sticker, "cost" = 100, "max_supply" = 4),
		// -- Fish & aquarium --
		list("path" = /obj/item/storage/fish_case/random, "cost" = 300, "max_supply" = 5),
		list("path" = /obj/item/fish_feed, "cost" = 25, "max_supply" = 6),
		list("path" = /obj/item/storage/box/aquarium_props, "cost" = 50, "max_supply" = 4),
		// -- Books --
		list("path" = /obj/item/book/random, "cost" = 40, "max_supply" = 8),
		list("path" = /obj/item/book/manual/random, "cost" = 60, "max_supply" = 6),
		list("path" = /obj/item/book/manuscript, "cost" = 25, "max_supply" = 6),
	)

/datum/cargo_crate/misc_arts

/datum/cargo_crate/misc_arts/aquarium_kit
	name = "Aquarium Starter Kit"
	cost = 1200
	max_supply = 2
	contains = list(
		/obj/item/book/fish_catalog,
		/obj/item/storage/fish_case/random/freshwater,
		/obj/item/storage/fish_case/random/freshwater,
		/obj/item/storage/fish_case/random/freshwater,
		/obj/item/fish_feed,
		/obj/item/storage/box/aquarium_props,
		/obj/item/aquarium_kit,
	)
	crate_type = /obj/structure/closet/crate/wooden

// =============================================================================
// INSTRUMENTS
// =============================================================================

/datum/cargo_list/misc_instruments
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/instrument/violin, "cost" = 120, "max_supply" = 3),
		list("path" = /obj/item/instrument/guitar, "cost" = 120, "max_supply" = 3),
		list("path" = /obj/item/instrument/eguitar, "cost" = 200, "max_supply" = 2),
		list("path" = /obj/item/instrument/banjo, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/instrument/glockenspiel, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/instrument/accordion, "cost" = 150, "max_supply" = 3),
		list("path" = /obj/item/instrument/trumpet, "cost" = 120, "max_supply" = 3),
		list("path" = /obj/item/instrument/saxophone, "cost" = 120, "max_supply" = 3),
		list("path" = /obj/item/instrument/trombone, "cost" = 120, "max_supply" = 3),
		list("path" = /obj/item/instrument/recorder, "cost" = 40, "max_supply" = 5),
		list("path" = /obj/item/instrument/harmonica, "cost" = 40, "max_supply" = 5),
		list("path" = /obj/item/instrument/piano_synth, "cost" = 250, "max_supply" = 2),
		list("path" = /obj/item/instrument/bikehorn, "cost" = 100, "max_supply" = 2),
		// -- Stationary instruments (non-small) --
		list("path" = /obj/structure/musician/piano/unanchored, "cost" = 400, "max_supply" = 2, "small_item" = FALSE),
	)

// =============================================================================
// RELIGIOUS
// =============================================================================

/datum/cargo_list/misc_religious
	crate_type = /obj/structure/closet/crate/secure
	access_budget = ACCESS_CHAPEL_OFFICE
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/holywater, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/storage/book/bible/booze, "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/clothing/neck/crucifix, "cost" = 25, "max_supply" = 6),
		list("path" = /obj/item/clothing/neck/crucifix/rosary, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/item/storage/fancy/candle_box, "cost" = 25, "max_supply" = 6),
		list("path" = /obj/item/clothing/suit/hooded/chaplain_hoodie, "cost" = 120, "max_supply" = 4),
	)

/datum/cargo_crate/misc_religious

// =============================================================================
// PARTY SUPPLIES
// =============================================================================

/datum/cargo_list/misc_party
	small_item = TRUE
	entries = list(
		// -- Glowsticks --
		list("path" = /obj/item/flashlight/glowstick, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/flashlight/glowstick/red, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/flashlight/glowstick/blue, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/flashlight/glowstick/cyan, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/flashlight/glowstick/orange, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/flashlight/glowstick/yellow, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/flashlight/glowstick/pink, "cost" = 10, "max_supply" = 10),
		// -- Shelter capsules --
		list("path" = /obj/item/survivalcapsule/party, "cost" = 800, "max_supply" = 2),
	)

/datum/cargo_crate/misc_party

// =============================================================================
// SMOKING PRODUCTS
// =============================================================================

/datum/cargo_list/misc_smoking
	small_item = TRUE
	entries = list(
		// -- Cigarettes (ShadyCigs vendor brands) --
		list("path" = /obj/item/storage/fancy/cigarettes, "cost" = 15, "max_supply" = 8),
		list("path" = /obj/item/storage/fancy/cigarettes/cigpack_uplift, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/storage/fancy/cigarettes/cigpack_robust, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/storage/fancy/cigarettes/cigpack_carp, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/storage/fancy/cigarettes/cigpack_midori, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/storage/fancy/cigarettes/dromedaryco, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/storage/fancy/cigarettes/cigpack_robustgold, "cost" = 50, "max_supply" = 3),
		// -- Cigars --
		list("path" = /obj/item/storage/fancy/cigarettes/cigars, "cost" = 80, "max_supply" = 3),
		list("path" = /obj/item/storage/fancy/cigarettes/cigars/havana, "cost" = 120, "max_supply" = 2),
		list("path" = /obj/item/storage/fancy/cigarettes/cigars/cohiba, "cost" = 175, "max_supply" = 2),
		// -- Accessories --
		list("path" = /obj/item/storage/fancy/rollingpapers, "cost" = 10, "max_supply" = 8),
		list("path" = /obj/item/lighter/greyscale, "cost" = 10, "max_supply" = 8),
		list("path" = /obj/item/lighter, "cost" = 30, "max_supply" = 4),
		list("path" = /obj/item/storage/box/matches, "cost" = 5, "max_supply" = 10),
	)

