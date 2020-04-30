/datum/gear/hat
	subtype_path = /datum/gear/hat
	slot = SLOT_HEAD
	sort_category = "Headwear"
	species_blacklist = list("plasmaman") //Their helmet takes up the head slot
	cost = 800

//HARDHATS

/datum/gear/hat/hhat_yellow
	display_name = "hardhat, yellow"
	path = /obj/item/clothing/head/hardhat
	allowed_roles = list("Chief Engineer", "Station Engineer", "Atmospheric Technician")

/datum/gear/hat/hhat_orange
	display_name = "hardhat, orange"
	path = /obj/item/clothing/head/hardhat/orange
	allowed_roles = list("Chief Engineer", "Station Engineer", "Atmospheric Technician")

/datum/gear/hat/hhat_blue
	display_name = "hardhat, blue"
	path = /obj/item/clothing/head/hardhat/dblue
	allowed_roles = list("Chief Engineer", "Station Engineer", "Atmospheric Technician")

//CIVILIAN HATS & MISC

/datum/gear/hat/that
	display_name = "tophat"
	path = /obj/item/clothing/head/that
	cost = 1000

/datum/gear/hat/red_beret
	display_name = "red beret"
	path = /obj/item/clothing/head/beret
	cost = 2000

/datum/gear/hat/bowler
	display_name = "bowler hat"
	path = /obj/item/clothing/head/bowler
	cost = 2000

/datum/gear/hat/ushanka
	display_name = "space ushanka"
	path = /obj/item/clothing/head/ushanka
	cost = 2000

/datum/gear/hat/flatcap
	display_name = "flatcap"
	path = /obj/item/clothing/head/flatcap
	cost = 2000

/datum/gear/hat/fedora
	display_name = "fedora"
	path = /obj/item/clothing/head/fedora
	cost = 2000

/datum/gear/hat/sombrero
	display_name = "sombrero"
	path = /obj/item/clothing/head/sombrero
	cost = 2000

/datum/gear/hat/sombrero/green
	display_name = "green sombrero"
	path = /obj/item/clothing/head/sombrero/green

//SOFT CAPS

/datum/gear/hat/soft/red
	display_name = "cap, red"
	path = /obj/item/clothing/head/soft/red
	cost = 1500

/datum/gear/hat/soft/blue
	display_name = "cap, blue"
	path = /obj/item/clothing/head/soft/blue
	cost = 1500

/datum/gear/hat/soft/green
	display_name = "cap, green"
	path = /obj/item/clothing/head/soft/green
	cost = 1500

/datum/gear/hat/soft/yellow
	display_name = "cap, yellow"
	path = /obj/item/clothing/head/soft/yellow
	cost = 1500

/datum/gear/hat/soft/grey
	display_name = "cap, grey"
	path = /obj/item/clothing/head/soft/grey
	cost = 1500

/datum/gear/hat/soft/orange
	display_name = "cap, orange"
	path = /obj/item/clothing/head/soft/orange
	cost = 1500

/datum/gear/hat/soft/purple
	display_name = "cap, purple"
	path = /obj/item/clothing/head/soft/purple
	cost = 1500

/datum/gear/hat/soft/black
	display_name = "cap, black"
	path = /obj/item/clothing/head/soft/black
	cost = 1500

//BEANIES

/datum/gear/hat/beanie
	display_name = "beanie, white"
	path = /obj/item/clothing/head/beanie
	cost = 1500

/datum/gear/hat/beanie/black
	display_name = "beanie, black"
	path = /obj/item/clothing/head/beanie/black

/datum/gear/hat/beanie/red
	display_name = "beanie, red"
	path = /obj/item/clothing/head/beanie/red

/datum/gear/hat/beanie/green
	display_name = "beanie, green"
	path = /obj/item/clothing/head/beanie/green

/datum/gear/hat/beanie/darkblue
	display_name = "beanie, darkblue"
	path = /obj/item/clothing/head/beanie/darkblue

/datum/gear/hat/beanie/purple
	display_name = "beanie, purple"
	path = /obj/item/clothing/head/beanie/purple

/datum/gear/hat/beanie/yellow
	display_name = "beanie, yellow"
	path = /obj/item/clothing/head/beanie/yellow

/datum/gear/hat/beanie/orange
	display_name = "beanie, orange"
	path = /obj/item/clothing/head/beanie/orange

/datum/gear/hat/beanie/cyan
	display_name = "beanie, cyan"
	path = /obj/item/clothing/head/beanie/cyan

/datum/gear/hat/beanie/striped
	display_name = "beanie, striped"
	path = /obj/item/clothing/head/beanie/striped

/datum/gear/hat/beanie/stripedred
	display_name = "beanie, red striped"
	path = /obj/item/clothing/head/beanie/stripedred

/datum/gear/hat/beanie/stripedblue
	display_name = "beanie, blue striped"
	path = /obj/item/clothing/head/beanie/stripedblue

/datum/gear/hat/beanie/stripedgreen
	display_name = "beanie, green striped"
	path = /obj/item/clothing/head/beanie/stripedgreen

/datum/gear/hat/beanie/waldo
	display_name = "beanie, red striped with bobble"
	path = /obj/item/clothing/head/beanie/waldo
	cost = 7500

/datum/gear/hat/beanie/rasta
	display_name = "beanie, rastafarian stripes"
	path = /obj/item/clothing/head/beanie/rasta
	cost = 7500

//MEME HATS

/datum/gear/hat/speedwagon
	display_name = "extremely masculine hat"
	path = /obj/item/clothing/head/speedwagon
	cost = 25000

/datum/gear/hat/speedwagon_xl
	display_name = "extremely elongated masculine hat"
	path = /obj/item/clothing/head/speedwagon/cursed
	cost = 100000

/datum/gear/hat/delinquent
	display_name = "delinquent hat"
	path = /obj/item/clothing/head/delinquent
	cost = 5000

/datum/gear/hat/cueball
	display_name = "cubeball helmet"
	path = /obj/item/clothing/head/cueball
	cost = 5000

/datum/gear/hat/piratehat
	display_name = "pirate hat"
	description = "Yarr. Comes with one free pirate speak manual."
	path = /obj/item/clothing/head/pirate
	cost = 5000

/datum/gear/hat/tinfoil
	display_name = "tinfoil hat"
	path = /obj/item/clothing/head/foilhat
	cost = 100000

/datum/gear/hat/tinfoil/plasmaman
	display_name = "tinfoil envirosuit helmet"
	path = /obj/item/clothing/head/foilhat/plasmaman
	species_whitelist = list("plasmaman")
