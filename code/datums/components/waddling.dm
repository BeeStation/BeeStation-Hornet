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

	var/prev_trans = matrix(target.transform)
	var/waddle_trans = turn(target.transform, pick(-12, 0, 12))
	var/rest_z = target.get_screen_base_pixel_z()
	if(isliving(target))
		var/mob/living/living = target
		rest_z += living.has_offset(pixel = PIXEL_Z_OFFSET)
	for(var/atom/movable/waddler as anything in target.get_associated_mimics() + target)
		animate(waddler, pixel_z = rest_z + 4, time = 0)
		animate(pixel_z = rest_z, transform = waddle_trans, time = 0.2 SECONDS)
		animate(pixel_z = rest_z, transform = prev_trans, time = 0)
