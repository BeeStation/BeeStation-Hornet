/**
 * # Clothing Cargo Items
 *
 * Costumes, formal wear, uniforms, and collectible hats.
 * Split into Costumes, Formal Wear, Collectible Hats, and Uniforms & Accessories.
 */

// =============================================================================
// COSTUMES
// =============================================================================

/datum/cargo_item/clothing_costumes
	category = "Clothing"
	subcategory = "Costumes"

// --- Wizard ---

/datum/cargo_item/clothing_costumes/wizard_staff
	name = "Wizard Staff"
	item_path = /obj/item/staff
	cost = 200
	max_supply = 3

/datum/cargo_item/clothing_costumes/wizard_robe
	name = "Fake Wizard Robe"
	item_path = /obj/item/clothing/suit/wizrobe/fake
	cost = 200
	max_supply = 3

/datum/cargo_item/clothing_costumes/wizard_hat
	name = "Fake Wizard Hat"
	item_path = /obj/item/clothing/head/wizard/fake
	cost = 200
	max_supply = 3
	small_item = TRUE

// --- Clown & Mime ---

/datum/cargo_item/clothing_costumes/clown_backpack
	name = "Clown Backpack"
	item_path = /obj/item/storage/backpack/clown
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_costumes/clown_shoes
	name = "Clown Shoes"
	item_path = /obj/item/clothing/shoes/clown_shoes
	cost = 50
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/clothing_costumes/clown_mask
	name = "Clown Mask"
	item_path = /obj/item/clothing/mask/gas/clown_hat
	cost = 50
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/clothing_costumes/clown_uniform
	name = "Clown Uniform"
	item_path = /obj/item/clothing/under/rank/civilian/clown
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_costumes/clown_pin
	name = "Clown Firing Pin"
	item_path = /obj/item/firing_pin/clown
	cost = 500
	max_supply = 2
	small_item = TRUE

/datum/cargo_item/clothing_costumes/mime_uniform
	name = "Mime Uniform"
	item_path = /obj/item/clothing/under/rank/civilian/mime
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_costumes/mime_mask
	name = "Mime Mask"
	item_path = /obj/item/clothing/mask/gas/mime
	cost = 50
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/clothing_costumes/french_beret
	name = "French Beret"
	item_path = /obj/item/clothing/head/frenchberet
	cost = 50
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/clothing_costumes/suspenders
	name = "Suspenders"
	item_path = /obj/item/clothing/suit/suspenders
	cost = 50
	max_supply = 3

/datum/cargo_item/clothing_costumes/mime_backpack
	name = "Mime Backpack"
	item_path = /obj/item/storage/backpack/mime
	cost = 100
	max_supply = 3

// --- Animal & Creature Costumes ---

/datum/cargo_item/clothing_costumes/snowman_head
	name = "Snowman Head"
	item_path = /obj/item/clothing/head/costume/snowman
	cost = 75
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/clothing_costumes/snowman_suit
	name = "Snowman Suit"
	item_path = /obj/item/clothing/suit/costume/snowman
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_costumes/chicken_head
	name = "Chicken Head"
	item_path = /obj/item/clothing/head/costume/chicken
	cost = 75
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/clothing_costumes/chicken_suit
	name = "Chicken Suit"
	item_path = /obj/item/clothing/suit/costume/chickensuit
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_costumes/monkey_mask
	name = "Monkey Mask"
	item_path = /obj/item/clothing/mask/gas/monkeymask
	cost = 75
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/clothing_costumes/monkey_suit
	name = "Monkey Suit"
	item_path = /obj/item/clothing/suit/costume/monkeysuit
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_costumes/cardborg_head
	name = "Cardborg Head"
	item_path = /obj/item/clothing/head/costume/cardborg
	cost = 75
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/clothing_costumes/cardborg_suit
	name = "Cardborg Suit"
	item_path = /obj/item/clothing/suit/costume/cardborg
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_costumes/xenos_head
	name = "Xenos Helmet"
	item_path = /obj/item/clothing/head/costume/xenos
	cost = 75
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/clothing_costumes/xenos_suit
	name = "Xenos Suit"
	item_path = /obj/item/clothing/suit/costume/xenos
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_costumes/ian_costume
	name = "Ian Costume"
	item_path = /obj/item/clothing/suit/hooded/ian_costume
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_costumes/carp_costume
	name = "Carp Costume"
	item_path = /obj/item/clothing/suit/hooded/carp_costume
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_costumes/bee_costume
	name = "Bee Costume"
	item_path = /obj/item/clothing/suit/hooded/bee_costume
	cost = 100
	max_supply = 3

// =============================================================================
// FORMAL WEAR
// =============================================================================

/datum/cargo_item/clothing_formal
	category = "Clothing"
	subcategory = "Formal Wear"

/datum/cargo_item/clothing_formal/black_tango
	name = "Black Tango Dress"
	item_path = /obj/item/clothing/under/dress/blacktango
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_formal/assistant_formal
	name = "Assistant Formal Uniform"
	item_path = /obj/item/clothing/under/misc/assistantformal
	cost = 50
	max_supply = 5

/datum/cargo_item/clothing_formal/blue_suit
	name = "Blue Lawyer Suit"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/bluesuit
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_formal/lawyer_jacket
	name = "Lawyer Jacket"
	item_path = /obj/item/clothing/suit/toggle/lawyer
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_formal/purple_suit
	name = "Purple Lawyer Suit"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/purpsuit
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_formal/lawyer_jacket_purple
	name = "Purple Lawyer Jacket"
	item_path = /obj/item/clothing/suit/toggle/lawyer/purple
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_formal/lawyer_jacket_black
	name = "Black Lawyer Jacket"
	item_path = /obj/item/clothing/suit/toggle/lawyer/black
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_formal/waistcoat
	name = "Waistcoat"
	item_path = /obj/item/clothing/accessory/waistcoat
	cost = 50
	max_supply = 5
	small_item = TRUE

/datum/cargo_item/clothing_formal/tie_blue
	name = "Blue Tie"
	item_path = /obj/item/clothing/neck/tie/blue
	cost = 25
	max_supply = 5
	small_item = TRUE

/datum/cargo_item/clothing_formal/tie_red
	name = "Red Tie"
	item_path = /obj/item/clothing/neck/tie/red
	cost = 25
	max_supply = 5
	small_item = TRUE

/datum/cargo_item/clothing_formal/tie_black
	name = "Black Tie"
	item_path = /obj/item/clothing/neck/tie/black
	cost = 25
	max_supply = 5
	small_item = TRUE

/datum/cargo_item/clothing_formal/bowler
	name = "Bowler Hat"
	item_path = /obj/item/clothing/head/hats/bowler
	cost = 50
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/clothing_formal/fedora
	name = "Fedora"
	item_path = /obj/item/clothing/head/fedora
	cost = 50
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/clothing_formal/flatcap
	name = "Flat Cap"
	item_path = /obj/item/clothing/head/flatcap
	cost = 50
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/clothing_formal/beret
	name = "Beret"
	item_path = /obj/item/clothing/head/beret
	cost = 50
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/clothing_formal/tophat
	name = "Top Hat"
	item_path = /obj/item/clothing/head/hats/tophat
	cost = 50
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/clothing_formal/laceup_shoes
	name = "Lace-up Shoes"
	item_path = /obj/item/clothing/shoes/laceup
	cost = 50
	max_supply = 5
	small_item = TRUE

/datum/cargo_item/clothing_formal/suit_charcoal
	name = "Charcoal Suit"
	item_path = /obj/item/clothing/under/suit/charcoal
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_formal/suit_navy
	name = "Navy Suit"
	item_path = /obj/item/clothing/under/suit/navy
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_formal/suit_burgundy
	name = "Burgundy Suit"
	item_path = /obj/item/clothing/under/suit/burgundy
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_formal/suit_checkered
	name = "Checkered Suit"
	item_path = /obj/item/clothing/under/suit/checkered
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_formal/suit_tan
	name = "Tan Suit"
	item_path = /obj/item/clothing/under/suit/tan
	cost = 100
	max_supply = 3

/datum/cargo_item/clothing_formal/burial_garments
	name = "Burial Garments"
	item_path = /obj/item/clothing/under/misc/burial
	cost = 100
	max_supply = 5
	small_item = TRUE

// =============================================================================
// COLLECTIBLE HATS
// =============================================================================

/datum/cargo_item/clothing_collectible
	category = "Clothing"
	subcategory = "Collectible Hats"
	small_item = TRUE

/datum/cargo_item/clothing_collectible/chef
	name = "Collectible Chef Hat"
	item_path = /obj/item/clothing/head/collectable/chef
	cost = 150
	max_supply = 1

/datum/cargo_item/clothing_collectible/paper
	name = "Collectible Paper Hat"
	item_path = /obj/item/clothing/head/collectable/paper
	cost = 150
	max_supply = 1

/datum/cargo_item/clothing_collectible/tophat
	name = "Collectible Top Hat"
	item_path = /obj/item/clothing/head/collectable/tophat
	cost = 150
	max_supply = 1

/datum/cargo_item/clothing_collectible/captain
	name = "Collectible Captain Hat"
	item_path = /obj/item/clothing/head/collectable/captain
	cost = 150
	max_supply = 1

/datum/cargo_item/clothing_collectible/beret
	name = "Collectible Beret"
	item_path = /obj/item/clothing/head/collectable/beret
	cost = 150
	max_supply = 1

/datum/cargo_item/clothing_collectible/welding
	name = "Collectible Welding Helmet"
	item_path = /obj/item/clothing/head/collectable/welding
	cost = 150
	max_supply = 1

/datum/cargo_item/clothing_collectible/flatcap
	name = "Collectible Flat Cap"
	item_path = /obj/item/clothing/head/collectable/flatcap
	cost = 150
	max_supply = 1

/datum/cargo_item/clothing_collectible/pirate
	name = "Collectible Pirate Hat"
	item_path = /obj/item/clothing/head/collectable/pirate
	cost = 150
	max_supply = 1

/datum/cargo_item/clothing_collectible/kitty
	name = "Collectible Kitty Ears"
	item_path = /obj/item/clothing/head/collectable/kitty
	cost = 150
	max_supply = 1

/datum/cargo_item/clothing_collectible/rabbitears
	name = "Collectible Rabbit Ears"
	item_path = /obj/item/clothing/head/collectable/rabbitears
	cost = 150
	max_supply = 1

/datum/cargo_item/clothing_collectible/wizard
	name = "Collectible Wizard Hat"
	item_path = /obj/item/clothing/head/collectable/wizard
	cost = 150
	max_supply = 1

/datum/cargo_item/clothing_collectible/hardhat
	name = "Collectible Hard Hat"
	item_path = /obj/item/clothing/head/collectable/hardhat
	cost = 150
	max_supply = 1

/datum/cargo_item/clothing_collectible/hos
	name = "Collectible HoS Hat"
	item_path = /obj/item/clothing/head/collectable/HoS
	cost = 150
	max_supply = 1

/datum/cargo_item/clothing_collectible/hop
	name = "Collectible HoP Hat"
	item_path = /obj/item/clothing/head/collectable/HoP
	cost = 150
	max_supply = 1

/datum/cargo_item/clothing_collectible/thunderdome
	name = "Collectible Thunderdome Helmet"
	item_path = /obj/item/clothing/head/collectable/thunderdome
	cost = 150
	max_supply = 1

/datum/cargo_item/clothing_collectible/swat
	name = "Collectible SWAT Helmet"
	item_path = /obj/item/clothing/head/collectable/swat
	cost = 150
	max_supply = 1

/datum/cargo_item/clothing_collectible/slime
	name = "Collectible Slime Hat"
	item_path = /obj/item/clothing/head/collectable/slime
	cost = 150
	max_supply = 1

/datum/cargo_item/clothing_collectible/police
	name = "Collectible Police Hat"
	item_path = /obj/item/clothing/head/collectable/police
	cost = 150
	max_supply = 1

/datum/cargo_item/clothing_collectible/xenom
	name = "Collectible Xeno Helmet"
	item_path = /obj/item/clothing/head/collectable/xenom
	cost = 150
	max_supply = 1

/datum/cargo_item/clothing_collectible/petehat
	name = "Collectible Pete Hat"
	item_path = /obj/item/clothing/head/collectable/petehat
	cost = 150
	max_supply = 1

// =============================================================================
// UNIFORMS & WORK WEAR
// =============================================================================

/datum/cargo_item/clothing_uniforms
	category = "Clothing"
	subcategory = "Uniforms & Work Wear"

/datum/cargo_item/clothing_uniforms/hazardvest
	name = "Hazard Vest"
	item_path = /obj/item/clothing/suit/hazardvest
	cost = 75
	max_supply = 6

/datum/cargo_item/clothing_uniforms/galoshes
	name = "Galoshes"
	item_path = /obj/item/clothing/shoes/galoshes
	cost = 300
	max_supply = 3

/datum/cargo_item/clothing_uniforms/nitrile_gloves
	name = "Nitrile Gloves"
	item_path = /obj/item/clothing/gloves/color/latex/nitrile
	cost = 50
	max_supply = 6
	small_item = TRUE

// =============================================================================
// CLOTHING CRATES
// =============================================================================

/datum/cargo_crate/clothing
	category = "Clothing"
	subcategory = "Clothing Packs"

/datum/cargo_crate/clothing/securityclothes
	name = "Security Formal Wear"
	desc = "Contains formal uniforms and accessories for Security, Warden, and HoS."
	cost = 1500
	max_supply = 2
	access_budget = ACCESS_SECURITY
	contains = list(
		/obj/item/clothing/under/rank/security/officer/formal,
		/obj/item/clothing/under/rank/security/officer/formal,
		/obj/item/clothing/suit/jacket/officer/blue,
		/obj/item/clothing/suit/jacket/officer/blue,
		/obj/item/clothing/head/beret/sec/navyofficer,
		/obj/item/clothing/head/beret/sec/navyofficer,
		/obj/item/clothing/under/rank/security/warden/formal,
		/obj/item/clothing/suit/jacket/warden/tan,
		/obj/item/clothing/head/beret/sec/navywarden,
		/obj/item/clothing/under/rank/security/head_of_security/formal,
		/obj/item/clothing/suit/jacket/hos/blue,
		/obj/item/clothing/head/hats/hos/beret/navyhos,
	)
	crate_type = /obj/structure/closet/crate/secure/gear

/datum/cargo_crate/clothing/contraband
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
	crate_type = /obj/structure/closet/crate/wooden
