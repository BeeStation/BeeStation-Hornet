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


//Blob
#define BLOB_REROLL_TIME 2400 //blob gets a free reroll every X time
#define BLOB_SPREAD_COST 4
#define BLOB_ATTACK_REFUND 2 //blob refunds this much if it attacks and doesn't spread
#define BLOB_REFLECTOR_COST 15
#define BLOB_STRAIN_COLOR_LIST list("#BE5532", "#7D6EB4", "#EC8383", "#00E5B1", "#00668B", "#FFF68", "#BBBBAA", "#CD7794", "#57787B", "#3C6EC8", "#AD6570", "#823ABB")

//Overthrow time to update heads obj
#define OBJECTIVE_UPDATING_TIME 300

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

/// Checks if the given mob is a blood cultist
#define IS_CULTIST(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/cult))

///It is faster as a macro than a proc
#define IS_HERETIC(mob) (mob.mind?.has_antag_datum(/datum/antagonist/heretic))
#define IS_HERETIC_MONSTER(mob) (mob.mind?.has_antag_datum(/datum/antagonist/heretic_monster))
/// Checks if the given mob is either a heretic or a heretic monster.
#define IS_HERETIC_OR_MONSTER(mob) (IS_HERETIC(mob) || IS_HERETIC_MONSTER(mob))

/// Define for the heretic faction applied to heretics and heretic mobs.
#define FACTION_HERETIC "heretics"

#define FACTION_SYNDICATE "Syndicate"
#define FACTION_BLOB "Blob"
#define FACTION_ALIEN "Xenomorph"
#define FACTION_WIZARD "Wizard"

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


/// How much does it cost to reroll strains?
#define BLOB_REROLL_COST 40

/// How many telecrystals a normal traitor starts with
#define TELECRYSTALS_DEFAULT 20
/// How many telecrystals mapper/admin only "precharged" uplink implant
#define TELECRYSTALS_PRELOADED_IMPLANT 10
/// The normal cost of an uplink implant; used for calcuating how many
/// TC to charge someone if they get a free implant through choice or
/// because they have nothing else that supports an implant.
#define UPLINK_IMPLANT_TELECRYSTAL_COST 3

///Checks if given mob is a hive host
#define IS_HIVEHOST(mob) (mob.mind?.has_antag_datum(/datum/antagonist/hivemind))
///Checks if given mob is an awakened vessel
#define IS_WOKEVESSEL(mob) (mob.mind?.has_antag_datum(/datum/antagonist/hivevessel))

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
