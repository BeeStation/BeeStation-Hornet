
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
#define STASIS_ASCENSION_EFFECT "heretic_ascension"

#define IS_IN_STASIS(mob) (mob.has_status_effect(/datum/status_effect/grouped/stasis))


// Status effect application helpers.
// These are macros for easier use of adjust_timed_status_effect and set_timed_status_effect.
//
// adjust_x:
// - Adds duration to a status effect
// - Removes duration if a negative duration is passed.
// - Ex: adjust_stutter(10 SECONDS) adds ten seconds of stuttering.
// - Ex: adjust_jitter(-5 SECONDS) removes five seconds of jittering, or just removes jittering if less than five seconds exist.
//
// adjust_x_up_to:
// - Will only add (or remove) duration of a status effect up to the second parameter
// - If the duration will result in going beyond the second parameter, it will stop exactly at that parameter
// - The second parameter cannot be negative.
// - Ex: adjust_stutter_up_to(20 SECONDS, 10 SECONDS) adds ten seconds of stuttering.
//
// set_x:
// - Set the duration of a status effect to the exact number.
// - Setting duration to zero seconds is effectively the same as just using remove_status_effect, or qdelling the effect.
// - Ex: set_stutter(10 SECONDS) sets the stuttering to ten seconds, regardless of whether they had more or less existing stutter.
//
// set_x_if_lower:
// - Will only set the duration of that effect IF any existing duration is lower than what was passed.
// - Ex: set_stutter_if_lower(10 SECONDS) will set stuttering to ten seconds if no stuttering or less than ten seconds of stuttering exists
// - Ex: set_jitter_if_lower(20 SECONDS) will do nothing if more than twenty seconds of jittering already exists

#define adjust_stutter(duration) adjust_timed_status_effect(duration, /datum/status_effect/speech/stutter)
#define adjust_stutter_up_to(duration, up_to) adjust_timed_status_effect(duration, /datum/status_effect/speech/stutter, up_to)
#define set_stutter(duration) set_timed_status_effect(duration, /datum/status_effect/speech/stutter)
#define set_stutter_if_lower(duration) set_timed_status_effect(duration, /datum/status_effect/speech/stutter, TRUE)

#define adjust_derpspeech(duration) adjust_timed_status_effect(duration, /datum/status_effect/speech/stutter/derpspeech)
#define adjust_derpspeech_up_to(duration, up_to) adjust_timed_status_effect(duration, /datum/status_effect/speech/stutter/derpspeech, up_to)
#define set_derpspeech(duration) set_timed_status_effect(duration, /datum/status_effect/speech/stutter/derpspeech)
#define set_derpspeech_if_lower(duration) set_timed_status_effect(duration, /datum/status_effect/speech/stutter/derpspeech, TRUE)

#define adjust_slurring(duration) adjust_timed_status_effect(duration, /datum/status_effect/speech/slurring/drunk)
#define adjust_slurring_up_to(duration, up_to) adjust_timed_status_effect(duration, /datum/status_effect/speech/slurring/drunk, up_to)
#define set_slurring(duration) set_timed_status_effect(duration, /datum/status_effect/speech/slurring/drunk)
#define set_slurring_if_lower(duration) set_timed_status_effect(duration, /datum/status_effect/speech/slurring/drunk, TRUE)

#define adjust_dizzy(duration) adjust_timed_status_effect(duration, /datum/status_effect/dizziness)
#define adjust_dizzy_up_to(duration, up_to) adjust_timed_status_effect(duration, /datum/status_effect/dizziness, up_to)
#define set_dizzy(duration) set_timed_status_effect(duration, /datum/status_effect/dizziness)
#define set_dizzy_if_lower(duration) set_timed_status_effect(duration, /datum/status_effect/dizziness, TRUE)

#define adjust_jitter(duration) adjust_timed_status_effect(duration, /datum/status_effect/jitter)
#define adjust_jitter_up_to(duration, up_to) adjust_timed_status_effect(duration, /datum/status_effect/jitter, up_to)
#define set_jitter(duration) set_timed_status_effect(duration, /datum/status_effect/jitter)
#define set_jitter_if_lower(duration) set_timed_status_effect(duration, /datum/status_effect/jitter, TRUE)

#define adjust_confusion(duration) adjust_timed_status_effect(duration, /datum/status_effect/confusion)
#define adjust_confusion_up_to(duration, up_to) adjust_timed_status_effect(duration, /datum/status_effect/confusion, up_to)
#define set_confusion(duration) set_timed_status_effect(duration, /datum/status_effect/confusion)
#define set_confusion_if_lower(duration) set_timed_status_effect(duration, /datum/status_effect/confusion, TRUE)

#define adjust_drugginess(duration) adjust_timed_status_effect(duration, /datum/status_effect/drugginess)
#define adjust_drugginess_up_to(duration, up_to) adjust_timed_status_effect(duration, /datum/status_effect/drugginess, up_to)
#define set_drugginess(duration) set_timed_status_effect(duration, /datum/status_effect/drugginess)
#define set_drugginess_if_lower(duration) set_timed_status_effect(duration, /datum/status_effect/drugginess, TRUE)

//Staggered slowdown, an effect caused by tackling
#define STAGGERED_SLOWDOWN_LENGTH 3 SECONDS
#define STAGGERED_SLOWDOWN_STRENGTH 0.85 //multiplier
#define adjust_staggered_up_to(user, duration, up_to) user.amount_staggered() > up_to ? user.set_staggered(up_to) : user.adjust_staggered(duration)
#define set_staggered_if_lower(user, duration) user.amount_staggered() < duration ? FALSE : user.set_staggered(duration)
