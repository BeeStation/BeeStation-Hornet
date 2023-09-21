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
