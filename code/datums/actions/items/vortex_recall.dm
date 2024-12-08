/datum/action/item_action/vortex_recall
	name = "Vortex Recall"
	desc = "Recall yourself, and anyone nearby, to an attuned hierophant beacon at any time.<br>If the beacon is still attached, will detach it."
	icon_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "vortex_recall"

/datum/action/item_action/vortex_recall/is_available()
	var/area/current_area = get_area(master)
	if(!current_area || current_area.teleport_restriction == TELEPORT_ALLOW_NONE)
		return FALSE
	if(istype(master, /obj/item/hierophant_club))
		var/obj/item/hierophant_club/teleport_stick = master
		if(teleport_stick.teleporting)
			return FALSE
	return ..()
