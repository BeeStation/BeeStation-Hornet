/datum/export/gear

/datum/export/gear/sec_helmet
	cost = 100
	unit_name = "helmet"
	export_types = list(/obj/item/clothing/head/helmet/sec)

/datum/export/gear/sec_armor
	cost = 100
	unit_name = "armor vest"
	export_types = list(/obj/item/clothing/suit/armor/vest)

/datum/export/gear/riot_shield
	cost = 100
	unit_name = "riot shield"
	export_types = list(/obj/item/shield/riot)


/datum/export/gear/mask/breath
	cost = 2
	unit_name = "breath mask"
	export_types = list(/obj/item/clothing/mask/breath)

/datum/export/gear/mask/gas
	cost = 10
	unit_name = "gas mask"
	export_types = list(/obj/item/clothing/mask/gas)
	include_subtypes = FALSE


/datum/export/gear/space/helmet
	cost = 75
	unit_name = "space helmet"
	export_types = list(/obj/item/clothing/head/helmet/space, /obj/item/clothing/head/helmet/space/eva, /obj/item/clothing/head/helmet/space/nasavoid)
	include_subtypes = FALSE

/datum/export/gear/space/suit
	cost = 150
	unit_name = "space suit"
	export_types = list(/obj/item/clothing/suit/space, /obj/item/clothing/suit/space/eva, /obj/item/clothing/suit/space/nasavoid)
	include_subtypes = FALSE


/datum/export/gear/space/syndiehelmet
	cost = 150
	unit_name = "Syndicate space helmet"
	export_types = list(/obj/item/clothing/head/helmet/space/syndicate)

/datum/export/gear/space/syndiesuit
	cost = 300
	unit_name = "Syndicate space suit"
	export_types = list(/obj/item/clothing/suit/space/syndicate)


/datum/export/gear/radhelmet
	cost = 50
	unit_name = "radsuit hood"
	export_types = list(/obj/item/clothing/head/radiation)

/datum/export/gear/radsuit
	cost = 100
	unit_name = "radsuit"
	export_types = list(/obj/item/clothing/suit/radiation)

/datum/export/gear/biohood
	cost = 50
	unit_name = "biosuit hood"
	export_types = list(/obj/item/clothing/head/bio_hood)

/datum/export/gear/biosuit
	cost = 100
	unit_name = "biosuit"
	export_types = list(/obj/item/clothing/suit/bio_suit)

/datum/export/gear/bombhelmet
	cost = 50
	unit_name = "bomb suit hood"
	export_types = list(/obj/item/clothing/head/bomb_hood)

/datum/export/gear/bombsuit
	cost = 100
	unit_name = "bomb suit"
	export_types = list(/obj/item/clothing/suit/bomb_suit)

/datum/export/gear/goldpda
	cost = 500
	unit_name = "gilded PDA"
	export_types = list(/obj/item/pda/celebrity)

/datum/export/gear/envirosuitvip
	cost = 4500
	unit_name = "designer envirosuit"
	export_types = list(/obj/item/clothing/under/plasmaman/gold, /obj/item/clothing/head/helmet/space/plasmaman/gold)