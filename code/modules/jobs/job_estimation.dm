#define JOB_ESTIMATION_MAX_NAMES 3

/datum/controller/subsystem/job
	/// Estimated job, null if flexible
	var/list/job_estimation_jobs = list()
	/// players listed by name
	var/list/job_estimation_names = list()
	/// aggregate titles players have at medium or high
	var/list/job_estimation_interest = list()
	/// Stat tab rows
	var/list/job_estimation_rows = list()

/datum/controller/subsystem/job/proc/update_job_estimation(mob/dead/new_player/authenticated/player)
	if(!istype(player))
		return
	if(SSticker.HasRoundStarted() || !CONFIG_GET(flag/show_job_estimation))
		remove_job_estimation(player)
		return
	if(!player.client || player.ready != PLAYER_READY_TO_PLAY)
		remove_job_estimation(player)
		return

	var/datum/preferences/prefs = player.client.prefs
	var/datum/job/job = get_estimated_job(prefs)
	if(job?.title == JOB_NAME_ASSISTANT || job?.title == JOB_NAME_PRISONER)
		remove_job_estimation(player)
		return

	var/name = job ? get_job_estimation_listed_name(prefs, job) : null
	var/player_ref = REF(player)
	var/already_named_as_job = job_estimation_names[player_ref] && job_estimation_jobs[player_ref] == job
	if(name && !already_named_as_job)
		warn_excluded_from_antag(player)
	job_estimation_jobs[player_ref] = job
	if(name)
		job_estimation_names[player_ref] = name
	else
		job_estimation_names -= player_ref

	var/list/interested_titles = list()
	for(var/title in prefs.job_preferences)
		if(prefs.job_preferences[title] < JP_MEDIUM || title == job?.title)
			continue
		var/datum/job/other_job = get_job(title)
		if(other_job && can_estimate_job(prefs.parent, other_job))
			interested_titles += title
	job_estimation_interest[player_ref] = interested_titles
	rebuild_job_estimation()

/// Returns high priority job, else the only medium job
/datum/controller/subsystem/job/proc/get_estimated_job(datum/preferences/prefs)
	var/list/medium_jobs = list()
	for(var/title in prefs.job_preferences)
		var/datum/job/job = get_job(title)
		if(!job || !can_estimate_job(prefs.parent, job))
			continue
		if(prefs.job_preferences[title] == JP_HIGH)
			return job
		if(prefs.job_preferences[title] == JP_MEDIUM)
			medium_jobs += job
	if(length(medium_jobs) == 1)
		return medium_jobs[1]

/datum/controller/subsystem/job/proc/can_estimate_job(client/player_client, datum/job/job)
	if(!job.player_old_enough(player_client) || job.required_playtime_remaining(player_client))
		return FALSE
	// you'd think god would have made life easy and we can just access via is_banned_from(), but that can SLEEP
	if(player_client.ban_cache && check_role_ban(player_client.ban_cache, job.title))
		return FALSE
	return TRUE

/datum/controller/subsystem/job/proc/get_job_estimation_listed_name(datum/preferences/prefs, datum/job/job)
	if(!prefs.read_character_preference(/datum/preference/toggle/job_estimation_name))
		return
	if(prefs.job_preferences[job.title] != JP_HIGH && is_antag_restricted_job(job))
		return
	return get_job_estimation_name(prefs, job)

/datum/controller/subsystem/job/proc/is_antag_restricted_job(datum/job/job)
	for(var/datum/dynamic_ruleset/ruleset as anything in SSdynamic.gamemode_configured_rulesets + SSdynamic.supplementary_configured_rulesets)
		if(job.title in ruleset.restricted_roles)
			return TRUE
	return FALSE

/datum/controller/subsystem/job/proc/get_job_listed_by_name(mob/player)
	var/player_ref = REF(player)
	if(job_estimation_names[player_ref])
		return job_estimation_jobs[player_ref]

/datum/controller/subsystem/job/proc/is_job_listed_by_name(datum/job/job)
	for(var/player_ref in job_estimation_names)
		if(job_estimation_jobs[player_ref] == job)
			return TRUE
	return FALSE

/datum/controller/subsystem/job/proc/warn_excluded_from_antag(mob/player)
	var/datum/job/job = get_antag_restricted_job(player.client.prefs)
	if(job)
		to_chat(player, span_notice("Job Estimation shows your name as [job.title], so antagonists that can't be [job.title] won't pick you at roundstart, even if someone else gets the job."))

/datum/controller/subsystem/job/proc/get_antag_restricted_job(datum/preferences/prefs)
	if(!CONFIG_GET(flag/show_job_estimation))
		return
	var/datum/job/job = get_estimated_job(prefs)
	if(!job || prefs.job_preferences[job.title] != JP_HIGH)
		return
	if(job.title == JOB_NAME_ASSISTANT || job.title == JOB_NAME_PRISONER)
		return
	if(get_job_estimation_name(prefs, job) && is_antag_restricted_job(job))
		return job

/datum/controller/subsystem/job/proc/get_job_estimation_name(datum/preferences/prefs, datum/job/job)
	// Jobs like clown and AI are snowflake
	var/datum/preference/name/name_pref = prefs.get_job_name_preference(job)
	if(name_pref)
		var/job_name = prefs.read_character_preference(name_pref.type)
		if(istype(name_pref, /datum/preference/name/cyborg) && job_name == DEFAULT_CYBORG_NAME)
			return
		return job_name
	if(CONFIG_GET(flag/force_random_names) || prefs.read_character_preference(/datum/preference/choiced/random_name) != RANDOM_DISABLED)
		return
	return prefs.read_character_preference(/datum/preference/name/real_name)

/// Groups readied players by job
/datum/controller/subsystem/job/proc/rebuild_job_estimation()
	job_estimation_rows = list()
	if(!length(job_estimation_jobs))
		return

	var/list/names_by_job = list()
	var/list/anonymous_by_job = list()
	var/flexible = 0
	var/listed_departments = NONE
	var/list/flexible_department_sets = list()
	for(var/player_ref in job_estimation_jobs)
		var/datum/job/job = job_estimation_jobs[player_ref]
		if(!job)
			flexible++
			var/flexible_departments = NONE
			for(var/title in job_estimation_interest[player_ref])
				var/datum/job/interested_job = get_job(title)
				flexible_departments |= interested_job.departments_bitflags
			flexible_department_sets += flexible_departments
			continue
		listed_departments |= job.departments_bitflags
		if(!names_by_job[job.title])
			names_by_job[job.title] = list()
		var/name = job_estimation_names[player_ref]
		if(name)
			names_by_job[job.title] += name
		else
			anonymous_by_job[job.title] += 1

	var/list/interested_by_job = list()
	for(var/player_ref in job_estimation_interest)
		for(var/title in job_estimation_interest[player_ref])
			interested_by_job[title] += 1

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
		var/others = anonymous_by_job[title] + max(length(names) - JOB_ESTIMATION_MAX_NAMES, 0)
		names = names.Copy(1, min(length(names), JOB_ESTIMATION_MAX_NAMES) + 1)
		if(others)
			names += length(names) ? "+[others] more" : "[others] anonymous"
		var/row_text = jointext(names, ", ")
		if(interested_by_job[title])
			row_text += " ([interested_by_job[title]] also interested)"
		job_estimation_rows[title] = GENERATE_STAT_TEXT(row_text)
	if(flexible)
		job_estimation_rows["Flexible"] = GENERATE_STAT_TEXT("[flexible]")

	var/static/list/station_departments = list(
		DEPARTMENT_NAME_COMMAND = DEPARTMENT_BITFLAG_COMMAND,
		DEPARTMENT_NAME_SECURITY = DEPARTMENT_BITFLAG_SECURITY,
		DEPARTMENT_NAME_ENGINEERING = DEPARTMENT_BITFLAG_ENGINEERING,
		DEPARTMENT_NAME_MEDICAL = DEPARTMENT_BITFLAG_MEDICAL,
		DEPARTMENT_NAME_SCIENCE = DEPARTMENT_BITFLAG_SCIENCE,
		DEPARTMENT_NAME_SERVICE = DEPARTMENT_BITFLAG_SERVICE,
		DEPARTMENT_NAME_CARGO = DEPARTMENT_BITFLAG_CARGO,
		DEPARTMENT_NAME_SILICON = DEPARTMENT_BITFLAG_SILICON,
	)
	var/list/coverable_departments = list()
	var/list/empty_departments = list()
	for(var/department_name in station_departments)
		var/department_flag = station_departments[department_name]
		if(listed_departments & department_flag)
			continue
		var/flexible_count = 0
		for(var/flexible_departments in flexible_department_sets)
			if(flexible_departments & department_flag)
				flexible_count++
		if(flexible_count)
			coverable_departments += "[department_name] ([flexible_count])"
		else
			empty_departments += department_name
	if(length(coverable_departments))
		job_estimation_rows["Flexible could cover"] = GENERATE_STAT_TEXT(jointext(coverable_departments, ", "))
	if(length(empty_departments))
		job_estimation_rows["Nobody listed"] = GENERATE_STAT_TEXT(jointext(empty_departments, ", "))

/datum/controller/subsystem/job/proc/remove_job_estimation(mob/dead/new_player/authenticated/player)
	var/player_ref = REF(player)
	if(!(player_ref in job_estimation_jobs))
		return
	job_estimation_jobs -= player_ref
	job_estimation_names -= player_ref
	job_estimation_interest -= player_ref
	rebuild_job_estimation()

#undef JOB_ESTIMATION_MAX_NAMES
