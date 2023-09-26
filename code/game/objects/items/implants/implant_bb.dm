/obj/item/implant/bloodbrother
	name = "communication implant"
	desc = "Use this to communicate with your fellow blood brother(s)."
	icon = 'icons/obj/radio.dmi'
	icon_state = "headset"
	/// BB implant colour is different per team, and is set by brother antag datum
	var/implant_colour = "#ff0000"
	var/list/linked_implants // All other implants that this communicates to

/obj/item/implant/bloodbrother/Initialize(mapload)
	. = ..()
	linked_implants = list()

/obj/item/implant/bloodbrother/activate()
	. = ..()
	if(linked_implants.len)
		var/input = stripped_input(imp_in, "Enter a message to communicate to your blood brother(s).", "Radio Implant", "")
		if(!input || imp_in.stat == DEAD)
			return
		if(CHAT_FILTER_CHECK(input))
			to_chat(imp_in, "<span class='warning'>The message contains prohibited words!</span>")
			return
		input = imp_in.treat_message_min(input)

		var/my_message = "<font color=\"[implant_colour]\"><b><i>[imp_in.mind.name]:</i></b></font> [input]" //add sender, color source with syndie color
		var/ghost_message = "<font color=\"[implant_colour]\"><b><i>[imp_in.mind.name] -> Blood Brothers:</i></b></font> [input]"
		// Reminder: putting a font color directly is bad because color has different readability by your chat theme white/dark
		// This should be eventually changed to a form of `<span class="red">`, so that a color has a good readability for a chat theme.

		to_chat(imp_in, my_message) // Sends message to the user
		for(var/obj/item/implant/bloodbrother/i in linked_implants) // Sends message to all linked implnats
			var/M = i.imp_in
			to_chat(M, my_message)
		for(var/M in GLOB.dead_mob_list) // Sends message to ghosts
			var/link = FOLLOW_LINK(M, imp_in)
			to_chat(M, "[link] [ghost_message]")

		imp_in.log_talk(input, LOG_SAY, tag="Blood Brother Implant")
	else
		to_chat(imp_in, "<span class='bold'>There are no linked implants!</span>")

/obj/item/implant/bloodbrother/Destroy()
	. = ..()
	for(var/obj/item/implant/bloodbrother/i in linked_implants) // Removes this implant from the list of implants
		i.linked_implants -= src

/obj/item/implant/bloodbrother/proc/link_implant(var/obj/item/implant/bloodbrother/BB)
	if(BB)
		if(BB == src) // Don't want to put this implant into itself
			return
		linked_implants |= BB
		BB.linked_implants |= src

/obj/item/implant/bloodbrother/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Donk Corp(tm) Initiate Communication Implant<BR>
				<b>Life:</b> Indefinite.<BR>
				<b>Important Notes: <font color='red'>Illegal</font></B><BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a small, directly linked radio device along with a small speaker and microphone. Allows communication between two similar implants.<BR>"}
	return dat

/obj/item/implanter/bloodbrother
	name = "implanter (communication)"
	imp_type = /obj/item/implant/bloodbrother



