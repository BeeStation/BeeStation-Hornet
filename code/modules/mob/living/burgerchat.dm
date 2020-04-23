// Thanks to Burger from Burgerstation for the foundation for this

/* 
BYOND Forum posts that helped me:
http://www.byond.com/forum/post/1133166
http://www.byond.com/forum/post/1072433
http://www.byond.com/forum/post/940994
http://www.byond.com/docs/ref/skinparams.html#Fonts
*/

/mob/living
	var/list/stored_chat_text = list()
	/*
	var/chatOverhead_name
	var/chatOverhead_color
	*/

/proc/animate_chat(mob/living/target, message, message_language, message_mode, list/show_to, duration)

	var/list/chatOverhead_colors = list("#83c0dd","#8396dd","#9983dd","#dd83b6","#dd8383","#83dddc","#83dd9f","#a5dd83","#ddd983","#dda583","#dd8383")

	// color is based on name, but calculating color is a waste, so only calculate once for every time the name changes
	/*if(target.name != target.chatOverhead_name)
		target.chatOverhead_name = target.name
		target.chatOverhead_color = chatOverhead_colors[text2num(md5(target.name)) % length(chatOverhead_colors)]

	var/text_color = target.chatOverhead_color */

	var/text_color = pick(chatOverhead_colors)

	var/css = ""

	if((message_mode == MODE_WHISPER) || (message_mode == MODE_WHISPER_CRIT) || (message_mode == MODE_HEADSET) || (message_mode in GLOB.radiochannels))
		css += "font-style: italic;"

	if(copytext(message, length(message) - 1) == "!!" || istype(target.get_active_held_item(), /obj/item/megaphone))
		css += "font-size: 8px; font-weight: bold;"
		if(istype(target.get_active_held_item(), /obj/item/megaphone/clown))
			text_color = "#ff2abf"
	
	css += "color: [text_color];"

	message = copytext(message, 1, 120)

	var/datum/language/D = GLOB.language_datum_instances[message_language]

	// create 2 messages, one that appears if you know the language, and one that appears when you don't know the language

	var/image/I = image(loc = target, layer=FLY_LAYER)
	I.alpha = 0
	I.maptext_width = 128
	I.maptext_height = 64
	I.pixel_x = -48
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	I.maptext = "<center><span class='chatOverhead' style='[css]'>[message]</span></center>"

	var/image/O = image(loc = target, layer=FLY_LAYER)
	O.alpha = 0
	O.maptext_width = 128
	O.maptext_height = 64
	O.pixel_x = -48
	O.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	O.maptext = "<center><span class='chatOverhead' style='[css]'>[D.scramble(message)]</span></center>"

	target.stored_chat_text += I
	target.stored_chat_text += O

	// find a client that's connected to measure the height of the message, so it knows how much to bump up the others
	if(length(GLOB.clients))
		var/client/C = null
		for(var/client/player in GLOB.clients)
			if(player.byond_build >= 513)
				C = player
				break
		if(C)
			var/moveup = text2num(splittext(C.MeasureText(I.maptext, width = 128), "x")[2])
			for(var/image/old in target.stored_chat_text)
				if(old != I && old != O)
					var/pixel_y_new = old.pixel_y + moveup
					animate(old, 2, pixel_y = pixel_y_new)
		else // oh god this shouldn't happen, but MeasureText() was introduced in 513.1490 as a client proc
			for(var/image/old in target.stored_chat_text)
				if(old != I && old != O)
					var/pixel_y_new = old.pixel_y + 10
					animate(old, 2, pixel_y = pixel_y_new)

	for(var/client/C in show_to)
		if(C.mob.can_hear() && C.prefs.overhead_chat)
			if(C.mob.can_speak_in_language(message_language))
				C.images += I
			else
				C.images += O

	animate(I, 1, alpha = 255, pixel_y = 24)
	animate(O, 1, alpha = 255, pixel_y = 24)

	// wait a little bit, then delete the message
	spawn(duration)
		var/pixel_y_new = I.pixel_y + 10
		animate(I, 2, pixel_y = pixel_y_new, alpha = 0)
		animate(O, 2, pixel_y = pixel_y_new, alpha = 0)
		sleep(2)
		for(var/client/C in show_to)
			if(C.mob.can_hear() && C.prefs.overhead_chat)
				if(C.mob.can_speak_in_language(message_language))
					C.images -= I
				else
					C.images -= O

		target.stored_chat_text -= I
		target.stored_chat_text -= O
		qdel(I)
		qdel(O)