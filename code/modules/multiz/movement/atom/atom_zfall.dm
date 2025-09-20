/// If the object is currently in the process of zfalling
/atom/movable/var/zfalling = FALSE

/// Determines if this atom is able to zfall
/atom/movable/proc/can_zFall(turf/source, turf/target, direction)
	if(!direction)
		direction = DOWN
	if(!source)
		source = get_turf(src)
		if(!source)
			return FALSE
	if(!target)
		target = get_step_multiz(source, direction)
		if(!target)
			return FALSE
	return !(movement_type & (FLYING|FLOATING)) && has_gravity(src) && !throwing

/// Returns a set of flags, determining what the zfall system will consider this atom in its falling handling
/atom/proc/intercept_zImpact(atom/movable/AM, levels = 1)
	. |= SEND_SIGNAL(src, COMSIG_ATOM_INTERCEPT_Z_FALL, AM, levels)

/// Handles this atom landing on a turf from a zfall
/atom/movable/proc/onZImpact(turf/T, levels)
	SHOULD_CALL_PARENT(TRUE)
	var/atom/highest = null
	for(var/i in T.contents)
		var/atom/A = i
		if(!A.density)
			continue
		if(isobj(A) || ismob(A))
			if(!highest || A.layer > highest.layer)
				highest = A
	INVOKE_ASYNC(src, PROC_REF(SpinAnimation), 5, 2)
	//Signal for unique behavior for objects falling
	SEND_SIGNAL(src, COMSIG_ATOM_ON_Z_IMPACT, T, levels)
	if(highest)
		throw_impact(highest, new /datum/thrownthing(src, highest, DOWN, levels, min(5, levels), null, FALSE, MOVE_FORCE_STRONG, null, BODY_ZONE_HEAD))
	return TRUE
