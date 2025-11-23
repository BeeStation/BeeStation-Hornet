/obj/item/book/manuscript
	name = "empty manuscript"
	icon = 'icons/obj/library.dmi'
	icon_state ="book4"
	desc = "A book that is ready to write about a professional experience."
	unique = TRUE
	var/datum/job/booked_job
	var/writing // a flag that prevents double-writting

	attackby_skip = TRUE

/obj/item/book/manuscript/Destroy()
	booked_job = null
	. = ..()

/obj/item/book/manuscript/on_read(mob/user)
	if(isnull(booked_job))
		to_chat(user, span_notice("This book needs a pen to have someone's experience."))
		return
	to_chat(user, span_notice("This is written about [booked_job]. There's a wall of texts with unrecognisable handwriting."))

/obj/item/book/manuscript/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/pen) || !user.is_literate())
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
	var/is_antag = length(mind.antag_datums)

	var/datum/job/writter_job
	if(is_antag) // antag can make any job books. *NOTE: every antag including non-humans can do this, but who cares...
		writter_job = tgui_input_list(user, "Choose a job to pretend (*These books work real)", "Job selection for writing", SSjob.name_occupations)
		if(!writter_job)
			return ..()
		writter_job = SSjob.GetJob(writter_job)
	else
		writter_job = SSjob.GetJob(user.mind?.assigned_role)
	if(!writter_job)
		to_chat(user, span_notice("It seems you do not have any expertise in any job."))
		return ..()

	bookwriting(I, user, writter_job, is_antag ? 10 SECONDS : 20 SECONDS) // antag can write fast... it will look less suspicious
	return ..()

/obj/item/book/manuscript/proc/bookwriting(obj/item/I, mob/user, datum/job/writter_job, writing_delay = 20 SECONDS)
	writing = TRUE
	to_chat(user, span_notice("You start writing about your profession."))

	if(!I.use_tool(src, user, writing_delay, volume=50)) // TODO: pen writing sound?
		to_chat(user, span_notice("You stopped writing."))
		writing = FALSE
		return

	booked_job = writter_job
	name = "Manuscript: [booked_job.title] addition"
	title = name
	desc = "A book with the expertise of [booked_job.title]."

	add_overlay(image(icon='icons/mob/hud.dmi', icon_state="hud[get_hud_by_jobname(booked_job.title)]", pixel_x = 12, pixel_y = -8, layer = src.layer+0.1))

	to_chat(user, span_notice("You completed writing a job manuscript."))
	writing = FALSE
	return
