/datum/species/debug
	name = "CODER DISASTER"
	id = SPECIES_DEBUG
	bodyflag = FLAG_DEBUG_SPECIES
	changesource_flags = MIRROR_BADMIN
	sexes = 0

/datum/species/debug/get_custom_icons(part)
	switch(part)
		if("uniform")
			return 'icons/mob/species/debug/debug_all.dmi'
		if("gloves")
			return 'icons/mob/species/debug/debug_all.dmi'
		if("glasses")
			return 'icons/mob/species/debug/debug_all.dmi'
		if("ears")
			return 'icons/mob/species/debug/debug_all.dmi'
		if("shoes")
			return 'icons/mob/species/debug/debug_all.dmi'
		if("head")
			return 'icons/mob/species/debug/debug_all.dmi'
		if("belt")
			return 'icons/mob/species/debug/debug_all.dmi'
		if("suit")
			return 'icons/mob/species/debug/debug_all.dmi'
		if("mask")
			return 'icons/mob/species/debug/debug_all.dmi'
		if("back")
			return 'icons/mob/species/debug/debug_all.dmi'
		if("generic")
			return 'icons/mob/species/debug/debug_all.dmi'
		else
			return

/obj/item/clothing/head/costume/ushanka/spritesheet_debug
	name = "Racist Ushanka"
	desc = "The Return"
	flags_inv = HIDEEARS|HIDEHAIR
	icon_state = "ushankadown"
	item_state = "ushankadown"
	sprite_sheets = FLAG_DEBUG_SPECIES //The small emblem on the ushanka will appear green for the debug species instead of red
