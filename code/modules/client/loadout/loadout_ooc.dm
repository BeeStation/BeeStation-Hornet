/datum/gear/ooc
	subtype_path = /datum/gear/ooc
	sort_category = "OOC"
	cost = 10000
	is_equippable = FALSE

/datum/gear/ooc/char_slot
	display_name = "extra character slot"
	description = "An extra charslot, allowing you to create and manage more characters."
	cost = 2000
	path = /obj/item/toy/figure/assistant
	gear_flags = GEAR_MULTI_PURCHASE

/datum/gear/ooc/char_slot/can_purchase(client/user, silent)
	if (!..())
		return FALSE
	if (user.player_details.loadout.get_purchased_count(src) >= CHARACTER_SLOTS_PURCHASABLE)
		if (!silent)
			to_chat(user, span_warning("You have reached the maximum number of purchasable slots!"))
		return FALSE
	return TRUE

/datum/gear/ooc/char_slot/purchase(client/user, purchase_count)
	user.prefs.compute_save_slot_count(user.player_details.loadout)

/datum/gear/ooc/real_antagtoken
	display_name = "antag token"
	description = "If you can afford it, you deserve it."
	cost = 100000
	path = /obj/item/coin/antagtoken
	gear_flags = GEAR_MULTI_PURCHASE

/datum/gear/ooc/real_antagtoken/purchase(datum/preferences/prefs, client/user)
	INVOKE_ASYNC(user, TYPE_PROC_REF(/client, inc_antag_token_count), 1)
	message_admins("[user.ckey] has purchased a genuine antag token.")
	log_game("[user.ckey] has purchased a genuine antag token.")
