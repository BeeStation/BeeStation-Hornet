GLOBAL_DATUM_INIT(crew_manifest_tgui, /datum/crew_manifest, new)

/datum/crew_manifest

/datum/crew_manifest/ui_state(mob/user)
	return GLOB.always_state

/datum/crew_manifest/ui_status(mob/user, datum/ui_state/state)
	var/static/list/allowed_mobs_typecache = typecacheof(list(/mob/dead, /mob/living/silicon))
	return (is_type_in_typecache(user, allowed_mobs_typecache) || user.client?.holder) ? UI_INTERACTIVE : UI_CLOSE

/datum/crew_manifest/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CrewManifest")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/crew_manifest/ui_static_data(mob/user)
	var/static/list/job_ordering = list_to_assoc_index(GLOB.command_positions + GLOB.engineering_positions + GLOB.supply_positions + (GLOB.nonhuman_positions - "pAI") + GLOB.civilian_positions + GLOB.gimmick_positions + GLOB.medical_positions + GLOB.science_positions + GLOB.security_positions)
	return list(
		"command" = list(
			"jobs" = GLOB.command_positions,
			"order" = SSjob.chain_of_command
		),
		"icons" = GLOB.id_to_hud,
		"order" = job_ordering
	)

/datum/crew_manifest/ui_data(mob/user)
	var/list/positions = list()
	for(var/datum/job/job in SSjob.occupations)
		// Check if there are additional open positions or if there is no limit
		for(var/department in get_job_departments(job.departments))
			var/list/department_info = positions[department]
			if(!department_info)
				positions[department] = department_info = list("exceptions" = list(), "open" = 0)
			if(job.total_positions == -1)
				// Add job to list of exceptions, meaning it does not have a position limit
				department_info["exceptions"] |= job.title
			else
				// Add open positions to current department
				department_info["open"] += max(0, job.total_positions - job.current_positions)
	return list(
		"manifest" = GLOB.data_core.get_manifest(),
		"positions" = positions
	)

/datum/crew_manifest/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet/job_icons))
