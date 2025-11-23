/datum/bounty/manuscript
	reward = 4000
	var/shipped = FALSE
	var/datum/job/bounty_job

	var/static/list/available_jobs
	var/static/list/bad_jobs = typecacheof(list(
		/datum/job/gimmick,
		/datum/job/ai,
		/datum/job/cyborg,
		/datum/job/deputy,
	), only_root_path = TRUE)

/datum/bounty/manuscript/New()
	..()

	// Finds a job if there's no preset
	if(!bounty_job)
		var/datum/job/job
		var/static/error_count = 30
		while(!job)
			if(!available_jobs)
				available_jobs = SSjob.occupations.Copy()
			if(error_count-- < 0)
				name = "MANUSCRIPT BOUNTY ERROR"
				CRASH("Fail to make a manuscript bounty: There's no available job.")
			job = pick_n_take(available_jobs)
			if((!job.total_positions) || job.lock_flags || is_type_in_list(job, bad_jobs))
				available_jobs -= job
				continue
		available_jobs -= job
		bounty_job = job
		error_count = 30

	// calculates bounty value
	var/mult = 1
	if(bounty_job.departments & DEPT_BITFLAG_CAR)
		mult = 0.4 // too easy for cargo
	if(bounty_job.departments & DEPT_BITFLAG_COM)
		mult += 1
	mult += rand(-4, 6)/10

	reward = round(reward*mult, 1) + rand(100, 2000)
	name = "Manuscript of [bounty_job.title]"
	description = "Central Command seeks for a professional knowledge of [bounty_job.title] as a form of a manuscript written by someone who has the excellent expertise in their job. Find someone to write a manuscript, and ship the paper to the command."

/datum/bounty/manuscript/completion_string()
	return shipped ? "Shipped" : "Not Shipped"

/datum/bounty/manuscript/can_claim()
	return ..() && shipped

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
	reward = 1500

/datum/bounty/manuscript/assistant/New()
	bounty_job = SSjob.GetJob(JOB_NAME_ASSISTANT)
	..()
