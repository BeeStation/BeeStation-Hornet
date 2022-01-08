/*
These defines are the balancing points of various parts of the radiation system.
Changes here can have widespread effects: make sure you test well.
Ask ninjanomnom if they're around
*/

#define RAD_BACKGROUND_RADIATION 9 					// How much radiation is harmless to a mob

// apply_effect((amount*RAD_MOB_COEFFICIENT)/max(1, (radiation**2)*RAD_OVERDOSE_REDUCTION), IRRADIATE, blocked)
#define RAD_MOB_COEFFICIENT 0.20					// Radiation applied is multiplied by this
#define RAD_MOB_SKIN_PROTECTION ((1/RAD_MOB_COEFFICIENT)+RAD_BACKGROUND_RADIATION)

#define RAD_LOSS_PER_TICK 0.5
#define RAD_TOX_COEFFICIENT 0.08					// Toxin damage per tick coefficient
#define RAD_OVERDOSE_REDUCTION 0.000001				// Coefficient to the reduction in applied rads once the thing, usualy mob, has too much radiation
													// WARNING: This number is highly sensitive to change, graph is first for best results
#define RAD_BURN_THRESHOLD 1000						// Applied radiation must be over this to burn

#define RAD_MOB_SAFE 500							// How much stored radiation in a mob with no ill effects

#define RAD_MOB_HAIRLOSS 800						// How much stored radiation to check for hair loss

#define RAD_MOB_MUTATE 1250							// How much stored radiation to check for mutation

#define RAD_MOB_VOMIT 2000							// The amount of radiation to check for vomitting
#define RAD_MOB_VOMIT_PROB 1						// Chance per tick of vomitting

#define RAD_MOB_KNOCKDOWN 2000						// How much stored radiation to check for stunning
#define RAD_MOB_KNOCKDOWN_PROB 1					// Chance of knockdown per tick when over threshold
#define RAD_MOB_KNOCKDOWN_AMOUNT 3					// Amount of knockdown when it occurs

#define RAD_NO_INSULATION 1.0						// For things that shouldn't become irradiated for whatever reason
#define RAD_VERY_LIGHT_INSULATION 0.9				// What girders have
#define RAD_LIGHT_INSULATION 0.8
#define RAD_MEDIUM_INSULATION  0.7					// What common walls have
#define RAD_HEAVY_INSULATION 0.6					// What reinforced walls have
#define RAD_EXTREME_INSULATION 0.5					// What rad collectors have
#define RAD_FULL_INSULATION 0						// Unused

// WARNING: The defines below could have disastrous consequences if tweaked incorrectly. See: The great SM purge of Oct.6.2017
// contamination_chance = 		[doesn't matter, will always contaminate]
// contamination_strength = 	strength * RAD_CONTAMINATION_STR_COEFFICIENT
// contamination_threshold =	1 / (RAD_CONTAMINATION_BUDGET_SIZE * RAD_CONTAMINATION_STR_COEFFICIENT)
#define RAD_CONTAMINATION_BUDGET_SIZE 0.2			// Mob and non-mob budgets each gets a share from the radiation as large as this;
													// So this means 10% of the rads is "absorbed" by non-mobs (if there is a non-mob),
													// and another 10% of the rads is "absorbed" by mobs (if there is a mob)
#define RAD_DISTANCE_COEFFICIENT 1					// Lower means further rad spread

#define RAD_DISTANCE_COEFFICIENT_COMPONENT_MULTIPLIER 2	// Radiation components have additional penalty at distance coefficient
														// This is to reduce radiation by contaminated objects, mostly

#define RAD_HALF_LIFE 90							// The half-life of contaminated objects

#define RAD_WAVE_MINIMUM 10							// Radiation waves with less than this amount of power stop spreading
													// WARNING: Reducing can make rads subsytem more expensive
#define RAD_COMPONENT_MINIMUM 1						// To ensure slow contamination
													// WARNING: Reducing can make rads subsytem more expensive
#define RAD_CONTAMINATION_STR_COEFFICIENT (1 / RAD_HALF_LIFE / 8 * RAD_DISTANCE_COEFFICIENT_COMPONENT_MULTIPLIER ** 2)
													// Higher means higher strength scaling contamination strength
													// This number represents perservation of radiation
													// Set to control the most typical situation: clutters around typical radiation sources
													// This define is long and ugly because of the amount of math involved
													// and to free this define from mathematical errors of future define number tweakers
#define RAD_GEIGER_RC 4								// RC-constant for the LP filter for geiger counters. See #define LPFILTER for more info.
#define RAD_GEIGER_GRACE_PERIOD 4					// How many seconds after we last detect a radiation pulse until we stop blipping
