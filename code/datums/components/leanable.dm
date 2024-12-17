/// Things with this component can be leaned onto, optionally exclusive to RMB dragging
/datum/component/leanable
	/// How much will mobs that lean onto this object be offset
	var/leaning_offset = 11
	/// List of mobs currently leaning on our parent
	var/list/leaning_mobs = list()

/datum/component/leanable/Initialize(mob/living/leaner, leaning_offset = 11)
	. = ..()
	src.leaning_offset = leaning_offset
	mousedrop_receive(parent, leaner, leaner)

/datum/component/leanable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOUSEDROPPED_ONTO, PROC_REF(mousedrop_receive))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/datum/component/leanable/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOUSEDROPPED_ONTO, COMSIG_MOVABLE_MOVED))

/datum/component/leanable/Destroy(force)
	for (var/mob/living/leaner as anything in leaning_mobs)
		leaner.stop_leaning()
	leaning_mobs = null
	return ..()

/datum/component/leanable/proc/on_moved(datum/source)
	SIGNAL_HANDLER

	for (var/mob/living/leaner as anything in leaning_mobs)
		leaner.stop_leaning()

/datum/component/leanable/proc/mousedrop_receive(atom/source, atom/movable/dropped, mob/user, params)
	if (dropped != user)
		return
	if (!iscarbon(dropped) && !iscyborg(dropped))
		return
	var/mob/living/leaner = dropped
	if (leaner.incapacitated(IGNORE_RESTRAINTS) || leaner.stat != CONSCIOUS || leaner.notransform)
		return
	if (HAS_TRAIT_FROM(leaner, TRAIT_UNDENSE, TRAIT_LEANING))
		return
	var/turf/checked_turf = get_step(leaner, REVERSE_DIR(leaner.dir))
	if (checked_turf != get_turf(source))
		return
	leaner.start_leaning(source, leaning_offset)
	leaning_mobs += leaner
	RegisterSignals(leaner, list(COMSIG_LIVING_STOPPED_LEANING, COMSIG_PARENT_QDELETING), PROC_REF(stopped_leaning))
	return TRUE

/datum/component/leanable/proc/stopped_leaning(datum/source)
	SIGNAL_HANDLER
	leaning_mobs -= source
	UnregisterSignal(source, list(COMSIG_LIVING_STOPPED_LEANING, COMSIG_PARENT_QDELETING))

/**
 * Makes the mob lean on an atom
 * Arguments
 *
 * * atom/lean_target - the target the mob is trying to lean on
 * * leaning_offset - pixel offset to apply on the mob when leaning
 */
/mob/living/proc/start_leaning(atom/lean_target, leaning_offset)
	var/new_x = lean_target.pixel_x + base_pixel_x + body_position_pixel_x_offset
	var/new_y = lean_target.pixel_y + base_pixel_y + body_position_pixel_y_offset
	switch(dir)
		if(SOUTH)
			new_y += leaning_offset
		if(NORTH)
			new_y -= leaning_offset
		if(WEST)
			new_x += leaning_offset
		if(EAST)
			new_x -= leaning_offset

	animate(src, 0.2 SECONDS, pixel_x = new_x, pixel_y = new_y)
	ADD_TRAIT(src, TRAIT_UNDENSE, TRAIT_LEANING)
	visible_message(
		"<span class='notice'>[src] leans against [lean_target].</span>",
		"<span class='notice'>You lean against [lean_target].</span>",
	)
	RegisterSignals(src, list(
		COMSIG_MOB_CLIENT_PRE_MOVE,
		COMSIG_HUMAN_DISARM_HIT,
		COMSIG_MOVABLE_PULLED,
	), PROC_REF(stop_leaning))

	RegisterSignal(src, COMSIG_ATOM_TELEPORT_ACT, PROC_REF(teleport_away_while_leaning))
	RegisterSignal(src, COMSIG_ATOM_DIR_CHANGE, PROC_REF(lean_dir_changed))

/// You fall on your face if you get teleported while leaning
/mob/living/proc/teleport_away_while_leaning()
	SIGNAL_HANDLER

	// Make sure we unregister signal handlers and reset animation
	stop_leaning()
	// -1000 aura
	visible_message("<span class='notice'>[src] falls flat on [p_their()] face from losing [p_their()] balance!</span>", "<span class='warning'>You fall suddenly as the object you were leaning on vanishes from contact with you!</span>")
	Knockdown(3 SECONDS)

/mob/living/proc/stop_leaning()
	SIGNAL_HANDLER

	UnregisterSignal(src, list(
		COMSIG_MOB_CLIENT_PRE_MOVE,
		COMSIG_HUMAN_DISARM_HIT,
		COMSIG_MOVABLE_PULLED,
		COMSIG_ATOM_DIR_CHANGE,
		COMSIG_ATOM_TELEPORT_ACT,
	))
	animate(src, 0.2 SECONDS, pixel_x = base_pixel_x + body_position_pixel_x_offset, pixel_y = base_pixel_y + body_position_pixel_y_offset)
	REMOVE_TRAIT(src, TRAIT_UNDENSE, TRAIT_LEANING)
	SEND_SIGNAL(src, COMSIG_LIVING_STOPPED_LEANING)

/mob/living/proc/lean_dir_changed(atom/source, old_dir, new_dir)
	SIGNAL_HANDLER

	if (old_dir != new_dir)
		INVOKE_ASYNC(src, PROC_REF(stop_leaning))
