#define LOOKING_DIRECTION_UP 1
#define LOOKING_DIRECTION_NONE 0
#define LOOKING_DIRECTION_DOWN -1

/// The current direction the player is ACTUALLY looking, regardless of intent.
/mob/living/var/looking_direction = LOOKING_DIRECTION_NONE
/// The current direction the player is trying to look.
/mob/living/var/attempt_looking_direction = LOOKING_DIRECTION_NONE

///Checks if the user is incapacitated and cannot look up/down
/mob/living/proc/can_look_direction()
	return !(incapacitated(IGNORE_RESTRAINTS))

/// Tell the mob to attempt to look this direction until it's set back to NONE
/mob/living/proc/set_attempted_looking_direction(direction)
	if(attempt_looking_direction == direction && direction != LOOKING_DIRECTION_NONE) // we are already trying to look this way, reset
		set_attempted_looking_direction(LOOKING_DIRECTION_NONE)
		return
	attempt_looking_direction = direction
	set_look_direction(attempt_looking_direction)

/// Actually sets the looking direction, but it won't try to stay that way if we move out of range
/mob/living/proc/set_look_direction(direction, automatic = FALSE)
	// Handle none/failure
	if(direction == LOOKING_DIRECTION_NONE || !can_look_direction(direction))
		looking_direction = LOOKING_DIRECTION_NONE
		reset_perspective()
		return
	// Automatic attempts should not trigger the cooldown
	if(!automatic)
		changeNext_move(CLICK_CD_LOOK_DIRECTION)
	looking_direction = direction
	var/look_str = direction == LOOKING_DIRECTION_UP ? "up" : "down"
	if(update_looking_move(automatic))
		visible_message(span_notice("[src] looks [look_str]."), span_notice("You look [look_str]."))

/// Called by /mob/living/Moved(), checks if we can continue looking
/mob/living/proc/update_looking_move(automatic = FALSE)
	// Try looking the attempted direction now that we've moved
	if(attempt_looking_direction != LOOKING_DIRECTION_NONE && looking_direction == LOOKING_DIRECTION_NONE)
		set_look_direction(attempt_looking_direction, automatic = TRUE) // this won't loop recursively because looking_direction cannot be NONE above
	// We can't try looking nowhere!
	if(looking_direction == LOOKING_DIRECTION_NONE)
		return FALSE
	// Something changed, stop looking
	if(!can_look_direction(looking_direction))
		set_look_direction(LOOKING_DIRECTION_NONE)
	// Update perspective
	var/turf/base = find_visible_hole_in_direction(looking_direction)
	if(!isturf(base))
		if(!automatic)
			to_chat(src, span_warning("You can't see through the [looking_direction == LOOKING_DIRECTION_UP ? "ceiling above" : "floor below"] you."))
		set_look_direction(LOOKING_DIRECTION_NONE)
		return FALSE
	reset_perspective(base)
	return TRUE

/mob/living/verb/look_up_short()
	set name = "Look Up"
	set category = "IC"
	// you pressed the verb while holding a keybind, unlock!
	attempt_looking_direction = LOOKING_DIRECTION_NONE
	if(looking_direction == LOOKING_DIRECTION_UP)
		set_look_direction(LOOKING_DIRECTION_NONE)
		return
	look_up()

/**
 * look_up Changes the perspective of the mob to any openspace turf above the mob
 * lock: If it should continue to try looking even if there is no seethrough turf
 */
/mob/living/proc/look_up(lock = FALSE)
	if(lock)
		set_attempted_looking_direction(LOOKING_DIRECTION_UP)
	else
		set_look_direction(LOOKING_DIRECTION_UP)

/mob/living/verb/look_down_short()
	set name = "Look Down"
	set category = "IC"
	// you pressed the verb while holding a keybind, unlock!
	attempt_looking_direction = LOOKING_DIRECTION_NONE
	if(looking_direction == LOOKING_DIRECTION_DOWN)
		set_look_direction(LOOKING_DIRECTION_NONE)
		return
	look_down()

/**
 * look_down Changes the perspective of the mob to any openspace turf below the mob
 * lock: If it should continue to try looking even if there is no seethrough turf
 */
/mob/living/proc/look_down(lock = FALSE)
	if(lock)
		set_attempted_looking_direction(LOOKING_DIRECTION_DOWN)
	else
		set_look_direction(LOOKING_DIRECTION_DOWN)

/// Helper, resets from looking up or down, and unlocks the view.
/mob/living/proc/look_reset()
	set_attempted_looking_direction(LOOKING_DIRECTION_NONE)

/mob/living/proc/find_visible_hole_in_direction(direction)
	// Our current z-level turf
	var/turf/turf_base = get_turf(src)
	// The target z-level turf
	var/turf/turf_other = get_step_multiz(turf_base, direction == LOOKING_DIRECTION_UP ? UP : DOWN)
	if(!turf_other) // There is nothing above/below
		return FALSE
	// This turf is the one we are looking through
	var/turf/seethrough_turf = direction == LOOKING_DIRECTION_UP ? turf_other : turf_base
	// The turf we should end up looking at.
	var/turf/end_turf = turf_other
	if(istransparentturf(seethrough_turf)) //There is no turf we can look through directly above/below us, look for nearby turfs
		return end_turf
	// Turf in front of you to try to look through before anything else
	var/turf/seethrough_turf_front = get_step(seethrough_turf, dir)
	if(istransparentturf(seethrough_turf_front))
		return direction == LOOKING_DIRECTION_UP ? seethrough_turf_front : get_step_multiz(seethrough_turf_front, DOWN)
	var/target_z = direction == LOOKING_DIRECTION_UP ? turf_other.z : z
	var/list/checkturfs = block(locate(x-1,y-1,target_z),locate(x+1,y+1,target_z))-turf_base-turf_other
	for(var/turf/checkhole in checkturfs)
		if(istransparentturf(checkhole))
			seethrough_turf = checkhole
			end_turf = direction == LOOKING_DIRECTION_UP ? checkhole : get_step_multiz(checkhole, DOWN)
			break
	if(!istransparentturf(seethrough_turf))
		return FALSE
	return end_turf

#undef LOOKING_DIRECTION_UP
#undef LOOKING_DIRECTION_NONE
#undef LOOKING_DIRECTION_DOWN
