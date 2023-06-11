/obj/item/taperecorder
	name = "universal recorder"
	desc = "A device that can record to cassette tapes, and play them. It automatically translates the content in playback."
	icon = 'icons/obj/device.dmi'
	icon_state = "taperecorder_empty"
	item_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	materials = list(/datum/material/iron=60, /datum/material/glass=30)
	force = 2
	throwforce = 0
	drop_sound = 'sound/items/handling/taperecorder_drop.ogg'
	pickup_sound = 'sound/items/handling/taperecorder_pickup.ogg'
	var/recording = 0
	var/playing = 0
	var/playsleepseconds = 0
	var/obj/item/tape/mytape
	var/starting_tape_type = /obj/item/tape/random
	var/open_panel = 0
	var/canprint = 1


/obj/item/taperecorder/Initialize(mapload)
	. = ..()
	if(starting_tape_type)
		mytape = new starting_tape_type(src)
	update_icon()
	become_hearing_sensitive()

/obj/item/taperecorder/Destroy()
	QDEL_NULL(mytape)
	return ..()

/obj/item/taperecorder/examine(mob/user)
	. = ..()
	. += "The wire panel is [open_panel ? "opened" : "closed"]."


/obj/item/taperecorder/attackby(obj/item/I, mob/user, params)
	if(!mytape && istype(I, /obj/item/tape))
		if(!user.transferItemToLoc(I,src))
			return
		mytape = I
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		update_icon()


/obj/item/taperecorder/proc/eject(mob/user)
	if(mytape)
		to_chat(user, "<span class='notice'>You remove [mytape] from [src].</span>")
		stop()
		user.put_in_hands(mytape)
		mytape = null
		update_icon()

/obj/item/taperecorder/fire_act(exposed_temperature, exposed_volume)
	mytape.ruin() //Fires destroy the tape
	..()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/taperecorder/attack_hand(mob/user)
	if(loc == user)
		if(mytape)
			if(!user.is_holding(src))
				return ..()
			eject(user)
	else
		return ..()

/obj/item/taperecorder/proc/can_use(mob/user)
	if(user && ismob(user))
		if(!user.incapacitated())
			return TRUE
	return FALSE


/obj/item/taperecorder/verb/ejectverb()
	set name = "Eject Tape"
	set category = "Object"

	if(!can_use(usr))
		return
	if(!mytape)
		return

	eject(usr)


/obj/item/taperecorder/update_icon()
	if(!mytape)
		icon_state = "taperecorder_empty"
	else if(recording)
		icon_state = "taperecorder_recording"
	else if(playing)
		icon_state = "taperecorder_playing"
	else
		icon_state = "taperecorder_idle"


/obj/item/taperecorder/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans, list/message_mods = list())
	. = ..()
	if(mytape && recording)
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] [message]"

/obj/item/taperecorder/verb/record()
	set name = "Start Recording"
	set category = "Object"

	if(!can_use(usr))
		return
	if(!mytape || mytape.ruined)
		return
	if(recording)
		return
	if(playing)
		return

	if(mytape.used_capacity < mytape.max_capacity)
		to_chat(usr, "<span class='notice'>Recording started.</span>")
		recording = 1
		update_icon()
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] Recording started."
		var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
		var/max = mytape.max_capacity
		while(recording && used < max)
			mytape.used_capacity++
			used++
			sleep(10)
		recording = 0
		update_icon()
	else
		to_chat(usr, "<span class='notice'>The tape is full.</span>")


/obj/item/taperecorder/verb/stop()
	set name = "Stop"
	set category = "Object"

	if(!can_use(usr))
		return

	if(recording)
		recording = 0
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] Recording stopped."
		to_chat(usr, "<span class='notice'>Recording stopped.</span>")
		return
	else if(playing)
		playing = 0
		var/turf/T = get_turf(src)
		T.visible_message("<font color=Maroon><B>Tape Recorder</B>: Playback stopped.</font>")
	update_icon()


/obj/item/taperecorder/verb/play()
	set name = "Play Tape"
	set category = "Object"

	if(!can_use(usr))
		return
	if(!mytape || mytape.ruined)
		return
	if(recording)
		return
	if(playing)
		return

	playing = 1
	update_icon()
	to_chat(usr, "<span class='notice'>Playing started.</span>")
	var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
	var/max = mytape.max_capacity
	for(var/i = 1, used < max, sleep(10 * playsleepseconds))
		if(!mytape)
			break
		if(playing == 0)
			break
		if(mytape.storedinfo.len < i)
			break
		say(mytape.storedinfo[i])
		if(mytape.storedinfo.len < i + 1)
			playsleepseconds = 1
			sleep(10)
			say("End of recording.")
		else
			playsleepseconds = mytape.timestamp[i + 1] - mytape.timestamp[i]
		if(playsleepseconds > 14)
			sleep(10)
			say("Skipping [playsleepseconds] seconds of silence")
			playsleepseconds = 1
		i++

	playing = 0
	update_icon()


/obj/item/taperecorder/attack_self(mob/user)
	if(!mytape || mytape.ruined)
		return
	if(recording)
		stop()
	else
		record()


/obj/item/taperecorder/verb/print_transcript()
	set name = "Print Transcript"
	set category = "Object"

	var/list/transcribed_info = mytape.storedinfo
	if(!length(transcribed_info))
		return
	if(!mytape)
		return
	if(!canprint)
		to_chat(usr, "<span class='notice'>The recorder can't print that fast!</span>")
		return
	if(recording || playing)
		return
	if(!can_use(usr))
		return

	var/transcribed_text = "<b>Transcript:</b><br><br>"
	var/page_count = 1

	var/tape_name = mytape.name
	var/initial_tape_name = initial(mytape.name)
	var/paper_name = "paper- '[tape_name == initial_tape_name ? "Tape" : "[tape_name]"] Transcript'"

	for(var/transcript_excerpt in transcribed_info)
		var/excerpt_length = length(transcript_excerpt)

		// Very unexpected. Better abort non-gracefully.
		if(excerpt_length > MAX_PAPER_LENGTH)
			say("Error: Data corruption detected. Cannot print.")
			CRASH("Transcript entry has more than [MAX_PAPER_LENGTH] chars: [excerpt_length] chars")

		// If we're going to overflow the paper's length, print the current transcribed text out first and reset to prevent us
		// going over the paper char count.
		if((length(transcribed_text) + excerpt_length) > MAX_PAPER_LENGTH)
			var/obj/item/paper/transcript_paper = new /obj/item/paper(get_turf(src))
			transcript_paper.add_raw_text(transcribed_text)
			transcript_paper.name = "[paper_name] page [page_count]"
			transcript_paper.update_appearance()
			transcribed_text = ""
			page_count++

		transcribed_text += "[transcript_excerpt]<br>"

	var/obj/item/paper/transcript_paper = new /obj/item/paper(get_turf(src))
	transcript_paper.add_raw_text(transcribed_text)
	transcript_paper.name = "[paper_name] page [page_count]"
	transcript_paper.update_appearance()
	to_chat(usr, "Transcript printed, [page_count] pages.")
	usr.put_in_hands(transcript_paper)
	canprint = FALSE
	addtimer(VARSET_CALLBACK(src, canprint, TRUE), 30 SECONDS)


//empty tape recorders
/obj/item/taperecorder/empty
	starting_tape_type = null


/obj/item/tape
	name = "tape"
	desc = "A magnetic tape that can hold up to ten minutes of content."
	icon_state = "tape_white"
	icon = 'icons/obj/device.dmi'
	item_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	materials = list(/datum/material/iron=20, /datum/material/glass=5)
	force = 1
	throwforce = 0
	var/max_capacity = 600
	var/used_capacity = 0
	var/list/storedinfo = list()
	var/list/timestamp = list()
	var/ruined = 0

/obj/item/tape/fire_act(exposed_temperature, exposed_volume)
	ruin()
	..()

/obj/item/tape/attack_self(mob/user)
	if(!ruined)
		to_chat(user, "<span class='notice'>You pull out all the tape!</span>")
		ruin()


/obj/item/tape/proc/ruin()
	//Lets not add infinite amounts of overlays when our fireact is called
	//repeatedly
	if(!ruined)
		add_overlay("ribbonoverlay")
	ruined = 1


/obj/item/tape/proc/fix()
	cut_overlay("ribbonoverlay")
	ruined = 0


/obj/item/tape/attackby(obj/item/I, mob/user, params)
	if(ruined && I.tool_behaviour == TOOL_SCREWDRIVER || istype(I, /obj/item/pen))
		to_chat(user, "<span class='notice'>You start winding the tape back in...</span>")
		if(I.use_tool(src, user, 120))
			to_chat(user, "<span class='notice'>You wound the tape back in.</span>")
			fix()

//Random colour tapes
/obj/item/tape/random
	icon_state = "random_tape"

/obj/item/tape/random/Initialize(mapload)
	. = ..()
	icon_state = "tape_[pick("white", "blue", "red", "yellow", "purple")]"
