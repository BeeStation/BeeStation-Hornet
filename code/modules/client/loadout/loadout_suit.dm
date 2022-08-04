/datum/gear/suit
	subtype_path = /datum/gear/suit
	slot = ITEM_SLOT_OCLOTHING
	sort_category = "External Wear"
	cost = 2500

//ALT ARMOR, MEDICAL VESTS, + LABCOATS

/datum/gear/suit/labcoat
	subtype_path = /datum/gear/suit/labcoat

/datum/gear/suit/labcoat/brig_doc_hazard
	display_name = "brig physician's hazard vest"
	path = /obj/item/clothing/suit/hazardvest/brig_physician
	allowed_roles = list(JOB_NAME_BRIGPHYSICIAN)

/datum/gear/suit/labcoat/brig_doc
	display_name = "brig physician's labcoat"
	path = /obj/item/clothing/suit/toggle/labcoat/brig_physician
	allowed_roles = list(JOB_NAME_BRIGPHYSICIAN)

/datum/gear/suit/labcoat/paramedic
	display_name = "EMT labcoat"
	path = /obj/item/clothing/suit/toggle/labcoat/paramedic
	allowed_roles = list(JOB_NAME_MEDICALDOCTOR, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_CHEMIST, JOB_NAME_GENETICIST)

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
	allowed_roles = list(JOB_NAME_CAPTAIN)

/datum/gear/suit/wintercoat/security
	display_name = "security winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/security
	allowed_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_BRIGPHYSICIAN, JOB_NAME_HEADOFSECURITY, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE)

/datum/gear/suit/wintercoat/medical
	display_name = "medical winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/medical
	allowed_roles = list(JOB_NAME_PARAMEDIC, JOB_NAME_MEDICALDOCTOR, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_CHEMIST, JOB_NAME_GENETICIST, JOB_NAME_VIROLOGIST, JOB_NAME_BRIGPHYSICIAN)

/datum/gear/suit/wintercoat/science
	display_name = "science winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/science
	allowed_roles = list(JOB_NAME_SCIENTIST, JOB_NAME_ROBOTICIST, JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_EXPLORATIONCREW)

/datum/gear/suit/wintercoat/engineering
	display_name = "engineering winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering
	allowed_roles = list(JOB_NAME_CHIEFENGINEER, JOB_NAME_STATIONENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN)

/datum/gear/suit/wintercoat/atmos
	display_name = "atmospherics winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	allowed_roles = list(JOB_NAME_CHIEFENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN)

/datum/gear/suit/wintercoat/hydro
	display_name = "hydroponics winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/hydro
	allowed_roles = list(JOB_NAME_BOTANIST)

/datum/gear/suit/wintercoat/cargo
	display_name = "cargo winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/cargo
	allowed_roles = list(JOB_NAME_CARGOTECHNICIAN, JOB_NAME_QUARTERMASTER)

/datum/gear/suit/wintercoat/miner
	display_name = "mining winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/miner
	allowed_roles = list(JOB_NAME_SHAFTMINER)

//NOSTALGIC WINTER COATS

/datum/gear/suit/oldwintercoat
	subtype_path = /datum/gear/suit/oldwintercoat
	cost = 6000

/datum/gear/suit/oldwintercoat/grey
	display_name = "nostalgic winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/old
	cost = 3000

/datum/gear/suit/oldwintercoat/security
	display_name = "nostalgic security winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/security/old
	allowed_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_BRIGPHYSICIAN, JOB_NAME_HEADOFSECURITY, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE)

/datum/gear/suit/oldwintercoat/medical
	display_name = "nostalgic medical winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/medical/old
	allowed_roles = list(JOB_NAME_PARAMEDIC, JOB_NAME_MEDICALDOCTOR, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_CHEMIST, JOB_NAME_GENETICIST, JOB_NAME_VIROLOGIST, JOB_NAME_BRIGPHYSICIAN)

/datum/gear/suit/oldwintercoat/science
	display_name = "nostalgic science winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/science/old
	allowed_roles = list(JOB_NAME_SCIENTIST, JOB_NAME_ROBOTICIST, JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_EXPLORATIONCREW)

/datum/gear/suit/oldwintercoat/engineering
	display_name = "nostalgic engineering winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering/old
	allowed_roles = list(JOB_NAME_CHIEFENGINEER, JOB_NAME_STATIONENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN)

/datum/gear/suit/oldwintercoat/atmos
	display_name = "nostalgic atmospherics winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering/atmos/old
	allowed_roles = list(JOB_NAME_CHIEFENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN)

/datum/gear/suit/oldwintercoat/hydro
	display_name = "nostalgic hydroponics winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat/hydro/old
	allowed_roles = list(JOB_NAME_BOTANIST)

//JACKETS

/datum/gear/suit/jacket
	subtype_path = /datum/gear/suit/jacket
	cost = 2500

/datum/gear/suit/jacket/bomber
	display_name = "bomber jacket"
	path = /obj/item/clothing/suit/jacket

/datum/gear/suit/jacket/softshell
	display_name = "softshell jacket"
	path = /obj/item/clothing/suit/toggle/softshell

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
	display_name = "letterman jacket, Nanotrasen blue"
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
	allowed_roles = list(JOB_NAME_CLOWN)
	cost = 8000

/datum/gear/suit/jacket/lawyer
	display_name = "blue suit jacket"
	path = /obj/item/clothing/suit/toggle/lawyer
	allowed_roles = list(JOB_NAME_LAWYER)

/datum/gear/suit/jacket/lawyer/purple
	display_name = "purple suit jacket"
	path = /obj/item/clothing/suit/toggle/lawyer/purple
	allowed_roles = list(JOB_NAME_LAWYER)

/datum/gear/suit/jacket/lawyer/black
	display_name = "black suit jacket"
	path = /obj/item/clothing/suit/toggle/lawyer/black
	allowed_roles = list(JOB_NAME_LAWYER)

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

//ROBES
/datum/gear/suit/robe
	subtype_path = /datum/gear/suit/robe
	cost = 5000

/datum/gear/suit/robe/blackbishop
	display_name = "black bishop's robes"
	path = /obj/item/clothing/suit/chaplainsuit/bishoprobe/black
	allowed_roles = list(JOB_NAME_CHAPLAIN)
