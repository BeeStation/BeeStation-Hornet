/datum/action/changeling/fakedeath
	name = "Reviving Stasis"
	desc = "We fall into a stasis, allowing us to regenerate and trick our enemies. Costs 15 chemicals."
	button_icon_state = "fake_death"
	chemical_cost = 15
	dna_cost = 0
	req_dna = 1
	check_flags = NONE
	ignores_fakedeath = TRUE
	var/revive_ready = FALSE

//Fake our own death and fully heal. You will appear to be dead but regenerate fully after a short delay.
/datum/action/changeling/fakedeath/sting_action(mob/living/user)
	..()
	if(revive_ready)
		INVOKE_ASYNC(src, PROC_REF(revive), user)
		revive_ready = FALSE
		name = "Reviving Stasis"
		desc = "We fall into a stasis, allowing us to regenerate and trick our enemies."
		button_icon_state = "fake_death"
		update_buttons()
		chemical_cost = 15
		to_chat(user, span_notice("We have revived ourselves."))
	else
		to_chat(user, span_notice("We begin our stasis, preparing energy to arise once more."))
		user.fakedeath("changeling") //play dead
		addtimer(CALLBACK(src, PROC_REF(ready_to_regenerate), user.mind), LING_FAKEDEATH_TIME, TIMER_UNIQUE)
	return TRUE

/datum/action/changeling/fakedeath/proc/revive(mob/living/user)
	if(!user || !istype(user))
		return
	user.cure_fakedeath("changeling")
	user.revive(full_heal = TRUE)
	user.regenerate_organs()

/datum/action/changeling/fakedeath/proc/ready_to_regenerate(datum/mind/mind)
	if(!mind || !iscarbon(mind.current))
		return
	var/datum/antagonist/changeling/ling = mind.has_antag_datum(/datum/antagonist/changeling)
	if(!ling || !(src in ling.innate_powers))
		return
	to_chat(mind.current, span_notice("We are ready to revive."))
	name = "Revive"
	desc = "We arise once more."
	button_icon_state = "revive"
	update_buttons()
	chemical_cost = 0
	revive_ready = TRUE

/datum/action/changeling/fakedeath/can_sting(mob/living/user)
	if(HAS_TRAIT(user, TRAIT_HUSK))
		to_chat(user, span_warning("This body is too damaged to revive!."))
		return
	if(HAS_TRAIT_FROM(user, TRAIT_DEATHCOMA, "changeling") && !revive_ready)
		to_chat(user, span_warning("We are already reviving."))
		return
	if(!user.stat && !revive_ready) //Confirmation for living changelings if they want to fake their death
		switch(alert("Are we sure we wish to fake our own death?",,"Yes", "No"))
			if("No")
				return
	return ..()
