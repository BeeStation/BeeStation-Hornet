/// Disables playtime requirements when being drafted for rulesets
//#define TESTING_DYNAMIC

#if defined(TESTING_DYNAMIC) && defined(CIBUILDING)
	#error TESTING_DYNAMIC is enabled, disable this!
#endif

#define DYNAMIC_STORYTELLERS_DIRECTORY "[global.config.directory]/dynamic/"

#define DYNAMIC_CATEGORY_ROUNDSTART "Roundstart"
#define DYNAMIC_CATEGORY_MIDROUND "Midround"
#define DYNAMIC_CATEGORY_LATEJOIN "Latejoin"

/// For relatively small antagonists (Sleeper Agent, Obsessed, Fugitives, etc.)
#define DYNAMIC_MIDROUND_LIGHT (1 << 0)
/// For round disruptive antagonists (Abductors, Malf AI, Slaughter Demon, etc.)
#define DYNAMIC_MIDROUND_MEDIUM (1 << 1)
/// For round ending antagonists (Wizard, Lone Operative, Blob, etc.)
#define DYNAMIC_MIDROUND_HEAVY (1 << 2)

/// Only one ruleset with this flag will be picked
#define HIGH_IMPACT_RULESET (1 << 0)
/// This ruleset can only be picked once
#define CANNOT_REPEAT (1 << 1)
/// Dynamic will call rule_process each tick if this is set
#define SHOULD_PROCESS_RULESET (1 << 2)
/// Should the chosen candidate(s) be picked based off of their antagonist reputation
#define SHOULD_USE_ANTAG_REP (1 << 3)
/// If this flag is enabled no other rulesets can be executed
#define NO_OTHER_RULESETS (1 << 4)
/// If we ignore the number of candidates when seeing if we can execute this
/// Mainly useful for rulesets which require a certain number of candidates, but
/// can draft them past the point of execution (midrounds from ghosts)
#define IGNORE_DRAFTED_COUNT (1 << 5)

#define DYNAMIC_EXECUTE_FAILURE 0
#define DYNAMIC_EXECUTE_SUCCESS 1
#define DYNAMIC_EXECUTE_WAITING 2

#define DYNAMIC_EXECUTE_STRINGIFY(state) (state == DYNAMIC_EXECUTE_FAILURE ? "FAIL" : (state == DYNAMIC_EXECUTE_SUCCESS ? "SUCCESS" : "WAITING"))

#define RULESET_STOP_PROCESSING 1

// If this is defined, then any storyteller configs which do not have
// a 'Version' tag that match this value will not be loaded.
//#define STORYTELLER_VERSION "GamemodeAntagonists"
