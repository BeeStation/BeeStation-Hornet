/datum/action/innate/clockcult/transmit
	name = "Hierophant Transmit"
	button_icon_state = "hierophant"
	desc = "Transmit a message to your allies through the Hierophant."

/datum/action/innate/clockcult/transmit/is_available()
	if(!IS_SERVANT_OF_RATVAR(owner))
		Remove(owner)
		return FALSE
	if(owner.incapacitated())
		return FALSE
	. = ..()

/datum/action/innate/clockcult/transmit/on_activate()
	var/message = tgui_input_text(owner, "What do you want to tell your allies?", "Hierophant Transmit", "", encode = FALSE)
	hierophant_message(message, owner, "<span class='brass'>")
