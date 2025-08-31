/mob/living/carbon/get_item_by_slot(slot_id)
	switch(slot_id)
		if(ITEM_SLOT_BACK)
			return back
		if(ITEM_SLOT_MASK)
			return wear_mask
		if(ITEM_SLOT_NECK)
			return wear_neck
		if(ITEM_SLOT_HEAD)
			return head
		if(ITEM_SLOT_HANDCUFFED)
			return handcuffed
		if(ITEM_SLOT_LEGCUFFED)
			return legcuffed
	return ..()

/mob/living/carbon/get_slot_by_item(obj/item/looking_for)
	if(looking_for == back)
		return ITEM_SLOT_BACK

	if(back && (looking_for in back))
		return ITEM_SLOT_BACKPACK

	if(looking_for == wear_mask)
		return ITEM_SLOT_MASK

	if(looking_for == wear_neck)
		return ITEM_SLOT_NECK

	if(looking_for == head)
		return ITEM_SLOT_HEAD

	if(looking_for == handcuffed)
		return ITEM_SLOT_HANDCUFFED

	if(looking_for == legcuffed)
		return ITEM_SLOT_LEGCUFFED

	return ..()

/mob/living/carbon/proc/equip_in_one_of_slots(obj/item/I, list/slots, qdel_on_fail = TRUE)
	for(var/slot in slots)
		if(equip_to_slot_if_possible(I, slots[slot], qdel_on_fail = FALSE, disable_warning = TRUE))
			return slot
	if(qdel_on_fail)
		qdel(I)
	return null

//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
/mob/living/carbon/equip_to_slot(obj/item/equipping, slot, initial = FALSE)
	if(!slot)
		return
	if(!istype(equipping))
		return

	var/index = get_held_index_of_item(equipping)
	if(index)
		held_items[index] = null

	if(equipping.pulledby)
		equipping.pulledby.stop_pulling()

	equipping.screen_loc = null
	if(client)
		client.screen -= equipping
	if(observers?.len)
		for(var/mob/dead/observe as anything in observers)
			if(observe.client)
				observe.client.screen -= equipping
	//Call pickup behaviour on items put on mobs
	if(!(equipping.item_flags & PICKED_UP))
		equipping.pickup(src)
	equipping.forceMove(src)
	equipping.plane = ABOVE_HUD_PLANE
	var/not_handled = FALSE

	switch(slot)
		if(ITEM_SLOT_BACK)
			if(back)
				return
			back = equipping
			update_worn_back()
		if(ITEM_SLOT_MASK)
			if(wear_mask)
				return
			wear_mask = equipping
			update_worn_mask()
		if(ITEM_SLOT_HEAD)
			if(head)
				return
			head = equipping
			SEND_SIGNAL(src, COMSIG_CARBON_EQUIP_HAT, equipping)
			update_worn_head()
		if(ITEM_SLOT_NECK)
			if(wear_neck)
				return
			wear_neck = equipping
			update_worn_neck(equipping)
		if(ITEM_SLOT_HANDCUFFED)
			set_handcuffed(equipping)
			update_handcuffed()
		if(ITEM_SLOT_LEGCUFFED)
			legcuffed = equipping
			update_worn_legcuffs()
		if(ITEM_SLOT_HANDS)
			put_in_hands(equipping)
			update_held_items()
		if(ITEM_SLOT_BACKPACK)
			if(!back || !back.atom_storage?.attempt_insert(equipping, src, override = TRUE))
				not_handled = TRUE
		else
			not_handled = TRUE

	//Item has been handled at this point and equipped callback can be safely called
	//We cannot call it for items that have not been handled as they are not yet correctly
	//in a slot (handled further down inheritance chain, probably living/carbon/human/equip_to_slot
	if(!not_handled)
		has_equipped(equipping, slot, initial)

	return not_handled

/mob/living/carbon/get_equipped_speed_mod_items()
	return ..() + get_equipped_items()

/// This proc is called after an item has been successfully handled and equipped to a slot.
/mob/living/carbon/proc/has_equipped(obj/item/item, slot, initial = FALSE)
	return item.equipped(src, slot, initial)

/mob/living/carbon/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE, was_thrown = FALSE, silent = FALSE)
	. = ..() //Sets the default return value to what the parent returns.
	if(!. || !I) //We don't want to set anything to null if the parent returned 0.
		return

	var/not_handled = FALSE //if we actually unequipped an item, this is because we dont want to run this proc twice, once for carbons and once for humans
	if(I == head)
		head = null
		SEND_SIGNAL(src, COMSIG_CARBON_UNEQUIP_HAT, I, force, newloc, no_move, invdrop, silent)
		if(!QDELETED(src))
			update_worn_head()
	else if(I == back)
		back = null
		if(!QDELETED(src))
			update_worn_back()
	else if(I == wear_mask)
		wear_mask = null
		if(!QDELETED(src))
			update_worn_mask()
	else if(I == wear_neck)
		wear_neck = null
		if(!QDELETED(src))
			update_worn_neck(I)
	else if(I == handcuffed)
		set_handcuffed(null)
		if(buckled && buckled.buckle_requires_restraints)
			buckled.unbuckle_mob(src)
		if(!QDELETED(src))
			update_handcuffed()
	else if(I == legcuffed)
		legcuffed = null
		if(!QDELETED(src))
			update_worn_legcuffs()
	else
		not_handled = TRUE

	if(I == internal && (QDELETED(src) || QDELETED(I) || I.loc != src))
		cutoff_internals()
		if(!QDELETED(src))
			update_action_buttons_icon(status_only = TRUE)

	if(not_handled)
		return

	update_equipment_speed_mods()
	update_obscured_slots(I.flags_inv)

/// Returns TRUE if an air tank compatible helmet is equipped.
/mob/living/carbon/proc/can_breathe_helmet()
	if (isclothing(head) && (head.clothing_flags & HEADINTERNALS))
		return TRUE

/// Returns TRUE if an air tank compatible mask is equipped.
/mob/living/carbon/proc/can_breathe_mask()
	if (isclothing(wear_mask) && (wear_mask.clothing_flags & MASKINTERNALS))
		return TRUE

/// Returns TRUE if a breathing tube is equipped.
/mob/living/carbon/proc/can_breathe_tube()
	if (get_organ_slot(ORGAN_SLOT_BREATHING_TUBE))
		return TRUE

/// Returns TRUE if an air tank compatible mask or breathing tube is equipped.
/mob/living/carbon/proc/can_breathe_internals()
	return can_breathe_tube() || can_breathe_mask() || can_breathe_helmet()

/// Returns truthy if air tank is open and mob lacks apparatus, or if the tank moved away from the mob.
/mob/living/carbon/proc/invalid_internals()
	return (internal || external) && (!can_breathe_internals() || (internal && internal.loc != src))

/**
 * Open the internal air tank without checking for any breathing apparatus.
 * Returns TRUE if the air tank was opened successfully.
 * Closes any existing tanks before opening another one.
 *
 * Arguments:
 * * tank - The given tank to open and start breathing from.
 * * is_external - A boolean which indicates if the air tank must be equipped, or stored elsewhere.
 */
/mob/living/carbon/proc/open_internals(obj/item/tank/target_tank, is_external = FALSE)
	if (!target_tank)
		return
	close_all_airtanks()
	if (is_external)
		external = target_tank
	else
		internal = target_tank
	target_tank.after_internals_opened(src)
	update_action_buttons_icon()
	return TRUE

/**
 * Opens the given internal air tank if a breathing apparatus is found. Returns TRUE if successful, FALSE otherwise.
 * Returns TRUE if the tank was opened successfully.
 *
 * Arguments:
 * * tank - The given tank we will attempt to toggle open and start breathing from.
 * * is_external - A boolean which indicates if the air tank must be equipped, or stored elsewhere.
 */
/mob/living/carbon/proc/try_open_internals(obj/item/tank/target_tank, is_external = FALSE)
	if (!can_breathe_internals())
		return
	return open_internals(target_tank, is_external)

/**
 * Actually closes the active internal or external air tank.
 * Returns TRUE if the tank was opened successfully.
 *
 * Arguments:
 * * is_external - A boolean which indicates if the air tank must be equipped, or stored elsewhere.
 */
/mob/living/carbon/proc/close_internals(is_external = FALSE)
	var/obj/item/tank/target_tank = is_external ? external : internal
	if (!target_tank)
		return
	if (is_external)
		external = null
	else
		internal = null
	target_tank.after_internals_closed(src)
	update_action_buttons_icon()
	return TRUE

/// Close the the currently open external (that's EX-ternal) air tank. Returns TREUE if successful.
/mob/living/carbon/proc/close_externals()
	return close_internals(TRUE)

/// Quickly/lazily close all airtanks without any returns or notifications.
/mob/living/carbon/proc/close_all_airtanks()
	if(external)
		close_externals()
	if(internal)
		close_internals()


/**
 * Prepares to open the internal air tank and notifies the mob in chat.
 * Handles displaying messages to the user before doing the actual opening.
 * Returns TRUE if the tank was opened/closed successfully.
 *
 * Arguments:
 * * tank - The given tank to toggle open and start breathing from.
 * * is_external - A boolean which indicates if the air tank must be equipped, or stored elsewhere.
 */
/mob/living/carbon/proc/toggle_open_internals(obj/item/tank/target_tank, is_external = FALSE)
	if (!target_tank)
		return
	if(internal || (is_external && external))
		to_chat(src, span_notice("You switch your internals to [target_tank]."))
	else
		to_chat(src, span_notice("You open [target_tank] valve."))
	return open_internals(target_tank, is_external)

/**
 * Prepares to close the currently open internal air tank and notifies in chat.
 * Handles displaying messages to the user before doing the actual closing.
 * Returns TRUE if
 *
 * Arguments:
 * * is_external - A boolean which indicates if the air tank must be equipped, or stored elsewhere.
 */
/mob/living/carbon/proc/toggle_close_internals(is_external = FALSE)
	if (!internal && !external)
		return
	to_chat(src, span_notice("You close [is_external ? external : internal] valve."))
	return close_internals(is_external)

/// Prepares emergency disconnect from open air tanks and notifies in chat. Usually called after mob suddenly unequips breathing apparatus.
/mob/living/carbon/proc/cutoff_internals()
	if (!external && !internal)
		return
	to_chat(src, span_notice("Your internals disconnect from [external || internal] and the valve closes."))
	close_all_airtanks()

/**
 * Toggles the given internal air tank open, or close the currently open one, if a compatible breathing apparatus is found.
 * Returns TRUE if the tank was opened successfully.
 *
 * Arguments:
 * * tank - The given tank to toggle open and start breathing from internally.
 */
/mob/living/carbon/proc/toggle_internals(obj/item/tank)
	// Carbons can't open their own internals tanks.
	return FALSE

/**
 * Toggles the given external (that's EX-ternal) air tank open, or close the currently open one, if a compatible breathing apparatus is found.
 * Returns TRUE if the tank was opened successfully.
 *
 * Arguments:
 * * tank - The given tank to toggle open and start breathing from externally.
 */
/mob/living/carbon/proc/toggle_externals(obj/item/tank)
	// Carbons can't open their own externals tanks.
	return FALSE

/mob/living/carbon/proc/get_holding_bodypart_of_item(obj/item/I)
	var/index = get_held_index_of_item(I)
	return index && hand_bodyparts[index]

/**
 * Proc called when offering an item to another player
 *
 * This handles creating an alert and adding an overlay to it
 */

/mob/living/carbon/proc/give(mob/living/carbon/offered)
	if(has_status_effect(/datum/status_effect/offering))
		to_chat(src, span_warning("You're already offering up something!"))
		return

	if(IS_DEAD_OR_INCAP(src))
		to_chat(src, span_warning("You're unable to offer anything in your current state!"))
		return

	var/obj/item/offered_item = get_active_held_item()
	if(!offered_item)
		to_chat(src, span_warning("You're not holding anything to give!"))
		return

	if(offered)
		if(IS_DEAD_OR_INCAP(offered))
			to_chat(src, span_warning("They're unable to take anything in their current state!"))
			return

		if(!CanReach(offered))
			to_chat(src, span_warning("You have to be adjacent to offer things!"))
			return
	else
		if(!(locate(/mob/living/carbon) in orange(1, src)))
			to_chat(src, span_warning("There's nobody adjacent to offer it to!"))
			return

	if(offered_item.on_offered(src)) // see if the item interrupts with its own behavior
		return

	visible_message(span_notice("[src] is offering [offered ? "[offered] " : ""][offered_item]."), \
					span_notice("You offer [offered ? "[offered] " : ""][offered_item]."), null, 2)

	INVOKE_ASYNC(src, PROC_REF(emote), "offer")

	apply_status_effect(/datum/status_effect/offering, offered_item, null, offered)

/**
 * Proc called when the player clicks the give alert
 *
 * Handles checking if the player taking the item has open slots and is in range of the offerer
 * Also deals with the actual transferring of the item to the players hands
 * Arguments:
 * * offerer - The person giving the original item
 * * I - The item being given by the offerer
 */

/mob/living/carbon/proc/take(mob/living/carbon/offerer, obj/item/I)
	clear_alert("[offerer]")
	if(IS_DEAD_OR_INCAP(src))
		to_chat(src,  span_warning("You're unable to take anything in your current state!"))
		return
	if(get_dist(src, offerer) > 1)
		to_chat(src, span_warning("[offerer] is out of range!"))
		return
	if(!I || offerer.get_active_held_item() != I)
		to_chat(src, span_warning("[offerer] is no longer holding the item they were offering! "))
		return
	if(!get_empty_held_indexes())
		to_chat(src, span_warning("You have no empty hands!"))
		return
	if(I.on_offer_taken(offerer, src)) // see if the item has special behavior for being accepted
		return
	if(!offerer.temporarilyRemoveItemFromInventory(I))
		visible_message(span_notice("[offerer] tries to hand over [I] but it's stuck to them...."))
		return
	visible_message(span_notice("[src] takes [I] from [offerer]"), \
					span_notice("You take [I] from [offerer]"))
	put_in_hands(I)

///Returns a list of all body_zones covered by clothing
/mob/living/carbon/proc/get_covered_body_zones()
	RETURN_TYPE(/list)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/covered_flags = NONE
	var/list/all_worn_items = get_equipped_items()
	for(var/obj/item/worn_item in all_worn_items)
		covered_flags |= worn_item.body_parts_covered

	return cover_flags2body_zones(covered_flags)

///Returns a bitfield of all zones covered by clothing
/mob/living/carbon/proc/get_all_covered_flags()
	SHOULD_NOT_OVERRIDE(TRUE)

	var/covered_flags = NONE
	var/list/all_worn_items = get_equipped_items()
	for(var/obj/item/worn_item in all_worn_items)
		covered_flags |= worn_item.body_parts_covered

	return covered_flags
