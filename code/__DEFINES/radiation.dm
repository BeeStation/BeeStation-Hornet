/*
These defines are the balancing points of various parts of the radiation system.
Changes here can have widespread effects: make sure you test well.
Ask god if they're around
*/

#define RAD_MOB_HAIRLOSS (1 MINUTES)						// How much stored radiation to check for hair loss

#define RAD_MOB_MUTATE (2 MINUTES)							// How much stored radiation to check for mutation

/// The time since irradiated before checking for vomitting
#define RAD_MOB_VOMIT (2 MINUTES)
#define RAD_MOB_VOMIT_PROB 1						// Chance per tick of vomitting

#define RAD_MOB_KNOCKDOWN (2 MINUTES)				// How much stored radiation to check for stunning
#define RAD_MOB_KNOCKDOWN_PROB 1					// Chance of knockdown per tick when over threshold
#define RAD_MOB_KNOCKDOWN_AMOUNT 3					// Amount of knockdown when it occurs

#define RAD_NO_INSULATION 1.0						// For things that shouldn't become irradiated for whatever reason
#define RAD_VERY_LIGHT_INSULATION 0.9				// What girders have
#define RAD_LIGHT_INSULATION 0.8
#define RAD_MEDIUM_INSULATION  0.7					// What common walls have
#define RAD_HEAVY_INSULATION 0.6					// What reinforced walls have
#define RAD_EXTREME_INSULATION 0.5					// What rad collectors have
#define RAD_FULL_INSULATION 0 						// Completely stops radiation from coming through

/// The default chance something can be irradiated
#define DEFAULT_RADIATION_CHANCE 10

/// The default chance for uranium structures to irradiate
#define URANIUM_IRRADIATION_CHANCE DEFAULT_RADIATION_CHANCE

/// The minimum exposure time before uranium structures can irradiate
#define URANIUM_RADIATION_MINIMUM_EXPOSURE_TIME (3 SECONDS)

/// Return values of [proc/get_perceived_radiation_danger]
// If you change these, update /datum/looping_sound/geiger as well.
#define PERCEIVED_RADIATION_DANGER_LOW 1
#define PERCEIVED_RADIATION_DANGER_MEDIUM 2
#define PERCEIVED_RADIATION_DANGER_HIGH 3
#define PERCEIVED_RADIATION_DANGER_EXTREME 4

/// The time before geiger counters reset back to normal without any radiation pulses
#define TIME_WITHOUT_RADIATION_BEFORE_RESET (5 SECONDS)
