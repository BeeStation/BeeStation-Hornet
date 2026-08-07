/datum/gear/ooc
	subtype_path = /datum/gear/ooc
	sort_category = "OOC"
	cost = 10000
	is_equippable = FALSE

/datum/gear/ooc/char_slot
	display_name = "extra character slot"
	description = "An extra charslot. Pretty self-explanatory."
	cost = 10000
	path = /obj/item/toy/figure/captain

/datum/gear/ooc/char_slot/purchase(client/C)
	// This is only locally immediately after purchase - this will be incremented on load in preferences.dm
	C.prefs.max_save_slots += 1

/datum/gear/ooc/real_antagtoken
	display_name = "antag token"
	description = "If you can afford it, you deserve it."
	cost = 100000
	path = /obj/item/coin/antagtoken
	multi_purchase = TRUE

/datum/gear/ooc/real_antagtoken/purchase(client/C)
	INVOKE_ASYNC(C, TYPE_PROC_REF(/client, inc_antag_token_count), 1)
	message_admins("[C.ckey] has purchased a genuine antag token.")
	log_game("[C.ckey] has purchased a genuine antag token.")
