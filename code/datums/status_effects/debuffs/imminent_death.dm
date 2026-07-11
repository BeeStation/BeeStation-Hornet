/datum/status_effect/imminent_death
	id = "imminent death"
	duration = 30 SECONDS
	alert_type = null
	remove_on_fullheal = TRUE
	var/saved = FALSE
	var/initial_message = "You suddenly feel very weak!"
	var/first_warning = "You feel sick..."
	var/second_warning = "It is getting hard to stay standing!"
	var/third_warning = "Darkness floods your vision!"
	var/death_message = "Images of your life flash before your eyes..."
	var/fix_message = "You feel your strength return."

/datum/status_effect/imminent_death/on_apply()
	give_warning(span_notice(initial_message))
	addtimer(CALLBACK(src, PROC_REF(give_warning), span_warning(first_warning)), 10 SECONDS, TIMER_DELETE_ME)
	addtimer(CALLBACK(src, PROC_REF(give_warning), span_warningbold(second_warning)), 20 SECONDS, TIMER_DELETE_ME)
	addtimer(CALLBACK(src, PROC_REF(give_warning), span_warningbig(third_warning)), 25 SECONDS, TIMER_DELETE_ME)
	addtimer(CALLBACK(src, PROC_REF(give_warning), span_warningbold(death_message)), 28 SECONDS, TIMER_DELETE_ME)
	return ..()

/datum/status_effect/imminent_death/on_remove()
	if(!saved)
		owner.death()
	else
		give_warning(span_notice(fix_message))

/datum/status_effect/imminent_death/tick(seconds_between_ticks)
	if(owner.nutrition > 0)
		saved = TRUE
		qdel(src)


/datum/status_effect/imminent_death/proc/give_warning(message)
	to_chat(owner, message)



/datum/status_effect/imminent_death/robotic
	initial_message = "Battery failure reported, backup capacitors activated. Estimated time until failure: 30 seconds."
	first_warning = "LOW_POWER_STATE = TRUE"
	second_warning = "CORE.STAT reports imminent shutdown!"
	third_warning = "CLOSE_GRACEFULLY.bin initializing"
	death_message = "CORE shutting down..."
	fix_message = "Battery power restored. Aborting shutdown..."
