/mob/living/simple_animal/hostile/holoparasite
	/// A lazy list containing the overlays for inhand items.
	var/list/hand_overlays
	/**
	 * A bitflag defining which item slots map to the internal storage slot.
	 * To clarify - these are NOT separate slots, they are all aliases for the same internal storage slot.
	 * This is so dextrous holoparasites can use defibs and such.
	 */
	var/static/internal_storage_slot_aliases = ITEM_SLOT_DEX_STORAGE | ITEM_SLOT_BACK | ITEM_SLOT_BELT

/mob/living/simple_animal/hostile/holoparasite/doUnEquip(obj/item/equipped_item, force, newloc, no_move, invdrop = TRUE, was_thrown = FALSE, silent = FALSE)
	if(!is_manifested() || !can_use_abilities)
		return FALSE
	. = ..()
	if(.)
		update_held_items()
		var/datum/holoparasite_ability/weapon/dextrous/dexterity = stats.weapon
		if(!istype(dexterity))
			return FALSE
		if(equipped_item == dexterity.internal_storage)
			dexterity.internal_storage = null
			update_inv_internal_storage()

/mob/living/simple_animal/hostile/holoparasite/incapacitated(flags)
	return !can_use_abilities || ..()

/mob/living/simple_animal/hostile/holoparasite/can_put_in_hand(item, hand_index)
	return can_use_abilities && ..()

/mob/living/simple_animal/hostile/holoparasite/put_in_hand_check(obj/item/item)
	return can_use_abilities && ..()

/mob/living/simple_animal/hostile/holoparasite/get_equipped_items(include_pockets = FALSE)
	var/datum/holoparasite_ability/weapon/dextrous/dexterity = stats.weapon
	if(!istype(dexterity))
		return
	if(!QDELETED(dexterity.internal_storage))
		return list(dexterity.internal_storage)

/mob/living/simple_animal/hostile/holoparasite/can_equip(obj/item/item, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	var/datum/holoparasite_ability/weapon/dextrous/dexterity = stats.weapon
	if(!istype(dexterity) || !can_use_abilities)
		return FALSE
	if(CHECK_BITFIELD(internal_storage_slot_aliases, slot))
		return item.w_class <= dexterity.max_w_class && QDELETED(dexterity.internal_storage)
	return ..()

/mob/living/simple_animal/hostile/holoparasite/equip_to_slot(obj/item/item, slot)
	var/datum/holoparasite_ability/weapon/dextrous/dexterity = stats.weapon
	if(!istype(dexterity) || !is_manifested() || !can_use_abilities)
		return
	if(CHECK_BITFIELD(internal_storage_slot_aliases, slot))
		if(item.w_class > dexterity.max_w_class)
			to_chat(src, span_danger("[src] is too big to fit in your internal storage!"))
			return
		// I have no idea why this is needed, but it is, and it works, so we're doing it this way.
		var/hand_slot = get_held_index_of_item(item)
		if(hand_slot)
			held_items[hand_slot] = null
		dexterity.internal_storage = item
		update_held_items()
		update_inv_internal_storage()
	else
		to_chat(src, span_danger("You are trying to equip this item to an unsupported inventory slot. Report this to a coder!"))

/mob/living/simple_animal/hostile/holoparasite/get_item_by_slot(slot_id)
	var/datum/holoparasite_ability/weapon/dextrous/dexterity = stats.weapon
	if(!istype(dexterity))
		return
	if(CHECK_BITFIELD(internal_storage_slot_aliases, slot_id))
		return dexterity.internal_storage
	return ..()

/mob/living/simple_animal/hostile/holoparasite/getBackSlot()
	var/datum/holoparasite_ability/weapon/dextrous/dexterity = stats.weapon
	if(istype(dexterity))
		return ITEM_SLOT_DEX_STORAGE

/mob/living/simple_animal/hostile/holoparasite/getBeltSlot()
	var/datum/holoparasite_ability/weapon/dextrous/dexterity = stats.weapon
	if(istype(dexterity))
		return ITEM_SLOT_DEX_STORAGE

/mob/living/simple_animal/hostile/holoparasite/update_held_items()
	if(LAZYLEN(hand_overlays))
		cut_overlay(hand_overlays)
		QDEL_LAZYLIST(hand_overlays)
	if(!dextrous)
		return
	var/obj/item/l_hand = get_item_for_held_index(1)
	var/obj/item/r_hand = get_item_for_held_index(2)
	// Add items to HUD.
	if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
		if(r_hand)
			r_hand.plane = ABOVE_HUD_PLANE
			r_hand.screen_loc = ui_holopara_r_hand
			client.screen |= r_hand
		if(l_hand)
			l_hand.plane = ABOVE_HUD_PLANE
			l_hand.screen_loc = ui_holopara_l_hand
			client.screen |= l_hand
	// Handle inhand overlays.
	if(r_hand)
		var/mutable_appearance/r_hand_overlay = r_hand.build_worn_icon(default_layer = HOLOPARA_HANDS_LAYER, default_icon_file = r_hand.righthand_file, isinhands = TRUE)
		LAZYADD(hand_overlays, r_hand_overlay)
	if(l_hand)
		var/mutable_appearance/l_hand_overlay = l_hand.build_worn_icon(default_layer = HOLOPARA_HANDS_LAYER, default_icon_file = l_hand.lefthand_file, isinhands = TRUE)
		LAZYADD(hand_overlays, l_hand_overlay)
	if(LAZYLEN(hand_overlays))
		add_overlay(hand_overlays)
	// Update dextrous drop HUD icon.
	var/datum/holoparasite_ability/weapon/dextrous/dexterity = stats.weapon
	if(!istype(dexterity))
		return
	dexterity.drop?.update_icon()

/mob/living/simple_animal/hostile/holoparasite/proc/update_inv_internal_storage()
	var/datum/holoparasite_ability/weapon/dextrous/dexterity = stats.weapon
	if(!istype(dexterity))
		return
	if(dexterity.internal_storage && client && hud_used?.hud_shown)
		dexterity.internal_storage.screen_loc = ui_inventory
		client.screen += dexterity.internal_storage

/mob/living/simple_animal/hostile/holoparasite/regenerate_icons()
	. = ..()
	update_held_items()
	update_inv_internal_storage()
