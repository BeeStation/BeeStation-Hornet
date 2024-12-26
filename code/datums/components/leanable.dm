/// Things with this component can be leaned onto, optionally exclusive to RMB dragging
/datum/component/leanable
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// How much will mobs that lean onto this object be offset
	var/leaning_offset = 11
	/// Leaning mob of our parent, as only one person can lean on us at a time
	var/mob/living/leaning_mob

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
	leaning_mob = null
	return ..()

/datum/component/leanable/proc/on_moved(datum/source)
	SIGNAL_HANDLER

	leaning_mob.stop_leaning()

/datum/component/leanable/proc/mousedrop_receive(atom/source, atom/movable/dropped, mob/user, params)
	var/mob/living/leaner = dropped
	if (dropped != user)
		return FALSE
	if (!iscarbon(dropped) && !iscyborg(dropped))
		return FALSE
	if (leaner.incapacitated(IGNORE_RESTRAINTS) || leaner.stat != CONSCIOUS || leaner.notransform || leaner.buckled)
		return FALSE
	if (HAS_TRAIT_FROM(leaner, TRAIT_UNDENSE, TRAIT_LEANING))
		return FALSE
	if(ISDIAGONALDIR(get_dir(leaner, source))) //Not leaning on a corner, idiot
		return FALSE
	leaner.start_leaning(source, leaning_offset)
	leaning_mob = leaner
	RegisterSignals(leaner, list(COMSIG_LIVING_STOPPED_LEANING, COMSIG_PARENT_QDELETING), PROC_REF(stopped_leaning))
	return TRUE

/datum/component/leanable/proc/stopped_leaning(obj/source)
	SIGNAL_HANDLER
	leaning_mob = null
	UnregisterSignal(source, list(COMSIG_LIVING_STOPPED_LEANING, COMSIG_PARENT_QDELETING))
	if(!leaning_mob)
		qdel(src)

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
	switch(get_dir(src, lean_target))
		if(SOUTH)
			new_y -= leaning_offset
		if(NORTH)
			new_y += leaning_offset
		if(WEST)
			new_x -= leaning_offset
		if(EAST)
			new_x += leaning_offset

	leaned_object = lean_target
	animate(src, 0.2 SECONDS, pixel_x = new_x, pixel_y = new_y)
	ADD_TRAIT(src, TRAIT_UNDENSE, TRAIT_LEANING)
	visible_message(
		"<span class='notice'>[src] leans against [lean_target].</span>",
		"<span class='notice'>You lean against [lean_target].</span>",
	)
	RegisterSignals(src, list(
		COMSIG_MOB_CLIENT_MOVED,
		COMSIG_HUMAN_DISARM_HIT,
		COMSIG_MOVABLE_PULLED,
	), PROC_REF(stop_leaning))

	RegisterSignal(src, COMSIG_ATOM_TELEPORT_ACT, PROC_REF(teleport_away_while_leaning))
	RegisterSignal(leaned_object, COMSIG_AIRLOCK_OPEN, PROC_REF(airlock_opened))

/// You fall on your face if you get teleported while leaning
/mob/living/proc/teleport_away_while_leaning(datum/source)
	SIGNAL_HANDLER

	// Make sure we unregister signal handlers and reset animation
	stop_leaning(source)
	// -1000 aura
	visible_message("<span class='notice'>[src] falls flat on [p_their()] face from losing [p_their()] balance!</span>", "<span class='warning'>You fall suddenly as the object you were leaning on vanishes from contact with you!</span>")
	Knockdown(3 SECONDS)

/mob/living/proc/airlock_opened(datum/source)
	SIGNAL_HANDLER

	// Make sure we unregister signal handlers and reset animation
	stop_leaning(source)
	visible_message("<span class='notice'>[src] falls flat on [p_their()] face from losing [p_their()] balance!</span>", "<span class='warning'>You fall suddenly as the airlock you were leaning on opens!</span>")
	Knockdown(3 SECONDS) //boowomp

/mob/living/proc/stop_leaning(datum/source)
	SIGNAL_HANDLER

	UnregisterSignal(src, list(
		COMSIG_MOB_CLIENT_MOVED,
		COMSIG_HUMAN_DISARM_HIT,
		COMSIG_MOVABLE_PULLED,
		COMSIG_ATOM_TELEPORT_ACT,
	))
	UnregisterSignal(leaned_object, COMSIG_AIRLOCK_OPEN)

	leaned_object = null
	animate(src, 0.2 SECONDS, pixel_x = base_pixel_x + body_position_pixel_x_offset, pixel_y = base_pixel_y + body_position_pixel_y_offset)
	REMOVE_TRAIT(src, TRAIT_UNDENSE, TRAIT_LEANING)
	SEND_SIGNAL(src, COMSIG_LIVING_STOPPED_LEANING)
