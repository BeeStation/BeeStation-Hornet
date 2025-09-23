/datum/computer_file/program/gasrig_monitor
	filename = "rigmoni"
	filedesc = "Advanced Gas Rig Monitoring"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "crew"
	extended_desc = "Program for controlling the stations Advanced Gas Rig"
	category = PROGRAM_CATEGORY_ENGI
	transfer_access = list(ACCESS_CONSTRUCTION)
	size = 4
	tgui_id = "NtosAtmosGasRig"
	program_icon = "clipboard-list"
	requires_ntnet = TRUE
	power_consumption = 60 WATT
	var/obj/machinery/atmospherics/gasrig/core/gasrig


/datum/computer_file/program/gasrig_monitor/on_start(mob/user)
	..()
	for(var/obj/machinery/atmospherics/gasrig/core/rig_core in GLOB.machines)
		gasrig = rig_core
		return TRUE
	return FALSE

/datum/computer_file/program/gasrig_monitor/ui_data(mob/user)
	if(gasrig == null)
		return ..()
	return gasrig.ui_data(user)

/datum/computer_file/program/gasrig_monitor/ui_static_data(mob/user)
	if(gasrig == null)
		return ..()
	return gasrig.ui_static_data(user)

/datum/computer_file/program/gasrig_monitor/ui_act(action, params)
	if(isnull(gasrig))
		return ..()
	return gasrig.ui_act_base(action, params)
