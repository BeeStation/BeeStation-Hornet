/datum/bounty/manuscript
	reward = 4000
	var/shipped = FALSE
	var/datum/job/bounty_job
	var/repeated = 0 // number of completion
	var/total_claimed = 0

	var/static/list/available_jobs
	var/static/list/bad_jobs = typecacheof(list(
		/datum/job/gimmick,
		/datum/job/ai,
		/datum/job/cyborg,
		/datum/job/posibrain,
		/datum/job/deputy,
	), only_root_path = TRUE)

/datum/bounty/manuscript/New()
	..()
	assign_bounty_job()

/datum/bounty/manuscript/proc/assign_bounty_job(force = FALSE)
	// Finds a job if there's no preset
	if(!bounty_job || force)
		var/datum/job/job
		var/static/error_count = 30
		while(!job)
			if(!length(available_jobs))
				available_jobs = SSjob.occupations.Copy()
			if(error_count-- < 0)
				name = "MANUSCRIPT BOUNTY ERROR"
				CRASH("Failed to make a manuscript bounty: There are no available jobs.")
			job = pick_n_take(available_jobs)
			if((!job.total_positions) || job.lock_flags || is_type_in_typecache(job, bad_jobs))
				job = null
				continue
		bounty_job = job
		error_count = 30

	// calculates bounty value
	var/mult = 1
	if(bounty_job.departments & DEPT_BITFLAG_CAR)
		mult = 0.6 // too easy for cargo
	if(bounty_job.departments & DEPT_BITFLAG_COM)
		mult += 1
	if(bounty_job.title == JOB_NAME_CAPTAIN)
		mult += 0.2

	reward = round(/datum/bounty/manuscript::reward*mult, 50)
	name = "Manuscript of the [bounty_job.title]"
	description = "Central Command seeks the professional knowledge of the [bounty_job.title] in the form of a manuscript written by someone with relevant expertise. Find someone to write the manuscript, and ship it to Central Command."
	if(repeated)
		description += "\nYou have completed this for [repeated] [repeated == 1 ? "time" : "times"], and earned credits in total of [total_claimed]."

	shipped = FALSE
	claimed = FALSE

/datum/bounty/manuscript/completion_string()
	return shipped ? "Shipped" : "Not Shipped"

/datum/bounty/manuscript/can_claim()
	return ..() && shipped

/datum/bounty/manuscript/claim()
	..()
	repeated++
	total_claimed += reward * SSeconomy.bounty_modifier
	description = "Central Command appreciates your service of delivering the manuscript. Another manuscript can be delivered in 4 minutes. You have completed this [repeated] [repeated == 1 ? "time" : "times"], and earned a total of [total_claimed] credits."
	addtimer(CALLBACK(src, PROC_REF(assign_bounty_job), TRUE), 4 MINUTES, TIMER_UNIQUE | TIMER_STOPPABLE)
	//addtimer(CALLBACK(src, PROC_REF(begin_tracking), picked_level), 60 SECONDS)

/datum/bounty/manuscript/applies_to(obj/item/book/manuscript/book)
	if(shipped)
		return FALSE
	if(book.flags_1 & HOLOGRAM_1)
		return FALSE
	if(!istype(book, /obj/item/book/manuscript))
		return FALSE
	if(book.booked_job.title == bounty_job.title)
		return TRUE
	return FALSE

/datum/bounty/manuscript/ship(obj/O)
	if(!applies_to(O))
		return
	shipped = TRUE

// no restriction for now
// /datum/bounty/manuscript/compatible_with(datum/bounty/other_bounty)
/datum/bounty/manuscript/assistant
	reward = 4000

/datum/bounty/manuscript/assistant/New()
	bounty_job = SSjob.GetJob(JOB_NAME_ASSISTANT)
	if(!length(available_jobs))
		available_jobs = SSjob.occupations.Copy()
		available_jobs -= JOB_NAME_ASSISTANT
	..()
