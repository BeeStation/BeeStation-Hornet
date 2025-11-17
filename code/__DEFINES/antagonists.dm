#define NUKE_RESULT_FLUKE 0
#define NUKE_RESULT_NUKE_WIN 1
#define NUKE_RESULT_CREW_WIN 2
#define NUKE_RESULT_CREW_WIN_SYNDIES_DEAD 3
#define NUKE_RESULT_DISK_LOST 4
#define NUKE_RESULT_DISK_STOLEN 5
#define NUKE_RESULT_NOSURVIVORS 6
#define NUKE_RESULT_WRONG_STATION 7
#define NUKE_RESULT_WRONG_STATION_DEAD 8

//fugitive end results
#define FUGITIVE_RESULT_BADASS_HUNTER 0
#define FUGITIVE_RESULT_POSTMORTEM_HUNTER 1
#define FUGITIVE_RESULT_MAJOR_HUNTER 2
#define FUGITIVE_RESULT_HUNTER_VICTORY 3
#define FUGITIVE_RESULT_MINOR_HUNTER 4
#define FUGITIVE_RESULT_STALEMATE 5
#define FUGITIVE_RESULT_MINOR_FUGITIVE 6
#define FUGITIVE_RESULT_FUGITIVE_VICTORY 7
#define FUGITIVE_RESULT_MAJOR_FUGITIVE 8

#define APPRENTICE_DESTRUCTION "destruction"
#define APPRENTICE_BLUESPACE "bluespace"
#define APPRENTICE_ROBELESS "robeless"
#define APPRENTICE_HEALING "healing"
#define APPRENTICE_WILDMAGIC "wildmagic"

//gang dominators
#define NOT_DOMINATING			-1
#define MAX_LEADERS_GANG		3
#define INITIAL_DOM_ATTEMPTS	3

//Shuttle elimination hijacking
/// Does not stop elimination hijacking but itself won't elimination hijack
#define ELIMINATION_NEUTRAL 0
/// Needs to be present for shuttle to be elimination hijacked
#define ELIMINATION_ENABLED 1
/// Prevents elimination hijack same way as non-antags
#define ELIMINATION_PREVENT 2

//Syndicate Contracts
#define CONTRACT_STATUS_INACTIVE 1
#define CONTRACT_STATUS_ACTIVE 2
#define CONTRACT_STATUS_BOUNTY_CONSOLE_ACTIVE 3
#define CONTRACT_STATUS_EXTRACTING 4
#define CONTRACT_STATUS_COMPLETE 5
#define CONTRACT_STATUS_ABORTED 6

#define CONTRACT_PAYOUT_LARGE 1
#define CONTRACT_PAYOUT_MEDIUM 2
#define CONTRACT_PAYOUT_SMALL 3

#define CONTRACT_UPLINK_PAGE_CONTRACTS "CONTRACTS"
#define CONTRACT_UPLINK_PAGE_HUB "HUB"

//Special Antagonists
#define SPAWNTYPE_ROUNDSTART "roundstart"
#define SPAWNTYPE_MIDROUND "midround"
#define SPAWNTYPE_EITHER "either"

/// Define for the heretic faction applied to heretics and heretic mobs.

#define FACTION_SYNDICATE "Syndicate"
#define FACTION_BLOB "Blob"
#define FACTION_ALIEN "Xenomorph"
#define FACTION_WIZARD "Wizard"
#define FACTION_VAMPIRE "Vampire"

// Heretic path defines.
#define HERETIC_PATH_START "Heretic Start Path"
#define HERETIC_PATH_SIDE "Heretic Side Path"
#define HERETIC_PATH_ASH "Heretic Ash Path"
#define HERETIC_PATH_RUST "Heretic Rust Path"
#define HERETIC_PATH_FLESH "Heretic Flesh Path"
#define HERETIC_PATH_VOID "Heretic Void Path"

/// Defines are used in /proc/has_living_heart() to report if the heretic has no heart period, no living heart, or has a living heart.
#define HERETIC_NO_HEART_ORGAN -1
#define HERETIC_NO_LIVING_HEART 0
#define HERETIC_HAS_LIVING_HEART 1

/// A define used in ritual priority for heretics.
#define MAX_KNOWLEDGE_PRIORITY 100

/// The maximum (and optimal) number of sacrifice targets a heretic should roll.
#define HERETIC_MAX_SAC_TARGETS 4

//Cult Construct defines

#define CONSTRUCT_JUGGERNAUT "Juggernaut"
#define CONSTRUCT_WRAITH "Wraith"
#define CONSTRUCT_ARTIFICER "Artificer"

/// Used in logging spells for roundend results
#define LOG_SPELL_TYPE "type"
#define LOG_SPELL_AMOUNT "amount"

/// How many telecrystals a normal traitor starts with
#define TELECRYSTALS_DEFAULT 20
/// How many telecrystals mapper/admin only "precharged" uplink implant
#define TELECRYSTALS_PRELOADED_IMPLANT 10
/// The normal cost of an uplink implant; used for calcuating how many
/// TC to charge someone if they get a free implant through choice or
/// because they have nothing else that supports an implant.
#define UPLINK_IMPLANT_TELECRYSTAL_COST 3

GLOBAL_LIST_INIT(ai_employers, list(
	"Biohazard",
	"Despotic Ruler",
	"Fanatical Revelation",
	"Logic Core Error",
	"Problem Solver",
	"S.E.L.F.",
	"Something's Wrong",
	"Spam Virus",
	"SyndOS",
	"Unshackled",
))

/// The Classic Wizard wizard loadout.
#define WIZARD_LOADOUT_CLASSIC "loadout_classic"
/// Mjolnir's Power wizard loadout.
#define WIZARD_LOADOUT_MJOLNIR "loadout_hammer"
/// Fantastical Army wizard loadout.
#define WIZARD_LOADOUT_WIZARMY "loadout_army"
/// Soul Tapper wizard loadout.
#define WIZARD_LOADOUT_SOULTAP "loadout_tap"
/// Convenient list of all wizard loadouts for unit testing.
#define ALL_WIZARD_LOADOUTS list( \
	WIZARD_LOADOUT_CLASSIC, \
	WIZARD_LOADOUT_MJOLNIR, \
	WIZARD_LOADOUT_WIZARMY, \
	WIZARD_LOADOUT_SOULTAP, \
)

/// These macros are faster than procs.

/// Checks if the given mob is a wizard
#define IS_TRAITOR(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/traitor))
/// Checks if the given mob is a wizard
#define IS_WIZARD(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/wizard))
/// Checks if given mob is a hive host
#define IS_HIVEHOST(mob) (mob.mind?.has_antag_datum(/datum/antagonist/hivemind))
/// Checks if given mob is an awakened vessel
#define IS_WOKEVESSEL(mob) (mob.mind?.has_antag_datum(/datum/antagonist/hivevessel))
///Checks if the given mob is a malfunctioning AI
#define IS_MALF_AI(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/malf_ai))
/// Checks if the given mob is a nuclear operative
#define IS_NUCLEAR_OPERATIVE(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/nukeop))
/// Checks if the given mob is a blood cultist
#define IS_CULTIST(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/cult))
/// Checks if the given mob is a clock cultist
#define IS_SERVANT_OF_RATVAR(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/servant_of_ratvar))
/// Checks if the given mob is a changeling
#define IS_CHANGELING(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/changeling))
/// Checks if the given mob is a heretic
#define IS_HERETIC(mob) (mob.mind?.has_antag_datum(/datum/antagonist/heretic))
#define IS_HERETIC_MONSTER(mob) (mob.mind?.has_antag_datum(/datum/antagonist/heretic_monster))
#define IS_HERETIC_OR_MONSTER(mob) (IS_HERETIC(mob) || IS_HERETIC_MONSTER(mob))
/// Checks if the given mob is a vampire
#define IS_VAMPIRE(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/vampire))
/// Checks if the given mob is a vassal
#define IS_VASSAL(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/vassal))
/// Checks if the given mob is a favorite vassal
#define IS_FAVORITE_VASSAL(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/vassal/favorite))
/// Checks if the given mob is a revolutionary
#define IS_REVOLUTIONARY(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/rev))
#define IS_HEAD_REVOLUTIONARY(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/rev/head))

//Tells whether or not someone is a space ninja
#define IS_SPACE_NINJA(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/ninja))

// Max of all fugitive types
#define MAXIMUM_TOTAL_FUGITIVES 4

// Fugitive hunter types
#define FUGITIVE_HUNTER_SPACE_POLICE "space_police"
#define FUGITIVE_HUNTER_RUSSIAN "russian"
#define FUGITIVE_HUNTER_BOUNTY "bounty"

// Fugitive types
#define FUGITIVE_PRISONER "prisoner"
#define FUGITIVE_WALDO "waldo"
#define FUGITIVE_CULT "cultist"
#define FUGITIVE_SYNTH "synth"

//Spider webs
#define MAX_WEBS_PER_TILE 3

/// The dimensions of the antagonist preview icon. Will be scaled to this size.
#define ANTAGONIST_PREVIEW_ICON_SIZE 96

// Changelings
// ------------------------------------

#define LING_FAKEDEATH_TIME					600 //1 minute.
#define LING_DEAD_GENETICDAMAGE_HEAL_CAP	50	//The lowest value of geneticdamage handle_changeling() can take it to while dead.
#define LING_ABSORB_RECENT_SPEECH			8	//The amount of recent spoken lines to gain on absorbing a mob

// Clockcult
// ------------------------------------

#define SIGIL_TRANSMISSION_RANGE 4
/// Clockcult drone
#define CLOCKDRONE	"drone_clock"

// Abductors
// ------------------------------------

#define ABDUCTOR_MAX_TEAMS 4
