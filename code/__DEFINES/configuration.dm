// TODO these two should be config options
#define STATION_GOAL_BUDGET  1
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
#define BRIISH_TALK_FILE "british_talk.json"
#define CANADIAN_TALK_FILE "canadian_replacement.json"
#define FRENCH_TALK_FILE "french_replacement.json"
#define GONGOLA_TALK_FILE "spurdo_replacement.json"
#define BRAIN_DAMAGE_FILE "traumas.json"
#define ION_FILE "ion_laws.json"
#define PIRATE_NAMES_FILE "pirates.json"
#define REDPILL_FILE "redpill.json"
#define WANTED_FILE "wanted_message.json"
#define REVENANT_NAME_FILE "revenant_names.json"
#define ITALIAN_TALK_FILE "italian_replacement.json"
#define VALENTINE_FILE "valentines.json"
#define GIMMICK_OBJ_FILE "[STRING_DIRECTORY]/gimmick_objectives.txt"
#define DEPT_GIMMICK_OBJ_FILE "[STRING_DIRECTORY]/dept_gimmick_objectives.txt"
#define TARGET_GIMMICK_OBJ_FILE "[STRING_DIRECTORY]/target_gimmick_objectives.txt"
#define SPLASH_DESC_FILE "splash.json"
#define MEDIEVAL_SPEECH_FILE "medieval_speech.json"
#define HERETIC_INFLUENCE_FILE "heretic_influences.json"
#define MALFUNCTION_FLAVOR_FILE "malfunction_flavor.json"

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
