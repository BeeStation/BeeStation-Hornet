/// Disables playtime requirements when being drafted for rulesets
//#define TESTING_DYNAMIC

#if defined(TESTING_DYNAMIC) && defined(CIBUILDING)
	#error TESTING_DYNAMIC is enabled, disable this!
#endif

#define DYNAMIC_STORYTELLERS_DIRECTORY "[global.config.directory]/dynamic/"

#define DYNAMIC_CATEGORY_GAMEMODE "Gamemode"
#define DYNAMIC_CATEGORY_SUPPLEMENTARY "Supplementary"
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
/// Latejoining as this ruleset is not allowed, used for supplementary rulesets
/// and for when a gamemode ruleset could not be executed at roundstart.
#define NO_LATE_JOIN (1 << 5)
/// Is this ruleset obvious? We will only show 1 obvious ruleset in the
/// roundstart security report.
#define IS_OBVIOUS_RULESET (1 << 6)
/// If antagonists spawned by this ruleset are admin-removed, then this flag will make
/// it so that dynamic does not attempt to re-introduce an antagonist role to compensate
/// for the removal.
#define NO_TRANSFER_RULESET (1 << 7)
/// If an antagonist spawned by this role is admin-removed, do not attempt to re-introduce
/// it unless there are no other remaining antagonists of the same type, required for conversion
/// antagonists which may create more antagonists that are not associated with a spawned
/// ruleset. Not required for rulesets which pass on their spawning ruleset to any converts.
/// Because it is difficult to track conversion in modes like clockcult, we don't try to associate
/// antagonists to a single ruleset, and just assume that if an antagonist exists it is because of
/// us.
#define NO_CONVERSION_TRANSFER_RULESET (1 << 8)
/// If this flag is set, then minimum player count cares about total pop rather than
/// crew counts.
#define REQUIRED_POP_ALLOW_UNREADY (1 << 9)

#define DYNAMIC_EXECUTE_FAILURE 0
#define DYNAMIC_EXECUTE_SUCCESS 1
#define DYNAMIC_EXECUTE_WAITING 2

#define DYNAMIC_EXECUTE_STRINGIFY(state) (state == DYNAMIC_EXECUTE_FAILURE ? "FAIL" : (state == DYNAMIC_EXECUTE_SUCCESS ? "SUCCESS" : "WAITING"))

#define RULESET_STOP_PROCESSING 1

// If this is defined, then any storyteller configs which do not have
// a 'Version' tag that match this value will not be loaded.
//#define STORYTELLER_VERSION "GamemodeAntagonists"
