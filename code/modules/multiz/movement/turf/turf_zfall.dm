/// Attempts a landing on this turf, or continues the zFall if there is no interception
/// Grants an opportunity for atoms on this turf to intercept the fall, such as catwalks
/// If the zFall ends on this turf, do_z_impact is called
/turf/proc/attempt_z_impact(atom/movable/A, levels = 1, turf/prev_turf)
	var/flags = NONE
	for(var/i in contents)
		var/atom/thing = i
		flags |= thing.intercept_zImpact(A, levels)
		if(flags & FALL_STOP_INTERCEPTING)
			break
	if(prev_turf && !(flags & FALL_NO_MESSAGE))
		prev_turf.visible_message(span_danger("[A] falls through [prev_turf]!"))
	if(flags & FALL_INTERCEPTED)
		return FALSE
	if(zFall(A, levels + 1, from_zfall = TRUE))
		return FALSE
	do_z_impact(A, levels)
	return TRUE

/// Displays a message for the impact, and then forwards the impact to the atom
/turf/proc/do_z_impact(atom/movable/A, levels)
	// You can "crash into" openspace above zero gravity, but it looks weird to say that
	if(!isopenspace(src))
		A.visible_message(span_danger("[A] crashes into [src]!"))
	A.onZImpact(src, levels)

/// returns if an atom is allowed to zfall through this turf, using zPassOut and zPassIn
/turf/proc/can_zFall(atom/movable/A, turf/target)
	return zPassOut(DOWN, falling = TRUE) && target.zPassIn(DOWN, falling = TRUE) && (!istype(target, /turf/open/space) || A.has_gravity(target))

/// Determines if an atom should start zfalling or continue zfalling from the current point
/// Basically if this turf is "fall"able
/// from_zfall being true means that at least one level has been fell through already.
/turf/proc/can_start_zFall(atom/movable/A, turf/target, force = FALSE, from_zfall = FALSE)
	if(!from_zfall && A.zfalling) // We don't want to trigger another zfall
		return FALSE
	if(!target || (!isobj(A) && !ismob(A)))
		return FALSE
	if(!force && (!can_zFall(A, target) || !A.can_zFall(src, target, DOWN)))
		return FALSE
	return TRUE

/// A non-waiting proc that calls zFall()
/turf/proc/try_start_zFall(atom/movable/A, levels = 1, force = FALSE, old_loc = null)
	set waitfor = FALSE
	zFall(A, levels, force, old_loc, FALSE)

/// Checks if we can start a zfall and then performs the zfall
/// This function is recursive via zFall_Move -> attempt_z_impact -> zFall
/turf/proc/zFall(atom/movable/A, levels = 1, force = FALSE, old_loc = null, from_zfall = FALSE)
	var/direction = DOWN
	if(A.has_gravity() == NEGATIVE_GRAVITY)
		direction = UP
	var/turf/target = get_step_multiz(src, direction)
	if(!can_start_zFall(A, target, force, from_zfall))
		return FALSE
	if(from_zfall) // if this is a >1 level fall
		addtimer(CALLBACK(src, PROC_REF(zFall_Finish), A, levels, force, old_loc, from_zfall), 0.2 SECONDS) // This is the delay between falling zlevels. Otherwise zfalls would be instant to the client, which does not look great.
		return TRUE
	else
		return zFall_Move(A, levels, old_loc, target)


/turf/proc/zFall_Finish(atom/movable/A, levels = 1, force = FALSE, old_loc = null, from_zfall = FALSE)
	var/turf/new_turf = get_turf(A) // make sure we didn't move onto a solid turf, if we did this will perform a zimpact via the caller
	var/turf/target = get_step_multiz(new_turf, DOWN)
	if(!new_turf.can_start_zFall(A, target, force, from_zfall))
		new_turf.do_z_impact(A, levels - 1)
		return TRUE // skip parent zimpact - do a zimpact on new turf, the turf below us is solid
	else if(new_turf != src) // our fall continues... no need to check can_start_zFall again, because we just checked it
		new_turf.zFall_Move(A, levels, old_loc, target)
		return TRUE // don't do an impact from the parent caller. essentially terminating the old fall with no actions

	//Duplicating from parent
	return zFall_Move(A, levels, old_loc, target)


/// Actually performs the zfall movement, regardless of if you can fall or not
/// Pulls any pulls objects onto old turf, if anything is pulling the atom, it's removed
/// Then attempts actually impacting the new turf, but this could continue the zFall loop.
/turf/proc/zFall_Move(atom/movable/A, levels = 1, old_loc = null, turf/target)
	A.zfalling = TRUE
	if(A.pulling && old_loc) // Moves whatever we're pulling to where we were before so we're still adjacent
		A.pulling.moving_from_pull = A
		A.pulling.Move(old_loc)
		A.pulling.moving_from_pull = null
	if(A.pulledby) // Prevents dragging stuff while on another z-level
		A.pulledby.stop_pulling()
	if(!A.Move(target))
		A.doMove(target)
	// Returns false if we continue falling - which calls zfall again
	// which calls attempt_z_impact (which returns true) if it impacts
	// basically, check if we should hit the ground, otherwise call zFall again.
	. = target.attempt_z_impact(A, levels, src)
	A.zfalling = FALSE
