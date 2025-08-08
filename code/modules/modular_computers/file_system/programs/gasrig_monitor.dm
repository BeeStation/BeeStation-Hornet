/datum/computer_file/program/gasrig_monitor
	filename = "rigmoni"
	filedesc = "Advanced Gas Rig Monitoring"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "crew"
	extended_desc = "Program for controlling the stations Advanced Gas Rig"
	size = 4
	tgui_id = "AtmosGasRig"
	program_icon = "clipboard-list"
	var/obj/machinery/atmospherics/gasrig/core/gasrig


/datum/computer_file/program/gasrig_monitor/on_ui_create(mob/user, datum/tgui/ui)
	//for error handling
	var/rig_found = FALSE
	for(var/obj/machinery/atmospherics/gasrig/core/C in GLOB.machines)
		gasrig = C
		rig_found = TRUE
	if(!rig_found)
		CRASH("[src] was not able to find a Gas Rig!")

/datum/computer_file/program/gasrig_monitor/ui_data(mob/user)
	if(gasrig == null)
		..()
		return
	gasrig.ui_data(user)

/datum/computer_file/program/gasrig_monitor/ui_act(action, params)
	if(gasrig == null)
		..()
		return
	gasrig.ui_act(action, params)
