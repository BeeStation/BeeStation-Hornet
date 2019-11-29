/datum/gear/ooc/char_slot
	display_name = "extra character slot"
	sort_category = "OOC"
	description = "An extra charslot. Pretty self-explanatory."
	cost = 10000

/datum/gear/ooc/char_slot/purchase(var/client/C)
	C?.prefs?.max_save_slots += 1
