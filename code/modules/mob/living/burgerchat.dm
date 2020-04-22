// Thanks to Burger from Burgerstation for the foundation for this

/* 
BYOND Forum posts that helped me:
http://www.byond.com/forum/post/1133166
http://www.byond.com/forum/post/1072433
http://www.byond.com/forum/post/940994
http://www.byond.com/docs/ref/skinparams.html#Fonts
*/

/atom
	var/list/stored_chat_text = list()

/proc/animate_chat(atom/target, message, message_language, message_mode, list/show_to, duration)

	var/spans = "<span class='chatOverhead'>"
	var/spansend = "</span>"

	if((message_mode == "whisper") || (message_mode == "headset") || (message_mode in GLOB.radiochannels))
		spans += "<span class='Italicize'>"
		spansend += "</span>"

	if(copytext(message, length(message) - 1) == "!!")
		spans += "<span class='Yell'>"
		spansend += "</span>"

	message = copytext(message, 1, 120)

	var/text_color = pick("#f4e0e1", "#f6a9bd", "#fee4a7", "#86dbd4", "#95c9e2")

	var/datum/language/D = GLOB.language_datum_instances[message_language]

	// create 2 messages, one that appears if you know the language, and one that appears when you don't know the language

	var/image/I = image(loc = target, layer=FLY_LAYER)
	I.alpha = 0
	I.maptext_width = 128
	I.maptext_height = 64
	I.pixel_x = -48
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	I.maptext = "<center>[spans]<font color='[text_color]'>[message]</font>[spansend]</center>"

	var/image/O = image(loc = target, layer=FLY_LAYER)
	O.alpha = 0
	O.maptext_width = 128
	O.maptext_height = 64
	O.pixel_x = -48
	O.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	O.maptext = "<center>[spans]<font color='[text_color]'>[D.scramble(message)]</font>[spansend]</center>"

	target.stored_chat_text += I
	target.stored_chat_text += O

	// find a client that's connected to measure the height of the message, so it knows how much to bump up the others
	if(length(GLOB.clients))
		var/client/C = GLOB.clients[1]
		var/moveup = text2num(splittext(C.MeasureText(I.maptext, width = 128), "x")[2])
		for(var/image/old in target.stored_chat_text)
			if(old != I && old != O)
				var/pixel_y_new = old.pixel_y + moveup
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
		qdel(I)