
//! **These are all the different status effects. Use the paths for each effect in the defines.**

/// if it allows multiple instances of the effect
#define STATUS_EFFECT_MULTIPLE 0
/// if it allows only one, preventing new instances
#define STATUS_EFFECT_UNIQUE 1
/// if it allows only one, but new instances replace
#define STATUS_EFFECT_REPLACE 2
/// if it only allows one, and new instances just instead refresh the timer
#define STATUS_EFFECT_REFRESH 3
/// call a merge proc to combine 2 status effects
#define STATUS_EFFECT_MERGE 4

//Necropolis
///makes the edges of the target's screen obscured
#define CURSE_BLINDING (1<<0)
///causes gradual damage
#define CURSE_WASTING (1<<1)
///hands reach out from the sides of the screen, doing damage and stunning if they hit the target
#define CURSE_GRASPING (1<<2)

//Incapacitated status effect flags
/// If the incapacitated status effect will ignore a mob in restraints (handcuffs)
#define IGNORE_RESTRAINTS (1<<0)
/// If the incapacitated status effect will ignore a mob in stasis (stasis beds)
#define IGNORE_STASIS (1<<1)
/// If the incapacitated status effect will ignore a mob being agressively grabbed
#define IGNORE_GRAB (1<<2)

// Grouped effect sources, see also code/__DEFINES/traits.dm
#define STASIS_MACHINE_EFFECT "stasis_machine"

#define STASIS_ADMIN "stasis_admin"

// Stasis helpers
#define STASIS_SHAPECHANGE_EFFECT "stasis_shapechange"

#define ISADVANCEDTOOLUSER(mob) (HAS_TRAIT(mob, TRAIT_ADVANCEDTOOLUSER) && !HAS_TRAIT(mob, TRAIT_DISCOORDINATED_TOOL_USER))

#define IS_IN_STASIS(mob) (mob.has_status_effect(/datum/status_effect/grouped/stasis))


//Staggered slowdown, an effect caused by tackling
#define STAGGERED_SLOWDOWN_LENGTH 3 SECONDS
#define STAGGERED_SLOWDOWN_STRENGTH 0.85 //multiplier
#define adjust_staggered_up_to(user, duration, up_to) user.amount_staggered() > up_to ? user.set_staggered(up_to) : user.adjust_staggered(duration)
#define set_staggered_if_lower(user, duration) user.amount_staggered() < duration ? FALSE : user.set_staggered(duration)
