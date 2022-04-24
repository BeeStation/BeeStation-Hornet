// Atom movement signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

//This signal return value bitflags can be found in __DEFINES/misc.dm
//called for each movable in a turf contents on /turf/zImpact(): (atom/movable/A, levels)
#define COMSIG_ATOM_INTERCEPT_Z_FALL "movable_intercept_z_impact"
///called on /living when someone starts pulling (atom/movable/pulled, state, force)
#define COMSIG_LIVING_START_PULL "living_start_pull"
/// from base of atom/setDir(): (old_dir, new_dir)
#define COMSIG_ATOM_DIR_CHANGE "atom_dir_change"
