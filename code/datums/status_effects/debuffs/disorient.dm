/datum/status_effect/incapacitating/disoriented
	id = "disoriented"
	tick_interval = 1 SECONDS
	var/last_twitch = 0

/datum/status_effect/incapacitating/disoriented/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_DISORIENTED, TRAIT_STATUS_EFFECT(id))
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/disorient)

/datum/status_effect/incapacitating/disoriented/on_remove()
	REMOVE_TRAIT(owner, TRAIT_DISORIENTED, TRAIT_STATUS_EFFECT(id))
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/disorient)
	return ..()

/datum/status_effect/incapacitating/disoriented/tick()
	if(last_twitch < world.time + 7 && (!HAS_TRAIT(owner, TRAIT_IMMOBILIZED)))
		INVOKE_ASYNC(owner, TYPE_PROC_REF(/atom/movable, twitch))
		playsound(owner, 'sound/effects/electric_shock_short.ogg', 35, TRUE, 0.5, 1.5)
		last_twitch = world.time

///An animation for the object shaking wildly.
/atom/movable/proc/twitch()
	var/degrees = rand(-45,45)
	transform = transform.Turn(degrees)
	var/old_x = pixel_x
	var/old_y = pixel_y
	pixel_x += rand(-3,3)
	pixel_y += rand(-1,1)

	sleep(0.2 SECONDS)

	transform = transform.Turn(-degrees)
	pixel_x = old_x
	pixel_y = old_y
