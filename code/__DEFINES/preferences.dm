// Preferences value defines

#define PARALLAX_INSANE "Insane"
#define PARALLAX_HIGH "High"
#define PARALLAX_MED "Medium"
#define PARALLAX_LOW "Low"
#define PARALLAX_DISABLE "Disabled"

#define PIXEL_SCALING_AUTO 0
#define PIXEL_SCALING_1X 1
#define PIXEL_SCALING_1_2X 1.5
#define PIXEL_SCALING_2X 2
#define PIXEL_SCALING_3X 3
#define PIXEL_SCALING_4X 4

#define SCALING_METHOD_NORMAL "normal"
#define SCALING_METHOD_DISTORT "distort"
#define SCALING_METHOD_BLUR "blur"

#define PARALLAX_DELAY_DEFAULT world.tick_lag
#define PARALLAX_DELAY_MED     1
#define PARALLAX_DELAY_LOW     2

#define SEC_DEPT_NONE "None"
#define SEC_DEPT_RANDOM "Random"
#define SEC_DEPT_ENGINEERING "Engineering"
#define SEC_DEPT_MEDICAL "Medical"
#define SEC_DEPT_SCIENCE "Science"
#define SEC_DEPT_SUPPLY "Supply"

// Playtime tracking system, see jobs_exp.dm
#define EXP_TYPE_LIVING			"Living"
#define EXP_TYPE_CREW			"Crew"
#define EXP_TYPE_COMMAND		"Command"
#define EXP_TYPE_ENGINEERING	"Engineering"
#define EXP_TYPE_MEDICAL		"Medical"
#define EXP_TYPE_SCIENCE		"Science"
#define EXP_TYPE_SUPPLY			"Supply"
#define EXP_TYPE_SECURITY		"Security"
#define EXP_TYPE_SILICON		"Silicon"
#define EXP_TYPE_SERVICE		"Service"
#define EXP_TYPE_ANTAG			"Antag"
#define EXP_TYPE_SPECIAL		"Special"
#define EXP_TYPE_GHOST			"Ghost"
#define EXP_TYPE_ADMIN			"Admin"

//Flags in the players table in the db
#define DB_FLAG_EXEMPT 1

#define DEFAULT_CYBORG_NAME "Default Cyborg Name"

// Choose grid or list TGUI layouts for UI's, when possible.
/// Force grid layout, even if default is a list.
#define TGUI_LAYOUT_GRID "grid"
/// Force list layout, even if default is a grid.
#define TGUI_LAYOUT_LIST "list"

//Job preferences levels
#define JP_LOW 1
#define JP_MEDIUM 2
#define JP_HIGH 3

//Backpacks
#define GBACKPACK "Grey Backpack"
#define GSATCHEL "Grey Satchel"
#define GDUFFELBAG "Grey Duffel Bag"
#define LSATCHEL "Leather Satchel"
#define DBACKPACK "Department Backpack"
#define DSATCHEL "Department Satchel"
#define DDUFFELBAG "Department Duffel Bag"

//Suit/Skirt
#define PREF_SUIT "Jumpsuit"
#define PREF_SKIRT "Jumpskirt"

//Uplink spawn loc
#define UPLINK_PDA "PDA"
#define UPLINK_RADIO "Radio"
#define UPLINK_PEN "Pen" //like a real spy!

//Plasmamen helmet styles
#define HELMET_DEFAULT "Default"
#define HELMET_MK2 "Mark II"
#define HELMET_PROTECTIVE "Protective"

GLOBAL_LIST_INIT(helmet_styles, list(
	HELMET_DEFAULT,
	HELMET_MK2,
	HELMET_PROTECTIVE,
))

// True value of max save slots (3 is default, 8 is byond member, +1 to either if you have the extra slot loadout entry). Potential max is 9
#define TRUE_MAX_SAVE_SLOTS 9

// Values for /datum/preference/preference_type
/// This preference is character specific.
#define PREFERENCE_CHARACTER "character"
/// This preference is account specific.
#define PREFERENCE_PLAYER "player"

// Values for /datum/preferences/current_tab
/// Open the character preference window
#define PREFERENCE_TAB_CHARACTER_PREFERENCES 0

/// Open the game preferences window
#define PREFERENCE_TAB_GAME_PREFERENCES 1

/// These will be shown in the character sidebar, but at the bottom.
#define PREFERENCE_CATEGORY_FEATURES "features"

/// Any preferences that will show to the sides of the character in the setup menu.
#define PREFERENCE_CATEGORY_CLOTHING "clothing"

/// Preferences that will be put into the 3rd list, and are not contextual.
#define PREFERENCE_CATEGORY_NON_CONTEXTUAL "non_contextual"

/// Will be put under the game preferences window.
#define PREFERENCE_CATEGORY_GAME_PREFERENCES "game_preferences"

/// These will show in the list to the right of the character preview.
#define PREFERENCE_CATEGORY_SECONDARY_FEATURES "secondary_features"

/// These are preferences that are supplementary for main features,
/// such as hair color being affixed to hair.
#define PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES "supplemental_features"

//randomized elements
#define RANDOM_ANTAG_ONLY 1
#define RANDOM_DISABLED 2
#define RANDOM_ENABLED 3

// randomize_appearance_prefs() and randomize_human_appearance() proc flags
#define RANDOMIZE_SPECIES (1<<0)
#define RANDOMIZE_NAME (1<<1)


// Undatumized preference tags

#define PREFERENCE_TAG_LAST_CL			"last_changelog"
#define PREFERENCE_TAG_DEFAULT_SLOT		"default_slot"
#define PREFERENCE_TAG_IGNORING			"ignoring"
#define PREFERENCE_TAG_KEYBINDS			"key_bindings"
#define PREFERENCE_TAG_PURCHASED_GEAR	"purchased_gear"
#define PREFERENCE_TAG_ROLE_PREFERENCES_GLOBAL "be_special"
#define PREFERENCE_TAG_FAVORITE_OUTFITS "favorite_outfits"
#define PREFERENCE_TAG_PAI_NAME			"pai_name"
#define PREFERENCE_TAG_PAI_DESCRIPTION	"pai_description"
#define PREFERENCE_TAG_PAI_COMMENT		"pai_comment"

GLOBAL_LIST_INIT(undatumized_preference_tags_player, list(
	PREFERENCE_TAG_LAST_CL,
	PREFERENCE_TAG_DEFAULT_SLOT,
	PREFERENCE_TAG_IGNORING,
	PREFERENCE_TAG_KEYBINDS,
	PREFERENCE_TAG_PURCHASED_GEAR,
	PREFERENCE_TAG_ROLE_PREFERENCES_GLOBAL,
	PREFERENCE_TAG_FAVORITE_OUTFITS,
	PREFERENCE_TAG_PAI_NAME,
	PREFERENCE_TAG_PAI_DESCRIPTION,
	PREFERENCE_TAG_PAI_COMMENT,
))

GLOBAL_PROTECT(undatumized_preference_tags_player)

#define CHARACTER_PREFERENCE_RANDOMIZE "randomize"
#define CHARACTER_PREFERENCE_JOB_PREFERENCES "job_preferences"
#define CHARACTER_PREFERENCE_ALL_QUIRKS "all_quirks"
#define CHARACTER_PREFERENCE_EQUIPPED_GEAR "equipped_gear"
#define CHARACTER_PREFERENCE_ROLE_PREFERENCES "role_preferences"

GLOBAL_LIST_INIT(undatumized_preference_tags_character, list(
	CHARACTER_PREFERENCE_RANDOMIZE,
	CHARACTER_PREFERENCE_JOB_PREFERENCES,
	CHARACTER_PREFERENCE_ALL_QUIRKS,
	CHARACTER_PREFERENCE_EQUIPPED_GEAR,
	CHARACTER_PREFERENCE_ROLE_PREFERENCES,
))

GLOBAL_PROTECT(undatumized_preference_tags_character)

#define PREFERENCE_SHEET_NORMAL "preferences"
#define PREFERENCE_SHEET_LARGE "preferences_l"
#define PREFERENCE_SHEET_HUGE "preferences_h"

#define PREFERENCE_BODYZONE_SIMPLIFIED "Simplified Targeting"	// Use the simplified system
#define PREFERENCE_BODYZONE_INTENT "Precise Targeting"	// Use the bodyzone intent system

/// Stop loading immediately, inform the user. Do not save the data.
#define PREFERENCE_LOAD_ERROR 0
/// There is no data to load, they are a guest and will never have this data.
#define PREFERENCE_LOAD_IGNORE 1
/// No data found - create a new character, continue loading
#define PREFERENCE_LOAD_NO_DATA 2
/// Normal behavior - success!
#define PREFERENCE_LOAD_SUCCESS 3

// Priorities must be in order!
/// The default priority level
#define PREFERENCE_PRIORITY_DEFAULT 1

/// The priority at which the hotkey preference is set, required for TGUI say special macros
#define PREFERENCE_PRIORITY_HOTKEYS 2

/// The priority at which species runs, needed for external organs to apply properly.
#define PREFERENCE_PRIORITY_SPECIES 2

/// The priority at which gender is determined, needed for proper randomization.
#define PREFERENCE_PRIORITY_GENDER 3

/// The priority at which body model is decided, applied after gender so we can
/// make sure they're non-binary.
#define PREFERENCE_PRIORITY_BODY_MODEL 4

/// The priority at which eye color is applied, needed so IPCs get the right screen color.
#define PREFERENCE_PRIORITY_EYE_COLOR 4

/// The priority at which names are decided, needed for proper randomization.
#define PREFERENCE_PRIORITY_NAMES 4

/// The priority at which hair color is applied, needed so IPCs get the right antenna color.
/// Dependant on gender to create an informed value
#define PREFERENCE_PRIORITY_HAIR_COLOR 4

/// Dependant on gender to create an informed value
#define PREFERENCE_PRIORITY_HAIR_STYLE 4

/// Dependant on gender to create an informed value
#define PREFERENCE_PRIORITY_FACIAL_HAIR 4

/// Dependant on gender to create an informed value
#define PREFERENCE_PRIORITY_SOCKS 4

/// Dependant on gender to create an informed value
#define PREFERENCE_PRIORITY_UNDERSHIRT 4

/// Dependant on gender to create an informed value
#define PREFERENCE_PRIORITY_UNDERWEAR 4

/// Dependant on gender to create an informed value
#define PREFERENCE_PRIORITY_JUMPSUIT 4

/// Dependant on hair colour to create an informed value
#define PREFERENCE_PRIORITY_FACIAL_COLOR 5

/// Dependant on hair colour and gender to create an informed value
#define PREFERENCE_PRIORITY_GRADIENT_COLOR 5

/// The maximum preference priority, keep this updated, but don't use it for `priority`.
#define MAX_PREFERENCE_PRIORITY PREFERENCE_PRIORITY_GRADIENT_COLOR

/// For choiced preferences, this key will be used to set display names in constant data.
#define CHOICED_PREFERENCE_DISPLAY_NAMES "display_names"

/// For main feature preferences, this key refers to a feature considered supplemental.
/// For instance, hair color being supplemental to hair.
#define SUPPLEMENTAL_FEATURE_KEY "supplemental_feature"
