
/// Amount of units between station levels.
#define MULTI_Z_DISTANCE 4

// Defines for SSmapping's multiz_levels
/// TRUE if we're ok with going up
#define Z_LEVEL_UP 1
/// TRUE if we're ok with going down
#define Z_LEVEL_DOWN 2
#define LARGEST_Z_LEVEL_INDEX Z_LEVEL_DOWN

/// The below procs require you to either directly pass in a turf, or assign to a turf typed variable
/// The unsafe access to above needs to be null checked otherwise the compiler gets confused with the ternary
/// expression.

/// Attempt to get the turf below the provided one according to either
/// the map config defined z-traits, or the assigned below turf.
#define GET_TURF_BELOW(turf) \
( \
	!(turf) ? null : ( \
		(turf).below || ( \
			(turf).set_below(MAPPING_TURF_BELOW(turf)) \
		) \
	) \
)
#define MAPPING_TURF_BELOW(turf) ((!(turf) || !length(SSmapping.multiz_levels) || !SSmapping.multiz_levels[(turf).z][Z_LEVEL_DOWN]) ? null : get_step((turf), DOWN))

/// Attempt to get the turf above the provided one according to either
/// the map config defined z-traits, or the assigned above turf
#define GET_TURF_ABOVE(turf) \
( \
	!(turf) ? null : ( \
		(turf).above || ( \
			(turf).set_above(MAPPING_TURF_ABOVE(turf)) \
		) \
	) \
)
#define MAPPING_TURF_ABOVE(turf) ((!(turf) || !length(SSmapping.multiz_levels) || !SSmapping.multiz_levels[(turf).z][Z_LEVEL_UP]) ? null : get_step((turf), UP))
