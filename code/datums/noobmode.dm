/datum/action/equipHazard
	name = "Equip skinsuit"
	desc = "hazard gear and internals. Takes a few seconds."
	icon_icon = 'icons/obj/clothing/suits.dmi'
	button_icon_state = "skinsuit"
	var/obj/item/clothing/suit/space/skinsuit/suitslot
	var/obj/item/clothing/mask/breath/maskslot
	var/obj/item/clothing/head/helmet/space/helmetslot
	var/obj/item/tank/internals/airslot
	var/obj/item/storage/box/survBox
	var/paniced = FALSE

/datum/action/equipHazard/Trigger()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		testing(paniced)
		if(!paniced)
			if(pannickEquip(H))
				toggle()
		else
			if(stowEquipment(H))
				toggle()
		//var/obj/item/held = H.get_active_held_item()
		/*if(!held)
			held = H.get_inactive_held_item()
			if(held && istype(held,/obj/item/storage/box/survival))
				to_chat(H,"<span class='warning'>You are putting on the outfit inside [held], hold still!</span>")
				pannickEquip(H)
			else
				to_chat(H,"<span class='warning'> you must be holding the box!</span>")
				return
		else
			if(held && istype(held,/obj/item/storage/box/survival))
				to_chat(H,"<span class='warning'>You are putting on the outfit inside [held], hold still!</span>")
				pannickEquip(H)
				*/


/datum/action/equipHazard/proc/GatherItems(obj/item/storage/CNT)
	var/stuff = CNT.contents
	airslot = locate(/obj/item/tank/internals) in stuff
	helmetslot = locate(/obj/item/clothing/head/helmet/space) in stuff
	maskslot = locate(/obj/item/clothing/mask/breath) in stuff
	suitslot = locate(/obj/item/clothing/suit/space/skinsuit) in stuff
	if(!airslot || !helmetslot || !maskslot || !suitslot)
		return FALSE
	return TRUE

/datum/action/equipHazard/proc/toggle()
	if(paniced)
		paniced = FALSE
	else
		paniced = TRUE

/datum/action/equipHazard/Grant(mob/user, obj/item/containBox)
	. = ..()
	survBox = containBox

/datum/action/equipHazard/proc/stowEquipment(mob/living/carbon/human/USR,speed = 10)
	to_chat(USR,"<span class='notice'> You stuff the emergency equipment back into the box")
	if(!do_after(USR, speed))
		return FALSE
	testing("time passed")
	if(helmetslot && helmetslot == USR.head)
		survBox.attackby(helmetslot,USR)
	if(maskslot && maskslot == USR.wear_mask)
		survBox.attackby(maskslot,USR)
	if(suitslot && suitslot == USR.wear_suit)
		if(!suitslot.rolled_up)
			suitslot.attack_self(USR)
		survBox.attackby(suitslot,USR)
	if(airslot && airslot.loc != survBox)//instead of checking every pocket we just check the turf
		if(airslot in range(1,USR))
			survBox.attackby(airslot,USR)
	return TRUE
/datum/action/equipHazard/proc/pannickEquip(mob/living/carbon/human/USR,speed = 10)
	to_chat(USR,"<span class='warning'>You panic and grab your emergency suit!</span>")
	if(!do_after(USR, speed))
		return FALSE
	GatherItems(survBox)
	/*
		to_chat(USR,"<span class='warning'>You dont have all the needed items inside your box!</span>")
		return FALSE
	*/
	testing("gather check passed")
	if(!istype(USR.head, /obj/item/clothing/head/helmet/space))
		if(helmetslot)
			if(!USR.equip_to_slot_if_possible(helmetslot,SLOT_HEAD))
				if(!USR.dropItemToGround(USR.head))
					to_chat(USR,"Could not dequip [USR.head.name].")
				else
					if(!USR.equip_to_slot_if_possible(helmetslot,SLOT_HEAD))
						to_chat(USR,"<span class='warning'>Could not equip [helmetslot.name].</span>")
		else
			to_chat(USR,"<span class='warning'>Missing space helmet!</span>")
	if(!USR.wear_mask || !(USR.wear_mask.clothing_flags & MASKINTERNALS))
		if(maskslot)
			if(!USR.equip_to_slot_if_possible(maskslot,SLOT_WEAR_MASK))
				if(!USR.dropItemToGround(USR.wear_mask))
					to_chat(USR,"Could not dequip [USR.wear_mask.name]")
				else
					if(!USR.equip_to_slot_if_possible(maskslot,SLOT_WEAR_MASK))
						to_chat(USR,"<span class='warning'>Could not equip [maskslot.name].</span>")
		else
			to_chat(USR,"<span class='warning'>Missing breathing mask!</span>")
	if(!istype(USR.wear_suit, /obj/item/clothing/suit/space))
		if(suitslot)
			if(suitslot.rolled_up)
				suitslot.attack_self(USR)
			if(!USR.equip_to_slot_if_possible(suitslot,SLOT_WEAR_SUIT))
				if(!USR.dropItemToGround(USR.wear_suit))
					to_chat(USR,"Could not dequip [USR.wear_suit.name].")
				else
					if(!USR.equip_to_slot_if_possible(suitslot,SLOT_WEAR_SUIT))
						suitslot.attack_self(USR)
						to_chat(USR,"<span class='warning'>Could not equip [suitslot.name].</span>")
		else
			to_chat(USR,"<span class='warning'>Missing space suit!</span>.")
	if(!USR.internal)
		if(airslot)
			if(!USR.equip_to_slot_if_possible(airslot,SLOT_S_STORE))
				USR.put_in_hands(airslot,FALSE)
			USR.internal = airslot
		else
			to_chat(USR,"<span class='warning'>Missing internals tank!</span>")
	USR.update_action_buttons_icon()
	return TRUE
