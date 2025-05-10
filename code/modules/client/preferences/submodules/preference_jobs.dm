/datum/preferences/proc/set_job_preference_level(datum/job/job, level)
	if (!job || job.lock_flags)
		return FALSE

	log_preferences("[parent?.ckey]: Set [job.title] preference to level [level].")

	if (level == JP_HIGH)
		for(var/other_job in job_preferences)
			if(job_preferences[other_job] == JP_HIGH)
				job_preferences[other_job] = JP_MEDIUM
				log_preferences("[parent?.ckey]: Set [other_job] preference to level [JP_MEDIUM].")

	if(level == null)
		job_preferences -= job.title
	else
		job_preferences[job.title] = level
	mark_undatumized_dirty_character()

	return TRUE

/// Returns what job is marked as highest
/datum/preferences/proc/get_highest_priority_job()
	var/datum/job/preview_job
	var/highest_pref = 0

	for(var/job in job_preferences)
		if(job_preferences[job] > highest_pref)
			preview_job = SSjob.GetJob(job)
			highest_pref = job_preferences[job]

	return preview_job
