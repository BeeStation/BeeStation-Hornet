// RBMK Monitoring was moved here for QoL

//Monitoring program.
/datum/computer_file/program/nuclear_monitor
	filename = "ntnrms"
	filedesc = "NT NRMS"
	category = PROGRAM_CATEGORY_ENGI
	ui_header = "smmon_0.gif"
	program_icon_state = "smmon_0"
	extended_desc = "Nuclear Reactor Monitoring System, connects to specially calibrated sensors to provide information on the status of nuclear reactors."
	requires_ntnet = TRUE
	transfer_access = list(ACCESS_CONSTRUCTION)
	network_destination = "rbmk monitoring system"
	size = 5
	tgui_id = "NtosRbmk"
	program_icon = "radiation"
	alert_able = TRUE
	power_consumption = 80 WATT

	/// Last known status of the reactor, used to set the program icon.
	var/last_status = 0
	/// List of reactors that we are going to send the data of.
	var/list/obj/machinery/atmospherics/components/unary/rbmk/core/reactors = list()
	/// The reactor which will send a notification to us if it's melting.
	var/obj/machinery/atmospherics/components/unary/rbmk/core/focused_reactor

/datum/computer_file/program/nuclear_monitor/on_start(mob/living/user)
	. = ..()
	refresh()

/datum/computer_file/program/nuclear_monitor/kill_program(forced = FALSE)
	for(var/obj/machinery/atmospherics/components/unary/rbmk/core/reactor in reactors)
		clear_reactor(reactor)
	return ..()

/datum/computer_file/program/nuclear_monitor/process_tick()
	. = ..()
	var/new_status = get_status()
	if(last_status != new_status)
		last_status = new_status
		ui_header = "smmon_[last_status].gif"
		program_icon_state = "smmon_[last_status]"
		if(istype(computer))
			computer.update_appearance()

// Refreshes list of active reactors
/datum/computer_file/program/nuclear_monitor/proc/refresh()
	for(var/reactor in reactors)
		clear_reactor(reactor)
	var/turf/user_turf = get_turf(computer.ui_host())
	if(!user_turf)
		return
	for(var/obj/machinery/atmospherics/components/unary/rbmk/core/reactor in GLOB.machines)
		// Exclude Syndicate owned, Delaminating, not within coverage, not on a tile.
		if(!isturf(reactor.loc) || !(is_station_level(reactor.z) || is_mining_level(reactor.z) || reactor.get_virtual_z_level() == user_turf.get_virtual_z_level()))
			continue
		reactors += reactor
		RegisterSignal(reactor, COMSIG_QDELETING, PROC_REF(clear_reactor))

/datum/computer_file/program/nuclear_monitor/ui_data(mob/user)
	var/list/data = list()
	data["rbmk_data"] = list()

	for(var/obj/machinery/atmospherics/components/unary/rbmk/core/reactor in reactors)
		data["rbmk_data"] += list(reactor.rbmk_ui_data())
	data["focus_uid"] = focused_reactor?.uid

	return data

/datum/computer_file/program/nuclear_monitor/ui_act(action, params)
	. = ..()
	switch(action)
		if("PRG_refresh")
			refresh()
			return TRUE
		if("PRG_focus")
			for(var/obj/machinery/atmospherics/components/unary/rbmk/core/reactor in reactors)
				if(reactor.uid == params["focus_uid"])
					if(focused_reactor == reactor)
						unfocus_reactor(reactor)
					else
						focus_reactor(reactor)
					return TRUE

/// Sends a meltdown alert to the computer if our focused reactor is delaminating.
/// [var/obj/machinery/atmospherics/components/unary/rbmk/core/focused_reactor].
/datum/computer_file/program/nuclear_monitor/proc/send_alert()
	SIGNAL_HANDLER

	if(!computer.get_ntnet_status())
		return

	computer.alert_call(src, "Nuclear reactor meltdown in progress!")
	alert_pending = TRUE

/datum/computer_file/program/nuclear_monitor/proc/clear_reactor(obj/machinery/atmospherics/components/unary/rbmk/core/reactor)
	SIGNAL_HANDLER
	reactors -= reactor
	if(focused_reactor == reactor)
		unfocus_reactor()
	UnregisterSignal(reactor, COMSIG_QDELETING)

/datum/computer_file/program/nuclear_monitor/proc/focus_reactor(obj/machinery/atmospherics/components/unary/rbmk/core/reactor)
	if(reactor == focused_reactor)
		return
	if(focused_reactor)
		unfocus_reactor()
	RegisterSignal(reactor, COMSIG_SUPERMATTER_DELAM_ALARM, PROC_REF(send_alert))
	focused_reactor = reactor

/datum/computer_file/program/nuclear_monitor/proc/unfocus_reactor()
	if(!focused_reactor)
		return
	UnregisterSignal(focused_reactor, COMSIG_SUPERMATTER_DELAM_ALARM)
	focused_reactor = null

/datum/computer_file/program/nuclear_monitor/proc/get_status()
	. = REACTOR_NOMINAL
	for(var/obj/machinery/atmospherics/components/unary/rbmk/core/reactor in reactors)
		. = max(., reactor.get_status())
