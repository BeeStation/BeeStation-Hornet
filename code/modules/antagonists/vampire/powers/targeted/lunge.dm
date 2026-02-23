#define LUNGE_TIME 3 SECONDS

/datum/action/vampire/targeted/lunge
	name = "Predatory Lunge"
	desc = "Spring at your target to grapple them without warning, or tear the dead's heart out. Attacks from concealment or the rear may even knock them down if strong enough."
	button_icon_state = "power_lunge"
	power_explanation = "Click any player to start spinning wildly and, after a short delay, lunge at them.\n\
		When lunging at someone, you will aggressively grab them, unless they are a curator.\n\
		You cannot lunge if you are already grabbing someone, or are being grabbed.\n\
		If you grab from behind or darkness, you will knock the target down, scaling with your rank.\n\
		If used on a dead body, you will tear their organs out.\n\
		At level 4, you will instantly lunge, but are limited to tackling from only 6 tiles away."
	power_flags = NONE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = VAMPIRE_CAN_BUY | VASSAL_CAN_BUY
	bloodcost = 10
	cooldown_time = 10 SECONDS
	power_activates_immediately = FALSE

/datum/action/vampire/targeted/lunge/upgrade_power()
	. = ..()
	//range is lowered when you get stronger.
	if(level_current > 3)
		target_range = 6

/datum/action/vampire/targeted/lunge/can_use()
	. = ..()
	if(!.)
		return FALSE

	if(owner.pulledby && owner.pulledby.grab_state >= GRAB_AGGRESSIVE)
		owner.balloon_alert(owner, "grabbed!")
		return FALSE
	if(owner.pulling)
		owner.balloon_alert(owner, "grabbing someone!")
		return FALSE
	if(datum_flags & DF_ISPROCESSING)
		owner.balloon_alert(owner, "already lunging!")
		return FALSE
	return TRUE

/// Check: Are we lunging at a person?
/datum/action/vampire/targeted/lunge/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	// Has to be alive
	if(!isliving(target_atom))
		return FALSE
	// Has to be on a turf
	if(!isturf(target_atom.loc))
		return FALSE
	// Has to be mobile
	var/mob/living/user = owner
	if(user.body_position == LYING_DOWN || HAS_TRAIT(owner, TRAIT_IMMOBILIZED))
		return FALSE

/datum/action/vampire/targeted/lunge/FireTargetedPower(atom/target_atom)
	. = ..()
	owner.face_atom(target_atom)
	if(level_current > 3)
		do_lunge(target_atom)
		return TRUE

	prepare_target_lunge(target_atom)
	return TRUE

///Starts processing the power and prepares the lunge by spinning, calls lunge at the end of it.
/datum/action/vampire/targeted/lunge/proc/prepare_target_lunge(atom/target_atom)
	START_PROCESSING(SSprocessing, src)
	owner.balloon_alert(owner, "lunge started!")

	// Spin
	owner.spin(8, 1)
	owner.balloon_alert_to_viewers("spins wildly!", "you spin!")
	// Smoke
	do_smoke(0, owner.loc, smoke_type = /obj/effect/particle_effect/smoke/transparent)
	//animate them shake
	var/base_x = owner.base_pixel_x
	var/base_y = owner.base_pixel_y
	animate(owner, pixel_x = base_x, pixel_y = base_y, time = 1, loop = -1)
	for(var/i in 1 to 25)
		var/x_offset = base_x + rand(-3, 3)
		var/y_offset = base_y + rand(-3, 3)
		animate(pixel_x = x_offset, pixel_y = y_offset, time = 1)

	// Actually lunge now
	if(!do_after(owner, LUNGE_TIME, timed_action_flags = (IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE), extra_checks = CALLBACK(src, PROC_REF(check_valid_target), target_atom)))
		end_target_lunge(base_x, base_y)
		return FALSE

	end_target_lunge()
	do_lunge(target_atom)
	return TRUE

///When preparing to lunge ends, this clears it up.
/datum/action/vampire/targeted/lunge/proc/end_target_lunge(base_x, base_y)
	animate(owner, pixel_x = base_x, pixel_y = base_y, time = 1)
	STOP_PROCESSING(SSprocessing, src)

/datum/action/vampire/targeted/lunge/process()
	if(!power_in_use) //If running SSfasprocess (on cooldown)
		return ..() //Manage our cooldown timers

///Actually lunges the target, then calls lunge end.
/datum/action/vampire/targeted/lunge/proc/do_lunge(atom/hit_atom)
	var/turf/targeted_turf = get_turf(hit_atom)

	var/safety = get_dist(owner, targeted_turf) * 3 + 1
	var/consequetive_failures = 0
	while(--safety && !hit_atom.Adjacent(owner))
		if(!step_to(owner, targeted_turf))
			consequetive_failures++
		if(consequetive_failures >= 3) // If 3 steps don't work, just stop.
			break

	lunge_end(hit_atom, targeted_turf)

/datum/action/vampire/targeted/lunge/proc/lunge_end(atom/hit_atom, turf/target_turf)
	power_activated_sucessfully()
	// Am I next to my target to start giving the effects?
	if(!owner.Adjacent(hit_atom))
		return

	var/mob/living/user = owner
	var/mob/living/carbon/target = hit_atom

	// Did I slip or get knocked unconscious?
	if(user.body_position != STANDING_UP || user.incapacitated)
		var/send_dir = get_dir(user, target_turf)
		new /datum/forced_movement(user, get_ranged_target_turf(user, send_dir, 1), 1, FALSE)
		user.spin(10)
		return

	if(IS_CURATOR(target) || target.is_shove_knockdown_blocked())
		owner.balloon_alert(owner, "pushed away!")
		target.grabbedby(owner)
		return

	owner.balloon_alert(owner, "you lunge at [target]!")
	if(target.stat == DEAD)
		playsound(get_turf(target), 'sound/effects/splat.ogg', 40, TRUE)
		owner.visible_message(
			span_warning("[owner] tears into [target]'s chest!"),
			span_warning("You tear into [target]'s chest!"),
		)
		var/obj/item/bodypart/chest/chest = target.get_bodypart(BODY_ZONE_CHEST)
		chest.dismember()
	else
		target.grabbedby(owner)
		target.grippedby(owner, instant = TRUE)
		// Did we knock them down?
		if(!is_source_facing_target(target, owner) || owner.alpha <= 40)
			target.Knockdown(10 + level_current * 5)
			target.Paralyze(0.1)

#undef LUNGE_TIME
