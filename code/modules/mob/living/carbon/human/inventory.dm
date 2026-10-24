
/**
 * Used to return a list of equipped items on a human mob; does not by default include held items, see include_flags
 *
 * Argument(s):
 * * Optional - include_flags, (see obj.flags.dm) describes which optional things to include or not (pockets, accessories, held items)
 */
/mob/living/carbon/human/get_equipped_items(include_flags = NONE)
	var/list/items = ..()
	if(!(include_flags & INCLUDE_POCKETS))
		items -= list(l_store, r_store, s_store)
	if((include_flags & INCLUDE_ACCESSORIES) && w_uniform)
		var/obj/item/clothing/under/worn_under = w_uniform
		for (var/accessory in worn_under.attached_accessories)
			items += worn_under.attached_accessories[accessory]
	return items

/mob/living/carbon/human/can_equip(obj/item/equip_target, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE, indirect_action = FALSE)
	return dna.species.can_equip(equip_target, slot, disable_warning, src, bypass_equip_delay_self, ignore_equipped, indirect_action)

// Return the item currently in the slot ID
/mob/living/carbon/human/get_item_by_slot(slot_id)
	switch(slot_id)
		if(ITEM_SLOT_BACK)
			return back
		if(ITEM_SLOT_MASK)
			return wear_mask
		if(ITEM_SLOT_NECK)
			return wear_neck
		if(ITEM_SLOT_HANDCUFFED)
			return handcuffed
		if(ITEM_SLOT_LEGCUFFED)
			return legcuffed
		if(ITEM_SLOT_BELT)
			return belt
		if(ITEM_SLOT_ID)
			return wear_id
		if(ITEM_SLOT_EARS)
			return ears
		if(ITEM_SLOT_EYES)
			return glasses
		if(ITEM_SLOT_GLOVES)
			return gloves
		if(ITEM_SLOT_HEAD)
			return head
		if(ITEM_SLOT_FEET)
			return shoes
		if(ITEM_SLOT_OCLOTHING)
			return wear_suit
		if(ITEM_SLOT_ICLOTHING)
			return w_uniform
		if(ITEM_SLOT_LPOCKET)
			return l_store
		if(ITEM_SLOT_RPOCKET)
			return r_store
		if(ITEM_SLOT_SUITSTORE)
			return s_store
	return null

/mob/living/carbon/human/get_slot_by_item(obj/item/looking_for)
	if(looking_for == belt)
		return ITEM_SLOT_BELT

	if(looking_for == wear_id)
		return ITEM_SLOT_ID

	if(looking_for == ears)
		return ITEM_SLOT_EARS

	if(looking_for == glasses)
		return ITEM_SLOT_EYES

	if(looking_for == gloves)
		return ITEM_SLOT_GLOVES

	if(looking_for == head)
		return ITEM_SLOT_HEAD

	if(looking_for == shoes)
		return ITEM_SLOT_FEET

	if(looking_for == wear_suit)
		return ITEM_SLOT_OCLOTHING

	if(looking_for == w_uniform)
		return ITEM_SLOT_ICLOTHING

	if(looking_for == r_store)
		return ITEM_SLOT_RPOCKET

	if(looking_for == l_store)
		return ITEM_SLOT_LPOCKET

	if(looking_for == s_store)
		return ITEM_SLOT_SUITSTORE

	return ..()

/mob/living/carbon/human/proc/get_body_slots()
	return list(
		back,
		s_store,
		handcuffed,
		legcuffed,
		wear_suit,
		gloves,
		shoes,
		belt,
		wear_id,
		l_store,
		r_store,
		w_uniform
		)

/mob/living/carbon/human/proc/get_head_slots()
	return list(
		head,
		wear_mask,
		wear_neck,
		glasses,
		ears,
		)

/mob/living/carbon/human/proc/get_storage_slots()
	return list(
		back,
		belt,
		l_store,
		r_store,
		s_store,
		)

//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
// Initial is used to indicate whether or not this is the initial equipment (job datums etc) or just a player doing it
/mob/living/carbon/human/equip_to_slot(obj/item/I, slot, initial = FALSE, redraw_mob = FALSE, indirect_action = FALSE)
	if(!..()) //a check failed or the item has already found its slot
		return

	var/not_handled = FALSE //Added in case we make this type path deeper one day
	switch(slot)
		if(ITEM_SLOT_BELT)
			if(belt)
				return
			belt = I
			update_worn_belt()
		if(ITEM_SLOT_ID)
			if(wear_id)
				return
			wear_id = I
			sec_hud_set_ID()
			update_worn_id()
		if(ITEM_SLOT_EARS)
			if(ears)
				return
			ears = I
			update_worn_ears()
		if(ITEM_SLOT_EYES)
			if(glasses)
				return
			glasses = I
			var/obj/item/clothing/glasses/G = I
			if(G.glass_colour_type)
				update_glasses_color(G, 1)
			if(G.tint)
				update_tint()
			if(G.vision_flags || G.darkness_view || G.invis_override || G.invis_view || !isnull(G.lighting_alpha))
				update_sight()
			update_worn_glasses()
		if(ITEM_SLOT_GLOVES)
			if(gloves)
				return
			gloves = I
			update_worn_gloves()
		if(ITEM_SLOT_FEET)
			if(shoes)
				return
			shoes = I
			update_worn_shoes()
		if(ITEM_SLOT_OCLOTHING)
			if(wear_suit)
				return

			wear_suit = I

			if(I.flags_inv & HIDEJUMPSUIT)
				update_worn_undersuit()
			if(wear_suit.breakouttime) //when equipping a straightjacket
				ADD_TRAIT(src, TRAIT_RESTRAINED, SUIT_TRAIT)
				stop_pulling() //can't pull if restrained
				update_action_buttons_icon() //certain action buttons will no longer be usable.
			update_worn_oversuit()
		if(ITEM_SLOT_ICLOTHING)
			if(w_uniform)
				return
			w_uniform = I
			update_worn_undersuit()
		if(ITEM_SLOT_LPOCKET)
			l_store = I
			update_pockets()
		if(ITEM_SLOT_RPOCKET)
			r_store = I
			update_pockets()
		if(ITEM_SLOT_SUITSTORE)
			if(s_store)
				return
			s_store = I
			update_suit_storage()
		else
			to_chat(src, span_danger("You are trying to equip this item to an unsupported inventory slot. Report this to a coder!"))
			not_handled = TRUE

	//Item is handled and in slot, valid to call callback, for this proc should always be true
	if(!not_handled)
		has_equipped(I, slot, initial)

	return not_handled //For future deeper overrides

/mob/living/carbon/human/get_equipped_speed_mod_items()
	return ..() - list(l_store, r_store, s_store)

/mob/living/carbon/human/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE, was_thrown = FALSE, silent = FALSE)
	. = ..(I, force, newloc, no_move, invdrop, was_thrown) //See mob.dm for an explanation on this and some rage about people copypasting instead of calling ..() like they should.
	if(!. || !I)
		return
	if(I == wear_suit)
		if(s_store && invdrop)
			dropItemToGround(s_store, TRUE) //It makes no sense for your suit storage to stay on you if you drop your suit.
		if(wear_suit.breakouttime) //when unequipping a straightjacket
			REMOVE_TRAIT(src, TRAIT_RESTRAINED, SUIT_TRAIT)
			drop_all_held_items() //suit is restraining
			update_action_buttons_icon() //certain action buttons may be usable again.
		wear_suit = null
		if(!QDELETED(src)) //no need to update we're getting deleted anyway
			if(I.flags_inv & HIDEJUMPSUIT)
				update_worn_undersuit()
			update_worn_oversuit()
	else if(I == w_uniform)
		if(invdrop)
			if(r_store)
				dropItemToGround(r_store, TRUE) //Again, makes sense for pockets to drop.
			if(l_store)
				dropItemToGround(l_store, TRUE)
			if(wear_id)
				dropItemToGround(wear_id)
			if(belt)
				dropItemToGround(belt)
		w_uniform = null
		if(!QDELETED(src))
			update_worn_undersuit()
	else if(I == gloves)
		gloves = null
		if(!QDELETED(src))
			update_worn_gloves()
	else if(I == glasses)
		glasses = null
		var/obj/item/clothing/glasses/G = I
		if(G.glass_colour_type)
			update_glasses_color(G, 0)
		if(G.tint)
			update_tint()
		if(G.vision_flags || G.darkness_view || G.invis_override || G.invis_view || !isnull(G.lighting_alpha))
			update_sight()
		if(!QDELETED(src))
			update_worn_glasses()
	else if(I == ears)
		ears = null
		if(!QDELETED(src))
			update_worn_ears()
	else if(I == shoes)
		shoes = null
		if(!QDELETED(src))
			update_worn_shoes()
	else if(I == belt)
		belt = null
		if(!QDELETED(src))
			update_worn_belt()
	else if(I == wear_id)
		wear_id = null
		sec_hud_set_ID()
		if(!QDELETED(src))
			update_worn_id()
	else if(I == r_store)
		r_store = null
		if(!QDELETED(src))
			update_pockets()
	else if(I == l_store)
		l_store = null
		if(!QDELETED(src))
			update_pockets()
	else if(I == s_store)
		s_store = null
		if(!QDELETED(src))
			update_suit_storage()

/// Adds the passed item's coverage to the mob's coverage related flags
/mob/living/carbon/proc/add_item_coverage(obj/item/item)
	var/pre_coverage = obscured_slots
	obscured_slots |= item.flags_inv
	covered_slots |= item.flags_inv | item.transparent_protection
	if(pre_coverage != obscured_slots)
		item_coverage_changed(obscured_slots & ~pre_coverage, pre_coverage & ~obscured_slots)

/// Removes the passed item's coverage from the mob's coverage related flags
/mob/living/carbon/proc/remove_item_coverage(obj/item/item)
	refresh_obscured() // No way to remove a single item's coverage without recalculating everything

/mob/living/carbon/refresh_obscured()
	var/pre_coverage = obscured_slots

	obscured_slots = NONE
	covered_slots = NONE
	for(var/obj/item/other_equipped_item as anything in get_equipped_items())
		obscured_slots |= other_equipped_item.flags_inv
		covered_slots |= other_equipped_item.flags_inv | other_equipped_item.transparent_protection

	if(HAS_TRAIT(src, TRAIT_HUSK))
		obscured_slots |= HIDEHAIR|HIDEFACIALHAIR

	if(pre_coverage != obscured_slots)
		item_coverage_changed(obscured_slots & ~pre_coverage, pre_coverage & ~obscured_slots)

/**
 * Called when a mob's obscured slots change
 *
 * Args
 * * added_slots - slots that were added to obscured_slots
 * * removed_slots - slots that were removed from obscured_slots
 */
/mob/living/carbon/proc/item_coverage_changed(added_slots, removed_slots)
	update_clothing(hidden_slots_to_inventory_slots(added_slots|removed_slots))
	if((added_slots|removed_slots) & (HIDEJUMPSUIT|HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT|HIDEMUTWINGS|HIDEANTENNAE))
		update_body()

/mob/living/carbon/human/toggle_internals(obj/item/tank, is_external = FALSE)
	// Just close the tank if it's the one the mob already has open.
	var/obj/item/existing_tank = is_external ? external : internal
	if(tank == existing_tank)
		return toggle_close_internals(is_external)
	// Use breathing tube regardless of mask.
	if(can_breathe_tube())
		return toggle_open_internals(tank, is_external)
	// Use mask in absence of tube.
	if(isclothing(wear_mask) && ((wear_mask.visor_flags & MASKINTERNALS) || (wear_mask.clothing_flags & MASKINTERNALS)))
		// Adjust dishevelled breathing mask back onto face.
		if (wear_mask.mask_adjusted)
			wear_mask.adjustmask(src)
		return toggle_open_internals(tank, is_external)
	// Use helmet in absence of tube or valid mask.
	if(can_breathe_helmet())
		return toggle_open_internals(tank, is_external)
	// Notify user of missing valid breathing apparatus.
	if(wear_mask)
		// Invalid mask
		to_chat(src, span_warning("[wear_mask] can't use [tank]!"))
	else if(head)
		// Invalid headgear
		to_chat(src, span_warning("[head] isn't airtight! You need a mask!"))
	else
		// Not wearing any breathing apparatus.
		to_chat(src, span_warning("You need a mask!"))

/// Returns TRUE if the tank successfully toggles open/closed. Opens the tank only if a breathing apparatus is found.
/mob/living/carbon/human/toggle_externals(obj/item/tank)
	return toggle_internals(tank, TRUE)

/mob/living/carbon/human/wear_mask_update(obj/item/I, toggle_off = 1)
	if((I.flags_inv & (HIDEHAIR|HIDEFACIALHAIR)) || (initial(I.flags_inv) & (HIDEHAIR|HIDEFACIALHAIR)))
		update_hair()
	// Close internal air tank if mask was the only breathing apparatus.
	if(invalid_internals())
		cutoff_internals()
	if(I.flags_inv & HIDEEYES)
		update_worn_glasses()
	sec_hud_set_security_status()
	..()

/mob/living/carbon/human/head_update(obj/item/I, forced)
	if((I.flags_inv & (HIDEHAIR|HIDEFACIALHAIR)) || forced)
		update_hair()
	// Close internal air tank if helmet was the only breathing apparatus.
	if(invalid_internals())
		cutoff_internals()
	if(I.flags_inv & HIDEEYES || forced)
		update_worn_glasses()
	if(I.flags_inv & HIDEEARS || forced)
		update_body()
	sec_hud_set_security_status()
	..()

/mob/living/carbon/human/proc/equipOutfit(outfit, visuals_only = FALSE)
	var/datum/outfit/O = null

	if(ispath(outfit))
		O = new outfit
	else
		O = outfit
		if(!istype(O))
			return 0
	if(!O)
		return 0

	return O.equip(src, visuals_only)

//delete all equipment without dropping anything
/mob/living/carbon/human/proc/delete_equipment()
	for(var/slot in get_equipped_items(INCLUDE_POCKETS|INCLUDE_HELD))//order matters, dependant slots go first
		qdel(slot)
	for(var/obj/item/held_item in held_items)
		qdel(held_item)

/// take the most recent item out of a slot or place held item in a slot
/mob/living/carbon/human/proc/smart_equip_targeted(slot_type = ITEM_SLOT_BELT, slot_item_name = "belt")
	if(incapacitated)
		return
	var/obj/item/thing = get_active_held_item()
	var/obj/item/equipped_item = get_item_by_slot(slot_type)
	if(!equipped_item) // We also let you equip an item like this
		if(!thing)
			to_chat(src, span_warning("You have no [slot_item_name] to take something out of!"))
			return
		if(equip_to_slot_if_possible(thing, slot_type))
			update_held_items()
		return
	var/datum/storage/storage = equipped_item.atom_storage
	if(!storage)
		if(!thing)
			equipped_item.attack_hand(src)
		else
			to_chat(src, span_warning("You can't fit [thing] into your [equipped_item.name]!"))
		return
	if(!storage.supports_smart_equip)
		return
	if(thing) // put thing in storage item
		if(!equipped_item.atom_storage?.attempt_insert(thing, src))
			to_chat(src, span_warning("You can't fit [thing] into your [equipped_item.name]!"))
		return
	var/atom/real_location = storage.real_location?.resolve()
	if(!real_location.contents.len) // nothing to take out
		to_chat(src, span_warning("There's nothing in your [equipped_item.name] to take out!"))
		return
	var/obj/item/stored = real_location.contents[real_location.contents.len]
	if(!stored || stored.on_found(src))
		return
	stored.attack_hand(src) // take out thing from item in storage slot
	return
