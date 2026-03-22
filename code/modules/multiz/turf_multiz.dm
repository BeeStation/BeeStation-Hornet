
//The zpass procs exist to be overriden, not directly called
//use can_z_pass for that
///If we'd allow anything to travel into us
/turf/proc/zPassIn(direction, falling = FALSE)
	return FALSE

///If we'd allow anything to travel out of us
/turf/proc/zPassOut(direction, falling = FALSE)
	return FALSE

/// returns if this turf allows air to pass into it
/// direction is the direction the air is moving in
/turf/proc/zAirIn(direction, turf/source)
	return FALSE

/// returns if this turf allows air to pass out of it
/// direction is the direction the air is moving in
/turf/proc/zAirOut(direction, turf/source)
	return FALSE
