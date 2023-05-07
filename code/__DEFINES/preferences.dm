// Legacy chat toggles.
// !!! DO NOT ADD ANY NEW ONES HERE !!!
// Use `/datum/preference/toggle` instead.
#define CHAT_OOC			(1<<0)
#define CHAT_DEAD			(1<<1)
#define CHAT_GHOSTEARS		(1<<2)
#define CHAT_GHOSTSIGHT		(1<<3)
#define CHAT_PRAYER			(1<<4)
#define CHAT_RADIO			(1<<5)
#define CHAT_PULLR			(1<<6)
#define CHAT_GHOSTWHISPER	(1<<7)
#define CHAT_GHOSTPDA		(1<<8)
#define CHAT_GHOSTRADIO 	(1<<9)
#define CHAT_BANKCARD  (1<<10)
#define CHAT_GHOSTLAWS	(1<<11)
#define CHAT_GHOSTFOLLOWMINDLESS (1<<12)

#define TOGGLES_DEFAULT_CHAT (CHAT_OOC|CHAT_DEAD|CHAT_GHOSTEARS|CHAT_GHOSTSIGHT|CHAT_PRAYER|CHAT_RADIO|CHAT_PULLR|CHAT_GHOSTWHISPER|CHAT_GHOSTPDA|CHAT_GHOSTRADIO|CHAT_BANKCARD|CHAT_GHOSTLAWS|CHAT_GHOSTFOLLOWMINDLESS)

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
#define EXP_TYPE_GIMMICK		"Gimmick"
#define EXP_TYPE_ANTAG			"Antag"
#define EXP_TYPE_SPECIAL		"Special"
#define EXP_TYPE_GHOST			"Ghost"
#define EXP_TYPE_ADMIN			"Admin"

//Flags in the players table in the db
#define DB_FLAG_EXEMPT 1

#define DEFAULT_CYBORG_NAME "Default Cyborg Name"


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
#define UPLINK_IMPLANT "Implant"
#define UPLINK_IMPLANT_WITH_PRICE "[UPLINK_IMPLANT] (-[UPLINK_IMPLANT_TELECRYSTAL_COST] TC)"

//Plasmamen helmet styles, when you edit those remember to edit list in preferences.dm
#define HELMET_DEFAULT "Default"
#define HELMET_MK2 "Mark II"
#define HELMET_PROTECTIVE "Protective"

// All DB preference entries go here
// --- DO NOT EVER CHANGE OR RE-USE VALUES HERE ---
// If you remove an entry, comment it out and leave it for preservation sake
// All the values must be strings because they are map entries not list indexes
#define PREFERENCE_TAG_TOGGLES			"1"
#define PREFERENCE_TAG_TOGGLES2			"2"
#define PREFERENCE_TAG_ASAY_COLOUR		"3"
#define PREFERENCE_TAG_OOC_COLOUR		"4"
#define PREFERENCE_TAG_LAST_CL			"5"
#define PREFERENCE_TAG_UI_STYLE			"6"
#define PREFERENCE_TAG_OUTLINE_COLOUR	"7"
#define PREFERENCE_TAG_BALLOON_ALERTS	"8"
#define PREFERENCE_TAG_DEFAULT_SLOT		"9"
#define PREFERENCE_TAG_CHAT_TOGGLES		"10"
#define PREFERENCE_TAG_GHOST_FORM		"11"
#define PREFERENCE_TAG_GHOST_ORBIT		"12"
#define PREFERENCE_TAG_GHOST_ACCS		"13"
#define PREFERENCE_TAG_GHOST_OTHERS		"14"
#define PREFERENCE_TAG_PREFERRED_MAP	"15"
#define PREFERENCE_TAG_IGNORING			"16"
#define PREFERENCE_TAG_CLIENTFPS		"17"
#define PREFERENCE_TAG_PARALLAX			"18"
#define PREFERENCE_TAG_PIXELSIZE		"19"
#define PREFERENCE_TAG_SCALING_METHOD	"20"
#define PREFERENCE_TAG_TIP_DELAY		"21"
#define PREFERENCE_TAG_PDA_THEME		"22"
#define PREFERENCE_TAG_PDA_COLOUR		"23"
#define PREFERENCE_TAG_KEYBINDS			"24"
#define PREFERENCE_TAG_PURCHASED_GEAR	"25"
#define PREFERENCE_TAG_BE_SPECIAL		"26"
#define PREFERENCE_TAG_PAI_NAME			"27"
#define PREFERENCE_TAG_PAI_DESCRIPTION	"28"
#define PREFERENCE_TAG_PAI_COMMENT		"29"

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

/// Open the keybindings window
#define PREFERENCE_TAB_KEYBINDINGS 2

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

//randomised elements
#define RANDOM_ANTAG_ONLY 1
#define RANDOM_DISABLED 2
#define RANDOM_ENABLED 3

// randomise_appearance_prefs() and randomize_human_appearance() proc flags
#define RANDOMIZE_SPECIES (1<<0)
#define RANDOMIZE_NAME (1<<1)
