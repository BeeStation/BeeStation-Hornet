/turf
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
	/// The computed depth, this should never be directly accessed.
	/// This is assumed to always be correct, so if below is changed it
	/// must be invalidated by setting it to null.
	var/tmp/z_depth = null
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
	if (!shadower)
		WARNING("Turf at [x], [y], [z] queued without a shadower, please investigate")
		return

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
	GET_TURF_BELOW(src)
	// Get turf below caused
	if (!shadower)
		return
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

/turf/Entered(atom/movable/thing, turf/oldLoc)
	. = ..()
	if ((thing.bound_overlay && !thing.bound_overlay.destruction_timer) || (thing.zmm_flags & ZMM_IGNORE) || thing.invisibility == INVISIBILITY_ABSTRACT || !TURF_IS_MIMICKING(above))
		return
	above.update_mimic()

/// Calculate the z-depth of this provided turf.
/// If it needs to be changed, then re-initialise z-mimic
/turf/proc/calculate_zdepth()
	z_depth = null
	// Traverse to the bottom of the stack
	var/turf/b = src.below || MAPPING_TURF_BELOW(src)
	// We are the bottom
	if (!b)
		z_depth = 0
		return z_depth
	var/turf/nextb = b.below || MAPPING_TURF_BELOW(b)
	// Keep going down until we reach the bottom or something that has a valid z_depth
	while (nextb && !nextb.z_depth)
		b = nextb
		nextb = b.below || MAPPING_TURF_BELOW(b)
	if (nextb)
		b = nextb
	// Set the base zdepth if b has nothing below it (Reset the stack)
	if (!b.below && !MAPPING_TURF_BELOW(b))
		b.z_depth = 0
	// Begin building up, we know there is at least 1 turf above
	var/turf/a = b.above || MAPPING_TURF_ABOVE(b)
	var/turf/nexta = a.above || MAPPING_TURF_ABOVE(a)
	a.z_depth = b.z_depth + 1
	// Continue up until we build all the way to the top
	while (nexta)
		nexta.z_depth = a.z_depth + 1
		a = nexta
		nexta = a.above || MAPPING_TURF_ABOVE(a)
	// Return whatever we were assigned during this process
	return z_depth
