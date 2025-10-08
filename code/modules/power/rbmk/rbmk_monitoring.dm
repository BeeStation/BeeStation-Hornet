// RBMK Monitoring was moved here for QoL

//Monitoring program.
/datum/computer_file/program/nuclear_monitor
	filename = "rbmkmonitor"
	filedesc = "Nuclear Reactor Monitoring"
	category = PROGRAM_CATEGORY_ENGI
	ui_header = "smmon_0.gif"
	program_icon_state = "smmon_0"
	extended_desc = "This program connects to specially calibrated sensors to provide information on the status of nuclear reactors."
	requires_ntnet = TRUE
	transfer_access = list(ACCESS_CONSTRUCTION)
	network_destination = "rbmk monitoring system"
	size = 5
	tgui_id = "NtosRbmkStats"
	program_icon = "radiation"
	alert_able = TRUE
	power_consumption = 80 WATT
	var/active = TRUE //Easy process throttle
	var/last_status
	COOLDOWN_DECLARE(next_stat_interval)
	var/list/kpaData = list()
	var/list/powerData = list()
	var/list/tempInputData = list()
	var/list/tempOutputdata = list()
	var/list/reactors
	var/obj/machinery/atmospherics/components/unary/rbmk/core/reactor // Currently selected RBMK Reactor.

/datum/computer_file/program/nuclear_monitor/Destroy()
	clear_signals()
	reactor = null
	return ..()

/datum/computer_file/program/nuclear_monitor/process_tick()
	..()
	if(!reactor || !active)
		return FALSE
	var/new_status = get_status()
	if(last_status != new_status)
		last_status = new_status
		ui_header = "smmon_[last_status].gif"
		program_icon_state = "smmon_[last_status]"
		if(istype(computer))
			computer.update_icon()
	if(COOLDOWN_FINISHED(src, next_stat_interval))
		COOLDOWN_START(src, next_stat_interval, 1 SECONDS) //You only get a slow tick.
		kpaData += (reactor) ? reactor.pressure : 0
		if(length(kpaData) > 100) //Only lets you track over a certain timeframe.
			kpaData.Cut(1, 2)
		powerData += (reactor) ? reactor.power*10 : 0 //We scale up the figure for a consistent:tm: scale
		if(length(powerData) > 100) //Only lets you track over a certain timeframe.
			powerData.Cut(1, 2)
		tempInputData += (reactor) ? reactor.last_coolant_temperature : 0 //We scale up the figure for a consistent:tm: scale
		if(length(tempInputData) > 100) //Only lets you track over a certain timeframe.
			tempInputData.Cut(1, 2)
		tempOutputdata += (reactor) ? reactor.last_output_temperature : 0 //We scale up the figure for a consistent:tm: scale
		if(length(tempOutputdata) > 100) //Only lets you track over a certain timeframe.
			tempOutputdata.Cut(1, 2)

/datum/computer_file/program/nuclear_monitor/on_start(mob/living/user)
	. = ..(user)
	//No reactor? Go find one then.
	if(!reactor)
		var/user_z_level = user.get_virtual_z_level()
		for(var/obj/machinery/atmospherics/components/unary/rbmk/core/reactor_core in GLOB.machines)
			if(compare_z(reactor_core.get_virtual_z_level(), user_z_level))
				reactor = reactor_core
				break
	active = TRUE

/datum/computer_file/program/nuclear_monitor/kill_program(forced = FALSE)
	active = FALSE
	..()

/datum/computer_file/program/nuclear_monitor/ui_data()
	var/list/data = list()
	data["integrity"] = reactor ? reactor.get_integrity_percent() : 100
	data["powerData"] = powerData
	data["kpaData"] = kpaData
	data["tempInputData"] = tempInputData
	data["tempOutputdata"] = tempOutputdata
	data["coolantInput"] = reactor ? reactor.last_coolant_temperature : 0
	data["coolantOutput"] = reactor ? reactor.last_output_temperature : 0
	data["power"] = reactor ? reactor.power : 0
	data["kpa"] = reactor ? reactor.pressure : 0
	return data

/datum/computer_file/program/nuclear_monitor/ui_act(action, params)
	if(..())
		return TRUE

	switch(action)
		if("swap_reactor")
			var/list/choices = list()
			var/user_z_level = usr.get_virtual_z_level()
			for(var/obj/machinery/atmospherics/components/unary/rbmk/core/reactor_core in GLOB.machines)
				if(!compare_z(reactor_core.get_virtual_z_level(), user_z_level))
					continue
				choices += reactor_core
			reactor = input(usr, "What reactor do you wish to monitor?", "Nuclear Monitoring Selector", null) as null|anything in choices
			powerData = list()
			kpaData = list()
			tempInputData = list()
			tempOutputdata = list()
			return TRUE

/datum/computer_file/program/nuclear_monitor/proc/set_signals()
	if(reactor)
		RegisterSignal(reactor, COMSIG_SUPERMATTER_DELAM_ALARM, PROC_REF(send_alert), override = TRUE)
		RegisterSignal(reactor, COMSIG_SUPERMATTER_DELAM_START_ALARM, PROC_REF(send_start_alert), override = TRUE)

/datum/computer_file/program/nuclear_monitor/proc/clear_signals()
	if(reactor)
		UnregisterSignal(reactor, COMSIG_SUPERMATTER_DELAM_ALARM)
		UnregisterSignal(reactor, COMSIG_SUPERMATTER_DELAM_START_ALARM)

/datum/computer_file/program/nuclear_monitor/proc/get_status()
	. = NUCLEAR_REACTOR_INACTIVE
	for(var/obj/machinery/atmospherics/components/unary/rbmk/core/reactor_core in reactors)
		. = max(., reactor_core.get_status())

/datum/computer_file/program/nuclear_monitor/proc/send_alert()
	if(!computer.get_ntnet_status())
		return
	if(computer.active_program != src)
		computer.alert_call(src, "Nuclear reactor meltdown in progress!")
		alert_pending = TRUE

/datum/computer_file/program/nuclear_monitor/proc/send_start_alert()
	if(!computer.get_ntnet_status())
		return
	if(computer.active_program == src)
		computer.alert_call(src, "Nuclear reactor meltdown in progress!")

// Nuclear reactor UI for ghosts only. Inherited attack_ghost will call this.
/obj/machinery/atmospherics/components/unary/rbmk/core/ui_interact(mob/user, datum/tgui/ui)
	if(!isobserver(user))
		return FALSE
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "NtosGhostRbmkStats")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/atmospherics/components/unary/rbmk/core/ui_data()
	var/list/data = list()
	data["integrity"] = get_integrity_percent()
	data["coolantInput"] = last_coolant_temperature
	data["coolantOutput"] = last_output_temperature
	data["power"] = power
	data["kpa"] = pressure
	return data
