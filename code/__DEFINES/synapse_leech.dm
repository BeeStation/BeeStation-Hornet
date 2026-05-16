// Synapse Leech Constants

// Saturation
/// Saturation drained per second while hiding (forced drain, ignores metabolic limit)
#define LEECH_HIDE_SATURATION_DRAIN 0.5
/// Many abilities won't work below this saturation
#define LEECH_MIN_SATURATION 10

// Healing
/// Saturation that the healing system wants to spend per second (before metabolic capping)
#define LEECH_HEAL_SATURATION_DRAIN 1
/// HP restored per point of saturation actually spent on healing
#define LEECH_HEAL_PER_SATURATION 2

// Substrate conversion
/// How much substrate is created from 1 point of saturation.
#define SUBSTRATE_CONVERSION_RATIO 4
/// How fast saturation converts to substrate (in saturation points per second).
#define SUBSTRATE_CONVERSION_SPEED 0.5

// Ability burrow-state usage flags.
/// Ability is usable while the leech is NOT burrowed inside a host.
#define LEECH_ABILITY_USABLE_UNBURROWED (1<<0)
/// Ability is usable while the leech IS burrowed inside a host.
#define LEECH_ABILITY_USABLE_BURROWED (1<<1)
/// Convenience: ability works in either state.
#define LEECH_ABILITY_USABLE_ALWAYS (LEECH_ABILITY_USABLE_UNBURROWED | LEECH_ABILITY_USABLE_BURROWED)
