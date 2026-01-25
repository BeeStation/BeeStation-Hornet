/mob/living/carbon/monkey/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	switch(slot)
		if(ITEM_SLOT_HANDS)
			if(get_empty_held_indexes())
				return TRUE
			return FALSE
		if(ITEM_SLOT_MASK)
			if(wear_mask)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_MASK) )
				return FALSE
			return TRUE
		if(ITEM_SLOT_NECK)
			if(wear_neck)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_NECK) )
				return FALSE
			return TRUE
		if(ITEM_SLOT_HEAD)
			if(head)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_HEAD) )
				return FALSE
			return TRUE
		if(ITEM_SLOT_BACK)
			if(back)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_BACK) )
				return FALSE
			return TRUE
		if(ITEM_SLOT_ICLOTHING)
			if(w_uniform)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_ICLOTHING) )
				return FALSE
			return TRUE
	return FALSE //Unsupported slot

/mob/living/carbon/monkey/equip_to_slot(obj/item/I, slot)
	if(!..()) //a check failed or the item has already found its slot
		return

	var/not_handled = FALSE //Added in case we make this type path deeper one day
	switch(slot)
		if(ITEM_SLOT_ICLOTHING)
			w_uniform = I
			update_suit_sensors()
			update_worn_undersuit()
		else
			to_chat(src, span_danger("You are trying to equip this item to an unsupported inventory slot. Report this to a coder!"))

	//Item is handled and in slot, valid to call callback, for this proc should always be true
	if(!not_handled)
		I.equipped(src, slot)

	return not_handled //For future deeper overrides

//Hopefully this doesn't fuck with anything
/mob/living/carbon/monkey/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE, was_thrown = FALSE, silent = FALSE)
	. = ..()
	if(!. || !I) //We don't want to set anything to null if the parent returned 0.
		return

	if(I == w_uniform)
		w_uniform = null
		if(!QDELETED(src))
			update_worn_undersuit()
