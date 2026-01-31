/datum/computer_file/program/cdr_monitor
	filename = "ntcdrms"
	filedesc = "NT CDRMS"
	category = PROGRAM_CATEGORY_ENGI
	ui_header = "smmon_0.gif"
	program_icon_state = "smmon_0"
	extended_desc = "The Condensate Decay Reactor monitoring system. As one might expect, it monitors CDRs."
	requires_ntnet = TRUE
	transfer_access = list(ACCESS_CONSTRUCTION)
	network_destination = "metallic decay reactor monitoring system"
	size = 4
	tgui_id = "NtosCdr"
	program_icon = "radiation"
	power_consumption = 60 WATT

	var/list/obj/machinery/atmospherics/components/unary/cdr/cdrs = list()

	var/obj/machinery/atmospherics/components/unary/cdr/selected_cdr = null

/datum/computer_file/program/cdr_monitor/on_start(mob/living/user)
	. = ..()
	refresh()

/datum/computer_file/program/cdr_monitor/ui_data(mob/user)
	var/list/data = list()
	data["selected_cdr_uid"] = selected_cdr?.cdr_uid
	data["cdr_data"] = list()
	for(var/obj/machinery/atmospherics/components/unary/cdr/cdr in cdrs)
		data["cdr_data"] += list((cdr.ui_static_data(user) + cdr.ui_data(user))) //very stupid, but I frankly dont know another solution
	return data

/datum/computer_file/program/cdr_monitor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch (action)
		if("refresh")
			refresh()
			return TRUE
		if("select_cdr")
			for (var/obj/machinery/atmospherics/components/unary/cdr/cdr in cdrs)
				if(!params["select_cdr"])
					selected_cdr = null
					return TRUE
				if(cdr.cdr_uid == text2num(params["select_cdr"]))
					selected_cdr = cdr
					return TRUE
	if(selected_cdr)
		selected_cdr.ui_act(action, params, ui, state)

/datum/computer_file/program/cdr_monitor/proc/refresh()
	for(var/obj/machinery/atmospherics/components/unary/cdr/cdr in cdrs)
		clear_cdr(cdr)
	var/turf/user_turf = get_turf(computer.ui_host())
	if(!user_turf)
		return
	for (var/obj/machinery/atmospherics/components/unary/cdr/cdr in GLOB.machines)
		if (!(is_station_level(cdr.z) || is_mining_level(cdr.z) || cdr.z == user_turf.z))
			continue
		cdrs += cdr
		RegisterSignal(cdr, COMSIG_QDELETING, PROC_REF(clear_cdr))

/datum/computer_file/program/cdr_monitor/proc/clear_cdr(obj/machinery/atmospherics/components/unary/cdr/cdr)
	SIGNAL_HANDLER
	if(selected_cdr == cdr)
		selected_cdr = null
	cdrs -= cdr
	UnregisterSignal(cdr, COMSIG_QDELETING)
