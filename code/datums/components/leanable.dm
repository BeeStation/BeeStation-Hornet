/// Things with this component can be leaned onto, optionally exclusive to RMB dragging in the future
/datum/component/leanable
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// How much will mobs that lean onto this object be offset
	var/leaning_offset = 11
	/// Leaning mob of our parent, as only one person can lean on us at a time
	var/mob/living/leaning_mob
	/// Is this object currently leanable?
	var/is_currently_leanable = TRUE

/datum/component/leanable/Initialize(mob/living/leaner, leaning_offset = 11)
	. = ..()
	src.leaning_offset = leaning_offset
	var/atom/leanable_atom = parent
	is_currently_leanable = leanable_atom.density
	leaning_mob = leaner

/datum/component/leanable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOUSEDROPPED_ONTO, PROC_REF(mousedrop_receive))
	RegisterSignal(leaning_mob, COMSIG_LIVING_STOPPED_LEANING, PROC_REF(stopped_leaning))
	RegisterSignal(parent, COMSIG_ATOM_DENSITY_CHANGED, PROC_REF(on_density_change))
	if(!mousedrop_receive(parent, leaning_mob, leaning_mob))
		stopped_leaning(src)

/datum/component/leanable/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOUSEDROPPED_ONTO)
	UnregisterSignal(leaning_mob, COMSIG_LIVING_STOPPED_LEANING)
	UnregisterSignal(parent, COMSIG_ATOM_DENSITY_CHANGED)
	leaning_mob = null

/datum/component/leanable/proc/stopped_leaning(obj/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/component/leanable/proc/mousedrop_receive(atom/source, atom/movable/dropped, mob/user, params)
	if(dropped != user) //Have we been dropped on a valid leanable object?
		return FALSE

	var/mob/living/leaner = dropped
	leaning_mob = leaner

	if(!iscarbon(dropped) && !iscyborg(dropped)) //Are we not a cyborg or carbon?
		return FALSE
	if(!(usr == leaner)) //Are we trying to lean someone else?
		return FALSE
	if(leaner.incapacitated(IGNORE_RESTRAINTS) || leaner.stat != CONSCIOUS || leaner.notransform || leaner.buckled || leaner.body_position == LYING_DOWN) //Are we in a valid state?
		return FALSE
	if(HAS_TRAIT_FROM(leaner, TRAIT_UNDENSE, TRAIT_LEANING)) //Are we leaning already?
		return FALSE
	if(ISDIAGONALDIR(get_dir(leaner, source))) //Not leaning on a corner, idiot
		return FALSE
	if(!is_currently_leanable) //Is the object currently able to be leaned on?
		return FALSE

	leaner.apply_status_effect(STATUS_EFFECT_LEANING, source, leaning_offset)
	return TRUE

/datum/component/leanable/proc/on_density_change()
	SIGNAL_HANDLER
	is_currently_leanable = !is_currently_leanable
	if(!is_currently_leanable)
		leaning_mob.stop_leaning(src)

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

	animate(src, 0.2 SECONDS, pixel_x = new_x, pixel_y = new_y)
	ADD_TRAIT(src, TRAIT_UNDENSE, TRAIT_LEANING)
	visible_message(
		"<span class='notice'>[src] leans against [lean_target].</span>",
		"<span class='notice'>You lean against [lean_target].</span>",
	)

	leaned_object = lean_target
	RegisterSignals(src, list(
		COMSIG_MOB_CLIENT_MOVED,
		COMSIG_HUMAN_DISARM_HIT,
		COMSIG_MOVABLE_PULLED,
		COMSIG_PARENT_QDELETING,
		COMSIG_LIVING_RESIST,
		COMSIG_LIVING_MINOR_SHOCK,
		COMSIG_LIVING_RESTING_UPDATED
	), PROC_REF(stop_leaning))
	RegisterSignal(src, COMSIG_ATOM_TELEPORT_ACT, PROC_REF(teleport_away_while_leaning))
	RegisterSignal(lean_target, COMSIG_AIRLOCK_OPEN, PROC_REF(airlock_opened))


/mob/living/proc/stop_leaning(atom/parent)
	SIGNAL_HANDLER

	remove_status_effect(/datum/status_effect/leaning)
	UnregisterSignal(src, list(
		COMSIG_MOB_CLIENT_MOVED,
		COMSIG_HUMAN_DISARM_HIT,
		COMSIG_MOVABLE_PULLED,
		COMSIG_ATOM_TELEPORT_ACT,
		COMSIG_PARENT_QDELETING,
		COMSIG_LIVING_RESIST,
		COMSIG_LIVING_MINOR_SHOCK,
		COMSIG_LIVING_RESTING_UPDATED
	))
	UnregisterSignal(leaned_object, COMSIG_AIRLOCK_OPEN)
	leaned_object = null

	animate(src, 0.2 SECONDS, pixel_x = base_pixel_x + body_position_pixel_x_offset, pixel_y = base_pixel_y + body_position_pixel_y_offset)
	REMOVE_TRAIT(src, TRAIT_UNDENSE, TRAIT_LEANING)
	SEND_SIGNAL(src, COMSIG_LIVING_STOPPED_LEANING)


/// You fall on your face if you get teleported while leaning
/mob/living/proc/teleport_away_while_leaning(datum/source)
	SIGNAL_HANDLER

	// Make sure we unregister signal handlers and reset animation
	stop_leaning()
	// -1000 aura
	visible_message("<span class='notice'>[src] falls flat on [p_their()] face from losing [p_their()] balance!</span>", "<span class='warning'>You fall suddenly as the object you were leaning on vanishes from contact with you!</span>")
	Knockdown(3 SECONDS)

/mob/living/proc/airlock_opened(datum/source)
	SIGNAL_HANDLER

	if(HAS_TRAIT(src, NO_GRAVITY_TRAIT)) //If there's no gravity on the mob, don't fall lmao
		return

	stop_leaning() // Make sure we unregister signal handlers and reset animation
	forceMove(get_turf(source))
	visible_message("<span class='notice'>[src] falls flat on [p_their()] face from losing [p_their()] balance!</span>", "<span class='warning'>You fall suddenly as the airlock you were leaning on opens!</span>")
	Knockdown(3 SECONDS) //boowomp
