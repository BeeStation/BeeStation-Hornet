/datum/computer_file/program/supermatter_monitor
	filename = "ntcims"
	filedesc = "NT CIMS"
	category = PROGRAM_CATEGORY_ENGI
	ui_header = "smmon_0.gif"
	program_icon_state = "smmon_0"
	extended_desc = "Crystal Integrity Monitoring System, connects to specially calibrated supermatter sensors to provide information on the status of supermatter-based engines."
	requires_ntnet = TRUE
	transfer_access = list(ACCESS_CONSTRUCTION)
	network_destination = "supermatter monitoring system"
	size = 4
	tgui_id = "NtosSupermatter"
	program_icon = "radiation"
	alert_able = TRUE
	power_consumption = 60 WATT

	/// Last known status of the supermatter, used to set the program icon.
	var/last_status = SUPERMATTER_INACTIVE
	/// List of supermatters that we are going to send the data of.
	var/list/obj/machinery/power/supermatter_crystal/supermatters = list()
	/// The supermatter which will send a notification to us if it's delamming.
	var/obj/machinery/power/supermatter_crystal/focused_supermatter

/datum/computer_file/program/supermatter_monitor/on_start(mob/living/user)
	. = ..()
	refresh()

/datum/computer_file/program/supermatter_monitor/kill_program(forced = FALSE)
	for(var/obj/machinery/power/supermatter_crystal/supermatter in supermatters)
		clear_supermatter(supermatter)
	supermatters = null
	. = ..()

/datum/computer_file/program/supermatter_monitor/process_tick()
	. = ..()
	var/new_status = SUPERMATTER_INACTIVE
	for(var/obj/machinery/power/supermatter_crystal/sm in supermatters)
		new_status = max(new_status, sm.get_status())

	if(last_status != new_status)
		last_status = new_status
		ui_header = "smmon_[last_status].gif"
		program_icon_state = "smmon_[last_status]"
		if(istype(computer))
			computer.update_icon()

/datum/computer_file/program/supermatter_monitor/ui_static_data(mob/user)
	var/list/data = list()
	data["gas_metadata"] = sm_gas_data()

	return data

/datum/computer_file/program/supermatter_monitor/ui_data(mob/user)
	var/list/data = list()
	data["sm_data"] = list()

	for(var/obj/machinery/power/supermatter_crystal/sm in supermatters)
		data["sm_data"] += list(sm.sm_ui_data())
	data["focus_uid"] = focused_supermatter?.uid

	return data

/datum/computer_file/program/supermatter_monitor/ui_act(action, params)
	. = ..()
	if(.)
		return TRUE

	switch(action)
		if("PRG_refresh")
			refresh()
			return TRUE
		if("PRG_focus")
			for (var/obj/machinery/power/supermatter_crystal/sm in supermatters)
				if(sm.uid == params["focus_uid"])
					if(focused_supermatter == sm)
						unfocus_supermatter(sm)
					else
						focus_supermatter(sm)
					return TRUE

// Refreshes list of active supermatter crystals
/datum/computer_file/program/supermatter_monitor/proc/refresh()
	for(var/supermatter in supermatters)
		clear_supermatter(supermatter)

	var/turf/user_turf = get_turf(computer.ui_host())
	if(!user_turf)
		return

	for(var/obj/machinery/power/supermatter_crystal/sm in GLOB.machines)
		// Exclude Syndicate owned, Delaminating, not within coverage, not on a tile.
		if(!sm.include_in_cims || !isturf(sm.loc) || !(is_station_level(sm.z) || is_mining_level(sm.z) || sm.z == user_turf.z))
			continue

		supermatters += sm
		RegisterSignal(sm, COMSIG_QDELETING, PROC_REF(clear_supermatter))


/**
  * Sends an SM delam alert to the computer if our focused supermatter is delaminating.
  * [var/obj/machinery/power/supermatter_crystal/focused_supermatter].
**/
/datum/computer_file/program/supermatter_monitor/proc/send_alert()
	SIGNAL_HANDLER

	if(!computer.get_ntnet_status())
		return

	computer.alert_call(src, "Crystal delamination in progress!")
	alert_pending = TRUE

/datum/computer_file/program/supermatter_monitor/proc/clear_supermatter(obj/machinery/power/supermatter_crystal/sm)
	SIGNAL_HANDLER

	supermatters -= sm
	if(focused_supermatter == sm)
		unfocus_supermatter()
	UnregisterSignal(sm, COMSIG_QDELETING)

/datum/computer_file/program/supermatter_monitor/proc/focus_supermatter(obj/machinery/power/supermatter_crystal/sm)
	if(sm == focused_supermatter)
		return

	if(focused_supermatter)
		unfocus_supermatter()

	RegisterSignal(sm, COMSIG_SUPERMATTER_DELAM_ALARM, PROC_REF(send_alert))
	focused_supermatter = sm

/datum/computer_file/program/supermatter_monitor/proc/unfocus_supermatter()
	if(!focused_supermatter)
		return

	UnregisterSignal(focused_supermatter, COMSIG_SUPERMATTER_DELAM_ALARM)
	focused_supermatter = null
