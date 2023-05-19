/// returns if this turf allows a movable to pass into it
/// direction is the direction the ATOM is moving in
/turf/proc/zPassIn(atom/movable/A, direction, turf/source, falling = FALSE)
	return FALSE

/// returns if this turf allows a movable to pass out of it
/// direction is the direction the ATOM is moving in
/turf/proc/zPassOut(atom/movable/A, direction, turf/destination, falling = FALSE)
	return FALSE

/// returns if this turf allows air to pass into it
/// direction is the direction the air is moving in
/turf/proc/zAirIn(direction, turf/source)
	return FALSE

/// returns if this turf allows air to pass out of it
/// direction is the direction the air is moving in
/turf/proc/zAirOut(direction, turf/source)
	return FALSE

/// Called for propogation on turf deletions to turfs above and below itself
/turf/proc/multiz_turf_del(turf/T, dir)
	return

/// Called for propogation on turf additions to turfs above and below itself
/turf/proc/multiz_turf_new(turf/T, dir)
	return
