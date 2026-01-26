/datum/computer_file/program/mdr_monitor
	filename = "ntmdrms"
	filedesc = "NT MDRms"
	category = PROGRAM_CATEGORY_ENGI
	ui_header = "smmon_0.gif"
	program_icon_state = "smmon_0"
	extended_desc = "The Metallic Decay Reactor monitoring system. As one might expect, it monitors MDRs."
	requires_ntnet = TRUE
	transfer_access = list(ACCESS_CONSTRUCTION)
	network_destination = "metallic decay reactor monitoring system"
	size = 4
	tgui_id = "NtosMdr"
	program_icon = "radiation"
	power_consumption = 60 WATT

	var/list/obj/machinery/atmospherics/components/unary/mdr/mdrs = list()

	var/obj/machinery/atmospherics/components/unary/mdr/selected_mdr = null

/datum/computer_file/program/mdr_monitor/on_start(mob/living/user)
	. = ..()
	refresh()

/datum/computer_file/program/mdr_monitor/ui_data(mob/user)
	. = ..()
	.["selected_mdr_uid"] = selected_mdr?.mdr_uid
	.["mdr_data"] = list()
	for(var/mdr as anything in mdrs)
		.["mdr_data"][mdr] = (mdrs[mdr].ui_static_data(user) + mdrs[mdr].ui_data(user)) //very stupid, but I frankly dont know another solution

/datum/computer_file/program/mdr_monitor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch (action)
		if("refresh")
			refresh()
			return TRUE
		if("select_mdr")
			selected_mdr = mdrs["[params["select_mdr"]]"]
			return TRUE
	if(selected_mdr)
		selected_mdr.ui_act(action, params, ui, state)

/datum/computer_file/program/mdr_monitor/proc/refresh()
	for(var/mdr in mdrs)
		clear_mdr(mdrs[mdr])
	var/turf/user_turf = get_turf(computer.ui_host())
	if(!user_turf)
		return
	for (var/obj/machinery/atmospherics/components/unary/mdr/mdr in GLOB.machines)
		if (!(is_station_level(mdr.z) || is_mining_level(mdr.z) || mdr.z == user_turf.z))
			continue
		mdrs["[mdr.mdr_uid]"] = mdr
		RegisterSignal(mdr, COMSIG_QDELETING, PROC_REF(clear_mdr))

/datum/computer_file/program/mdr_monitor/proc/clear_mdr(obj/machinery/atmospherics/components/unary/mdr/mdr)
	SIGNAL_HANDLER
	if(selected_mdr == mdr)
		selected_mdr = null
	for(var/iter_mdr in mdrs)
		if(mdr == mdrs[iter_mdr])
			mdrs -= iter_mdr
	UnregisterSignal(mdr, COMSIG_QDELETING)
