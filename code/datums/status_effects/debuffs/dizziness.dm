/datum/status_effect/dizziness
	id = "dizziness"
	tick_interval = 2 SECONDS
	alert_type = null
	remove_on_fullheal = TRUE
	var/list/sway_timers = list()
	var/client/sway_client
	var/sway_generation = 0

/datum/status_effect/dizziness/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/dizziness/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(clear_dizziness))
	RegisterSignal(owner, COMSIG_MOB_LOGOUT, PROC_REF(clear_sway))
	return TRUE

/datum/status_effect/dizziness/on_remove()
	UnregisterSignal(owner, list(COMSIG_LIVING_DEATH, COMSIG_MOB_LOGOUT))
	clear_sway()

/datum/status_effect/dizziness/proc/clear_sway(datum/source)
	SIGNAL_HANDLER
	sway_generation++
	for(var/timer in sway_timers)
		deltimer(timer)
	sway_timers.Cut()
	var/client/previous_client = sway_client
	sway_client = null
	previous_client?.clear_camera_effect(src)

/// Signal proc that self deletes our dizziness effect
/datum/status_effect/dizziness/proc/clear_dizziness(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/status_effect/dizziness/tick(seconds_between_ticks)
	// How much time is left, in seconds
	var/amount = duration / 10
	if(amount <= 0)
		return

	// How strong the dizziness effect is on us.
	// If we're resting, the effect is 5x as strong, but also decays 5x fast.
	// Meaning effectively, 1 tick is actually dizziness_strength ticks of duration
	var/dizziness_strength = owner.resting ? 5 : 1

	// How much time will be left, in seconds, next tick
	var/next_amount = max((amount - (dizziness_strength * seconds_between_ticks * 0.1)), 0)

	// If we have a dizziness strength > 1, we will subtract ticks off of the total duration
	if(remove_duration((dizziness_strength - 1) * seconds_between_ticks))
		return

	// Now we can do the actual dizzy effects.
	// Don't bother animating if they're clientless.
	clear_sway()
	if(!owner.client)
		return
	if(!owner.client.brandish_camera)
		animate_original(amount, next_amount)
		return
	sway_client = owner.client
	sway_client.ensure_camera_state().bind_effect_body()
	var/epoch = sway_client.camera_state.effect_epoch
	var/time = world.time
	var/amplitude = amount * (sin(amount * time) + 1)
	var/x_diff = clamp(amplitude * sin(amount * time), -32, 32)
	var/y_diff = clamp(amplitude * cos(amount * time), -32, 32)
	sway_timers += addtimer(CALLBACK(src, PROC_REF(set_camera_sway), x_diff, y_diff, sway_client, sway_generation, epoch), 0.3 SECONDS, TIMER_STOPPABLE)
	x_diff += clamp(amplitude * sin(next_amount * (time + 3)), -32, 32)
	y_diff += clamp(amplitude * cos(next_amount * (time + 3)), -32, 32)
	sway_timers += addtimer(CALLBACK(src, PROC_REF(set_camera_sway), x_diff, y_diff, sway_client, sway_generation, epoch), 0.6 SECONDS, TIMER_STOPPABLE)
	sway_timers += addtimer(CALLBACK(src, PROC_REF(set_camera_sway), 0, 0, sway_client, sway_generation, epoch), 0.9 SECONDS, TIMER_STOPPABLE)

/datum/status_effect/dizziness/proc/set_camera_sway(x_offset, y_offset, client/viewer, generation, epoch)
	if(viewer != sway_client || generation != sway_generation || owner.client != viewer || viewer?.camera_state?.effect_epoch != epoch)
		return
	if(!viewer.brandish_camera || (!x_offset && !y_offset))
		viewer.clear_camera_effect(src)
		return
	viewer.set_camera_effect(src, offset_w = x_offset, offset_z = y_offset)

/datum/status_effect/dizziness/proc/animate_original(amount, next_amount)
	// Want to be able to offset things by the time the animation should be "playing" at
	var/time = world.time
	var/delay = 0
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0

	var/amplitude = amount * (sin(amount * (time)) + 1)
	var/x_diff = clamp(amplitude * sin(amount * time), -32, 32)
	var/y_diff = clamp(amplitude * cos(amount * time), -32, 32)
	pixel_x_diff += x_diff
	pixel_y_diff += y_diff
	// Brief explanation. We're basically snapping between different pixel_x/ys instantly, with delays between
	// Doing this with relative changes. This way we don't override any existing pixel_x/y values
	// We use EASE_OUT here for similar reasons, we want to act at the end of the delay, not at its start
	// Relative animations are weird, so we do actually need this
	animate(owner.client, pixel_x = x_diff, pixel_y = y_diff, 3, easing = JUMP_EASING | EASE_OUT, flags = ANIMATION_RELATIVE, tag = CLIENT_CAMERA_ANIMATION)
	delay += 0.3 SECONDS // This counts as a 0.3 second wait, so we need to shift the sine wave by that much

	x_diff = clamp(amplitude * sin(next_amount * (time + delay)), -32, 32)
	y_diff = clamp(amplitude * cos(next_amount * (time + delay)), -32, 32)
	pixel_x_diff += x_diff
	pixel_y_diff += y_diff
	animate(pixel_x = x_diff, pixel_y = y_diff, 3, easing = JUMP_EASING | EASE_OUT, flags = ANIMATION_RELATIVE)

	// Now we reset back to our old pixel_x/y, since these animates are relative
	animate(pixel_x = -pixel_x_diff, pixel_y = -pixel_y_diff, 3, easing = JUMP_EASING | EASE_OUT, flags = ANIMATION_RELATIVE)
