/datum/action/item_action/equipHazard
	name = "Equip skinsuit"
	desc = "hazard gear and internals. Takes a few seconds."
	icon_icon = 'icons/obj/clothing/suits.dmi'
	button_icon_state = "skinsuit"
	var/obj/item/clothing/suit/space/skinsuit/suitslot
	var/obj/item/clothing/mask/breath/maskslot
	var/obj/item/clothing/head/helmet/space/helmetslot
	var/obj/item/tank/internals/airslot
	//var/obj/item/storage/box/survBox
	var/paniced = FALSE


/datum/action/item_action/equipHazard/Trigger()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		testing(paniced)
		if(!paniced && panicEquip(H) || stowEquipment(H))
			toggle()


/datum/action/item_action/equipHazard/proc/GatherItems(obj/item/storage/CNT)
	var/stuff = CNT.contents
	airslot = locate(/obj/item/tank/internals) in stuff
	helmetslot = locate(/obj/item/clothing/head/helmet/space) in stuff
	maskslot = locate(/obj/item/clothing/mask/breath) in stuff
	suitslot = locate(/obj/item/clothing/suit/space/skinsuit) in stuff
	if(!airslot || !helmetslot || !maskslot || !suitslot)
		return FALSE
	return TRUE

/datum/action/item_action/equipHazard/proc/toggle()
	if(paniced)
		paniced = FALSE
	else
		paniced = TRUE

/datum/action/item_action/equipHazard/proc/stowEquipment(mob/living/carbon/human/user,speed = 10)
	to_chat(user,"<span class='notice'> You stuff the emergency equipment back into the box")
	if(!do_after(user, speed))
		return FALSE
	testing("time passed")
	if(helmetslot && helmetslot == user.head)
		target.attackby(helmetslot,user)
	if(maskslot && maskslot == user.wear_mask)
		target.attackby(maskslot,user)
	if(suitslot && suitslot == user.wear_suit)
		if(!suitslot.rolled_up)
			suitslot.attack_self(user)
		target.attackby(suitslot,user)
	if(airslot && airslot.loc != target)//instead of checking every pocket we just check the turf
		if(airslot in range(1,user))
			target.attackby(airslot,user)
	return TRUE
/datum/action/item_action/equipHazard/proc/panicEquip(mob/living/carbon/human/user,speed = 10)
	to_chat(user,"<span class='warning'>You panic and grab your emergency suit!</span>")
	if(!do_after(user, speed))
		return FALSE
	GatherItems(target)
	/*
		to_chat(user,"<span class='warning'>You dont have all the needed items inside your box!</span>")
		return FALSE
	*/
	testing("gather check passed")
	if(!istype(user.head, /obj/item/clothing/head/helmet/space))
		if(helmetslot)
			if(!user.equip_to_slot_if_possible(helmetslot,SLOT_HEAD))
				if(!user.dropItemToGround(user.head))
					to_chat(user,"Could not dequip [user.head.name].")
				else
					if(!user.equip_to_slot_if_possible(helmetslot,SLOT_HEAD))
						to_chat(user,"<span class='warning'>Could not equip [helmetslot.name].</span>")
		else
			to_chat(user,"<span class='warning'>Missing space helmet!</span>")
	if(!user.wear_mask || !(user.wear_mask.clothing_flags & MASKINTERNALS))
		if(maskslot)
			if(!user.equip_to_slot_if_possible(maskslot,SLOT_WEAR_MASK))
				if(!user.dropItemToGround(user.wear_mask))
					to_chat(user,"Could not dequip [user.wear_mask.name]")
				else
					if(!user.equip_to_slot_if_possible(maskslot,SLOT_WEAR_MASK))
						to_chat(user,"<span class='warning'>Could not equip [maskslot.name].</span>")
		else
			to_chat(user,"<span class='warning'>Missing breathing mask!</span>")
	if(!istype(user.wear_suit, /obj/item/clothing/suit/space))
		if(suitslot)
			if(suitslot.rolled_up)
				suitslot.attack_self(user)
			if(!user.equip_to_slot_if_possible(suitslot,SLOT_WEAR_SUIT))
				if(!user.dropItemToGround(user.wear_suit))
					to_chat(user,"Could not dequip [user.wear_suit.name].")
				else
					if(!user.equip_to_slot_if_possible(suitslot,SLOT_WEAR_SUIT))
						suitslot.attack_self(user)
						to_chat(user,"<span class='warning'>Could not equip [suitslot.name].</span>")
		else
			to_chat(user,"<span class='warning'>Missing space suit!</span>.")
	if(!user.internal)
		if(airslot)
			if(!user.equip_to_slot_if_possible(airslot,SLOT_S_STORE))
				user.put_in_hands(airslot,FALSE)
			user.internal = airslot
		else
			to_chat(user,"<span class='warning'>Missing internals tank!</span>")
	user.update_action_buttons_icon()
	return TRUE
