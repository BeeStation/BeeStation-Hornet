// Synapse Leech Constants

// How much substrate is created from 1 point of saturation.
#define SUBSTRATE_CONVERSION_RATIO 10
// How fast saturation converts to substrate (in saturation points per second).
#define SUBSTRATE_CONVERSION_SPEED 1

// --- Mob Stats ---
#define LEECH_MAX_HEALTH 50
/// Negative = faster movement
#define LEECH_SPEED -0.5
#define LEECH_MELEE_DAMAGE 5
#define LEECH_ARMOUR_PENETRATION 75

// --- Saturation ---
/// Max saturation value (hunger resource)
#define LEECH_MAX_SATURATION 100
/// Starting saturation value (half full)
#define LEECH_INITIAL_SATURATION 50

// --- Substrate ---
#define LEECH_MAX_SUBSTRATE 100

// --- Toxin (per attack) ---
/// Max amount of toxin injected per melee hit
#define LEECH_TOXIN_PER_ATTACK 5
