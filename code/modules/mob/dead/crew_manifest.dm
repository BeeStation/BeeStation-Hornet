/datum/crew_manifest/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CREW_MANIFEST_UPDATE, PROC_REF(on_manifest_update))

/datum/crew_manifest/proc/on_manifest_update()
	SIGNAL_HANDLER
	ui_update()

/datum/crew_manifest/ui_state(mob/user)
	return GLOB.always_state

/datum/crew_manifest/ui_status(mob/user, datum/ui_state/state)
	var/static/list/allowed_mobs_typecache = typecacheof(list(
		/mob/dead,
		/mob/living/silicon,
	))
	return is_type_in_typecache(user, allowed_mobs_typecache) ? UI_INTERACTIVE : UI_CLOSE

/datum/crew_manifest/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CrewManifest")
		ui.open()

/datum/crew_manifest/ui_static_data(mob/user)
	var/static/list/ordering = list_to_assoc_index(flatten_list(GLOB.id_to_hud))
	return list(
		"command" = list(
			"name" = "Command",
			"huds" = GLOB.command_huds,
			"jobs" = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND),
			"order" = SSjob.chain_of_command
		),
		"order" = ordering,
	)

/datum/crew_manifest/ui_data(mob/user)
	var/user_theme = null
	if(isdead(user))
		user_theme = "generic"
	return list("manifest" = GLOB.manifest.get_manifest(), "user_theme" = user_theme)

/datum/crew_manifest/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet_batched/job_icons))
