/datum/component/asteroid_tracker
	/// The depth of our asteroid baseturf
	var/base_turf_depth = -1
	/// The turf that we were previously connected to
	var/turf/underlying_turf_below
	/// The turf underground
	var/turf/underground_turf
	can_transfer = TRUE

/datum/component/asteroid_tracker/Initialize(turf/underground_turf)
	. = ..()
	// Ensure that we are above an asteroid baseturf
	var/turf/self = parent
	if (!isturf(self))
		return COMPONENT_INCOMPATIBLE
	src.underground_turf = underground_turf

/datum/component/asteroid_tracker/RegisterWithParent()
	var/turf/self = parent
	for (var/i in length(self.baseturfs) to 1 step -1)
		if (self.baseturfs[i] == /turf/baseturf_skipover/asteroid)
			base_turf_depth = i
			break
	if (base_turf_depth == -1)
		return
	if (self.baseturfs[1] == /turf/open/space)
		self.baseturfs[1] = /turf/open/openspace
	// Change our underlying turf
	underlying_turf_below = self.below
	self.set_below(underground_turf)
	// Register the signal, needs to happen after turf change
	// before the below turf gets setup
	RegisterSignal(self, COMSIG_POST_TURF_CHANGE, PROC_REF(on_change_turf))

/datum/component/asteroid_tracker/UnregisterFromParent()
	var/turf/self = parent
	self.set_below(underlying_turf_below)
	underlying_turf_below = null
	UnregisterSignal(parent, COMSIG_POST_TURF_CHANGE)

/datum/component/asteroid_tracker/Destroy(force, silent)
	. = ..()
	var/turf/self = parent
	if (isturf(self))
		self.set_below(underlying_turf_below)

/// Check if the asteroid was removed and if we should change our underlying turf
/datum/component/asteroid_tracker/proc/on_change_turf(turf/source, path, list/new_baseturfs, flags, list/transferring_comps)
	SIGNAL_HANDLER
	var/list/baseturf_list = new_baseturfs || source.baseturfs
	if (length(baseturf_list) < base_turf_depth)
		qdel(src)
		return
	if (baseturf_list[base_turf_depth] != /turf/baseturf_skipover/asteroid)
		qdel(src)
