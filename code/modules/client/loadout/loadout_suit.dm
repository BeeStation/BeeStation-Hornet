/datum/gear/suit
	subtype_path = /datum/gear/suit
	slot = SLOT_WEAR_SUIT
	sort_category = "External Wear"

//WINTER COATS
/datum/gear/suit/coat
	subtype_path = /datum/gear/suit/coat

/datum/gear/suit/coat/grey
	display_name = "winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat

/datum/gear/suit/coat/job
	subtype_path = /datum/gear/suit/coat/job

/datum/gear/suit/coat/job/sec
	display_name = "winter coat, security"
	path = /obj/item/clothing/suit/hooded/wintercoat/security
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer")

/datum/gear/suit/coat/job/captain
	display_name = "winter coat, captain"
	path = /obj/item/clothing/suit/hooded/wintercoat/captain
	allowed_roles = list("Captain")

/datum/gear/suit/coat/job/med
	display_name = "winter coat, medical"
	path = /obj/item/clothing/suit/hooded/wintercoat/medical
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Chemist", "Paramedic", "Virologist")

/datum/gear/suit/coat/job/sci
	display_name = "winter coat, science"
	path = /obj/item/clothing/suit/hooded/wintercoat/science
	allowed_roles = list("Scientist", "Research Director")

/datum/gear/suit/coat/job/engi
	display_name = "winter coat, engineering"
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering
	allowed_roles = list("Chief Engineer", "Engineer")

/datum/gear/suit/coat/job/atmos
	display_name = "winter coat, atmospherics"
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	allowed_roles = list("Chief Engineer")

/datum/gear/suit/coat/job/hydro
	display_name = "winter coat, hydroponics"
	path = /obj/item/clothing/suit/hooded/wintercoat/hydro
	allowed_roles = list("Botanist")

/datum/gear/suit/coat/job/cargo
	display_name = "winter coat, cargo"
	path = /obj/item/clothing/suit/hooded/wintercoat/cargo
	allowed_roles = list("Quartermaster", "Cargo Technician")

/datum/gear/suit/coat/job/miner
	display_name = "winter coat, miner"
	path = /obj/item/clothing/suit/hooded/wintercoat/miner
	allowed_roles = list("Miner")

//JACKETS
/datum/gear/suit/leather_jacket
	display_name = "leather jacket"
	path = /obj/item/clothing/suit/jacket/leather

/datum/gear/suit/bomber_jacket
	display_name = "bomber jacket"
	path = /obj/item/clothing/suit/jacket

/datum/gear/suit/ol_miljacket
	display_name = "military jacket, olive"
	path = /obj/item/clothing/suit/jacket/miljacket

/datum/gear/suit/poncho
	display_name = "poncho, classic"
	path = /obj/item/clothing/suit/poncho

/datum/gear/suit/grponcho
	display_name = "poncho, green"
	path = /obj/item/clothing/suit/poncho/green

/datum/gear/suit/rdponcho
	display_name = "poncho, red"
	path = /obj/item/clothing/suit/poncho/red
