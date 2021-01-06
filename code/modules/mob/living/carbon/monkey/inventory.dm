/mob/living/carbon/monkey/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	switch(slot)
		if(SLOT_HANDS)
			if(get_empty_held_indexes())
				return EF_TRUE
			return EF_FALSE
		if(SLOT_WEAR_MASK)
			if(wear_mask)
				return EF_FALSE
			if( !(I.slot_flags & ITEM_SLOT_MASK) )
				return EF_FALSE
			return EF_TRUE
		if(SLOT_NECK)
			if(wear_neck)
				return EF_FALSE
			if( !(I.slot_flags & ITEM_SLOT_NECK) )
				return EF_FALSE
			return EF_TRUE
		if(SLOT_HEAD)
			if(head)
				return EF_FALSE
			if( !(I.slot_flags & ITEM_SLOT_HEAD) )
				return EF_FALSE
			return EF_TRUE
		if(SLOT_BACK)
			if(back)
				return EF_FALSE
			if( !(I.slot_flags & ITEM_SLOT_BACK) )
				return EF_FALSE
			return EF_TRUE
	return EF_FALSE //Unsupported slot



