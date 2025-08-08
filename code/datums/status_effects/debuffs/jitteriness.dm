/datum/status_effect/jitter
	id = "jitter"
	tick_interval = 2 SECONDS
	alert_type = null
	//remove_on_fullheal = TRUE

/datum/status_effect/jitter/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/jitter/on_apply()
	// If we're being applied to a dead person, don't make the status effect.
	// Just do a bit of jitter animation and be done.
	if(owner.stat == DEAD)
		owner.do_jitter_animation(duration / 10)
		return FALSE

	RegisterSignal(owner, lists(COMSIG_LIVING_POST_FULLY_HEAL, COMSIG_LIVING_DEATH), PROC_REF(remove_jitter))
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, id, /datum/mood_event/jittery)
	return TRUE

/datum/status_effect/jitter/on_remove()
	UnregisterSignal(owner, list(COMSIG_LIVING_POST_FULLY_HEAL, COMSIG_LIVING_DEATH))
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, id)
	// juuust in case, reset our x and y's from our jittering
	owner.pixel_x = 0
	owner.pixel_y = 0

/datum/status_effect/jitter/get_examine_text()
	switch(duration - world.time)
		if(5 MINUTES to INFINITY)
			return span_boldwarning("[owner.p_they(TRUE)] [owner.p_are()] convulsing violently!")
		if(3 MINUTES to 5 MINUTES)
			return span_warning("[owner.p_they(TRUE)] [owner.p_are()] extremely jittery.")
		if(1 MINUTES to 3 MINUTES)
			return span_warning("[owner.p_they(TRUE)] [owner.p_are()] twitching ever so slightly.")

	return null

/// Removes all of our jitteriness on a signal
/datum/status_effect/jitter/proc/remove_jitter(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/status_effect/jitter/tick()
	// Resting helps against jitter
	// While resting, we lose 8 seconds of duration (4 additional ticks) per tick
	if(owner.resting && remove_duration(4 * initial(tick_interval)))
		return

	var/time_left_in_seconds = (duration - world.time) / 10
	owner.do_jitter_animation(time_left_in_seconds)

/// Helper proc that causes the mob to do a jittering animation by jitter_amount.
/// jitter_amount will only apply up to 300 (maximum jitter effect).
/mob/living/proc/do_jitter_animation(jitter_amount = 100)
	var/amplitude = min(4, (jitter_amount / 100) + 1)
	var/pixel_x_diff = rand(-amplitude, amplitude)
	var/pixel_y_diff = rand(-amplitude / 3, amplitude / 3)
	animate(src, pixel_x = pixel_x_diff, pixel_y = pixel_y_diff , time = 0.2 SECONDS, loop = 6, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	animate(pixel_x = -pixel_x_diff , pixel_y = -pixel_y_diff , time = 0.2 SECONDS, flags = ANIMATION_RELATIVE)
