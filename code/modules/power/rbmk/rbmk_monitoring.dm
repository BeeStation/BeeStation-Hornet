// RBMK Monitoring was moved here for QoL

/obj/machinery/computer/reactor
	name = "reactor control console"
	desc = "Scream"
	light_color = "#55BA55"
	light_power = 1
	light_range = 3
	icon_state = "oldcomp"
	icon_screen = "stock_computer"
	icon_keyboard = null
	var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/reactor

/obj/machinery/computer/reactor/Initialize()
	. = ..()

/obj/machinery/computer/reactor/stats
	name = "reactor statistics console"
	desc = "A console for monitoring the statistics of a nuclear reactor."
	var/next_stat_interval = 0
	var/list/psiData = list()
	var/list/powerData = list()
	var/list/tempInputData = list()
	var/list/tempOutputdata = list()

/obj/machinery/computer/reactor/stats/attack_hand(mob/living/user)
	. = ..()
	ui_interact(user)

/obj/machinery/computer/reactor/stats/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RbmkStats")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/reactor/stats/process()
	if(world.time >= next_stat_interval)
		next_stat_interval = world.time + 1 SECONDS //You only get a slow tick.
		psiData += (reactor) ? reactor.pressure : 0
		if(psiData.len > 100) //Only lets you track over a certain timeframe.
			psiData.Cut(1, 2)
		powerData += (reactor) ? reactor.power*10 : 0 //We scale up the figure for a consistent:tm: scale
		if(powerData.len > 100) //Only lets you track over a certain timeframe.
			powerData.Cut(1, 2)
		tempInputData += (reactor) ? reactor.last_coolant_temperature : 0 //We scale up the figure for a consistent:tm: scale
		if(tempInputData.len > 100) //Only lets you track over a certain timeframe.
			tempInputData.Cut(1, 2)
		tempOutputdata += (reactor) ? reactor.last_output_temperature : 0 //We scale up the figure for a consistent:tm: scale
		if(tempOutputdata.len > 100) //Only lets you track over a certain timeframe.
			tempOutputdata.Cut(1, 2)

/obj/machinery/computer/reactor/stats/ui_data(mob/user)
	var/list/data = list()
	data["powerData"] = powerData
	data["psiData"] = psiData
	data["tempInputData"] = tempInputData
	data["tempOutputdata"] = tempOutputdata
	data["coolantInput"] = reactor ? reactor.last_coolant_temperature : 0
	data["coolantOutput"] = reactor ? reactor.last_output_temperature : 0
	data["power"] = reactor ? reactor.power : 0
	data ["psi"] = reactor ? reactor.pressure : 0
	return data

/obj/machinery/computer/reactor/control_rods
	name = "control rod management computer"
	desc = "A computer which can remotely raise / lower the control rods of a reactor."

/obj/machinery/computer/reactor/control_rods/attack_hand(mob/living/user)
	. = ..()
	ui_interact(user)

/obj/machinery/computer/reactor/control_rods/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RbmkControlRods")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/reactor/control_rods/ui_act(action, params)
	if(..())
		return
	if(!reactor)
		return
	if(action == "input")
		var/input = text2num(params["target"])
		reactor.desired_k = clamp(input, 0, 3)

/obj/machinery/computer/reactor/control_rods/ui_data(mob/user)
	var/list/data = list()
	data["control_rods"] = 0
	data["k"] = 0
	data["desiredK"] = 0
	if(reactor)
		data["k"] = reactor.K
		data["desiredK"] = reactor.desired_k
		data["control_rods"] = 100 - (reactor.desired_k / 3 * 100) //Rod insertion is extrapolated as a function of the percentage of K
	return data

/obj/machinery/computer/reactor/fuel_rods
	name = "Reactor Fuel Management Console"
	desc = "A console which can remotely raise fuel rods out of nuclear reactors."

/obj/machinery/computer/reactor/fuel_rods/attack_hand(mob/living/user)
	. = ..()
	if(!reactor)
		return FALSE
	if(reactor.power > 20)
		to_chat(user, "<span class='warning'>You cannot remove fuel from [reactor] when it is above 20% power.</span>")
		return FALSE
	if(!reactor.fuel_rods.len)
		to_chat(user, "<span class='warning'>[reactor] does not have any fuel rods loaded.</span>")
		return FALSE
	var/atom/movable/fuel_rod = input(usr, "Select a fuel rod to remove", "[src]", null) as null|anything in reactor.fuel_rods
	if(!fuel_rod)
		return
	playsound(src, pick('sound/effects/rbmk/switch.ogg','sound/effects/rbmk/switch2.ogg','sound/effects/rbmk/switch3.ogg'), 100, FALSE)
	fuel_rod.forceMove(get_turf(reactor))
	reactor.fuel_rods -= fuel_rod

/obj/machinery/computer/reactor/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/reactor/attack_ai(mob/user)
	. = ..()
	attack_hand(user)


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
	var/active = TRUE //Easy process throttle
	var/last_status
	var/next_stat_interval = 0
	var/list/psiData = list()
	var/list/powerData = list()
	var/list/tempInputData = list()
	var/list/tempOutputdata = list()
	var/list/reactors
	var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/reactor // Currently selected RBMK Reactor.

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
	if(world.time >= next_stat_interval)
		next_stat_interval = world.time + 1 SECONDS //You only get a slow tick.
		psiData += (reactor) ? reactor.pressure : 0
		if(psiData.len > 100) //Only lets you track over a certain timeframe.
			psiData.Cut(1, 2)
		powerData += (reactor) ? reactor.power*10 : 0 //We scale up the figure for a consistent:tm: scale
		if(powerData.len > 100) //Only lets you track over a certain timeframe.
			powerData.Cut(1, 2)
		tempInputData += (reactor) ? reactor.last_coolant_temperature : 0 //We scale up the figure for a consistent:tm: scale
		if(tempInputData.len > 100) //Only lets you track over a certain timeframe.
			tempInputData.Cut(1, 2)
		tempOutputdata += (reactor) ? reactor.last_output_temperature : 0 //We scale up the figure for a consistent:tm: scale
		if(tempOutputdata.len > 100) //Only lets you track over a certain timeframe.
			tempOutputdata.Cut(1, 2)

/datum/computer_file/program/nuclear_monitor/on_start(mob/living/user)
	. = ..(user)
	//No reactor? Go find one then.
	if(!reactor)
		for(var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/R in GLOB.machines)
			if(user.get_virtual_z_level() == R.get_virtual_z_level())
				reactor = R
				break
	active = TRUE

/datum/computer_file/program/nuclear_monitor/kill_program(forced = FALSE)
	active = FALSE
	..()

/datum/computer_file/program/nuclear_monitor/ui_data()
	var/list/data = list()
	data["powerData"] = powerData
	data["psiData"] = psiData
	data["tempInputData"] = tempInputData
	data["tempOutputdata"] = tempOutputdata
	data["coolantInput"] = reactor ? reactor.last_coolant_temperature : 0
	data["coolantOutput"] = reactor ? reactor.last_output_temperature : 0
	data["power"] = reactor ? reactor.power : 0
	data ["psi"] = reactor ? reactor.pressure : 0
	return data

/datum/computer_file/program/nuclear_monitor/ui_act(action, params)
	if(..())
		return TRUE

	switch(action)
		if("swap_reactor")
			var/list/choices = list()
			for(var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/R in GLOB.machines)
				if(usr.get_virtual_z_level() != R.get_virtual_z_level())
					continue
				choices += R
			reactor = input(usr, "What reactor do you wish to monitor?", "[src]", null) as null|anything in choices
			powerData = list()
			psiData = list()
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
	for(var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/S in reactors)
		. = max(., S.get_status())

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
