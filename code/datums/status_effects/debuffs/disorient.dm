/datum/status_effect/incapacitating/disoriented
	id = "disoriented"
	tick_interval = 1 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/disoriented

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
	if(HAS_TRAIT(owner, TRAIT_IMMOBILIZED))
		return
	owner.twitch()
	playsound(owner, 'sound/effects/electric_shock_short.ogg', 35, TRUE, 0.5, 1.5)

/atom/movable/screen/alert/status_effect/disoriented
	name = "Disoriented"
	desc = "You've been hit by a stun weapon. You're slower and stumbling, and if you're exhausted the next hit will put you on the floor."
	icon_state = "stun"

///Shakes the mob wildly for a moment.
/mob/living/proc/twitch()
	set waitfor = FALSE
	var/degrees = rand(-45,45)
	transform = transform.Turn(degrees)
	add_offsets(TWITCH_TRAIT, x_add = rand(-3,3), y_add = rand(-1,1), animate = FALSE)

	sleep(0.2 SECONDS)

	transform = transform.Turn(-degrees)
	remove_offsets(TWITCH_TRAIT, animate = FALSE)
