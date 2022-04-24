//Janitor

/// called on an object to clean it of cleanables. Usualy with soap: (num/strength)
#define COMSIG_COMPONENT_CLEAN_ACT "clean_act"

///(): Returns bitflags of wet values.
#define COMSIG_TURF_IS_WET "check_turf_wet"
///(max_strength, immediate, duration_decrease = INFINITY): Returns bool.
#define COMSIG_TURF_MAKE_DRY "make_turf_try"
