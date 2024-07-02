// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /turf signals

#define COMSIG_TURF_CHANGE "turf_change"
///from base of atom/has_gravity(): (atom/asker, list/forced_gravities)
#define COMSIG_TURF_HAS_GRAVITY "turf_has_gravity"
///from base of turf/multiz_turf_del(): (turf/source, direction)
#define COMSIG_TURF_MULTIZ_DEL "turf_multiz_del"
///from base of turf/multiz_turf_new: (turf/source, direction)
#define COMSIG_TURF_MULTIZ_NEW "turf_multiz_new"
/// from base of turf/proc/afterShuttleMove: (turf/new_turf)
#define COMSIG_TURF_AFTER_SHUTTLE_MOVE "turf_after_shuttle_move"
/// from base of /datum/turf_reservation/proc/Release: (datum/turf_reservation/reservation)
#define COMSIG_TURF_RESERVATION_RELEASED "turf_reservation_released"
