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
	display_name = "hat, tophat"
	path = /obj/item/clothing/head/that
	cost = 1000

/datum/gear/hat/red_beret
	display_name = "hat, red beret"
	path = /obj/item/clothing/head/beret
	cost = 2000

/datum/gear/hat/bowler
	display_name = "hat, bowler"
	path = /obj/item/clothing/head/bowler
	cost = 2000

/datum/gear/hat/bowler
	display_name = "hat, space ushanka"
	path = /obj/item/clothing/head/ushanka
	cost = 2000

/datum/gear/hat/flatcap
	display_name = "hat, flatcap"
	path = /obj/item/clothing/head/flatcap
	cost = 2000

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
