
/// Amount of units between station levels.
#define MULTI_Z_DISTANCE 4

// Defines for SSmapping's multiz_levels
/// TRUE if we're ok with going up
#define Z_LEVEL_UP 1
/// TRUE if we're ok with going down
#define Z_LEVEL_DOWN 2
#define LARGEST_Z_LEVEL_INDEX Z_LEVEL_DOWN

/// Attempt to get the turf below the provided one according to Z traits
#define GET_TURF_BELOW(turf) ((!(turf) || !length(SSmapping.multiz_levels) || !SSmapping.multiz_levels[(turf).z][Z_LEVEL_DOWN]) ? null : get_step((turf), DOWN))
/// Attempt to get the turf above the provided one according to Z traits
#define GET_TURF_ABOVE(turf) ((!(turf) || !length(SSmapping.multiz_levels) || !SSmapping.multiz_levels[(turf).z][Z_LEVEL_UP]) ? null : get_step((turf), UP))
