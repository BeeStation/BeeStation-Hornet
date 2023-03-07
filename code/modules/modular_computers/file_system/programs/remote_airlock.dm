/datum/computer_file/program/remote_airlock
	filename = "remote_airlock"
	filedesc = "Remote Airlock Control"
	extended_desc = "Allows remote control of select airlocks via an integrated local bluespace relay."
	category = PROGRAM_CATEGORY_MISC
	program_icon = "lock-open"
	tgui_id = "NtosAirlockControl"
	size = 1
	available_on_ntnet = FALSE
	undeletable = TRUE
	unsendable = TRUE

/datum/computer_file/program/remote_airlock/ui_data(mob/user)
	var/list/data = list()
	var/list/airlocks = list()
	var/list/all_controllable = list()
	var/obj/item/computer_hardware/hard_drive/drive = computer.all_components[MC_HDD]
	if(istype(drive) && length(drive.controllable_airlocks))
		all_controllable += drive.controllable_airlocks
	drive = computer.all_components[MC_HDD_JOB]
	if(istype(drive) && length(drive.controllable_airlocks))
		all_controllable += drive.controllable_airlocks
	for(var/obj/machinery/door/poddoor/airlock in GLOB.airlocks)
		if((airlock.id in all_controllable) && airlock.get_virtual_z_level() == computer.get_virtual_z_level() && !QDELETED(airlock))
			var/turf/L = get_turf(airlock)
			airlocks += list(list("id" = airlock.id,
				"name" = airlock.name,
				"open" = !airlock.density,
				"locx" = "[L.x]",
				"locy" = "[L.y]",
			))
	data["airlocks"] = airlocks
	return data

/datum/computer_file/program/remote_airlock/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("airlock_control")
			if(!params["id"])
				return
			var/list/all_controllable = list()
			var/obj/item/computer_hardware/hard_drive/drive = computer.all_components[MC_HDD]
			if(istype(drive) && length(drive.controllable_airlocks))
				all_controllable += drive.controllable_airlocks
			drive = computer.all_components[MC_HDD_JOB]
			if(istype(drive) && length(drive.controllable_airlocks))
				all_controllable += drive.controllable_airlocks
			for(var/obj/machinery/door/poddoor/airlock in GLOB.airlocks)
				if(airlock.id == params["id"])
					if(!(airlock.id in all_controllable))
						log_href_exploit(usr, " Attempted control of airlock: [params["id"]] which they do not have access to (access: [english_list(all_controllable)]).")
						return TRUE
					// Fail, but reload data
					if(airlock.get_virtual_z_level() != computer.get_virtual_z_level())
						return TRUE
					if(airlock.density)
						airlock.open()
					else
						airlock.close()
					return TRUE
