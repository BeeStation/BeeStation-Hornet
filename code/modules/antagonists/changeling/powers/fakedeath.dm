/datum/action/changeling/fakedeath
	name = "Reviving Stasis"
	desc = "We fall into a stasis, allowing us to regenerate and trick our enemies. Costs 15 chemicals."
	button_icon_state = "fake_death"
	chemical_cost = 15
	dna_cost = 0
	req_dna = 1
	req_stat = DEAD
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
		UpdateButtonIcon()
		chemical_cost = 15
		to_chat(user, "<span class='notice'>We have revived ourselves.</span>")
	else
		to_chat(user, "<span class='notice'>We begin our stasis, preparing energy to arise once more.</span>")
		user.fakedeath("changeling") //play dead
		user.update_stat()
		user.update_mobility()
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
	var/datum/antagonist/changeling/C = mind.has_antag_datum(/datum/antagonist/changeling)
	if(C?.purchasedpowers)
		to_chat(mind.current, "<span class='notice'>We are ready to revive.</span>")
		name = "Revive"
		desc = "We arise once more."
		button_icon_state = "revive"
		UpdateButtonIcon()
		chemical_cost = 0
		revive_ready = TRUE

/datum/action/changeling/fakedeath/can_sting(mob/living/user)
	if(HAS_TRAIT(user, TRAIT_HUSK))
		to_chat(user, "<span class='warning'>This body is too damaged to revive!.</span>")
		return
	if(HAS_TRAIT_FROM(user, TRAIT_DEATHCOMA, "changeling") && !revive_ready)
		to_chat(user, "<span class='warning'>We are already reviving.</span>")
		return
	if(!user.stat && !revive_ready) //Confirmation for living changelings if they want to fake their death
		switch(alert("Are we sure we wish to fake our own death?",,"Yes", "No"))
			if("No")
				return
	return ..()
