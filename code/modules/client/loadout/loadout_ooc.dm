/datum/gear/ooc/char_slot
	display_name = "extra character slot"
	sort_category = "OOC"
	description = "An extra charslot. Pretty self-explanatory."
	cost = 10000

/datum/gear/ooc/char_slot/purchase(var/client/C)
	C?.prefs?.max_save_slots += 1

/datum/gear/ooc/real_antagtoken
	display_name = "antag token"
	sort_category = "OOC"
	description = "If you can afford it, you deserve it."
	cost = 100000

/datum/gear/ooc/real_antagtoken/purchase(var/client/C)
	C.inc_antag_token_count(1)
	message_admins("[C.ckey] has purchased a genuine antag token.")
	log_game("[C.ckey] has purchased a genuine antag token.")
