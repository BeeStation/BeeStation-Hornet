/datum/keybinding/human
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB


/datum/keybinding/human/quick_equip
	key = "E"
	name = "quick_equip"
	full_name = "Quick equip"
	description = ""

/datum/keybinding/human/quick_equip/down(client/user)
	if (!ishuman(user.mob)) return
	var/mob/living/carbon/human/H = user.mob
	H.quick_equip()
	return TRUE

/datum/keybinding/human/quick_equipother
	key = "Shift-E"
	name = "quick_equipother"
	full_name = "Quick Equip Other"
	description = "Equip item in non-selected hand"

/datum/keybinding/human/quick_equipother/down(client/user)
	if (!ishuman(user.mob)) return
	var/mob/living/carbon/human/H = user.mob
	H.quick_equipother()
	return TRUE



/datum/keybinding/mob/quickleftpocket
	key = "Ctrl-Q"
	name = "quickleftpocket"
	full_name = "Quick Left Pocket"
	description = "Switch items in and out of your left pocket"

/datum/keybinding/mob/quickleftpocket/down(client/user)
	if (!ishuman(user.mob)) return
	var/mob/living/carbon/human/H = user.mob
	H.quickleftpocket()
	return TRUE

/datum/keybinding/mob/quickrightpocket
	key = "Ctrl-E"
	name = "quickrightpocket"
	full_name = "Quick Right Pocket"
	description = "Switch items in and out of your right pocket"

/datum/keybinding/mob/quickrightpocket/down(client/user)
	if (!ishuman(user.mob)) return
	var/mob/living/carbon/human/H = user.mob
	H.quickrightpocket()
	return TRUE

/datum/keybinding/human/quick_equip_belt
	key = "Shift-Q"
	name = "quick_equip_belt"
	full_name = "Put Item In Belt"
	description = ""

/datum/keybinding/human/quick_equip_belt/down(client/user)
	if (!ishuman(user.mob)) return
	var/mob/living/carbon/human/H = user.mob
	var/obj/item/thing = H.get_active_held_item()
	var/obj/item/equipped_belt = H.get_item_by_slot(SLOT_BELT)
	if(!equipped_belt) // We also let you equip a belt like this
		if(!thing)
			to_chat(user, "<span class='notice'>You have no belt to take something out of.</span>")
			return TRUE
		if(H.equip_to_slot_if_possible(thing, SLOT_BELT))
			H.update_inv_hands()
		return TRUE
	if(!SEND_SIGNAL(equipped_belt, COMSIG_CONTAINS_STORAGE)) // not a storage item
		if(!thing)
			equipped_belt.attack_hand(H)
		else
			to_chat(user, "<span class='notice'>You can't fit anything in.</span>")
		return TRUE
	if(thing) // put thing in belt
		if(!SEND_SIGNAL(equipped_belt, COMSIG_TRY_STORAGE_INSERT, thing, user.mob))
			to_chat(user, "<span class='notice'>You can't fit anything in.</span>")
		return TRUE
	if(!equipped_belt.contents.len) // nothing to take out
		to_chat(user, "<span class='notice'>There's nothing in your belt to take out.</span>")
		return TRUE
	var/obj/item/stored = equipped_belt.contents[equipped_belt.contents.len]
	if(!stored || stored.on_found(H))
		return TRUE
	stored.attack_hand(H) // take out thing from belt
	return TRUE


/datum/keybinding/human/quick_equip_backpack
	key = "Shift-R"
	name = "quick_equip_backpack"
	full_name = "Put Item In Backpack"
	description = ""

/datum/keybinding/human/quick_equip_backpack/down(client/user)
	if (!ishuman(user.mob)) return
	var/mob/living/carbon/human/H = user.mob
	var/obj/item/thing = H.get_active_held_item()
	var/obj/item/equipped_back = H.get_item_by_slot(SLOT_BACK)
	if(!equipped_back) // We also let you equip a backpack like this
		if(!thing)
			to_chat(user, "<span class='notice'>You have no backpack to take something out of.</span>")
			return
		if(H.equip_to_slot_if_possible(thing, SLOT_BACK))
			H.update_inv_hands()
		return
	if(!SEND_SIGNAL(equipped_back, COMSIG_CONTAINS_STORAGE)) // not a storage item
		if(!thing)
			equipped_back.attack_hand(H)
		else
			to_chat(user, "<span class='notice'>You can't fit anything in.</span>")
		return
	if(thing) // put thing in backpack
		if(!SEND_SIGNAL(equipped_back, COMSIG_TRY_STORAGE_INSERT, thing, user.mob))
			to_chat(user, "<span class='notice'>You can't fit anything in.</span>")
		return
	if(!equipped_back.contents.len) // nothing to take out
		to_chat(user, "<span class='notice'>There's nothing in your backpack to take out.</span>")
		return
	var/obj/item/stored = equipped_back.contents[equipped_back.contents.len]
	if(!stored || stored.on_found(H))
		return
	stored.attack_hand(H) // take out thing from backpack
	return
