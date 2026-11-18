/datum/element/waddling

/datum/element/waddling/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	if(isliving(target))
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(living_waddle))
	else
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(waddle))

/datum/element/waddling/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)

/datum/element/waddling/proc/living_waddle(mob/living/target, atom/oldloc, direction, forced)
	SIGNAL_HANDLER

	if(forced || target.incapacitated || target.body_position == LYING_DOWN || CHECK_MOVE_LOOP_FLAGS(target, MOVEMENT_LOOP_OUTSIDE_CONTROL))
		return
	waddling_animation(target)

/datum/element/waddling/proc/waddle(atom/movable/target, atom/oldloc, direction, forced)
	SIGNAL_HANDLER

	if(forced || CHECK_MOVE_LOOP_FLAGS(target, MOVEMENT_LOOP_OUTSIDE_CONTROL))
		return
	waddling_animation(target)

/datum/element/waddling/proc/waddling_animation(atom/movable/target)
	var/matrix/prev_trans = matrix(target.transform)
	var/matrix/waddle_trans = turn(target.transform, pick(-12, 0, 12))
	for(var/atom/movable/waddler as anything in target.get_associated_mimics() + target)
		animate(waddler, pixel_y = 4, time = 0)
		animate(pixel_y = 0, transform = waddle_trans, time = 0.2 SECONDS)
		animate(pixel_y = 0, transform = prev_trans, time = 0)
