/turf
	var/tmp/turf/above	//! If present, a turf above that is copying this turf. Implies a Z-connection and that the turf above is a z-mimic enabled turf.
	var/tmp/turf/below	//! If present, the turf below that we are copying. Implies a Z-connection and that this is a z-mimic enabled turf.
	// Various Z-Mimic abstract objects.
	var/tmp/atom/movable/openspace/turf_proxy/mimic_proxy      //! If we're a non-overwrite z-turf, this holds the appearance of the bottom-most Z-turf in the z-stack.
	var/tmp/atom/movable/openspace/multiplier/shadower         //! Object used to multiply color of all OO overlays at once.
	var/tmp/atom/movable/openspace/turf_mimic/mimic_above_copy //! If this is a delegate (non-overwrite) Z-turf with a z-turf above, this is the delegate copy that's copying us.
	var/tmp/atom/movable/openspace/turf_proxy/mimic_underlay   //! If we're at the bottom of the stack, a proxy used to fake a below space turf.
	/// How many times this turf is currently queued - multiple queue occurrences are allowed to ensure update consistency.
	var/tmp/z_queued = 0
	/// If this Z-turf leads to space, uninterrupted.
	var/tmp/z_eventually_space = FALSE
	// debug
	var/tmp/z_depth	//! Cached computed depth, used in analyzer.
	var/tmp/z_generation = 0	//! Update count, used in analyzer.
	/// General MultiZ flags, not entirely related to zmimic but better than using obj_flags
	var/z_flags = NONE

/turf/update_above()
	if (TURF_IS_MIMICKING(above))
		above.update_mimic()

/turf/proc/update_mimic()
	if(!(z_flags & Z_MIMIC_BELOW))
		return
	z_queued += 1
	// This adds duplicates for a reason. Do not change this unless you understand how ZM queues work.
	SSzcopy.queued_turfs += src

/// Enables Z-mimic for a turf that didn't already have it enabled.
/turf/proc/enable_zmimic(additional_flags = 0)
	if (z_flags & Z_MIMIC_BELOW)
		return FALSE
	z_flags |= Z_MIMIC_BELOW | additional_flags
	setup_zmimic(FALSE)
	return TRUE

/// Disables Z-mimic for a turf.
/turf/proc/disable_zmimic()
	if (!(z_flags & Z_MIMIC_BELOW))
		return FALSE
	z_flags &= ~Z_MIMIC_BELOW
	cleanup_zmimic()
	return TRUE

/// Sets up Z-mimic for this turf. You shouldn't call this directly 99% of the time.
/turf/proc/setup_zmimic(mapload)
	if (shadower)
		CRASH("Attempt to enable Z-mimic on already-enabled turf!")
	shadower = new(src)
	SSzcopy.openspace_turfs += 1
	var/turf/under = GET_TURF_BELOW(src)
	if (under)
		below = under
		below.above = src
	if (!(z_flags & (Z_MIMIC_OVERWRITE|Z_MIMIC_NO_OCCLUDE)) && mouse_opacity)
		mouse_opacity = MOUSE_OPACITY_OPAQUE
	update_mimic(!mapload) // Only recursively update if the map isn't loading.

/// Cleans up Z-mimic objects for this turf. You shouldn't call this directly 99% of the time.
/turf/proc/cleanup_zmimic()
	SSzcopy.openspace_turfs -= 1
	// Don't remove ourselves from the queue, the subsystem will explode. We'll naturally fall out of the queue.
	z_queued = 0
	// can't use QDEL_NULL as we need to supply force to qdel
	if(shadower)
		qdel(shadower, TRUE)
		shadower = null
	QDEL_NULL(mimic_above_copy)
	QDEL_NULL(mimic_underlay)
	for (var/atom/movable/openspace/mimic/OO in src)
		OO.owning_turf_changed()

	if (above)
		above.update_mimic()

	if (below)
		below.above = null
		below = null

/turf/Entered(atom/movable/thing, turf/oldLoc)
	. = ..()
	if ((thing.bound_overlay && !thing.bound_overlay.destruction_timer) || (thing.zmm_flags & ZMM_IGNORE) || thing.invisibility == INVISIBILITY_ABSTRACT || !TURF_IS_MIMICKING(above))
		return
	above.update_mimic()
