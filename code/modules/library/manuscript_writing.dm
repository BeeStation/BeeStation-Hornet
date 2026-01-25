#define BOOKWRITING_COOLDOWN_TIME 15 MINUTES

/obj/item/book/manuscript
	name = "empty manuscript"
	icon = 'icons/obj/library.dmi'
	icon_state ="book4"
	desc = "A book that is ready to be completed with professional experience."
	unique = TRUE
	var/writing /// a flag that prevents double-writting
	var/datum/job/booked_job /// a job datum that this manuscript has

	var/static/list/valid_jobs /// which jobs a manuscript can accept (used for antag filter)
	var/static/list/writing_cooldown_list = list() /// a snowflake that prevents an antag from making a lot of books

	attackby_skip = TRUE

/obj/item/book/manuscript/Initialize(mapload)
	. = ..()
	if(isnull(valid_jobs))
		valid_jobs = SSjob.name_occupations.Copy()
		valid_jobs -= list(JOB_NAME_GIMMICK, JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_POSIBRAIN)

/obj/item/book/manuscript/Destroy()
	booked_job = null
	. = ..()

/obj/item/book/manuscript/on_read(mob/user)
	if(isnull(booked_job))
		to_chat(user, span_notice("This book needs a pen to write someone's experience."))
		return
	to_chat(user, span_notice("This is about the [booked_job::title]. There's a wall of text with unrecognisable handwriting."))

/obj/item/book/manuscript/attackby(obj/item/attacking_item, mob/user, params)
	if(!istype(attacking_item, /obj/item/pen) || !user.is_literate())
		return ..()
	if(booked_job)
		to_chat(user, span_notice("The book is already written."))
		return ..()
	if(writing)
		to_chat(user, span_notice("The book is already being writen."))
		return ..()

	var/datum/mind/mind = user.mind
	if(!mind)
		return ..()
	if(writing_cooldown_list[FAST_REF(mind)] && (writing_cooldown_list[FAST_REF(mind)] > REALTIMEOFDAY)) // Prevent people writing multiple books
		to_chat(user, span_notice("You feel too tired to write more books for now. You might feel better in [round((writing_cooldown_list[FAST_REF(mind)] - REALTIMEOFDAY) / 600, 0.5)+0.5] minutes."))
		return ..()

	var/is_antag = length(mind.antag_datums)

	var/datum/job/writer_job
	if(!is_antag)
		if(!(user.mind?.assigned_role in valid_jobs))
			to_chat(user, span_notice("Your job knowledge doesn't seem to be describable in writing."))
			return ..()
		writer_job = SSjob.GetJob(user.mind?.assigned_role)

	var/list/jobs_with_knowledge = \
		is_antag ? valid_jobs \
		: user.mind?.assigned_role == JOB_NAME_CURATOR ? valid_jobs \
		: length(writer_job.manuscript_jobs) ? writer_job.manuscript_jobs \
		: null

	if(length(jobs_with_knowledge))
		writer_job = tgui_input_list(user, "Choose a job", "Manuscript", jobs_with_knowledge)
		if(!writer_job)
			return ..()
		writer_job = SSjob.GetJob(writer_job)

	bookwriting(attacking_item, user, writer_job, is_antag ? 10 SECONDS : 20 SECONDS) // antag can write fast... it will look less suspicious
	return ..()

/obj/item/book/manuscript/proc/bookwriting(obj/item/attacking_item, mob/user, datum/job/writer_job, writing_delay = 20 SECONDS)
	if(writing)
		to_chat(user, span_notice("The book is already being writen."))
		return
	writing = TRUE
	to_chat(user, span_notice("You start writing about your profession."))

	if(!attacking_item.use_tool(src, user, writing_delay, volume=50)) // TODO: pen writing sound?
		to_chat(user, span_notice("You stopped writing."))
		writing = FALSE
		return

	if(writing_cooldown_list[FAST_REF(user.mind)] && (writing_cooldown_list[FAST_REF(user.mind)] > REALTIMEOFDAY)) // Prevent people writing multiple books
		to_chat(user, span_notice("You feel too tired to write more books for now. You might feel better in [round((writing_cooldown_list[FAST_REF(user.mind)] - REALTIMEOFDAY) / 600, 0.5)+0.5] minutes."))
		writing = FALSE
		return

	booked_job = writer_job
	name = "Manuscript: [booked_job.title] addition"
	title = name
	desc = "A book with the expertise of the [booked_job.title]."
	to_chat(user, span_notice("You finished writing a job manuscript."))
	writing = FALSE

	// puts a job hud like a sticker on the book. Good to recognise
	add_overlay(image(icon='icons/mob/hud.dmi', icon_state="hud[get_hud_by_jobname(booked_job.title)]", pixel_x = 12, pixel_y = -8, layer = src.layer+0.1))

	// Preventing antag book mass production
	writing_cooldown_list[FAST_REF(user.mind)] = REALTIMEOFDAY + BOOKWRITING_COOLDOWN_TIME
	return

#undef BOOKWRITING_COOLDOWN_TIME
