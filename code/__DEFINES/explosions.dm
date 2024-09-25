#define EXPLODE_NONE 0 //Don't even ask me why we need this.
#define EXPLODE_DEVASTATE 1
#define EXPLODE_HEAVY 2
#define EXPLODE_LIGHT 3
#define EXPLODE_GIB_THRESHOLD 50	//ex_act() with EXPLODE_DEVASTATE severity will gib mobs with less than this much bomb armor

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

/// A wrapper for [/atom/proc/ex_act] to ensure that the explosion propagation and attendant signal are always handled.
#define EX_ACT(target, args...)\
	if(!(target.flags_1 & PREVENT_CONTENTS_EXPLOSION_1)) { \
		target.contents_explosion(##args);\
	};\
	SEND_SIGNAL(target, COMSIG_ATOM_EX_ACT, ##args);\
	target.ex_act(##args);

// Explodable component deletion values
/// Makes the explodable component queue to reset its exploding status when it detonates.
#define EXPLODABLE_NO_DELETE 0
/// Makes the explodable component delete itself when it detonates.
#define EXPLODABLE_DELETE_SELF 1
/// Makes the explodable component delete its parent when it detonates.
#define EXPLODABLE_DELETE_PARENT 2
