/datum/component/waddling
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

/datum/component/waddling/Initialize()
	. = ..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	if(isliving(parent))
		RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(LivingWaddle))
	else
		RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(Waddle))

/datum/component/waddling/proc/LivingWaddle()
	SIGNAL_HANDLER

	if(isliving(parent))
		var/mob/living/L = parent
		if(L.incapacitated || L.body_position == LYING_DOWN)
			return
	Waddle()

/datum/component/waddling/proc/Waddle()
	SIGNAL_HANDLER

	if(!isatom(parent))
		return

	var/atom/movable/target = parent

	animate(target, pixel_z = 4, time = 0)
	var/prev_trans = matrix(target.transform)
	animate(pixel_z = 0, transform = turn(target.transform, pick(-12, 0, 12)), time=2)
	animate(pixel_z = 0, transform = prev_trans, time = 0)
