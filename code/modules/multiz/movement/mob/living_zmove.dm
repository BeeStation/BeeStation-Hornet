#define MOVETYPE_NONE_JUMP -1
#define MOVETYPE_NONE 0
#define MOVETYPE_CLIMB 1
#define MOVETYPE_FLY 2
#define MOVETYPE_JETPACK 3
#define MOVETYPE_FLOAT 4
#define MOVETYPE_JAUNT 5

/// If we are currently attempting to move up or down
/mob/living/var/zmoving = FALSE

/// Returns a movement type that is allowed, given a source and target turf.
/// pre_move controls if things like fuel are consumed for jetpacks.
/mob/living/canZMove(dir, turf/source, turf/target, pre_move = TRUE)
	if(incapacitated(check_immobilized = TRUE) || resting || zmoving || IsKnockdown())
		return MOVETYPE_NONE
	if(incorporeal_move || (movement_type & PHASING))
		return MOVETYPE_JAUNT
	var/upwards = dir == UP
	if(((upwards && !target.allow_z_travel) || (!upwards && !source.allow_z_travel)))
		return MOVETYPE_NONE
	var/can_climb = FALSE // turf_can_climb(upwards ? target : source)
	if(!can_zTravel(target, dir) && !can_climb) // forwards to turf's zPassIn and zPassOut
		return MOVETYPE_NONE
	if(!has_gravity(source))
		return MOVETYPE_FLOAT
	else if(movement_type & FLYING)
		return MOVETYPE_FLY
	else if(has_jetpack_power(TRUE, THRUST_REQUIREMENT_GRAVITY * (upwards ? 2 : 0.5), require_stabilization = FALSE, use_fuel = !pre_move))
		return MOVETYPE_JETPACK
	else if(can_climb)
		return MOVETYPE_CLIMB
	return upwards ? MOVETYPE_NONE_JUMP : MOVETYPE_NONE

/// Attempts a zMove up or down, provides feedback if unable to do so.
/mob/living/zMove(dir, feedback = FALSE, feedback_to = src)
	if((dir != UP && dir != DOWN) || zmoving)
		return FALSE
	if(remote_control)
		remote_control.relaymove(src, dir)
		return
	var/turf/source = get_turf(src)
	var/turf/target = get_step_multiz(src, dir)
	if(!target)
		if(feedback)
			to_chat(feedback_to, "<span class='warning'>There is nothing in that direction!</span>")
		return FALSE
	if(istype(loc, /obj/effect/dummy/phased_mob)) // I despise this
		var/obj/effect/dummy/phased_mob/L = loc
		L.relaymove(src, dir)
		return
	if(istype(buckled))
		buckled.relaymove(src, dir)
		return
	var/move_verb = "floating"
	var/delay = 1 SECONDS
	var/upwards = dir == UP
	var/move_type = canZMove(dir, source, target)
	switch(move_type)
		if(MOVETYPE_NONE)
			if(feedback)
				to_chat(feedback_to, "<span class='warning'>Something is blocking you!</span>")
			return FALSE
		if(MOVETYPE_NONE_JUMP)
			visible_message("<span class='warning'>[src] jumps into the air, as if [p_they()] expected to float... Gravity pulls [p_them()] back down quickly.</span>", "<span class='warning'>You try jumping into the space above you. Gravity pulls you back down quickly.</span>")
			do_jump_animation()
			return FALSE
		if(MOVETYPE_JAUNT)
			move_verb = "moving"
			delay = 0.5 SECONDS
		if(MOVETYPE_CLIMB)
			move_verb = "climbing"
			delay = upwards ? 3 SECONDS : 1 SECONDS
		if(MOVETYPE_FLY)
			move_verb = "flying"
			delay = upwards ? 2 SECONDS : 1 SECONDS
		if(MOVETYPE_JETPACK)
			move_verb = "jetpacking"
			delay = 1 SECONDS
		if(MOVETYPE_FLOAT)
			move_verb = "floating"
			delay = 1 SECONDS
		else
			move_verb = "(unknown move type, call a coder!) moving"
	return start_travel_z(src, upwards, move_verb, delay, allow_movement = (move_type != MOVETYPE_CLIMB))

/// Actually starts a zMove, doing movement animations
/mob/living/proc/start_travel_z(mob/user, upwards = TRUE, move_verb = "floating", delay = 3 SECONDS, allow_movement = TRUE)
	user.visible_message("<span class='notice'>[user] begins [move_verb] [upwards ? "upwards" : "downwards"]!</span>", "<span class='notice'>You begin [move_verb] [upwards ? "upwards" : "downwards"].")
	animate(user, delay, pixel_y = upwards ? 32 : -32, transform = matrix() * 0.8)
	var/list/bucklemobs_c = user.buckled_mobs?.Copy()
	for(var/mob/M in bucklemobs_c)
		animate(M, delay, pixel_y = upwards ? 32 : -32, transform = matrix() * 0.8)
	zmoving = TRUE
	if(!allow_movement)
		if(!do_after(user, delay, get_turf(user), timed_action_flags = IGNORE_HELD_ITEM))
			zmoving = FALSE
			animate(user, 0, flags = ANIMATION_END_NOW)
			user.pixel_y = 0
			user.transform = matrix()
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.reset_lying_transform()
			for(var/mob/M in bucklemobs_c)
				animate(M, 0, flags = ANIMATION_END_NOW)
				M.pixel_y = 0
				M.transform = matrix()
				if(iscarbon(M))
					var/mob/living/carbon/C = M
					C.reset_lying_transform()
			return
		zmoving = FALSE
		continue_travel_z(user, upwards ? UP : DOWN, bucklemobs_c)
		return
	addtimer(CALLBACK(src, PROC_REF(continue_travel_z), user, upwards ? UP : DOWN, bucklemobs_c), delay)

/// Cleans up animations and then calls travel_z, which actually does the movement, and consumes fuel and such.area
/// Checks if you are still able to zmove after the animation.
/mob/living/proc/continue_travel_z(mob/user, dir, bucklemobs_c)
	zmoving = FALSE
	// reset animations
	user.pixel_y = 0
	user.transform = matrix()
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.reset_lying_transform()
	for(var/mob/M in bucklemobs_c)
		M.pixel_y = 0
		M.transform = matrix()
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			C.reset_lying_transform()
	var/turf/source = get_turf(user)
	var/turf/target = get_step_multiz(source, dir)
	if(user.canZMove(dir, source, target, pre_move = FALSE)) // actually use fuel this time
		source.travel_z(user, target, dir) // Move
	else
		balloon_alert(user, "movement was blocked")

/// Offsets the mob up and then quickly has them fall back down, like a jump.
/mob/proc/do_jump_animation()
	set waitfor = 0
	animate(src, 0.3 SECONDS, pixel_y = 16, transform = matrix() * 0.9, easing = QUAD_EASING)
	sleep(0.3 SECONDS)
	animate(src, 0.1 SECONDS, pixel_y = 0, transform = matrix(), easing = QUAD_EASING)

/mob/living/carbon/do_jump_animation()
	..()
	reset_lying_transform()

/mob/living/carbon/proc/reset_lying_transform()
	var/lying_prev_temp = lying_prev
	lying_prev = 0
	update_transform()
	lying_prev = lying_prev_temp

#undef MOVETYPE_NONE
#undef MOVETYPE_CLIMB
#undef MOVETYPE_FLY
#undef MOVETYPE_JETPACK
#undef MOVETYPE_FLOAT
#undef MOVETYPE_JAUNT
