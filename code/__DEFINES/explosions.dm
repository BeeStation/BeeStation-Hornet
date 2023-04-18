// The severity of explosions. Why are these inverted? I have no idea, but git blame doesn't go back far enough for me to find out.
/// The (current) highest possible explosion severity.
#define EXPLODE_DEVASTATE 3
/// The (current) middling explosion severity.
#define EXPLODE_HEAVY 2
/// The (current) lowest possible explosion severity.
#define EXPLODE_LIGHT 1
/// The default explosion severity used to mark that an object is beyond the impact range of the explosion.
#define EXPLODE_NONE 0

/// A wrapper for [/atom/proc/ex_act] to ensure that the explosion propagation and attendant signal are always handled.
#define EX_ACT(target, args...)\
	if(!(target.flags_1 & PREVENT_CONTENTS_EXPLOSION_1)) { \
		target.contents_explosion(##args);\
	};\
	SEND_SIGNAL(target, COMSIG_ATOM_EX_ACT, ##args);\
	target.ex_act(##args);

// Internal explosion argument list keys.
// Must match the arguments to [/datum/controller/subsystem/explosions/proc/propagate_blastwave]
/// The origin atom of the explosion.
#define EXARG_KEY_ORIGIN "origin"
/// The devastation range of the explosion.
#define EXARG_KEY_DEV_RANGE STRINGIFY(devastation_range)
/// The heavy impact range of the explosion.
#define EXARG_KEY_HEAVY_RANGE STRINGIFY(heavy_impact_range)
/// The light impact range of the explosion.
#define EXARG_KEY_LIGHT_RANGE STRINGIFY(light_impact_range)
/// The flame range of the explosion.
#define EXARG_KEY_FLAME_RANGE STRINGIFY(flame_range)
/// The flash range of the explosion.
#define EXARG_KEY_FLASH_RANGE STRINGIFY(flash_range)
/// Whether or not the explosion should be logged.
#define EXARG_KEY_ADMIN_LOG STRINGIFY(adminlog)
/// Whether or not the explosion should ignore the bombcap.
#define EXARG_KEY_IGNORE_CAP STRINGIFY(ignorecap)
/// Whether or not the explosion should produce sound effects and screenshake if it is large enough to warrant it.
#define EXARG_KEY_SILENT STRINGIFY(silent)
/// Whether or not the explosion should produce smoke if it is large enough to warrant it.
#define EXARG_KEY_SMOKE STRINGIFY(smoke)
/// Whether or not the explosion is magical
#define EXARG_KEY_MAGIC STRINGIFY(magic)
/// Whether or not the explosion is holy
#define EXARG_KEY_HOLY STRINGIFY(holy)
/// The explosion's explode cap
#define EXARG_KEY_CAP_MODIFIER STRINGIFY(cap_modifier)
/// Whether the explosion should effect z levels
#define EXARG_KEY_EXPLODE_Z STRINGIFY(explode_z)

// Explodable component deletion values
/// Makes the explodable component queue to reset its exploding status when it detonates.
#define EXPLODABLE_NO_DELETE 0
/// Makes the explodable component delete itself when it detonates.
#define EXPLODABLE_DELETE_SELF 1
/// Makes the explodable component delete its parent when it detonates.
#define EXPLODABLE_DELETE_PARENT 2

//gibtonite state defines
/// Gibtonite has not been mined
#define GIBTONITE_UNSTRUCK 0
/// Gibtonite has been mined and will explode soon
#define GIBTONITE_ACTIVE 1
/// Gibtonite has been stablized preventing an explosion
#define GIBTONITE_STABLE 2
/// Gibtonite will now explode
#define GIBTONITE_DETONATE 3

/// For object explosion block calculation
#define EXPLOSION_BLOCK_PROC -1
