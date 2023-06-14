/datum/component/waddling
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

/datum/component/waddling/Initialize()
	. = ..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	if(isliving(parent))
		RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), PROC_REF(LivingWaddle))
	else
		RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), PROC_REF(Waddle))

/datum/component/waddling/proc/LivingWaddle()
	SIGNAL_HANDLER

	var/mob/living/L = parent
	if(L.incapacitated() || !(L.mobility_flags & MOBILITY_STAND))
		return
	Waddle()

/datum/component/waddling/proc/Waddle()
	SIGNAL_HANDLER

	var/rot_degrees = pick(-12, 0, 12)
	var/atom/movable/AM = parent
	animate(AM, pixel_z = 4, time = 0)
	animate(pixel_z = 0, transform = turn(AM.transform, rot_degrees), time=2)
	animate(pixel_z = 0, transform = turn(AM.transform, -rot_degrees), time = 0)
