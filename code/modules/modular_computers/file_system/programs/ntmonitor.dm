/datum/computer_file/program/ntnetmonitor
	filename = "ntmonitor"
	filedesc = "NTNet Diagnostics and Monitoring"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "comm_monitor"
	extended_desc = "This program monitors stationwide NTNet network, provides access to logging systems, and allows for configuration changes"
	size = 8
	requires_ntnet = FALSE // We're letting this be used without access so if net is disabled it can be re-enabled (Theres no simple method to do it otherwise)
	transfer_access = list(ACCESS_RESEARCH)
	tgui_id = "NtosNetMonitor"
	program_icon = "network-wired"
	hardware_requirement = MC_NET	// It doesn't require a network connection directly but it does require a network card
	power_consumption = 80 WATT

/datum/computer_file/program/ntnetmonitor/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	var/obj/item/computer_hardware/network_card/card = computer.all_components[MC_NET]
	switch(action)
		if("resetIDS")
			SSmodular_computers.intrusion_detection_alarm = FALSE
			return TRUE
		if("toggleIDS")
			SSmodular_computers.intrusion_detection_enabled = !SSmodular_computers.intrusion_detection_enabled
			return TRUE
		if("toggle_relay")
			var/obj/machinery/ntnet_relay/target_relay = locate(params["ref"]) in GLOB.ntnet_relays
			if(!istype(target_relay))
				return
			target_relay.set_relay_enabled(!target_relay.relay_enabled)
			return TRUE
		if("purgelogs")
			SSmodular_computers.purge_logs()
			computer.add_log("SYSnotice :: LOGS PURGED! AUTHKEY :", TRUE, card)
			return TRUE
		if("toggle_mass_pda")
			var/mob/user = ui.user

			var/obj/item/modular_computer/target_tablet = locate(params["ref"]) in GLOB.TabletMessengers
			if(!istype(target_tablet))
				return
			var/obj/item/computer_hardware/hard_drive/drive = target_tablet.all_components[MC_HDD]
			if(!drive)
				to_chat(user, span_boldnotice("Target tablet somehow is lacking a hard drive."))
				return
			for(var/datum/computer_file/program/messenger/messenger_app in drive.stored_files)
				messenger_app.spam_mode = !messenger_app.spam_mode
			return TRUE

/datum/computer_file/program/ntnetmonitor/ui_data(mob/user)
	var/list/data = list()

	data["ntnetrelays"] = list()
	for(var/obj/machinery/ntnet_relay/relays as anything in GLOB.ntnet_relays)
		var/list/relay_data = list()
		relay_data["is_operational"] = !!relays.is_operational
		relay_data["name"] = relays.name
		relay_data["ref"] = REF(relays)

		data["ntnetrelays"] += list(relay_data)

	data["idsstatus"] = SSmodular_computers.intrusion_detection_enabled
	data["idsalarm"] = SSmodular_computers.intrusion_detection_alarm

	data["ntnetlogs"] = list()
	for(var/i in SSmodular_computers.logs)
		var/log_entry = i
		var/log_color = COLOR_WHITE  //default white
		var/entry_lower = LOWER_TEXT(log_entry)	// This will make sure lower case and upper case are treated the same for this purpose
		// very simple keyword‑based colouring
		if(findtext(entry_lower, "alert") || findtext(entry_lower, "warning"))
			log_color = COLOR_RED // red for alerts (detected threat)
		else if(findtext(entry_lower, "sysnotice") || findtext(entry_lower, "advisory"))
			log_color = "#ffaa00" // amber for notices (suspicious activity)
		else if(findtext(entry_lower, "message logged") || findtext(entry_lower, "msg log") || findtext(entry_lower, "transmission"))
			log_color = "#48aff0" // cyan for routine chat
		else if(findtext(entry_lower, "diagnostics"))
			log_color = "#12d312" // lime for diagnotics

		data["ntnetlogs"] += list(list(
			"entry" = log_entry,
			"color" = log_color,
		))

	data["tablets"] = list()
	for(var/obj/item/modular_computer/messenger as anything in GetViewableDevices())
		var/list/tablet_data = list()
		if(messenger.saved_identification)
			var/obj/item/computer_hardware/hard_drive/drive = messenger.all_components[MC_HDD]
			if(!drive)
				continue
			for(var/datum/computer_file/program/messenger/messenger_app in drive.stored_files)
				tablet_data["enabled_spam"] += messenger_app.spam_mode

			tablet_data["name"] += messenger.saved_identification
			tablet_data["ref"] += REF(messenger)

		data["tablets"] += list(tablet_data)

	return data
