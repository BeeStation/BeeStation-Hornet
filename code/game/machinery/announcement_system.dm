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
	var/arrival = "%PERSON has signed up as %RANK"
	var/arrivalToggle = 1
	var/newhead = "%PERSON, %RANK, is the department head."
	var/newheadToggle = 1

	var/greenlight = "Light_Green"
	var/pinklight = "Light_Pink"
	var/errorlight = "Error_Red"

/obj/machinery/announcement_system/Initialize()
	. = ..()
	GLOB.announcement_systems += src
	radio = new /obj/item/radio/headset/silicon/ai(src)
	update_icon()

/obj/machinery/announcement_system/update_icon()
	if(is_operational())
		icon_state = (panel_open ? "AAS_On_Open" : "AAS_On")
	else
		icon_state = (panel_open ? "AAS_Off_Open" : "AAS_Off")


	cut_overlays()
	if(arrivalToggle)
		add_overlay(greenlight)

	if(newheadToggle)
		add_overlay(pinklight)

	if(stat & BROKEN)
		add_overlay(errorlight)

/obj/machinery/announcement_system/Destroy()
	QDEL_NULL(radio)
	GLOB.announcement_systems -= src //"OH GOD WHY ARE THERE 100,000 LISTED ANNOUNCEMENT SYSTEMS?!!"
	return ..()

/obj/machinery/announcement_system/power_change()
	..()
	update_icon()

/obj/machinery/announcement_system/attackby(obj/item/P, mob/user, params)
	if(P.tool_behaviour == TOOL_SCREWDRIVER)
		P.play_tool_sound(src)
		panel_open = !panel_open
		to_chat(user, "<span class='notice'>You [panel_open ? "open" : "close"] the maintenance hatch of [src].</span>")
		update_icon()
	else if(default_deconstruction_crowbar(P))
		return
	else if(P.tool_behaviour == TOOL_MULTITOOL && panel_open && (stat & BROKEN))
		to_chat(user, "<span class='notice'>You reset [src]'s firmware.</span>")
		stat &= ~BROKEN
		update_icon()
	else
		return ..()

/obj/machinery/announcement_system/proc/CompileText(str, user, rank) //replaces user-given variables with actual thingies.
	str = replacetext(str, "%PERSON", "[user]")
	str = replacetext(str, "%RANK", "[rank]")
	return str

/obj/machinery/announcement_system/proc/announce(message_type, user, rank, list/channels)
	if(!is_operational())
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
		message = "The arrivals shuttle has been damaged. Docking for repairs..."

	if(channels.len == 0)
		radio.talk_into(src, message, null)
	else
		for(var/channel in channels)
			radio.talk_into(src, message, channel)

//config stuff

/obj/machinery/announcement_system/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "AutomatedAnnouncement", "Automated Announcement System", 500, 225, master_ui, state)
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
	if(stat & BROKEN)
		visible_message("<span class='warning'>[src] buzzes.</span>", "<span class='hear'>You hear a faint buzz.</span>")
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
		if("NewheadText")
			var/NewMessage = trim(html_encode(param["newText"]), MAX_MESSAGE_LEN)
			if(!usr.canUseTopic(src, !issilicon(usr)))
				return
			if(NewMessage)
				newhead = NewMessage
				log_game("The head announcement was updated: [NewMessage] by:[key_name(usr)]")
		if("NewheadToggle")
			newheadToggle = !newheadToggle
			update_icon()
		if("ArrivalToggle")
			arrivalToggle = !arrivalToggle
			update_icon()
	add_fingerprint(usr)

/obj/machinery/announcement_system/attack_robot(mob/living/silicon/user)
	. = attack_ai(user)

/obj/machinery/announcement_system/attack_ai(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	if(stat & BROKEN)
		to_chat(user, "<span class='warning'>[src]'s firmware appears to be malfunctioning!</span>")
		return
	interact(user)

/obj/machinery/announcement_system/proc/act_up() //does funny breakage stuff
	stat |= BROKEN
	update_icon()

	arrival = pick("#!@%ERR-34%2 CANNOT LOCAT@# JO# F*LE!", "CRITICAL ERROR 99.", "ERR)#: DA#AB@#E NOT F(*ND!")
	newhead = pick("OV#RL()D: \[UNKNOWN??\] DET*#CT)D!", "ER)#R - B*@ TEXT F*O(ND!", "AAS.exe is not responding. NanoOS is searching for a solution to the problem.")

/obj/machinery/announcement_system/emp_act(severity)
	. = ..()
	if(!(stat & (NOPOWER|BROKEN)) && !(. & EMP_PROTECT_SELF))
		act_up()

/obj/machinery/announcement_system/emag_act()
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	act_up()
