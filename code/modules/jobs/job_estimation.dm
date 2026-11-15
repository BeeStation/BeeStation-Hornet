#define JOB_ESTIMATION_MAX_NAMES 3

/datum/controller/subsystem/job
	/// High priority job
	var/list/job_estimation_jobs = list()
	/// players listed by name
	var/list/job_estimation_names = list()
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
	var/datum/job/job = prefs.get_highest_priority_job()
	if(job && prefs.job_preferences[job.title] != JP_HIGH)
		job = null
	if(job?.title == JOB_NAME_ASSISTANT || job?.title == JOB_NAME_PRISONER)
		remove_job_estimation(player)
		return

	var/name = job ? get_job_estimation_name(prefs, job) : null
	var/player_ref = REF(player)
	var/already_named_as_job = job_estimation_names[player_ref] && job_estimation_jobs[player_ref] == job
	if(name && !already_named_as_job)
		warn_excluded_from_antag(player, job)
	job_estimation_jobs[player_ref] = job
	if(name)
		job_estimation_names[player_ref] = name
	else
		job_estimation_names -= player_ref
	rebuild_job_estimation()

/datum/controller/subsystem/job/proc/get_job_listed_by_name(mob/player)
	var/player_ref = REF(player)
	if(job_estimation_names[player_ref])
		return job_estimation_jobs[player_ref]

/datum/controller/subsystem/job/proc/is_job_listed_by_name(datum/job/job)
	for(var/player_ref in job_estimation_names)
		if(job_estimation_jobs[player_ref] == job)
			return TRUE
	return FALSE

/datum/controller/subsystem/job/proc/warn_excluded_from_antag(mob/player, datum/job/job)
	for(var/datum/dynamic_ruleset/ruleset as anything in SSdynamic.gamemode_configured_rulesets + SSdynamic.supplementary_configured_rulesets)
		if(job.title in ruleset.restricted_roles)
			to_chat(player, span_notice("While your name is shown as [job.title], some roundstart antagonists can't pick you."))
			return

/datum/controller/subsystem/job/proc/get_job_estimation_name(datum/preferences/prefs, datum/job/job)
	if(!prefs.read_player_preference(/datum/preference/toggle/job_estimation_name))
		return
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
	for(var/player_ref in job_estimation_jobs)
		var/datum/job/job = job_estimation_jobs[player_ref]
		if(!job)
			flexible++
			continue
		if(!names_by_job[job.title])
			names_by_job[job.title] = list()
		var/name = job_estimation_names[player_ref]
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
		var/others = anonymous_by_job[title] + max(length(names) - JOB_ESTIMATION_MAX_NAMES, 0)
		names = names.Copy(1, min(length(names), JOB_ESTIMATION_MAX_NAMES) + 1)
		if(others)
			names += length(names) ? "+[others] more" : "[others] anonymous"
		job_estimation_rows[title] = GENERATE_STAT_TEXT(jointext(names, ", "))
	if(flexible)
		job_estimation_rows["Flexible"] = GENERATE_STAT_TEXT("[flexible]")

/datum/controller/subsystem/job/proc/remove_job_estimation(mob/dead/new_player/authenticated/player)
	var/player_ref = REF(player)
	if(!(player_ref in job_estimation_jobs))
		return
	job_estimation_jobs -= player_ref
	job_estimation_names -= player_ref
	rebuild_job_estimation()

#undef JOB_ESTIMATION_MAX_NAMES
