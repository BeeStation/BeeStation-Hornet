/datum/status_effect/critical_condition
	alert_type = null
	/// The probability, per move, that we fall back down again
	var/fall_probability = 15
	/// Are we currently crawling?
	var/crawling = TRUE
	/// The timer ID
	var/timer_id

/datum/status_effect/critical_condition/on_apply()
	ADD_TRAIT(owner, TRAIT_FLOORED, FROM_CRITICAL_CONDITION)
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, FROM_CRITICAL_CONDITION)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(owner, SIGNAL_UPDATETRAIT(TRAIT_INCAPACITATED), PROC_REF(start_stand_timer))
	start_stand_timer()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/critical_condition)
	return TRUE

/datum/status_effect/critical_condition/on_remove()
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(owner, SIGNAL_UPDATETRAIT(TRAIT_INCAPACITATED))
	REMOVE_TRAIT(owner, TRAIT_FLOORED, FROM_CRITICAL_CONDITION)
	REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, FROM_CRITICAL_CONDITION)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/critical_condition)
	if (timer_id)
		deltimer(timer_id)
		timer_id = null

/datum/status_effect/critical_condition/proc/start_stand_timer()
	// Start trying to climb
	if (HAS_TRAIT(owner, TRAIT_INCAPACITATED))
		return
	if (timer_id)
		return
	timer_id = addtimer(CALLBACK(src, PROC_REF(start_standing)), 2 SECONDS, TIMER_STOPPABLE)

/datum/status_effect/critical_condition/proc/on_move()
	SIGNAL_HANDLER
	if (timer_id)
		deltimer(timer_id)
		timer_id = null
	// Try to stand
	if (crawling)
		start_stand_timer()
		return
	if (!prob(fall_probability))
		return
	crawling = TRUE
	ADD_TRAIT(owner, TRAIT_FLOORED, FROM_CRITICAL_CONDITION)
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, FROM_CRITICAL_CONDITION)
	owner.custom_emote("collapses to the ground")
	to_chat(owner, span_pain(pick(\
		"You tremble and fall to the ground, your legs giving way to the crushing weight of your body!",\
		"Agony grips your limbs like chains, and with a gasp, you crumble to the earth, powerless to resist the pain.",\
		"Your vision blurs as searing pain pulses through your body - your knees buckle, and the world rushes up to meet you.",\
		"You stagger back, clutching at the air - then collapse, pain knocking you from your feet like a hammer blow.",\
		"Pain blindsides you, cold and absolute. Your legs go slack, and you hit the ground with a sickening thud.",\
		"Every nerve screams in protest. You sink to your knees, then to your side, unable to rise."\
	)))

/datum/status_effect/critical_condition/proc/start_standing()
	if (!do_after(owner, 3 SECONDS, owner, IGNORE_HELD_ITEM))
		return
	crawling = FALSE
	REMOVE_TRAIT(owner, TRAIT_FLOORED, FROM_CRITICAL_CONDITION)
	owner.get_up(TRUE)
	REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, FROM_CRITICAL_CONDITION)
