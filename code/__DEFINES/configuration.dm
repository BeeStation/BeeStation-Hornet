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
