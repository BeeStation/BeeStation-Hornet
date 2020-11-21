// Thanks to Burger from Burgerstation for the foundation for this

/*
BYOND Forum posts that helped me :
http://www.byond.com/forum/post/1133166
http://www.byond.com/forum/post/1072433
http://www.byond.com/forum/post/940994
http://www.byond.com/docs/ref/skinparams.html#Fonts
*/

#define COLOR_JOB_UNKNOWN "#dda583"
#define COLOR_PERSON_UNKNOWN "#999999"

//For jobs that aren't roundstart but still need colours
GLOBAL_LIST_INIT(job_colors_pastel, list(
	"Prisoner" = 		"#d38a5c",
	"CentCom" = 		"#90FD6D",
	"Unknown"=			COLOR_JOB_UNKNOWN,
))

/mob/living
	var/list/stored_chat_text = list()

/proc/animate_chat(mob/living/target, message, message_language, message_mode, list/show_to, duration)
	var/text_color

	if(message_mode == MODE_WHISPER)
		return

	var/mob/living/carbon/human/target_as_human = target
	if(istype(target_as_human))
		if(target_as_human.wear_id?.GetID())
			var/obj/item/card/id/idcard = target_as_human.wear_id
			var/datum/job/wearer_job = SSjob.GetJob(idcard.GetJobName())
			if(wearer_job)
				text_color = wearer_job.chat_color
			else
				text_color = GLOB.job_colors_pastel[idcard.GetJobName()]
		else
			text_color = COLOR_PERSON_UNKNOWN
	else
		text_color = target.mobsay_color

	if(!text_color)	//Just in case.
		text_color = COLOR_JOB_UNKNOWN

	var/css = ""

	if(copytext(message, length(message) - 1) == "!!")
		css += "font-weight: bold;"
	if(istype(target.get_active_held_item(), /obj/item/megaphone))
		css += "font-size: 8px;"
		if(istype(target.get_active_held_item(), /obj/item/megaphone/clown))
			text_color = "#ff2abf"
	else if((message_mode == MODE_WHISPER_CRIT) || (message_mode == MODE_HEADSET) || (message_mode in GLOB.radiochannels))
		css += "font-size: 6px;"

	css += "color: [text_color];"

	message = copytext(message, 1, 120)

	var/static/regex/url_scheme = new(@"[A-Za-z][A-Za-z0-9+-\.]*:\/\/", "g")
	message = replacetext(message, url_scheme, "")

	var/datum/language/D = GLOB.language_datum_instances[message_language]

	// create 2 messages, one that appears if you know the language, and one that appears when you don't know the language
	var/image/I = image(loc = get_atom_on_turf(target), layer=FLY_LAYER)
	I.alpha = 0
	I.maptext_width = 128
	I.maptext_height = 64
	I.pixel_x = -48
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	I.maptext = "<center><span class='chatOverhead' style='[css]'>[message]</span></center>"

	var/image/O = image(loc = get_atom_on_turf(target), layer=FLY_LAYER)
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
		var/client/C = GLOB.clients[1]
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
			if(C.mob.can_speak_language(message_language))
				C.images += I
			else
				C.images += O

	animate(I, 1, alpha = 255, pixel_y = 24)
	animate(O, 1, alpha = 255, pixel_y = 24)

	addtimer(CALLBACK(GLOBAL_PROC, .proc/fadeout_overhead_messages, I, O), duration)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/delete_overhead_messages, I, O, show_to, target, message_language), duration+5)


/proc/fadeout_overhead_messages(image/I, image/O)
	var/pixel_y_new = I.pixel_y + 10
	animate(I, 2, pixel_y = pixel_y_new, alpha = 0)
	animate(O, 2, pixel_y = pixel_y_new, alpha = 0)

/proc/delete_overhead_messages(image/I, image/O, list/show_to, mob/living/target, message_language)
	for(var/client/C in show_to)
		if(C.mob.can_hear() && C.prefs.overhead_chat)
			if(C.mob.can_speak_language(message_language))
				C.images -= I
			else
				C.images -= O
	target.stored_chat_text -= I
	target.stored_chat_text -= O
	qdel(I)
	qdel(O)
