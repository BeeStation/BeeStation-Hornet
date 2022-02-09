//quickswap items!
/mob/living/carbon/human/quick_equip()

	var/obj/item/I = get_active_held_item()
	if (I)
		for(var/obj/item/inv in get_equipped_items(TRUE))
			if(I.slot_flags == inv.slot_flags)
				var/list/obj/item/possible = list(get_inactive_held_item(), get_item_by_slot(ITEM_SLOT_BACK), get_item_by_slot(ITEM_SLOT_DEX_STORAGE), get_item_by_slot(ITEM_SLOT_BACK))//we get all possible places it can fit
				for(var/i in possible)
					if(!i)
						continue
					var/obj/item/store = i
					if(SEND_SIGNAL(store, COMSIG_TRY_STORAGE_INSERT, I, src))//this prioritizes storing it before swapping
						return
				if(putItemFromInventoryInHandIfPossible(inv, get_inactive_hand_index(), invdrop = FALSE))
					I.equip_to_best_slot(src, TRUE)
					return
 	..()

/mob/living/carbon/human/verb/equip_swap()//to bypass storage and directly swap
	set name = "equip swap"
	set hidden = 1

	var/obj/item/I = get_active_held_item()
	if (I)
		if(!equip_to_appropriate_slot(I))
			for(var/obj/item/inv in get_equipped_items())
				if(I.slot_flags & inv.slot_flags)
					if(putItemFromInventoryInHandIfPossible(inv, get_inactive_hand_index(), invdrop = FALSE))
						I.equip_to_best_slot(src)
		else
			update_inv_hands()
