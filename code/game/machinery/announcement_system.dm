GLOBAL_LIST_EMPTY(announcement_systems)

/obj/machinery/announcement_system
	density = TRUE
	name = "\improper Automated Announcement System"
	desc = "An automated announcement system that handles minor announcements over the radio."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "AAS_On"

	verb_say = "coldly states"
	verb_ask = "queries"
	verb_exclaim = "alarms"

	idle_power_usage = 20
	active_power_usage = 50

	circuit = /obj/item/circuitboard/machine/announcement_system

	var/obj/item/radio/headset/radio
	var/arrival = "%PERSON has signed up as %RANK. Welcome to %STNAME."
	var/arrivalToggle = 1
	var/newhead = "%PERSON, %RANK, is the department head."
	var/newheadToggle = 1

	var/greenlight = "Light_Green"
	var/pinklight = "Light_Pink"
	var/errorlight = "Error_Red"

/obj/machinery/announcement_system/Initialize(mapload)
	. = ..()
	GLOB.announcement_systems += src
	radio = new /obj/item/radio/headset/silicon/ai(src)
	update_icon()

/obj/machinery/announcement_system/randomize_language_if_on_station()
	return

/obj/machinery/announcement_system/update_icon()
	if(is_operational)
		icon_state = (panel_open ? "AAS_On_Open" : "AAS_On")
	else
		icon_state = (panel_open ? "AAS_Off_Open" : "AAS_Off")


	cut_overlays()
	if(arrivalToggle)
		add_overlay(greenlight)

	if(newheadToggle)
		add_overlay(pinklight)

	if(machine_stat & BROKEN)
		add_overlay(errorlight)

/obj/machinery/announcement_system/Destroy()
	QDEL_NULL(radio)
	GLOB.announcement_systems -= src //"OH GOD WHY ARE THERE 100,000 LISTED ANNOUNCEMENT SYSTEMS?!!"
	return ..()

/obj/machinery/announcement_system/attackby(obj/item/P, mob/user, params)
	if(P.tool_behaviour == TOOL_SCREWDRIVER)
		P.play_tool_sound(src)
		panel_open = !panel_open
		to_chat(user, span_notice("You [panel_open ? "open" : "close"] the maintenance hatch of [src]."))
		update_icon()
	else if(default_deconstruction_crowbar(P))
		return
	else if(P.tool_behaviour == TOOL_MULTITOOL && panel_open && (machine_stat & BROKEN))
		to_chat(user, span_notice("You reset [src]'s firmware."))
		set_machine_stat(machine_stat & ~BROKEN)
		update_icon()
	else
		return ..()

/obj/machinery/announcement_system/proc/CompileText(str, user, rank) //replaces user-given variables with actual thingies.
	str = replacetext(str, "%PERSON", "[user]")
	str = replacetext(str, "%RANK", "[rank]")
	str = replacetext(str, "%STNAME", "[GLOB.station_name]")  // retrieves the stations name
	return str

/obj/machinery/announcement_system/proc/announce(message_type, user, rank, list/channels, exploration_payout = 0)
	if(!is_operational)
		return

	var/message

	if(message_type == "ARRIVAL" && arrivalToggle)
		message = CompileText(arrival, user, rank)
	else if(message_type == "NEWHEAD" && newheadToggle)
		message = CompileText(newhead, user, rank)
	else if(message_type == "AIWIPE" && newheadToggle)
		message = CompileText("%PERSON has been moved to intelligence storage.", user, rank)
	else if(message_type == "CRYOSTORAGE")
		message = CompileText("%PERSON, %RANK has been moved to cryo storage.", user, rank)
	else if(message_type == "ARRIVALS_BROKEN")
		message = "The arrivals shuttle has been damaged. Docking for repairs."
	else if(message_type == "EXPLORATION_PAYOUT")
		message = "Exploration objective completed. [exploration_payout / channels.len] credits have been distributed to the departmental budget."

	if(channels.len == 0)
		radio.talk_into(src, message, null)
	else
		for(var/channel in channels)
			radio.talk_into(src, message, channel)

//config stuff

/obj/machinery/announcement_system/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/announcement_system/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AutomatedAnnouncement")
		ui.open()

/obj/machinery/announcement_system/ui_data()
	var/list/data = list()
	data["arrival"] = arrival
	data["arrivalToggle"] = arrivalToggle
	data["newhead"] = newhead
	data["newheadToggle"] = newheadToggle
	return data

/obj/machinery/announcement_system/ui_act(action, param)
	. = ..()
	if(.)
		return
	if(!usr.canUseTopic(src, !issilicon(usr)))
		return
	if(machine_stat & BROKEN)
		visible_message(span_warning("[src] buzzes."), span_hear("You hear a faint buzz."))
		playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, TRUE)
		return
	switch(action)
		if("ArrivalText")
			var/NewMessage = trim(html_encode(param["newText"]), MAX_MESSAGE_LEN)
			if(!usr.canUseTopic(src, !issilicon(usr)))
				return
			if(NewMessage)
				arrival = NewMessage
				log_game("The arrivals announcement was updated: [NewMessage] by:[key_name(usr)]")
				. = TRUE
		if("NewheadText")
			var/NewMessage = trim(html_encode(param["newText"]), MAX_MESSAGE_LEN)
			if(!usr.canUseTopic(src, !issilicon(usr)))
				return
			if(NewMessage)
				newhead = NewMessage
				log_game("The head announcement was updated: [NewMessage] by:[key_name(usr)]")
				. = TRUE
		if("NewheadToggle")
			newheadToggle = !newheadToggle
			update_icon()
			. = TRUE
		if("ArrivalToggle")
			arrivalToggle = !arrivalToggle
			update_icon()
			. = TRUE

/obj/machinery/announcement_system/attack_silicon(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	if(machine_stat & BROKEN)
		to_chat(user, span_warning("[src]'s firmware appears to be malfunctioning!"))
		return
	interact(user)
	return TRUE

/obj/machinery/announcement_system/proc/act_up() //does funny breakage stuff
	if(!atom_break()) // if badmins flag this unbreakable or its already broken
		return

	arrival = pick("#!@%ERR-34%2 CANNOT LOCAT@# JO# F*LE!", "CRITICAL ERROR 99.", "ERR)#: DA#AB@#E NOT F(*ND!")
	newhead = pick("OV#RL()D: \[UNKNOWN??\] DET*#CT)D!", "ER)#R - B*@ TEXT F*O(ND!", "AAS.exe is not responding. NanoOS is searching for a solution to the problem.")
	ui_update()

/obj/machinery/announcement_system/emp_act(severity)
	. = ..()
	if(!(machine_stat & (NOPOWER|BROKEN)) && !(. & EMP_PROTECT_SELF))
		act_up()

/obj/machinery/announcement_system/on_emag(mob/user)
	..()
	act_up()
