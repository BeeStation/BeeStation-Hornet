/datum/controller/subsystem/job
	/// Readied players in ready order
	var/list/job_estimation_entries = list()
	/// Stat tab rows from job_estimation_entries
	var/list/job_estimation_rows = list()

/datum/controller/subsystem/job/proc/update_job_estimation(mob/dead/new_player/authenticated/player)
	if(!istype(player))
		return
	var/datum/job/job = get_job_estimation_job(player)
	if(!job)
		remove_job_estimation(player)
		return

	job_estimation_entries[REF(player)] = list(job, get_job_estimation_name(player.client.prefs, job))
	rebuild_job_estimation()

/// job to be listed under, null if should not be listed
/datum/controller/subsystem/job/proc/get_job_estimation_job(mob/dead/new_player/authenticated/player)
	if(SSticker.HasRoundStarted() || !CONFIG_GET(flag/show_job_estimation))
		return
	if(!player.client || player.ready != PLAYER_READY_TO_PLAY)
		return
	var/datum/job/job = player.client.prefs.get_highest_priority_job()
	if(!job || job.title == JOB_NAME_ASSISTANT || job.title == JOB_NAME_PRISONER)
		return
	return job

/datum/controller/subsystem/job/proc/get_job_estimation_name(datum/preferences/prefs, datum/job/job)
	var/always_named = (job.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND) || job.title == JOB_NAME_AI
	if(!always_named && !prefs.read_player_preference(/datum/preference/toggle/job_estimation_name))
		return
	// Jobs like clown and AI are snowflake
	for(var/preference_type in GLOB.preference_entries)
		var/datum/preference/name/name_pref = GLOB.preference_entries[preference_type]
		if(!istype(name_pref) || !name_pref.relevant_job || !istype(job, name_pref.relevant_job))
			continue
		var/job_name = prefs.read_character_preference(preference_type)
		if(istype(name_pref, /datum/preference/name/cyborg) && job_name == DEFAULT_CYBORG_NAME)
			return
		return job_name
	if(CONFIG_GET(flag/force_random_names) || prefs.read_character_preference(/datum/preference/choiced/random_name) != RANDOM_DISABLED)
		return
	return prefs.read_character_preference(/datum/preference/name/real_name)

/// Groups readied players by job
/datum/controller/subsystem/job/proc/rebuild_job_estimation()
	job_estimation_rows = list()
	if(!length(job_estimation_entries))
		return

	var/list/names_by_job = list()
	var/list/anonymous_by_job = list()
	for(var/player_ref in job_estimation_entries)
		var/list/entry = job_estimation_entries[player_ref]
		var/datum/job/job = entry[1]
		var/name = entry[2]
		if(!names_by_job[job.title])
			names_by_job[job.title] = list()
		if(name)
			names_by_job[job.title] += name
		else
			anonymous_by_job[job.title] += 1

	// Command and silicons first
	var/list/command_titles = list()
	var/list/crew_titles = list()
	for(var/datum/job/job as anything in joinable_occupations)
		if(!names_by_job[job.title])
			continue
		if(job.departments_bitflags & (DEPARTMENT_BITFLAG_COMMAND | DEPARTMENT_BITFLAG_SILICON))
			command_titles += job.title
		else
			crew_titles += job.title

	job_estimation_rows["divider_job_estimation"] = GENERATE_STAT_DIVIDER
	job_estimation_rows["Job Estimation"] = GENERATE_STAT_TEXT("")
	for(var/title in command_titles + crew_titles)
		var/list/names = names_by_job[title]
		if(anonymous_by_job[title])
			names += "[anonymous_by_job[title]] anonymous"
		job_estimation_rows[title] = GENERATE_STAT_TEXT(jointext(names, ", "))

/datum/controller/subsystem/job/proc/remove_job_estimation(mob/dead/new_player/authenticated/player)
	var/player_ref = REF(player)
	if(!job_estimation_entries[player_ref])
		return
	job_estimation_entries -= player_ref
	rebuild_job_estimation()
