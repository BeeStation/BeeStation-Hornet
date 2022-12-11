/mob/living/Moved()
	. = ..()
	update_turf_movespeed(loc)
	update_looking_move()

/mob/living/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(.)
		return
	if(mover.throwing)
		return (!density || !(mobility_flags & MOBILITY_STAND) || (mover.throwing.thrower == src && !ismob(mover)))
	if(buckled == mover)
		return TRUE
	if(ismob(mover) && (mover in buckled_mobs))
		return TRUE
	return !mover.density || !(mobility_flags & MOBILITY_STAND)

/mob/living/toggle_move_intent()
	. = ..()
	update_move_intent_slowdown()

/mob/living/update_config_movespeed()
	update_move_intent_slowdown()
	return ..()

/mob/living/proc/update_move_intent_slowdown()
	var/mod = 0
	if(m_intent == MOVE_INTENT_WALK)
		mod = CONFIG_GET(number/movedelay/walk_delay)
	else
		mod = CONFIG_GET(number/movedelay/run_delay)
	if(!isnum_safe(mod))
		mod = 1
	add_movespeed_modifier(MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED, TRUE, 100, override = TRUE, multiplicative_slowdown = mod)

/mob/living/proc/update_turf_movespeed(turf/open/T)
	if(isopenturf(T))
		add_movespeed_modifier(MOVESPEED_ID_LIVING_TURF_SPEEDMOD, update=TRUE, priority=100, override=TRUE, multiplicative_slowdown=T.slowdown, movetypes=GROUND)
	else
		remove_movespeed_modifier(MOVESPEED_ID_LIVING_TURF_SPEEDMOD)

/mob/living/proc/update_pull_movespeed()
	if(pulling)
		if(isliving(pulling))
			var/mob/living/L = pulling
			if(!slowed_by_drag || (L.mobility_flags & MOBILITY_STAND) || L.buckled || grab_state >= GRAB_AGGRESSIVE)
				remove_movespeed_modifier(MOVESPEED_ID_BULKY_DRAGGING)
				return
			add_movespeed_modifier(MOVESPEED_ID_BULKY_DRAGGING, multiplicative_slowdown = PULL_PRONE_SLOWDOWN)
			return
		if(isobj(pulling))
			var/obj/structure/S = pulling
			if(!slowed_by_drag || !S.drag_slowdown)
				remove_movespeed_modifier(MOVESPEED_ID_BULKY_DRAGGING)
				return
			add_movespeed_modifier(MOVESPEED_ID_BULKY_DRAGGING, multiplicative_slowdown = S.drag_slowdown)
			return
	remove_movespeed_modifier(MOVESPEED_ID_BULKY_DRAGGING)

/mob/living/canZMove(dir, turf/target)
	return can_zTravel(target, dir)

/mob/living/zMove(dir, feedback = FALSE)
	if(dir != UP && dir != DOWN)
		return FALSE
	var/turf/source = get_turf(src)
	var/turf/target = get_step_multiz(src, dir)
	if(!target)
		to_chat(src, "<span class='warning'>There is nothing in that direction!</span>")
		return FALSE
	var/upwards = dir == UP
	var/move_verb = "floating"
	var/delay = 1 SECONDS
	if(istype(loc, /obj/effect/dummy/phased_mob)) // I despise this
		var/obj/effect/dummy/phased_mob/L = loc
		L.relaymove(src, dir)
		return
	if(incorporeal_move || (movement_type & PHASING))
		move_verb = "moving"
	else
		//Check if we can travel in that direction
		if(((upwards && !target.allow_z_travel) || (!upwards && !source.allow_z_travel)))
			to_chat(src, "<span class='warning'>Something is blocking you!</span>")
			return
		var/can_climb = turf_can_climb(upwards ? target : source)
		if(!canZMove(dir, target) && !can_climb)
			to_chat(src, "<span class='warning'>Something is blocking you!</span>")
			return FALSE
		if(has_gravity(source))
			move_verb = "flying"
			if(upwards)
				// If there's gravity and the space above is not climbable, don't travel
				if(!(movement_type & FLYING) && !can_climb)
					if(has_jetpack_power(TRUE, THRUST_REQUIREMENT_GRAVITY * 2, require_stabilization = FALSE))
						move_verb = "jetpacking"
						delay = 1 SECONDS
					else
						visible_message("<span class='warning'>[src] jumps into the air, as if [p_they()] expected to float... Gravity pulls [p_them()] back down quickly.</span>", "<span class='warning'>You try jumping into the space above you. Gravity pulls you back down quickly.</span>")
						return
				else if(can_climb)
					move_verb = "climbing"
				delay = 3 SECONDS
			else if(can_climb)
				move_verb = "climbing"
			else if(!(movement_type & FLYING) && has_jetpack_power(TRUE, THRUST_REQUIREMENT_GRAVITY * 0.5, require_stabilization = FALSE))
				move_verb = "jetpacking"
				delay = 1 SECONDS
	return source.travel_z(src, target, upwards, move_verb, delay)
