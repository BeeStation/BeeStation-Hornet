/datum/keybinding/human
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/human/can_use(client/user)
	return ishuman(user.mob) && !user.mob.incapacitated()


/datum/keybinding/human/quick_equip
	keys = list("E")
	name = "quick_equip"
	full_name = "Quick equip"
	description = ""
	keybind_signal = COMSIG_KB_HUMAN_QUICKEQUIP_DOWN

/datum/keybinding/human/quick_equip/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = user.mob
	H.quick_equip()
	return TRUE


/datum/keybinding/human/quick_equip_belt
	keys = list("ShiftE")
	name = "quick_equip_belt"
	full_name = "Put Item In Belt"
	description = ""
	keybind_signal = COMSIG_KB_HUMAN_QUICKEQUIPBELT_DOWN

/datum/keybinding/human/quick_equip_belt/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = user.mob
	var/obj/item/thing = H.get_active_held_item()
	var/obj/item/equipped_belt = H.get_item_by_slot(ITEM_SLOT_BELT)
	if(!equipped_belt) // We also let you equip a belt like this
		if(!thing)
			to_chat(user, "<span class='notice'>You have no belt to take something out of.</span>")
			return TRUE
		if(H.equip_to_slot_if_possible(thing, ITEM_SLOT_BELT))
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
	var/datum/component/storage/STR = equipped_belt.GetComponent(/datum/component/storage)
	if(!STR.can_be_opened)
		return FALSE
	var/obj/item/stored = equipped_belt.contents[equipped_belt.contents.len]
	if(!stored || stored.on_found(H))
		return TRUE
	stored.attack_hand(H) // take out thing from belt
	return TRUE


/datum/keybinding/human/quick_equip_backpack
	keys = list("ShiftB")
	name = "quick_equip_backpack"
	full_name = "Put Item In Backpack"
	description = ""
	keybind_signal = COMSIG_KB_HUMAN_BAGEQUIP_DOWN

/datum/keybinding/human/quick_equip_backpack/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = user.mob
	var/obj/item/thing = H.get_active_held_item()
	var/obj/item/equipped_back = H.get_item_by_slot(ITEM_SLOT_BACK)
	if(!equipped_back) // We also let you equip a backpack like this
		if(!thing)
			to_chat(user, "<span class='notice'>You have no backpack to take something out of.</span>")
			return
		if(H.equip_to_slot_if_possible(thing, ITEM_SLOT_BACK))
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


/datum/keybinding/human/quick_equip_suit_storage
	keys = list("ShiftQ")
	name = "quick_equip_suit_storage"
	full_name = "Put Item In Suit Storage"
	description = ""
	keybind_signal = COMSIG_KB_HUMAN_SUITEQUIP_DOWN

/datum/keybinding/human/quick_equip_suit_storage/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = user.mob
	var/obj/item/thing = H.get_active_held_item()
	var/obj/item/stored = H.get_item_by_slot(ITEM_SLOT_SUITSTORE)
	if(!stored)
		if(!thing)
			to_chat(user, "<span class='notice'>There's nothing in your suit storage to take out.")
			return TRUE
		if(H.equip_to_slot_if_possible(thing, ITEM_SLOT_SUITSTORE))
			H.update_inv_hands()
			return TRUE
	if(thing && stored)
		to_chat(user, "<span class='notice'>There's already something in your suit storage!")
		return TRUE
	if(!stored || stored.on_found(H))
		return TRUE
	stored.attack_hand(H)
	return TRUE
