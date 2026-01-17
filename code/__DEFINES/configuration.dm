// TODO these two should be config options
#define PR_ANNOUNCEMENTS_PER_ROUND 5 //The number of unique PR announcements allowed per round
									//This makes sure that a single person can only spam 3 reopens and 3 closes before being ignored

//config files
#define CONFIG_GET(X) global.config.Get(/datum/config_entry/##X)
#define CONFIG_SET(X, Y) global.config.Set(/datum/config_entry/##X, ##Y)

#define CONFIG_MAPS_FILE "maps.txt"

//flags
#define CONFIG_ENTRY_LOCKED 1	//can't edit
#define CONFIG_ENTRY_HIDDEN 2	//can't see value

/// Folder directory for strings
#define STRING_DIRECTORY "strings"

/// Folder directory for data
#define DATA_DIRECTORY "data"

/// Folder directory for maps
#define MAP_DIRECTORY "_maps"

/// Folder directory for config
#define CONFIG_DIRECTORY "config"

/// File defines, most of them are loaded from STRING_DIRECTORY
#define DSAY_NICKNAME_FILE "admin_nicknames.json"	//loaded from CONFIG_DIRECTORY
#define PHOBIA_FILE "phobia.json"
#define ION_LAWS_FILE "ion_laws.json"
#define OWO_TALK_FILE "owo_talk.json"
#define GONGOLA_TALK_FILE "spurdo_replacement.json"
/// File location for brain damage traumas
#define BRAIN_DAMAGE_FILE "traumas.json"
/// File location for AI ion laws
#define ION_FILE "ion_laws.json"
/// File location for pirate names
#define PIRATE_NAMES_FILE "pirates.json"
/// File location for redpill questions
#define REDPILL_FILE "redpill.json"
/// File location for locations on the station
#define LOCATIONS_FILE "locations.json"
/// File location for wanted posters messages
#define WANTED_FILE "wanted_message.json"
/// File location for really dumb suggestions memes
#define VISTA_FILE "steve.json"
#define REVENANT_NAME_FILE "revenant_names.json"
#define VALENTINE_FILE "valentines.json"
#define GIMMICK_OBJ_FILE "[STRING_DIRECTORY]/gimmick_objectives.txt"
#define DEPT_GIMMICK_OBJ_FILE "[STRING_DIRECTORY]/dept_gimmick_objectives.txt"
#define TARGET_GIMMICK_OBJ_FILE "[STRING_DIRECTORY]/target_gimmick_objectives.txt"
#define SPLASH_DESC_FILE "splash.json"
#define HERETIC_INFLUENCE_FILE "heretic_influences.json"
#define MALFUNCTION_FLAVOR_FILE "malfunction_flavor.json"
#define APPROVED_CIRCUITS_FILE "approved_circuits.json"
/// File location for hallucination lines
#define HALLUCINATION_FILE "hallucination.json"

/// Accent files
#define MEDIEVAL_SPEECH_FILE "accent_medieval.json"
#define ROADMAN_TALK_FILE "accent_roadman.json"
#define CANADIAN_TALK_FILE "accent_canadian.json"
#define FRENCH_TALK_FILE "accent_french.json"
#define ITALIAN_TALK_FILE "accent_italian.json"
#define BRITISH_TALK_FILE "accent_british.json"
#define SCOTTISH_TALK_FILE "accent_scottish.json"
#define SWEDISH_TALK_FILE "accent_swedish.json"

/// Force the log directory to be something specific in the data/logs folder
#define OVERRIDE_LOG_DIRECTORY_PARAMETER "log-directory"
/// Prevent the master controller from starting automatically
#define NO_INIT_PARAMETER "no-init"
/// Force the config directory to be something other than "config"
#define OVERRIDE_CONFIG_DIRECTORY_PARAMETER "config-directory"

// Defib stats
/// The time (in deciseconds) in which a fresh body can be defibbed
#define DEFIB_TIME_LIMIT 900

#define VALUE_MODE_NUM 0
#define VALUE_MODE_TEXT 1
#define VALUE_MODE_FLAG 2

#define KEY_MODE_TEXT 0
#define KEY_MODE_TYPE 1

// Flags for respawn config
/// Respawn not allowed
#define RESPAWN_FLAG_DISABLED 0
/// Respawn as much as you'd like
#define RESPAWN_FLAG_FREE 1
/// Can respawn, but not as the same character
#define RESPAWN_FLAG_NEW_CHARACTER 2
