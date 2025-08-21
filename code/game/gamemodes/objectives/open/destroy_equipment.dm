/datum/objective/open/damage_equipment
	name = "sabotage operations"
	explanation_text = "Sabotage equipment by damaging or disabling it within %DEPARTMENT%."
	var/selected_area
	var/list/valid_areas = list(
		"medical" = list(/area/medical),
		"engineering" = list(/area/engineering, /area/engine),
		"security" = list(/area/security),
		"the cargo bay" = list(/area/quartermaster, /area/cargo),
		"the bridge" = list(/area/bridge),
		"the communications relay" = list(/area/comms, /area/server, /area/tcommsat),
		"the science lab" = list(/area/science),
		"the research division server room" = list(/area/science/server),
		// Anywhere monitored by the AI will do
		"the AI's facilities" = list(/area/aisat, /area/ai_monitored)
	)
	var/damaged_machines = 0
	var/list/blacklisted_machine_types = list(
		/obj/machinery/atmospherics/pipe
	)

/datum/objective/open/damage_equipment/proc/register_machine_damage(obj/machinery/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_MACHINERY_BROKEN, COMSIG_QDELETING))
	damaged_machines ++

/datum/objective/open/damage_equipment/update_explanation_text()
	var/objective_text = pick(\
		"Sabotage equipment by damaging or disabling it within %DEPARTMENT%.",\
		"Damage equipment inside of %DEPARTMENT% in order to disrupt station operations.",\
		"Disrupt the operations of %DEPARTMENT% by damaging their equipment.")
	explanation_text = replacetext(objective_text, "%DEPARTMENT%", selected_area)

/datum/objective/open/damage_equipment/check_completion()
	return (damaged_machines > 0) || ..()

/datum/objective/open/damage_equipment/get_completion_message()
	if (!damaged_machines)
		return "[explanation_text] [span_redtext("No sabotaged machines!")]"
	return "[explanation_text] [span_infotext("[damaged_machines] sabotaged machines!")]"

/datum/objective/open/damage_equipment/get_target()
	return selected_area

/datum/objective/open/damage_equipment/find_target(list/dupe_search_range, list/blacklist)
	if(!dupe_search_range)
		dupe_search_range = get_owners()
	var/approved_targets = list()
	for(var/target_zone in valid_areas)
		if(!is_unique_objective(target_zone,dupe_search_range))
			continue
		approved_targets += target_zone
	set_target_zone(safepick(approved_targets))
	return selected_area

/datum/objective/open/damage_equipment/proc/set_target_zone(target_zone)
	selected_area = target_zone
	//Update the explanation text
	update_explanation_text()
	// Registered signals will be cleared automatically on destroy
	for (var/obj/machinery/machine in GLOB.machines)
		var/area/machine_area = get_area(machine)
		var/list/target_area_types = valid_areas[selected_area]
		for (var/area_zone in target_area_types)
			if (istype(machine_area, area_zone))
				var/allowed = TRUE
				for (var/blacklist_type in blacklisted_machine_types)
					if (istype(machine, blacklist_type))
						allowed = FALSE
						break
				if (!allowed)
					continue
				RegisterSignal(machine, COMSIG_MACHINERY_BROKEN, PROC_REF(register_machine_damage))
				RegisterSignal(machine, COMSIG_QDELETING, PROC_REF(register_machine_damage))
				break
