/*
* Roundstart
*/

/// In order to make rounds less predictable, a randomized divergence percentage is applied to the total point value
/// A random value will be chosen inbetween the lower and upper cap and then mulitplied to the calculated roundstart points
/// These should be floats. i.e: 0.20, 0.75, 1.0
#define DYNAMIC_ROUNDSTART_POINT_DIVERGENCE_LOWER 0.8
#define DYNAMIC_ROUNDSTART_POINT_DIVERGENCE_UPPER 1.4
/// How many roundstart points should be granted per player based off their status (OBSERVING, READY, UNREADY)
#define DYNAMIC_ROUNDSTART_POINTS_PER_READY 1
#define DYNAMIC_ROUNDSTART_POINTS_PER_UNREADY 0.5
#define DYNAMIC_ROUNDSTART_POINTS_PER_OBSERVER 0

/*
* Midround
*/

/// At this time the chance for a Light or Medium midround will reach 0%
#define DYNAMIC_MIDROUND_LIGHT_END_TIME 60 MINUTES
#define DYNAMIC_MIDROUND_MEDIUM_END_TIME 90 MINUTES
/// The starting chance for each of the ruleset types
#define DYNAMIC_MIDROUND_LIGHT_STARTING_CHANCE 100
#define DYNAMIC_MIDROUND_MEDIUM_STARTING_CHANCE 0
#define DYNAMIC_MIDROUND_HEAVY_STARTING_CHANCE 0
/// What ratio of the Light Percentage Chance Decrease should be given to the Medium Ruleset Percentage Chance
/// DYNAMIC_HEAVY_INCREASE_RATIO is not defined because it is calculated by doing 1 - DYNAMIC_MIDROUND_INCREASE_RATIO
#define DYNAMIC_MIDROUND_INCREASE_RATIO 0.75
/// The time at which dynamic will start choosing midrounds
#define DYNAMIC_MIDROUND_GRACEPERIOD 15 MINUTES

#define DYNAMIC_MIDROUND_POINTS_PER_LIVING 0.1
#define DYNAMIC_MIDROUND_POINTS_PER_OBSERVER 0.0
#define DYNAMIC_MIDROUND_POINTS_PER_DEAD -0.2

/*
* Midround Ruleset types
*/

/// For relatively small antagonists (Sleeper Agent, Obsessed, Fugitives, etc.)
#define DYNAMIC_MIDROUND_LIGHT "Light"
/// For round disruptive antagonists (Abductors, Malf AI, Slaughter Demon, etc.)
#define DYNAMIC_MIDROUND_MEDIUM "Medium"
/// For round ending antagonists (Wizard, Lone Operative, Blob, etc.)
#define DYNAMIC_MIDROUND_HEAVY "Heavy"

/*
* Latejoin
*/

/// The max amount of latejoin rulesets that can be picked
#define DYNAMIC_LATEJOIN_MAX_RULESETS 3
/// The probablity for a latejoin ruleset to be picked
#define DYNAMIC_LATEJOIN_PROBABILITY 10

/*
* Ruleset flags
*/

/// Only one ruleset with this flag will be picked
#define HIGH_IMPACT_RULESET (1 << 0)
/// This ruleset can only be picked once
#define CANNOT_REPEAT (1 << 1)
/// Dynamic will call rule_process each tick if this is set
#define SHOULD_PROCESS_RULESET (1 << 2)
/// Should the chosen candidate(s) be picked based off of their antagonist reputation
#define SHOULD_USE_ANTAG_REP (1 << 2)

/*
* Ruleset categories
*/

#define DYNAMIC_CATEGORY_ROUNDSTART "Roundstart"
#define DYNAMIC_CATEGORY_MIDROUND "Midround"
#define DYNAMIC_CATEGORY_LATEJOIN "Latejoin"

/*
* Ruleset return values
*/

#define DYNAMIC_EXECUTE_FAILURE 0
#define DYNAMIC_EXECUTE_SUCCESS 1
#define DYNAMIC_EXECUTE_NOT_ENOUGH_PLAYERS 2
#define RULESET_STOP_PROCESSING 1
