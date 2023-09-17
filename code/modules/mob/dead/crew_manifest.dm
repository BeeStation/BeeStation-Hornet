GLOBAL_DATUM_INIT(crew_manifest_tgui, /datum/crew_manifest, new)

/datum/crew_manifest

/datum/crew_manifest/ui_state(mob/user)
	return GLOB.always_state

/datum/crew_manifest/ui_status(mob/user, datum/ui_state/state)
	var/static/list/allowed_mobs_typecache = typecacheof(list(/mob/dead, /mob/living/silicon))
	return is_type_in_typecache(user, allowed_mobs_typecache) ? UI_INTERACTIVE : UI_CLOSE

/datum/crew_manifest/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CrewManifest")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/crew_manifest/ui_static_data(mob/user)
	var/static/list/ordering = list_to_assoc_index(flatten_list(GLOB.id_to_hud))
	return list(
		"command" = list(
			"huds" = GLOB.command_huds,
			"jobs" = GLOB.command_positions,
			"order" = SSjob.chain_of_command
		),
		"order" = ordering,
	)

/datum/crew_manifest/ui_data(mob/user)
	return list("manifest" = GLOB.data_core.get_manifest(), "generic" = isdead(user))

/datum/crew_manifest/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet/job_icons))
