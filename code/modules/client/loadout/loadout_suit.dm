/datum/gear/suit
	subtype_path = /datum/gear/suit
	slot = SLOT_WEAR_SUIT
	sort_category = "External Wear"
	cost = 2500

//ALT ARMOR, MEDICAL VESTS, + LABCOATS

/datum/gear/suit/labcoat
	subtype_path = /datum/gear/suit/labcoat

/datum/gear/suit/labcoat/brig_doc_hazard
	display_name = "brig physician's hazard vest"
	path = /obj/item/clothing/suit/hazardvest/brig_phys
	allowed_roles = list("Brig Physician")

/datum/gear/suit/labcoat/brig_doc
	display_name = "brig physician's labcoat"
	path = /obj/item/clothing/suit/toggle/labcoat/brig_phys
	allowed_roles = list("Brig Physician")

/datum/gear/suit/labcoat/emt
	display_name = "EMT labcoat"
	path = /obj/item/clothing/suit/toggle/labcoat/emt
	allowed_roles = list("Medical Doctor", "Chief Medical Officer", "Chemist", "Geneticist")

//WINTER COATS
/datum/gear/suit/wintercoat
	subtype_path = /datum/gear/suit/wintercoat
	cost = 5000

/datum/gear/suit/wintercoat/grey
	display_name = "winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat
	cost = 2500

/datum/gear/suit/wintercoat/captain
	display_name = "captain's winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/captain
	allowed_roles = list("Captain")

/datum/gear/suit/wintercoat/security
	display_name = "security winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/security
	allowed_roles = list("Security Officer", "Brig Physician", "Head of Security")

/datum/gear/suit/wintercoat/medical
	display_name = "medical winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/medical
	allowed_roles = list("Paramedic", "Medical Doctor", "Chief Medical Officer", "Chemist", "Geneticist")

/datum/gear/suit/wintercoat/science
	display_name = "science winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/science
	allowed_roles = list("Scientist", "Roboticist", "Research Director")

/datum/gear/suit/wintercoat/engineering
	display_name = "engineering winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering
	allowed_roles = list("Chief Engineer", "Station Engineer", "Atmospheric Technician")

/datum/gear/suit/wintercoat/hydro
	display_name = "hydroponics winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/hydro
	allowed_roles = list("Botanist")

/datum/gear/suit/wintercoat/hydro
	display_name = "hydroponics winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/hydro
	allowed_roles = list("Botanist")

/datum/gear/suit/wintercoat/cargo
	display_name = "cargo winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/cargo
	allowed_roles = list("Cargo Technician", "Quartermaster")

/datum/gear/suit/wintercoat/miner
	display_name = "mining winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/miner
	allowed_roles = list("Shaft Miner")

//JACKETS

/datum/gear/suit/jacket
	subtype_path = /datum/gear/suit/jacket
	cost = 2500

/datum/gear/suit/jacket/bomber
	display_name = "bomber jacket"
	path = /obj/item/clothing/suit/jacket

/datum/gear/suit/jacket/leather
	display_name = "leather jacket"
	path = /obj/item/clothing/suit/jacket/leather

/datum/gear/suit/jacket/leather/overcoat
	display_name = "leather overcoat"
	path = /obj/item/clothing/suit/jacket/leather/overcoat
	cost = 5000

/datum/gear/suit/jacket/miljacket
	display_name = "military jacket"
	path = /obj/item/clothing/suit/jacket/miljacket

/datum/gear/suit/jacket/letterman
	display_name = "letterman jacket, brown"
	path = /obj/item/clothing/suit/jacket/letterman

/datum/gear/suit/jacket/letterman_red
	display_name = "letterman jacket, red"
	path = /obj/item/clothing/suit/jacket/letterman_red

/datum/gear/suit/jacket/letterman_nanotrasen
	display_name = "letterman jacket, NanoTrasen blue"
	path = /obj/item/clothing/suit/jacket/letterman_nanotrasen
	cost = 5000

/datum/gear/suit/jacket/letterman_syndie
	display_name = "letterman jacket, Syndicate red"
	path = /obj/item/clothing/suit/jacket/letterman_syndie
	cost = 8000

/datum/gear/suit/jacket/joker
	display_name = "comedian's coat"
	path = /obj/item/clothing/suit/joker
	description = "You get what you deserve."
	allowed_roles = list("Clown")
	cost = 8000

/datum/gear/suit/jacket/lawyer
	display_name = "blue suit jacket"
	path = /obj/item/clothing/suit/toggle/lawyer
	allowed_roles = list("Lawyer")

/datum/gear/suit/jacket/lawyer/purple
	display_name = "purple suit jacket"
	path = /obj/item/clothing/suit/toggle/lawyer/purple
	allowed_roles = list("Lawyer")

/datum/gear/suit/jacket/lawyer/black
	display_name = "black suit jacket"
	path = /obj/item/clothing/suit/toggle/lawyer/black
	allowed_roles = list("Lawyer")

//PONCHOS

/datum/gear/suit/poncho
	subtype_path = /datum/gear/suit/poncho
	cost = 2000

/datum/gear/suit/poncho/classic
	display_name = "poncho, classic"
	path = /obj/item/clothing/suit/poncho

/datum/gear/suit/poncho/green
	display_name = "poncho, green"
	path = /obj/item/clothing/suit/poncho/green

/datum/gear/suit/poncho/red
	display_name = "poncho, red"
	path = /obj/item/clothing/suit/poncho/red
