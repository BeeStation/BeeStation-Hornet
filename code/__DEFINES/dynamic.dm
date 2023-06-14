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

/// This ruleset will be logged in persistence, to reduce the chances of it repeatedly rolling several rounds in a row.
#define PERSISTENT_RULESET (1 << 5)

/// This is a "heavy" midround ruleset, and should be run later into the round
#define MIDROUND_RULESET_STYLE_HEAVY "Heavy"

/// This is a "light" midround ruleset, and should be run early into the round
#define MIDROUND_RULESET_STYLE_LIGHT "Light"

/// No round event was hijacked this cycle
#define HIJACKED_NOTHING "HIJACKED_NOTHING"

/// This cycle, a round event was hijacked when the last midround event was too recent.
#define HIJACKED_TOO_RECENT "HIJACKED_TOO_RECENT"

/// Requirements when something needs a lot of threat to run, but still possible at low-pop
#define REQUIREMENTS_VERY_HIGH_THREAT_NEEDED list(90,90,90,80,60,50,40,40,40,40)
