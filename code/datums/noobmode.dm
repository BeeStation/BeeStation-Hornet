/datum/action/equipHazard
	name = "Equip skinsuit"
	desc = "Equips your skint suit thats inside the emergency box, has a small delay"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "jetboot"
	var/obj/item/clothing/suit/space/skinsuit/suitslot
	var/obj/item/clothing/mask/breath/maskslot
	var/obj/item/clothing/head/helmet/space/helmetslot
	var/obj/item/tank/internals/airslot
	var/obj/item/storage/box/survBox

/datum/action/equipHazard/Trigger()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		testing("triggerd")
		pannickEquip(H)
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


/datum/action/equipHazard/Grant(mob/user, obj/item/containBox)
	. = ..()
	survBox = containBox

/datum/action/equipHazard/proc/pannickEquip(mob/living/carbon/human/USR,speed = 5)
	testing("panick pickup")
	var/list/obj/item/dequiplist = list()
	do_mob(USR, USR, speed)
	if(!GatherItems(survBox))
		return FALSE
	testing("gather check passed")
	if(!USR.equip_to_slot_if_possible(helmetslot,SLOT_HEAD))
		dequiplist += USR.head
		if(helmetslot.mob_can_equip(USR,SLOT_HEAD))
			to_chat(USR,"Could not dequip [USR.head]")
	if(!USR.equip_to_slot_if_possible(maskslot,SLOT_WEAR_MASK))
		dequiplist += USR.wear_mask
		if(helmetslot.mob_can_equip(USR,SLOT_WEAR_MASK))
			to_chat(USR,"Could not dequip [USR.wear_mask]")
	suitslot.attack_self(USR)
	if(!USR.equip_to_slot_if_possible(suitslot,SLOT_WEAR_SUIT))
		dequiplist += USR.wear_suit
		if(helmetslot.mob_can_equip(USR,SLOT_WEAR_SUIT))
			to_chat(USR,"Could not dequip [USR.wear_suit]")
	if(!USR.equip_to_slot_if_possible(airslot,SLOT_S_STORE))
		USR.put_in_hands(airslot,FALSE)
	USR.internal = airslot
	USR.update_action_buttons_icon()
	return TRUE


