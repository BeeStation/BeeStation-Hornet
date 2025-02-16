//computer that handle the points and teleports the prisoner
/obj/machinery/computer/prisoner/gulag_teleporter_computer
	name = "labor camp teleporter console"
	desc = "Used to send criminals to the Labor Camp."
	icon_screen = "explosive"
	icon_keyboard = "security_key"
	req_access = list(ACCESS_ARMORY)
	circuit = /obj/item/circuitboard/computer/gulag_teleporter_console
	light_color = LIGHT_COLOR_RED
	var/default_goal = 200
	var/obj/machinery/gulag_teleporter/teleporter
	var/obj/structure/gulag_beacon/beacon
	var/mob/living/carbon/human/prisoner
	var/datum/record/crew/temporary_record

/obj/machinery/computer/prisoner/gulag_teleporter_computer/Initialize(mapload)
	. = ..()
	scan_machinery()


/obj/machinery/computer/prisoner/gulag_teleporter_computer/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/prisoner/gulag_teleporter_computer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GulagTeleporterConsole")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/prisoner/gulag_teleporter_computer/ui_data(mob/user)
	var/list/data = list()
	var/list/prisoner_list = list()
	var/can_teleport = FALSE

	if(teleporter && (teleporter.occupant && ishuman(teleporter.occupant)))
		prisoner = teleporter.occupant
		prisoner_list["name"] = prisoner.real_name
		if(contained_id)
			can_teleport = TRUE
		for(var/manifests in GLOB.manifest.general)
			var/datum/record/crew/crew_record = manifests
			if(crew_record.name == prisoner_list["name"])
				temporary_record = crew_record
				prisoner_list["crimstat"] = temporary_record.wanted_status

	data["prisoner"] = prisoner_list

	if(teleporter)
		data["teleporter"] = teleporter
		data["teleporter_location"] = "([teleporter.x], [teleporter.y], [teleporter.get_virtual_z_level()])"
		data["teleporter_lock"] = teleporter.locked
		data["teleporter_state_open"] = teleporter.state_open
	else
		data["teleporter"] = null
	if(beacon)
		data["beacon"] = beacon
		data["beacon_location"] = "([beacon.x], [beacon.y], [beacon.get_virtual_z_level()])"
	else
		data["beacon"] = null
	if(contained_id)
		data["id"] = contained_id
		data["id_name"] = contained_id.registered_name
		data["goal"] = contained_id.goal
		data["permanent"] = contained_id.permanent
	else
		data["id"] = null
	data["can_teleport"] = can_teleport

	return data

/obj/machinery/computer/prisoner/gulag_teleporter_computer/ui_act(action, list/params)
	if(..())
		return
	if(isliving(usr))
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
	if(!allowed(usr))
		to_chat(usr, span_warning("Access denied."))
		return
	switch(action)
		if("scan_teleporter")
			teleporter = findteleporter()
			return TRUE
		if("scan_beacon")
			beacon = findbeacon()
			return TRUE
		if("handle_id")
			if(contained_id)
				id_eject(usr)
			else
				id_insert(usr)
			return TRUE
		if("set_goal")
			var/new_goal = text2num(params["value"])
			if(!isnum_safe(new_goal) || !contained_id)
				return
			if(!new_goal)
				new_goal = default_goal
			contained_id.goal = clamp(new_goal, 0, 1500) //maximum 1500 points
			return TRUE
		if("set_permanent")
			if(!contained_id)
				return
			contained_id.permanent = !contained_id.permanent
			return TRUE
		if("toggle_open")
			if(teleporter.locked)
				to_chat(usr, span_alert("The teleporter must be unlocked first."))
				return
			teleporter.toggle_open()
			return TRUE
		if("teleporter_lock")
			if(teleporter.state_open)
				to_chat(usr, span_alert("The teleporter must be closed first."))
				return
			teleporter.locked = !teleporter.locked
			return TRUE
		if("teleport")
			if(!teleporter || !beacon)
				return
			addtimer(CALLBACK(src, PROC_REF(teleport), usr), 5)
			return TRUE

/obj/machinery/computer/prisoner/gulag_teleporter_computer/proc/scan_machinery()
	teleporter = findteleporter()
	beacon = findbeacon()

/obj/machinery/computer/prisoner/gulag_teleporter_computer/proc/findteleporter()
	var/obj/machinery/gulag_teleporter/teleporterf

	for(var/direction in GLOB.cardinals)
		teleporterf = locate(/obj/machinery/gulag_teleporter, get_step(src, direction))
		if(teleporterf && teleporterf.is_operational)
			return teleporterf

/obj/machinery/computer/prisoner/gulag_teleporter_computer/proc/findbeacon()
	return locate(/obj/structure/gulag_beacon)

/obj/machinery/computer/prisoner/gulag_teleporter_computer/proc/teleport(mob/user)
	if(!contained_id) //incase the ID was removed after the transfer timer was set.
		say("Warning: Unable to transfer prisoner without a valid Prisoner ID inserted!")
		return
	var/id_goal_not_set
	if(!contained_id.goal && !contained_id.permanent)
		id_goal_not_set = TRUE
		contained_id.goal = default_goal
		say("[contained_id]'s ID card goal defaulting to [contained_id.goal] points.")
		log_game("[key_name(user)] teleported [key_name(prisoner)] to the Labor Camp [COORD(beacon)] for [id_goal_not_set ? "default goal of ":""][contained_id.goal] points.")
	log_game("[key_name(user)] teleported [key_name(prisoner)] to the Labor Camp [COORD(beacon)] permanently.")
	teleporter.handle_prisoner(contained_id, temporary_record)
	playsound(src, 'sound/weapons/emitter.ogg', 50, TRUE)
	if(do_teleport(prisoner, get_turf(beacon)))
		prisoner.Paralyze(40) // small travel dizziness
		to_chat(prisoner, span_warning("The teleportation makes you a little dizzy."))
		if(teleporter.locked)
			teleporter.locked = FALSE
		teleporter.toggle_open()
		contained_id = null
		temporary_record = null
