/proc/power_failure()
	priority_announce("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure", ANNOUNCER_POWEROFF)
	for(var/obj/machinery/power/smes/smes as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/smes))
		if(istype(get_area(smes), /area/station/ai_monitored/turret_protected) || !is_station_level(smes.z))
			continue
		smes.charge = 0
		smes.output_level = 0
		smes.output_attempt = FALSE
		smes.update_appearance(UPDATE_ICON)
		smes.power_change()

	for(var/area/station_area as anything in GLOB.areas)
		if(!station_area.z || !is_station_level(station_area.z))
			continue
		if(!station_area.requires_power || station_area.always_unpowered )
			continue
		if(GLOB.typecache_powerfailure_safe_areas[station_area.type])
			continue

		station_area.power_light = FALSE
		station_area.power_equip = FALSE
		station_area.power_environ = FALSE
		station_area.power_change()

	for(var/obj/machinery/power/apc/current_apc as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc))
		if(!current_apc.cell || SSmapping.level_trait(current_apc.z, ZTRAIT_STATION))
			continue
		var/area/apc_area = current_apc.area
		if(is_type_in_typecache(apc_area, GLOB.typecache_powerfailure_safe_areas))
			continue

		current_apc.cell.charge = 0

/proc/power_restore()
	priority_announce("Power has been restored to [station_name()]. We apologize for the inconvenience.", "Power Systems Nominal", ANNOUNCER_POWERON)
	for(var/obj/machinery/power/apc/current_apc as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc))
		if(!current_apc.cell || SSmapping.level_trait(current_apc.z, ZTRAIT_STATION))
			continue
		current_apc.cell.charge = current_apc.cell.maxcharge
		current_apc.failure_timer = 0

	for(var/obj/machinery/power/smes/smes as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/smes))
		if(!is_station_level(smes.z))
			continue
		smes.charge = smes.capacity
		smes.output_level = smes.output_level_max
		smes.output_attempt = TRUE
		smes.update_appearance(UPDATE_ICON)
		smes.power_change()

	for(var/area/station_area as anything in GLOB.areas)
		if(!station_area.z || !is_station_level(station_area.z))
			continue
		if(!station_area.requires_power || station_area.always_unpowered)
			continue
		if(istype(station_area, /area/shuttle))
			continue
		station_area.power_light = TRUE
		station_area.power_equip = TRUE
		station_area.power_environ = TRUE
		station_area.power_change()

/proc/power_restore_quick()

	priority_announce("All SMESs on [station_name()] have been recharged. We apologize for the inconvenience.", "Power Systems Nominal", ANNOUNCER_POWERON)
	for(var/obj/machinery/power/smes/S as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/smes))
		if(!is_station_level(S.z))
			continue
		S.charge = S.capacity
		S.output_level = S.output_level_max
		S.output_attempt = TRUE
		S.update_icon()
		S.power_change()

