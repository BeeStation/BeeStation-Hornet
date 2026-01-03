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

/datum/computer_file/program/ntnetmonitor/ui_act(action, params)
	if(..())
		return
	var/obj/item/computer_hardware/network_card/card = computer.all_components[MC_NET]
	switch(action)
		if("resetIDS")	//intrusion_detection_alarm
			if(SSnetworks.station_network)
				SSnetworks.station_network.resetIDS()
			return TRUE
		if("toggleIDS")	//intrusion_detection_enabled
			if(SSnetworks.station_network)
				SSnetworks.station_network.toggleIDS()
			return TRUE
		if("toggleWireless")
			if(!SSnetworks.station_network)
				return

			// NTNet is disabled. Enabling can be done without user prompt
			if(SSnetworks.station_network.setting_disabled)
				computer.add_log("DIAGNOSTICS // NETWORK SERVICE MANUALY RE-ENABLED // AUTHKEY :", TRUE, card)
				SSnetworks.station_network.setting_disabled = FALSE
				return TRUE
			computer.add_log("DIAGNOSTICS // NETWORK SERVICE MANUALY DISABLED // AUTHKEY :", TRUE, card)
			SSnetworks.station_network.setting_disabled = TRUE
			return TRUE
		if("purgelogs")
			if(SSnetworks.station_network)
				SSnetworks.purge_logs()
				computer.add_log("SYSnotice :: LOGS PURGED! AUTHKEY :", TRUE, card)
			return TRUE
		if("updatemaxlogs")
			var/logcount = params["new_number"]
			if(SSnetworks.station_network)
				SSnetworks.update_max_log_count(logcount)
			return TRUE
		if("toggle_function")
			if(!SSnetworks.station_network)
				return
			SSnetworks.station_network.toggle_function(text2num(params["id"]), computer)
			return TRUE

/datum/computer_file/program/ntnetmonitor/ui_data(mob/user)
	if(!SSnetworks.station_network)
		return
	var/list/data = list()

	data["ntnetstatus"] = SSnetworks.station_network.check_function(zlevel=user.get_virtual_z_level())
	data["ntnetrelays"] = SSnetworks.relays.len
	data["idsstatus"] = SSnetworks.station_network.intrusion_detection_enabled
	data["idsalarm"] = SSnetworks.station_network.intrusion_detection_alarm

	data["config_softwaredownload"] = SSnetworks.station_network.setting_softwaredownload
	data["config_peertopeer"] = SSnetworks.station_network.setting_peertopeer
	data["config_communication"] = SSnetworks.station_network.setting_communication
	data["config_systemcontrol"] = SSnetworks.station_network.setting_systemcontrol

	data["ntnetlogs"] = list()
	data["minlogs"] = MIN_NTNET_LOGS
	data["maxlogs"] = MAX_NTNET_LOGS

	for (var/i in SSnetworks.logs)
		var/log_entry = i
		var/log_color = "#ffffff"            // default white
		var/entry_lower = LOWER_TEXT(log_entry)	// This will make sure lower case and upper case are treated the same for this purpose
		// very simple keyword‑based colouring
		if(findtext(entry_lower, "alert") || findtext(entry_lower, "warning"))
			log_color = "#ff0000"            // red for alerts (detected threat)
		else if(findtext(entry_lower, "sysnotice") || findtext(entry_lower, "advisory"))
			log_color = "#ffaa00"            // amber for notices (suspicious activity)
		else if(findtext(entry_lower, "message logged") || findtext(entry_lower, "msg log") || findtext(entry_lower, "transmission"))
			log_color = "#48aff0"            // cyan for routine chat
		else if(findtext(entry_lower, "diagnostics"))
			log_color = "#12d312"            // lime for diagnotics

		data["ntnetlogs"] += list(list(
		"entry" = log_entry,
		"color" = log_color,
		))
	data["ntnetmaxlogs"] = SSnetworks.setting_maxlogcount

	return data
