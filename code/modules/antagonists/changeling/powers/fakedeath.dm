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

/datum/action/changeling/fakedeath/proc/revive(mob/living/carbon/user)
	if(!istype(user))
		return

	user.cure_fakedeath("changeling")
	// Heal all damage and some minor afflictions,
	var/flags_to_heal = (HEAL_DAMAGE|HEAL_BODY|HEAL_STATUS|HEAL_CC_STATUS)
	// but leave out limbs so we can do it specially
	user.revive(flags_to_heal & ~HEAL_LIMBS)

	var/static/list/dont_regenerate = list(BODY_ZONE_HEAD) // headless changelings are funny
	if(!length(user.get_missing_limbs() - dont_regenerate))
		return

	playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
	user.visible_message(
		span_warning("[user]'s missing limbs reform, making a loud, grotesque sound!"),
		span_userdanger("Your limbs regrow, making a loud, crunchy sound and giving you great pain!"),
		span_hear("You hear organic matter ripping and tearing!"),
	)
	user.emote("scream")
	// Manually call this (outside of revive/fullheal) so we can pass our blacklist
	user.regenerate_limbs(dont_regenerate)

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
