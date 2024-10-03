/datum/round_event_control/bureaucratic_error
	name = "Bureaucratic Error"
	typepath = /datum/round_event/bureaucratic_error
	max_occurrences = 1
	weight = 5

/datum/round_event/bureaucratic_error
	announceWhen = 1
	var/chosen_job_title

/datum/round_event/bureaucratic_error/setup()
	var/error_count = 10
	while(error_count--)
		var/datum/job/J = SSjob.GetJob(pick(get_all_jobs()))
		if(!J || J.lock_flags)
			continue
		chosen_job_title = J.title
		break
	if(isnull(chosen_job_title))
		return kill()

/datum/round_event/bureaucratic_error/announce(fake)
	priority_announce("A recent bureaucratic error in the Organic Resources Department may result in personnel shortages in some departments and redundant staffing in others.", "Paperwork Mishap Alert", SSstation.announcer.get_rand_alert_sound())

/datum/round_event/bureaucratic_error/start()
	SSjob.set_overflow_role(chosen_job_title)
