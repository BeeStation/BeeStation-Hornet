//Strained Muscles: Temporary speed boost at the cost of rapid damage
//Limited because of hardsuits and such; ideally, used for a quick getaway

/datum/action/changeling/strained_muscles
	name = "Strained Muscles"
	desc = "We evolve the ability to reduce the acid buildup in our muscles, allowing us to move much faster."
	helptext = "The strain will make us tired, and we will rapidly become fatigued. Standard weight restrictions, like hardsuits, still apply. Cannot be used in lesser form."
	button_icon_state = "strained_muscles"
	chemical_cost = 0
	dna_cost = 1
	req_human = TRUE
	var/stacks = 0 //Increments every 5 seconds; damage increases over time
	toggleable = TRUE

/datum/action/changeling/strained_muscles/sting_action(mob/living/carbon/user)
	..()
	to_chat(user, span_notice("Our muscles tense and strengthen."))
	INVOKE_ASYNC(src, PROC_REF(muscle_loop), user)
	return TRUE

/datum/action/changeling/strained_muscles/on_deactivate(mob/living/carbon/user, atom/target)
	user.remove_movespeed_modifier(/datum/movespeed_modifier/strained_muscles)
	to_chat(user, "<span class='notice'>Our muscles relax.</span>")
	if(stacks >= 10)
		to_chat(user, "<span class='danger'>We collapse in exhaustion.</span>")
		user.Paralyze(60)
		user.emote("gasp")

/datum/action/changeling/strained_muscles/Remove(mob/user)
	user.remove_movespeed_modifier(/datum/movespeed_modifier/strained_muscles)
	return ..()

/datum/action/changeling/strained_muscles/proc/muscle_loop(mob/living/carbon/user)
	// Skip until the next sleep so that we have the active var set
	sleep(1)

	while(active)
		if(QDELETED(src) || QDELETED(user))
			return

		user.add_movespeed_modifier(/datum/movespeed_modifier/strained_muscles)
		if(user.stat != CONSCIOUS || user.staminaloss >= 90)
			active = !active
			to_chat(user, span_notice("Our muscles relax without the energy to strengthen them."))
			user.Paralyze(40)
			user.remove_movespeed_modifier(/datum/movespeed_modifier/strained_muscles)
			break

		stacks++

		user.adjustStaminaLoss(stacks * 1.3) //At first the changeling may regenerate stamina fast enough to nullify fatigue, but it will stack

		if(stacks == 11) //Warning message that the stacks are getting too high
			to_chat(user, span_warning("Our legs are really starting to hurt..."))

		sleep(40)

	while(!active && stacks) //Damage stacks decrease fairly rapidly while not in sanic mode
		if(QDELETED(src) || QDELETED(user))
			return

		stacks--
		sleep(20)
