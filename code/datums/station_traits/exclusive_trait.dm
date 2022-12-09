/*
	< Excluisve station traits >
		exclusive station traits are chosen by their own chance regardless of the amount of station trait number
		weight is not shared among itselves. 5 means 5% chance to appear per round.
		if there are 3 traits and these have weight 100, all of them will appear.
*/
/datum/station_trait/special_jobs
	name = "Special Jobs"
	trait_type = STATION_TRAIT_EXCLUSIVE
	weight = 100
	show_in_report = TRUE
	report_message = "We opened a slot for a special job. We expect their duty can fit the station."
	var/chosen_job = JOB_NAME_MAILMAN

/datum/station_trait/special_jobs/New()
	. = ..()
	var/datum/job/J = SSjob.GetJob(chosen_job)
	J.total_positions += 1
	J.spawn_positions += 1
