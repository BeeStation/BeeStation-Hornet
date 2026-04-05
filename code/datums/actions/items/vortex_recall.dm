/datum/action/item_action/vortex_recall
	name = "Vortex Recall"
	desc = "Recall yourself, and anyone nearby, to an attuned hierophant beacon at any time.<br>If the beacon is still attached, will detach it."
	button_icon = 'icons/hud/actions/actions_items.dmi'
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

/datum/action/item_action/toggle_unfriendly_fire
	name = "Toggle Friendly Fire \[ON\]"
	desc = "Toggles if the club's blasts cause friendly fire."
	button_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "vortex_ff_on"

/datum/action/item_action/toggle_unfriendly_fire/update_button(atom/movable/screen/movable/action_button/button, status_only, force)
	var/obj/item/hierophant_club/teleport_stick = master
	if(istype(master, /obj/item/hierophant_club))
		if(teleport_stick.friendly_fire_check == FALSE)
			button_icon_state = "vortex_ff_off"
			name = "Toggle Friendly Fire \[OFF\]"
		else
			button_icon_state = "vortex_ff_on"
			name = "Toggle Friendly Fire \[ON\]"
	return ..()
