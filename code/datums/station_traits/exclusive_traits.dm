/*
	< Excluisve station traits >
		exclusive station traits are chosen by their own chance regardless of the amount of station trait number
		weight is not shared among itselves. 5 means 5% chance to appear per round.
		if there are 3 traits and these have weight 100, all of them will appear.
*/

/datum/station_trait/job
	name = "Special Job"
	trait_type = STATION_TRAIT_EXCLUSIVE
	weight = 0
	show_in_report = TRUE
	report_message = "We opened a slot for a special job. We expect their duty can fit the station."
	abstract_type = /datum/station_trait/job

	var/datum/job/job_to_add

/datum/station_trait/job/New()
	if(!job_to_add)
		return

	var/datum/job/job = SSjob.GetJobType(job_to_add)
	job.total_positions++
	return ..()

/* subtype example:
/datum/station_trait/job/barber
	name = "Barber"
	weight = 33
	job_to_add = /datum/job/gimmick/barber
*/
