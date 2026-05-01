// Tgui late joins??? In this economy??

/mob/dead/new_player/authenticated/proc/LateChoices()
	ui_interact(src)

/mob/dead/new_player/authenticated/ui_state(mob/user)
	return GLOB.always_state

/mob/dead/new_player/authenticated/ui_status(mob/user, datum/ui_state/state)
	return (user == src && client) ? UI_INTERACTIVE : UI_CLOSE

/mob/dead/new_player/authenticated/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LateChoices")
		ui.open()
		// Slot counts, shuttle status, and queue position can change while the
		// window is open; the dynamic payload is small so just push it live.
		ui.set_autoupdate(TRUE)


// I kinda love the word payload now. It's got like- a nice... heft to it.
/mob/dead/new_player/authenticated/ui_static_data(mob/user)
	var/list/payload = SSemployer.build_tgui_payload()
	var/list/data = list(
		"employers" = payload["employers"],
		"employer_order" = payload["employer_order"],
	)

	// Department metadata (id, name, colour, ordering) doesn't change during a
	// round, so it lives in static data rather than being rebuilt every tick.
	var/list/departments = list()
	var/list/dept_order = list()
	for(var/datum/department_group/each_dept as anything in SSdepartment.sorted_department_for_latejoin)
		dept_order += each_dept.dept_id
		departments[each_dept.dept_id] = list(
			"id" = each_dept.dept_id,
			"name" = each_dept.pref_category_name,
			"colour" = each_dept.dept_colour || "#ff46c7",
		)
	data["departments"] = departments
	data["department_order"] = dept_order
	return data

/mob/dead/new_player/authenticated/ui_data(mob/user)
	var/list/data = list()

	data["round_duration"] = DisplayTimeText(world.time - SSticker.round_start_time)
	data["selected_employer"] = client?.prefs?.read_character_preference(/datum/preference/choiced/selected_employer)
	data["prioritized_jobs_active"] = SSjob.prioritized_jobs.len > 0

	// Mirrors the warning the legacy window printed at the top of the page.
	var/shuttle_status = null
	if(SSshuttle.emergency)
		switch(SSshuttle.emergency.mode)
			if(SHUTTLE_ESCAPE)
				shuttle_status = "evacuated"
			if(SHUTTLE_CALL)
				if(!SSshuttle.canRecall())
					shuttle_status = "evacuating"
	data["shuttle_status"] = shuttle_status

	var/list/jobs = list()
	for(var/datum/department_group/each_dept as anything in SSdepartment.sorted_department_for_latejoin)
		for(var/job_title in each_dept.jobs)
			var/datum/job/job_datum = SSjob.name_occupations[job_title]
			if(!job_datum)
				continue
			var/availability = IsJobUnavailable(job_datum.title, TRUE)
			var/is_command = (job_datum.job_flags & JOB_HEAD_OF_STAFF) || (job_title in each_dept.leaders)
			jobs[job_datum.title] = list(
				"title" = job_datum.title,
				"department" = each_dept.dept_id,
				"employer" = job_datum.get_employer_id(),
				"positions" = job_datum.current_positions,
				"available" = (availability == JOB_AVAILABLE),
				"unavailable_reason" = (availability == JOB_AVAILABLE) ? null : get_job_unavailable_error_message(availability, job_datum.title),
				"prioritized" = (job_datum in SSjob.prioritized_jobs),
				"command" = is_command,
			)
	data["jobs"] = jobs

	return data

/mob/dead/new_player/authenticated/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("select_employer")
			var/new_id = params["employer"]
			if(SSemployer.get_employer(new_id) && client?.prefs)
				client.prefs.update_preference(/datum/preference/choiced/selected_employer, new_id)
			return TRUE

		if("select_job")
			if(!SSticker || !SSticker.IsRoundInProgress())
				to_chat(src, span_danger("The round is either not ready, or has already finished..."))
				return TRUE

			if(!GLOB.enter_allowed)
				to_chat(src, span_notice("There is an administrative lock on entering the game!"))
				return TRUE

			// God why. Topic is a fuck. We duplicate from new_player here.
			var/hpc = CONFIG_GET(number/hard_popcap)
			var/epc = CONFIG_GET(number/extreme_popcap)
			var/relevant_cap = (hpc && epc) ? min(hpc, epc) : max(hpc, epc)
			if(SSticker.queued_players.len && !is_admin(ckey(key)) && !IS_PATRON(ckey(key)))
				if((living_player_count() >= relevant_cap) || (src != SSticker.queued_players[1]))
					to_chat(src, span_warning("Server is full."))
					return TRUE

			AttemptLateSpawn(params["job"])
			return TRUE

		if("view_manifest")
			ViewManifest()
			return TRUE
