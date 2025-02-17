/// This is the only ruleset that should be picked this round, used by admins and should not be on rulesets in code.
#define ONLY_RULESET (1 << 0)

/// Only one ruleset with this flag will be picked.
#define HIGH_IMPACT_RULESET (1 << 1)

/// This ruleset can only be picked once. Anything that does not have a scaling_cost MUST have this.
#define LONE_RULESET (1 << 2)

/// This ruleset can't execute alongside ANY other roundstart ruleset.
#define NO_OTHER_ROUNDSTARTS_RULESET (1 << 3)

/// This ruleset should only be rolled if the station is mostly intact, i.e the crew is not mostly dead and the station isn't full of holes.
/// Only used for midround/latejoin rolling.
#define INTACT_STATION_RULESET (1 << 4)

#define DYNAMIC_EXECUTE_FAILURE 0
#define DYNAMIC_EXECUTE_SUCCESS 1
#define DYNAMIC_EXECUTE_NOT_ENOUGH_PLAYERS 2

#define RULESET_STOP_PROCESSING 1

#define DYNAMIC_ROUNDSTART "Roundstart"
#define DYNAMIC_MIDROUND "Midround"
#define DYNAMIC_LATEJOIN "Latejoin"
