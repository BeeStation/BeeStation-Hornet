//Thead's how mafia works (too funny for me to not keep in game)

/datum/outfit/crook
	name = "Level 1 - Crook"
	uniform = /obj/item/clothing/under/color/grey
	id = /obj/item/card/id
	ears = /obj/item/radio/headset
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/sneakers/black
	l_pocket = /obj/item/switchblade
	r_pocket = /obj/item/crowbar/red

	backpack_contents = list( /obj/item/storage/box/survival=1,\
	/obj/item/toy/crayon/spraycan = 1)

/datum/outfit/boss
	name = "Level 50 - Boss"
	uniform = /obj/item/clothing/under/color/grey
	id = /obj/item/card/id
	belt = /obj/item/storage/belt/military/gang
	gloves = /obj/item/clothing/gloves/gang
	neck = /obj/item/clothing/neck/necklace/dope
	shoes = /obj/item/clothing/shoes/gang
	ears = /obj/item/radio/headset
	back = /obj/item/storage/backpack
	mask =  /obj/item/clothing/mask/gskull

	r_pocket = /obj/item/switchblade

	backpack_contents = list( /obj/item/storage/box/survival=1,\
		/obj/item/restraints/legcuffs/bola/energy = 1)


/datum/outfit/clandestine
	name = "Clandestine"
	head = /obj/item/clothing/head/beanie/black
	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/jacket/bomber

/datum/outfit/prima
	name = "Prima"
	head = /obj/item/clothing/head/costume/chicken
	uniform = /obj/item/clothing/under/color/yellow
	suit = /obj/item/clothing/suit/costume/chickensuit

/datum/outfit/zerog
	name = "Zero-G"
	uniform = /obj/item/clothing/under/color/blue
	suit = /obj/item/clothing/suit/apron
	head = /obj/item/clothing/head/beanie/stripedblue

/datum/outfit/max
	name = "Max"
	head = /obj/item/clothing/head/hats/tophat
	uniform = /obj/item/clothing/under/costume/joker
	suit = /obj/item/clothing/suit/costume/joker

/datum/outfit/blasto
	name = "Blasto"
	head = /obj/item/clothing/head/beret
	uniform = /obj/item/clothing/under/suit/navy
	suit = /obj/item/clothing/suit/jacket/miljacket

/datum/outfit/waffle
	name = "Waffle"
	head = /obj/item/clothing/head/costume/sombrero/green
	uniform = /obj/item/clothing/under/suit/green
	suit = /obj/item/clothing/suit/costume/poncho/green

/datum/outfit/north
	name = "North"
	head = /obj/item/clothing/head/costume/snowman
	uniform = /obj/item/clothing/under/suit/white
	suit = /obj/item/clothing/suit/costume/snowman

/datum/outfit/omni
	name = "Omni"
	head = /obj/item/clothing/head/soft/blue
	uniform = /obj/item/clothing/under/color/teal
	suit = /obj/item/clothing/suit/apron/overalls

/datum/outfit/newton
	name = "Newton"
	head = /obj/item/clothing/head/costume/griffin
	uniform = /obj/item/clothing/under/color/brown
	suit = /obj/item/clothing/suit/toggle/owlwings/griffinwings

/datum/outfit/cyber
	name = "Cyber"
	head = /obj/item/clothing/head/helmet/rus_ushanka
	uniform = /obj/item/clothing/under/color/darkblue
	suit = /obj/item/clothing/suit/jacket/officer/tan

/datum/outfit/donk
	name = "Donk"
	head = /obj/item/clothing/head/beret/black
	uniform =  /obj/item/clothing/under/color/green
	suit = /obj/item/clothing/suit/jacket/puffer/vest

/datum/outfit/gene
	name = "Gene"
	head = /obj/item/clothing/head/soft/green
	uniform = /obj/item/clothing/under/color/green
	suit = /obj/item/clothing/suit/toggle/labcoat/mad

/datum/outfit/gib
	name = "Gib"
	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/toggle/lawyer/black
	head = /obj/item/clothing/head/hats/bowler

/datum/outfit/diablo
	name = "Diablo"
	uniform = /obj/item/clothing/under/color/red
	suit = /obj/item/clothing/suit/jacket/leather
	head = /obj/item/clothing/head/beret

/datum/outfit/psyke
	name = "Psyke"
	head = /obj/item/clothing/head/soft/rainbow
	suit = /obj/item/clothing/suit/costume/poncho/ponchoshame
	uniform = /obj/item/clothing/under/color/rainbow

/datum/outfit/osiron
	name = "Osiron"
	uniform = /obj/item/clothing/under/costume/roman
	head = /obj/item/clothing/head/helmet/roman/legionnaire/fake
	suit = /obj/item/clothing/suit/toggle/owlwings

/datum/outfit/sirius
	name = "Sirius"
	head = /obj/item/clothing/head/fedora
	uniform = /obj/item/clothing/under/color/white
	suit = /obj/item/clothing/suit/costume/nerdshirt

/datum/outfit/sleepingcarp
	name = "Sleeping Carp"
	uniform = /obj/item/clothing/under/color/lightpurple
	suit = /obj/item/clothing/suit/toggle/lawyer/purple
	head = /obj/item/clothing/head/hooded/carp_hood

/datum/outfit/rigatonifamily
	name = "Rigatoni family"
	uniform = /obj/item/clothing/under/rank/civilian/chef
	suit = /obj/item/clothing/suit/apron/chef
	head = /obj/item/clothing/head/utility/chefhat

/datum/outfit/weed
	name = "Weed"
	head = /obj/item/clothing/head/beanie/rasta
	uniform = /obj/item/clothing/under/color/green
	suit = /obj/item/clothing/suit/costume/vapeshirt

// Item path defines for icon states and such

/obj/item/clothing/shoes/gang
	name = "blinged-out boots"
	desc = "Stand aside peasants."
	icon_state = "bling"

/obj/item/storage/belt/military/gang
	name = "badass belt"
	icon_state = "gangbelt"
	inhand_icon_state = "gang"
	desc = "The belt buckle simply reads 'BAMF'."

/obj/item/clothing/mask/gskull
	name = "golden death mask"
	icon_state = "gskull"
	desc = "Strike terror, and envy, into the hearts of your enemies."

/obj/item/clothing/gloves/gang
	name = "braggadocio's brass knuckles"
	desc = "Purely decorative, don't find out the hard way."
	icon_state = "knuckles"
	w_class = 3
