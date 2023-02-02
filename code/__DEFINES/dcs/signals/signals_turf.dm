// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /turf signals
#define COMSIG_TURF_CHANGE "turf_change"						//! from base of turf/ChangeTurf(): (path, list/new_baseturfs, flags, list/transferring_comps)
#define COMSIG_TURF_HAS_GRAVITY "turf_has_gravity"				//! from base of atom/has_gravity(): (atom/asker, list/forced_gravities)
#define COMSIG_TURF_MULTIZ_NEW "turf_multiz_new"				//! from base of turf/New(): (turf/source, direction)
#define COMSIG_TURF_AFTER_SHUTTLE_MOVE "turf_after_shuttle_move"	//! from base of turf/proc/afterShuttleMove: (turf/new_turf)

#define COMSIG_TURF_MOB_FALL "turf_mob_fall"                    //!
#define COMSIG_TURF_LIQUIDS_CREATION "turf_liquids_creation"    //!

///this is called whenever a turf is destroyed
#define COMSIG_TURF_DESTROY "turf_destroy"
///this is called whenever a turfs air is updated
#define COMSIG_TURF_UPDATE_AIR "turf_air_change"
