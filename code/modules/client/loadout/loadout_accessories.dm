// DO NOT CHANGE DISPLAY NAME

/datum/gear/accessory
	subtype_path = /datum/gear/accessory
	slot = ITEM_SLOT_NECK
	sort_category = "Accessories"

/datum/gear/accessory/scarf
	subtype_path = /datum/gear/accessory/scarf
	cost = 1000

/datum/gear/accessory/scarf/red
	display_name = "scarf, red"
	path = /obj/item/clothing/neck/scarf/red

/datum/gear/accessory/scarf/green
	display_name = "scarf, green"
	path = /obj/item/clothing/neck/scarf/green

/datum/gear/accessory/scarf/darkblue
	display_name = "scarf, dark blue"
	path = /obj/item/clothing/neck/scarf/darkblue

/datum/gear/accessory/scarf/zebra
	display_name = "scarf, zebra"
	path = /obj/item/clothing/neck/scarf/zebra
	cost = 1200

/datum/gear/accessory/scarf/stripedred
	display_name = "scarf, striped red"
	path = /obj/item/clothing/neck/stripedredscarf
	cost = 1200

/datum/gear/accessory/scarf/stripedblue
	display_name = "scarf, striped blue"
	path = /obj/item/clothing/neck/stripedbluescarf
	cost = 1200

//armbands
/datum/gear/accessory/armband_red
	display_name = "armband, red"
	path = /obj/item/clothing/accessory/armband
	cost = 1000

/datum/gear/accessory/armband_blu
	display_name = "armband, blue"
	path = /obj/item/clothing/accessory/armband/blue
	cost = 1000

/datum/gear/accessory/armband_grn
	display_name = "armband, green"
	path = /obj/item/clothing/accessory/armband/green
	cost = 1000

//ties
/datum/gear/accessory/tie
	subtype_path = /datum/gear/accessory/tie
	cost = 1500

/datum/gear/accessory/tie/blue
	display_name = "tie, blue"
	path = /obj/item/clothing/neck/tie/blue

/datum/gear/accessory/tie/red
	display_name = "tie, red"
	path = /obj/item/clothing/neck/tie/red

/datum/gear/accessory/tie/black
	display_name = "tie, black"
	path = /obj/item/clothing/neck/tie/black

/datum/gear/accessory/tie/horrible
	display_name = "tie, horrible"
	path = /obj/item/clothing/neck/tie/horrible

//necklaces and shiz

/datum/gear/accessory/petcollar
	display_name = "pet collar"
	path = /obj/item/clothing/neck/petcollar
	cost = 20000

/datum/gear/accessory/necklace
	display_name = "dope necklace"
	path = /obj/item/clothing/neck/necklace/dope
	cost = 25000

/datum/gear/accessory/oldnecklace
	display_name = "necklace, gold"
	path = /obj/item/clothing/neck/necklace/dope
	cost = 25000

/datum/gear/accessory/headphones
	display_name = "headphones"
	path = /obj/item/clothing/ears/headphones
	cost = 2000

//GLASSES

/datum/gear/accessory/eyepatch
	display_name = "eyepatch"
	slot = ITEM_SLOT_EYES
	path = /obj/item/clothing/glasses/eyepatch
	cost = 1200

/datum/gear/accessory/monocle
	display_name = "monocle"
	slot = ITEM_SLOT_EYES
	path = /obj/item/clothing/glasses/monocle
	cost = 1200

/datum/gear/accessory/glasses
	display_name = "prescription glasses"
	slot = ITEM_SLOT_EYES
	path = /obj/item/clothing/glasses/regular
	cost = 3000

/datum/gear/accessory/glasses/jamjar
	display_name = "jam jar glasses"
	path = /obj/item/clothing/glasses/regular/jamjar

/datum/gear/accessory/glasses/hipster
	display_name = "hipster glasses"
	path = /obj/item/clothing/glasses/regular/hipster

/datum/gear/accessory/glasses/circle
	display_name = "circular glasses"
	path = /obj/item/clothing/glasses/regular/circle

/datum/gear/accessory/glasses/sunglasses
	display_name = "sunglasses"
	path = /obj/item/clothing/glasses/sunglasses

/datum/gear/accessory/glasses/cold
	display_name = "cold goggles"
	path = /obj/item/clothing/glasses/cold

/datum/gear/accessory/glasses/heat
	display_name = "heat goggles"
	path = /obj/item/clothing/glasses/heat

/datum/gear/accessory/glasses/orange
	display_name = "orange sunglasses"
	path = /obj/item/clothing/glasses/orange

/datum/gear/accessory/glasses/red
	display_name = "red glasses"
	path = /obj/item/clothing/glasses/red

//LIPSTICK

/datum/gear/accessory/cosmetics
	subtype_path = /datum/gear/accessory/cosmetics
	cost = 1200

/datum/gear/accessory/cosmetics/lipstick
	display_name = "lipstick, red"
	path = /obj/item/lipstick

/datum/gear/accessory/cosmetics/lipstick/black
	display_name = "lipstick, black"
	path = /obj/item/lipstick/black

/datum/gear/accessory/cosmetics/lipstick/purple
	display_name = "lipstick, purple"
	path = /obj/item/lipstick/purple

/datum/gear/accessory/cosmetics/lipstick/lime
	display_name = "lipstick, lime"
	path = /obj/item/lipstick/jade //its lime colored

/datum/gear/accessory/cosmetics/lipstick/random
	display_name = "lipstick, random color"
	path = /obj/item/lipstick/random
	cost = 1400

//Cloaks

/datum/gear/accessory/cloak
	subtype_path = /datum/gear/accessory/cloak
	cost = 10000

/datum/gear/accessory/cloak/blackbishop
	display_name = "black bishop's cloak"
	path = /obj/item/clothing/neck/cloak/chap/bishop/black
	allowed_roles = list("Chaplain")
