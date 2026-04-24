/datum/computer_file/program/job_management
	filename = "job_manage"
	filedesc = "Job Manager"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "command"
	extended_desc = "Program for viewing and changing job slot avalibility."
	transfer_access = list(ACCESS_HEADS)
	size = 4
	tgui_id = "NtosJobManager"
	program_icon = "address-book"
	power_consumption = 80 WATT

	var/change_position_cooldown = 30

	//The scaling factor of max total positions in relation to the total amount of people on board the station in %
	var/max_relative_positions = 30 //30%: Seems reasonable, limit of 6 @ 20 players

	//This is used to keep track of opened positions for jobs to allow instant closing
	//Assoc array: "JobName" = (int)<Opened Positions>
	var/list/opened_positions = list()

/datum/computer_file/program/job_management/New()
	..()
	change_position_cooldown = CONFIG_GET(number/id_console_jobslot_delay)

/datum/computer_file/program/job_management/proc/can_edit_job(datum/job/job)
	if(!istype(job))
		return FALSE
	if(!(job.job_flags & JOB_CREW_MEMBER))
		return FALSE
	if(job.job_flags & JOB_CANNOT_OPEN_SLOTS)
		return FALSE
	return TRUE

/datum/computer_file/program/job_management/proc/can_open_job(datum/job/job)
	// Always allow reopening positions that were previously closed from this console
	if(opened_positions[job.title] < 0)
		return TRUE
	if((job.get_spawn_position_count() <= length(GLOB.player_list) * (max_relative_positions / 100)))
		var/delta = (world.time / 10) - GLOB.time_last_changed_position
		if(change_position_cooldown < delta)
			return TRUE
	return FALSE

/datum/computer_file/program/job_management/proc/can_close_job(datum/job/job)
	// Always allow reclosing positions that were previously opened from this console
	if(opened_positions[job.title] > 0)
		return TRUE
	if(job.get_spawn_position_count() > length(GLOB.player_list) * (max_relative_positions / 100))
		var/delta = (world.time / 10) - GLOB.time_last_changed_position
		if(change_position_cooldown < delta)
			return TRUE
	return FALSE

/datum/computer_file/program/job_management/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
	var/obj/item/card/id/user_id = card_slot?.stored_card

	if(!user_id || !(ACCESS_CHANGE_IDS in user_id.access))
		return TRUE

	switch(action)
		if("PRG_open_job")
			var/edit_job_target = params["target"]
			var/datum/job/j = SSjob.GetJob(edit_job_target)
			if(!can_edit_job(j) || !can_open_job(j))
				return TRUE
			if(opened_positions[edit_job_target] >= 0)
				GLOB.time_last_changed_position = world.time / 10
			j.total_position_delta++
			opened_positions[edit_job_target]++
			playsound(computer, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			return TRUE
		if("PRG_close_job")
			var/edit_job_target = params["target"]
			var/datum/job/j = SSjob.GetJob(edit_job_target)
			if(!can_edit_job(j) || !can_close_job(j))
				return TRUE
			//Allow instant closing without cooldown if a position has been opened before
			if(opened_positions[edit_job_target] <= 0)
				GLOB.time_last_changed_position = world.time / 10
			j.total_position_delta--
			opened_positions[edit_job_target]--
			playsound(computer, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			return TRUE
		if("PRG_priority")
			var/priority_target = params["target"]
			var/datum/job/j = SSjob.GetJob(priority_target)
			if(!can_edit_job(j))
				return TRUE
			if(j.get_spawn_position_count() <= j.current_positions)
				return TRUE
			if(j in SSjob.prioritized_jobs)
				SSjob.prioritized_jobs -= j
			else
				if(length(SSjob.prioritized_jobs) < 5)
					SSjob.prioritized_jobs += j
				else
					computer.say("Error: CentCom employment protocols restrict prioritising more than 5 jobs.")
			playsound(computer, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			return TRUE


/datum/computer_file/program/job_management/ui_data(mob/user)
	var/list/data = list()

	var/authed = FALSE
	var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
	var/obj/item/card/id/user_id = card_slot?.stored_card
	if(user_id && (ACCESS_CHANGE_IDS in user_id.access))
		authed = TRUE

	data["authed"] = authed

	var/list/pos = list()
	for(var/j in SSjob.occupations)
		var/datum/job/job = j
		if(!can_edit_job(job))
			continue

		pos += list(list(
			"title" = job.title,
			"current" = job.current_positions,
			"total" = job.get_spawn_position_count(),
			"status_open" = authed ? can_open_job(job) : FALSE,
			"status_close" = authed ? can_close_job(job) : FALSE,
		))
	data["slots"] = pos
	var/delta = round(change_position_cooldown - ((world.time / 10) - GLOB.time_last_changed_position), 1)
	data["cooldown"] = delta < 0 ? 0 : delta
	var/list/priority = list()
	for(var/j in SSjob.prioritized_jobs)
		var/datum/job/job = j
		priority += job.title
	data["prioritized"] = priority
	return data

