/datum/computer_file/program/borg_monitor
	filename = "cyborgmonitor"
	filedesc = "Cyborg Remote Monitoring"
	category = PROGRAM_CATEGORY_ROBO
	ui_header = "borg_mon.gif"
	program_icon_state = "generic"
	extended_desc = "This program allows for remote monitoring of station cyborgs."
	requires_ntnet = TRUE
	transfer_access = list(ACCESS_ROBOTICS)
	network_destination = "cyborg remote monitoring"
	size = 6
	tgui_id = "NtosCyborgRemoteMonitor"
	program_icon = "project-diagram"
	power_consumption = 100 WATT
	var/emagged = FALSE

/datum/computer_file/program/borg_monitor/run_emag()
	if(emagged)
		return FALSE
	emagged = TRUE
	return TRUE

/datum/computer_file/program/borg_monitor/ui_data(mob/user)
	var/list/data = list()

	// Syndicate version doesn't require an ID - so we use this proc instead of computer.GetID()
	data["card"] = !!get_id_name()

	data["cyborgs"] = list()
	for(var/mob/living/silicon/robot/robot as anything in GLOB.cyborg_list)
		if(!evaluate_borg(robot))
			continue

		var/list/upgrade
		for(var/obj/item/borg/upgrade/I in robot.upgrades)
			upgrade += "\[[I.name]\] "

		var/shell = FALSE
		if(robot.shell && !robot.ckey)
			shell = TRUE

		var/list/cyborg_data = list(
			name = robot.name,
			locked_down = robot.lockcharge,
			status = robot.stat,
			shell_discon = shell,
			charge = robot.cell ? round(robot.cell.percent()) : null,
			module = robot.model ? "[robot.model.name] Model" : "No Model Detected",
			upgrades = upgrade,
			ref = REF(robot)
		)
		data["cyborgs"] += list(cyborg_data)
	return data

/datum/computer_file/program/borg_monitor/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("messagebot")
			var/mob/living/silicon/robot/robot = locate(params["ref"]) in GLOB.cyborg_list
			if(!istype(robot))
				return TRUE
			var/sender_name = get_id_name()
			if(!sender_name)
				// This can only happen if the action somehow gets called as UI blocks this action with no ID
				computer.visible_message(span_notice("Insert an ID to send messages."))
				playsound(usr, 'sound/machines/terminal_error.ogg', 15, TRUE)
				return TRUE
			if(robot.stat == DEAD) //Dead borgs will listen to you no longer
				to_chat(usr, span_warn("Error -- Could not open a connection to unit:[robot]"))
			var/message = stripped_input(usr, message = "Enter message to be sent to remote cyborg.", title = "Send Message")
			if(!message)
				return
			if(OOC_FILTER_CHECK(message))
				to_chat(usr, span_warning("ERROR: Prohibited word(s) detected in message."))
				return
			to_chat(usr, "<br><br>[span_notice("Message to [robot] (as [sender_name]) -- \"[message]\"")]<br>")
			computer.send_sound()
			to_chat(robot, "<br><br>[span_notice("Message from [sender_name] -- \"[message]\"")]<br>")
			SEND_SOUND(robot, 'sound/machines/twobeep_high.ogg')
			if(robot.connected_ai)
				to_chat(robot.connected_ai, "<br><br>[span_notice("Message from [sender_name] to [robot] -- \"[message]\"")]<br>")
				SEND_SOUND(robot.connected_ai, 'sound/machines/twobeep_high.ogg')
			robot.logevent("Message from [sender_name] -- \"[message]\"")
			usr.log_talk(message, LOG_PDA, tag="Cyborg Monitor Program: ID name \"[sender_name]\" to [robot]")
			return TRUE

///This proc is used to determin if a borg should be shown in the list (based on the borg's scrambledcodes var). Syndicate version overrides this to show only syndicate borgs.
/datum/computer_file/program/borg_monitor/proc/evaluate_borg(mob/living/silicon/robot/robot)
	var/turf/computer_turf = get_turf(computer)
	var/turf/robot_turf = get_turf(robot)
	if(computer_turf.get_virtual_z_level() != robot_turf.get_virtual_z_level())
		return FALSE
	if(robot.scrambledcodes)
		return FALSE
	return TRUE

///Gets the ID's name, if one is inserted into the device. This is a separate proc solely to be overridden by the syndicate version of the app.
/datum/computer_file/program/borg_monitor/proc/get_id_name()
	var/obj/item/card/id/ID = computer.GetID()
	if(!istype(ID))
		return emagged ? "STDERR:UNDF" : FALSE
	return ID.registered_name

/datum/computer_file/program/borg_monitor/syndicate
	filename = "scyborgmonitor"
	filedesc = "Mission-Specific Cyborg Remote Monitoring"
	extended_desc = "This program allows for remote monitoring of mission-assigned cyborgs."
	requires_ntnet = FALSE
	available_on_ntnet = FALSE
	available_on_syndinet = TRUE
	transfer_access = null
	tgui_id = "NtosCyborgRemoteMonitorSyndicate"
	power_consumption = 10 WATT

/datum/computer_file/program/borg_monitor/syndicate/run_emag()
	return FALSE

/datum/computer_file/program/borg_monitor/syndicate/evaluate_borg(mob/living/silicon/robot/robot)
	if((get_turf(computer)).get_virtual_z_level() != (get_turf(robot)).get_virtual_z_level())
		return FALSE
	if(!robot.scrambledcodes)
		return FALSE
	return TRUE

/datum/computer_file/program/borg_monitor/syndicate/get_id_name()
	return "\[REDACTED\]" //no ID is needed for the syndicate version's message function, and the borg will see "[REDACTED]" as the message sender.
