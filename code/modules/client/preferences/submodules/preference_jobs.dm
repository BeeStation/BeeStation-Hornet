/datum/preferences/proc/set_job_preference_level(datum/job/job, level)
	if (!job)
		return FALSE

	if (level == JP_HIGH)
		var/datum/job/overflow_role = SSjob.overflow_role
		var/overflow_role_title = initial(overflow_role.title)

		for(var/other_job in job_preferences)
			if(job_preferences[other_job] == JP_HIGH)
				// Overflow role needs to go to NEVER, not medium!
				if(other_job == overflow_role_title)
					job_preferences[other_job] = null
				else
					job_preferences[other_job] = JP_MEDIUM

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
