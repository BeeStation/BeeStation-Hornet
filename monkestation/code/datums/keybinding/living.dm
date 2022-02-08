/datum/keybinding/living/radio_channel
	key = "Y"
	name = "Radio Communication"
	full_name = "Radio Communication"
	description = "Talk over a selected radio channel with this hotkey."
	keybind_signal = COMSIG_KB_LIVING_RADIO_CHANNEL_DOWN

/datum/keybinding/living/radio_channel/down(client/user)
	. = ..()
	if(!isliving(user.mob)) //The dead may not speak to us. That which lies must not speak again.
		return

	var/mob/living/L = user.mob
	L.radio_hotkey(L) //This is a proc because datums share variables. You do not want everyone trying to access the same variable at the same time. No, you don't.

/mob/living/proc/radio_hotkey(var/mob/living/L) //Proc kept with the hotkey itself
	var/list/channel_options = list("General")
	var/obj/item/radio/man_radio

	if(ishuman(L) || issilicon(L))
		man_radio = locate(/obj/item/radio) in L.contents
		if(!man_radio)
			return
		if(man_radio.channels)
			channel_options += man_radio.channels
		if(issilicon(L))
			channel_options += "Binary"

	else
		return

	var/selected_channel = input(L, "Choose a channel", "Radio Channel") in channel_options
	if(selected_channel)
		var/spoken_text = stripped_input(L, "Speaking into [selected_channel]", "Radio Communication")
		switch(selected_channel) //This feels like jank. But it probably is the best method I can do.
			if("General", "Red Team", "Blue Team")
				selected_channel = ";"
			if("Security")
				selected_channel = ".s "
			if("Engineering")
				selected_channel = ".e "
			if("Command")
				selected_channel = ".c "
			if("Science")
				selected_channel = ".n "
			if("Medical")
				selected_channel = ".m "
			if("Supply")
				selected_channel = ".u "
			if("Service")
				selected_channel = ".v "
			if("Exploration")
				selected_channel = ".q "
			if("AI Private")
				selected_channel = ".o "
			if("Syndicate")
				selected_channel = ".t "
			if("CentCom")
				selected_channel = ".y "
			if("Binary")
				selected_channel = ".b "
		L.say("[selected_channel][spoken_text]")

