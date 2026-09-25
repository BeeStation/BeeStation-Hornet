/datum/antagonist/abductee
	name = "\improper Abductee"
	roundend_category = "abductees"
	antagpanel_category = ANTAG_GROUP_ABDUCTORS
	antag_hud_name = "abductee"
	banning_key = UNBANNABLE_ANTAGONIST

/datum/antagonist/abductee/on_gain()
	give_objective()
	return ..()

/datum/antagonist/abductee/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/effects/antag/abductee.ogg', vol = 100, vary = FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE, use_reverb = FALSE)
	to_chat(owner, span_warning("<b>Your mind snaps!</b>"))
	to_chat(owner, "<big>[span_warning("<b>You can't remember how you got here...</b>")]</big>")
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Abductee", "Something isn't right with your brain, you feel like there is something you have to do no matter what...")

/datum/antagonist/abductee/proc/give_objective()
	var/mob/living/carbon/human/H = owner.current

	// Give the base objective
	var/datum/objective/abductee/base_objective = new()
	base_objective.owner = owner
	objectives += base_objective


	//pick flavor objective
	var/datum/objective/abductee/extra_objective
	switch(rand(1,10))
		if(6 to 10)
			extra_objective = new /datum/objective/abductee/fearful()
		if(3 to 5)
			extra_objective = new /datum/objective/abductee/violent()
		if(1 to 2)
			extra_objective = new /datum/objective/abductee/paranoid()

	extra_objective.owner = owner
	objectives += extra_objective
	log_objective(H, extra_objective.explanation_text)
