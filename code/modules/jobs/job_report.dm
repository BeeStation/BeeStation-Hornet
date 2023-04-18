#define JOB_REPORT_MENU_FAIL_REASON_TRACKING_DISABLED 1
#define JOB_REPORT_MENU_FAIL_REASON_NO_RECORDS 2

/datum/job_report_menu
	var/client/owner

/datum/job_report_menu/New(client/owner, mob/viewer)
	src.owner = owner
	ui_interact(viewer)

/datum/job_report_menu/ui_state()
	return GLOB.always_state

/datum/job_report_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "TrackedPlaytime")
		ui.open()

/datum/job_report_menu/ui_static_data()
	if (!CONFIG_GET(flag/use_exp_tracking))
		return list("failReason" = JOB_REPORT_MENU_FAIL_REASON_TRACKING_DISABLED)

	var/list/play_records = owner.prefs.exp
	if (!play_records.len)
		owner.set_exp_from_db()
		play_records = owner.prefs.exp
		if (!play_records.len)
			return list("failReason" = JOB_REPORT_MENU_FAIL_REASON_NO_RECORDS)

	var/list/data = list()
	data["jobPlaytimes"] = list()
	data["antagPlaytimes"] = list()
	data["specialPlaytimes"] = list()
	data["outdatedPlaytimes"] = list()

	for (var/job_name in SSjob.name_occupations)
		var/playtime = play_records[job_name] ? text2num(play_records[job_name]) : 0
		data["jobPlaytimes"][job_name] = playtime

	for (var/antag_name in GLOB.exp_specialmap[EXP_TYPE_ANTAG])
		var/playtime = play_records[antag_name] ? text2num(play_records[antag_name]) : 0
		data["antagPlaytimes"][antag_name] = playtime

	for (var/special_name in GLOB.exp_specialmap[EXP_TYPE_SPECIAL])
		var/playtime = play_records[special_name] ? text2num(play_records[special_name]) : 0
		data["specialPlaytimes"][special_name] = playtime

	for (var/outdated_role_name in GLOB.exp_specialmap[EXP_TYPE_DEPRECATED])
		var/playtime = play_records[outdated_role_name] ? text2num(play_records[outdated_role_name]) : 0
		data["outdatedPlaytimes"][outdated_role_name] = playtime

	data["livingTime"] = play_records[EXP_TYPE_LIVING]
	data["deadTime"] = play_records[EXP_TYPE_DEAD]
	data["observerTime"] = play_records[EXP_TYPE_OBSERVER]
	data["ghostTime"] = play_records[EXP_TYPE_GHOST] // it's deprecated, but still here because it's been used for years. the real ghost time is tracked by above two

	return data

#undef JOB_REPORT_MENU_FAIL_REASON_TRACKING_DISABLED
#undef JOB_REPORT_MENU_FAIL_REASON_NO_RECORDS
