/datum/gear/ooc/char_slot
	display_name = "extra character slot"
	sort_category = "OOC"
	description = "An extra charslot. Pretty self-explanatory."
	cost = 10000

/datum/gear/ooc/char_slot/purchase(var/client/C)
	C?.prefs?.max_save_slots += 1

/datum/gear/ooc/species/fly
	display_name = "Fly Person"
	sort_category = "OOC"
	description = "be able to play as a fly person in the game."
	cost = 500

/datum/gear/ooc/species/fly/purchase(var/client/C)
	C?.fly = TRUE
