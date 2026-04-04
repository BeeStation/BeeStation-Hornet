/**
 * # Miscellaneous Cargo Items
 *
 * Office supplies, art supplies, instruments, religious items, party supplies,
 * and other odds & ends.
 * Split into Office Supplies, Arts & Crafts, Religious, Party Supplies, and Contraband.
 */

// =============================================================================
// OFFICE SUPPLIES
// =============================================================================

/datum/cargo_list/misc_office
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/toner, "cost" = 50, "max_supply" = 10),
		list("path" = /obj/item/toner/large, "cost" = 100, "max_supply" = 8),
		list("path" = /obj/item/pen, "cost" = 5, "max_supply" = 15),
		list("path" = /obj/item/paper_bin, "cost" = 30, "max_supply" = 8),
		list("path" = /obj/item/camera_film, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/stack/wrapping_paper, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/storage/box/fountainpens, "cost" = 500, "max_supply" = 3),
	)

/datum/cargo_crate/misc_office

/datum/cargo_crate/misc_office/paper
	name = "Office Supply Crate"
	cost = 800
	max_supply = 3
	contains = list(
		/obj/structure/filingcabinet/chestdrawer/wheeled,
		/obj/item/camera_film,
		/obj/item/hand_labeler,
		/obj/item/hand_labeler_refill,
		/obj/item/hand_labeler_refill,
		/obj/item/paper_bin,
		/obj/item/pen/fourcolor,
		/obj/item/pen/fourcolor,
		/obj/item/pen,
		/obj/item/pen/fountain,
		/obj/item/pen/blue,
		/obj/item/pen/red,
		/obj/item/folder/blue,
		/obj/item/folder/red,
		/obj/item/folder/yellow,
		/obj/item/clipboard,
		/obj/item/clipboard,
		/obj/item/stamp,
		/obj/item/stamp/denied,
		/obj/item/laser_pointer/purple,
		/obj/item/sticky_note_pile,
	)

/datum/cargo_crate/misc_office/book_crate
	name = "Book Crate"
	cost = 1000
	max_supply = 2
	contains = list(
		/obj/item/book/kindred,
		/obj/item/book/manual/random,
		/obj/item/book/manual/random,
		/obj/item/book/manual/random,
		/obj/item/book/random,
		/obj/item/book/random,
		/obj/item/book/random,
		/obj/item/book/manuscript,
	)
	crate_type = /obj/structure/closet/crate/wooden

// =============================================================================
// ARTS & CRAFTS
// =============================================================================

/datum/cargo_list/misc_arts
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/storage/fish_case/random, "cost" = 500, "max_supply" = 5),
	)

/datum/cargo_crate/misc_arts

/datum/cargo_crate/misc_arts/artsupply
	name = "Art Supply Crate"
	cost = 1000
	max_supply = 2
	contains = list(
		/obj/structure/easel,
		/obj/structure/easel,
		/obj/item/canvas/nineteen_nineteen,
		/obj/item/canvas/nineteen_nineteen,
		/obj/item/canvas/twentythree_nineteen,
		/obj/item/canvas/twentythree_nineteen,
		/obj/item/canvas/twentythree_twentythree,
		/obj/item/canvas/twentythree_twentythree,
		/obj/item/toy/crayon/rainbow,
		/obj/item/toy/crayon/rainbow,
		/obj/item/vending_refill/sticker,
	)
	crate_type = /obj/structure/closet/crate/wooden

/datum/cargo_crate/misc_arts/aquarium_kit
	name = "Aquarium Starter Kit"
	cost = 2000
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

/datum/cargo_crate/misc_arts/bigband
	name = "Big Band Instrument Crate"
	cost = 2500
	max_supply = 1
	contains = list(
		/obj/item/instrument/violin,
		/obj/item/instrument/guitar,
		/obj/item/instrument/glockenspiel,
		/obj/item/instrument/accordion,
		/obj/item/instrument/saxophone,
		/obj/item/instrument/trombone,
		/obj/item/instrument/recorder,
		/obj/item/instrument/harmonica,
		/obj/structure/musician/piano/unanchored,
	)
	crate_type = /obj/structure/closet/crate/wooden

// =============================================================================
// RELIGIOUS
// =============================================================================

/datum/cargo_crate/misc_religious

/datum/cargo_crate/misc_religious/religious_supplies
	name = "Religious Supplies Crate"
	cost = 1000
	max_supply = 2
	access_budget = ACCESS_CHAPEL_OFFICE
	contains = list(
		/obj/item/reagent_containers/cup/glass/bottle/holywater,
		/obj/item/reagent_containers/cup/glass/bottle/holywater,
		/obj/item/storage/book/bible/booze,
		/obj/item/storage/book/bible/booze,
		/obj/item/clothing/neck/crucifix/rosary,
		/obj/item/clothing/suit/hooded/chaplain_hoodie,
		/obj/item/clothing/suit/hooded/chaplain_hoodie,
	)

// =============================================================================
// PARTY SUPPLIES
// =============================================================================

/datum/cargo_crate/misc_party

/datum/cargo_crate/misc_party/party
	name = "Party Supplies Crate"
	cost = 2000
	max_supply = 2
	contains = list(
		/obj/item/storage/box/drinkingglasses,
		/obj/item/reagent_containers/cup/glass/shaker,
		/obj/item/reagent_containers/cup/glass/bottle/patron,
		/obj/item/reagent_containers/cup/glass/bottle/goldschlager,
		/obj/item/reagent_containers/cup/glass/bottle/ale,
		/obj/item/reagent_containers/cup/glass/bottle/ale,
		/obj/item/reagent_containers/cup/glass/bottle/beer,
		/obj/item/reagent_containers/cup/glass/bottle/beer,
		/obj/item/reagent_containers/cup/glass/bottle/beer,
		/obj/item/reagent_containers/cup/glass/bottle/beer,
		/obj/item/flashlight/glowstick,
		/obj/item/flashlight/glowstick/red,
		/obj/item/flashlight/glowstick/blue,
		/obj/item/flashlight/glowstick/cyan,
		/obj/item/flashlight/glowstick/orange,
		/obj/item/flashlight/glowstick/yellow,
		/obj/item/flashlight/glowstick/pink,
		/obj/item/survivalcapsule/party,
	)


