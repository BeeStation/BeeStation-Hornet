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

/datum/cargo_item/misc_office

/datum/cargo_item/misc_office/toner
	name = "Toner Cartridge"
	item_path = /obj/item/toner
	cost = 50
	max_supply = 10
	small_item = TRUE

/datum/cargo_item/misc_office/toner_large
	name = "Large Toner Cartridge"
	item_path = /obj/item/toner/large
	cost = 100
	max_supply = 8
	small_item = TRUE

/datum/cargo_item/misc_office/pen
	name = "Pen"
	item_path = /obj/item/pen
	cost = 5
	max_supply = 15
	small_item = TRUE

/datum/cargo_item/misc_office/paper_bin
	name = "Paper Bin"
	item_path = /obj/item/paper_bin
	cost = 30
	max_supply = 8
	small_item = TRUE

/datum/cargo_item/misc_office/camera_film
	name = "Camera Film"
	item_path = /obj/item/camera_film
	cost = 50
	max_supply = 6
	small_item = TRUE

/datum/cargo_item/misc_office/wrapping_paper
	name = "Wrapping Paper"
	item_path = /obj/item/stack/wrapping_paper
	cost = 50
	max_supply = 6
	small_item = TRUE

/datum/cargo_item/misc_office/fountain_pen_box
	name = "Fountain Pen Box"
	item_path = /obj/item/storage/box/fountainpens
	cost = 500
	max_supply = 3
	small_item = TRUE

/datum/cargo_crate/misc_office

/datum/cargo_crate/misc_office/paper
	name = "Office Supply Crate"
	desc = "Contains a filing cabinet, pens, paper, folders, clipboards, stamps, a laser pointer, and sticky notes."
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
	desc = "Contains a codex gigas, random manuals, random books, and a manuscript."
	cost = 1000
	max_supply = 2
	contains = list(
		/obj/item/book/codex_gigas,
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

/datum/cargo_item/misc_arts

/datum/cargo_item/misc_arts/fish_case
	name = "Random Fish Case"
	item_path = /obj/item/storage/fish_case/random
	cost = 500
	max_supply = 5
	small_item = TRUE

/datum/cargo_crate/misc_arts

/datum/cargo_crate/misc_arts/artsupply
	name = "Art Supply Crate"
	desc = "Contains easels, canvases, rainbow crayons, and sticker refills."
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
	desc = "Contains a fish catalog, fish cases, fish feed, aquarium props, and an aquarium kit."
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
	desc = "Contains a violin, guitar, glockenspiel, accordion, saxophone, trombone, recorder, harmonica, and a piano."
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
	desc = "Contains holy water, bibles, a rosary, and chaplain hoodies."
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
	desc = "Contains drinks, glasses, a shaker, glowsticks, and a party capsule."
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

// =============================================================================
// CONTRABAND
// =============================================================================

/datum/cargo_crate/misc_contraband

/datum/cargo_crate/misc_contraband/contraband
	name = "Contraband Crate"
	desc = "A crate of illicit goods, drugs, and Syndicate paraphernalia."
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

/datum/cargo_crate/misc_contraband/specialops
	name = "Special Ops Supplies"
	desc = "A crate of dubiously-legal tactical equipment."
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

/datum/cargo_crate/misc_contraband/syndieclothes
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

/datum/cargo_crate/misc_contraband/syndicate
	name = "Syndicate Surplus Crate"
	desc = "A crate of Syndicate surplus goods. Contents are a mystery."
	cost = 20000
	max_supply = 1
	contraband = TRUE
	contains = list()
	crate_type = /obj/structure/closet/crate/internals

/datum/cargo_crate/misc_contraband/syndicate/fill(obj/structure/closet/crate/C)
