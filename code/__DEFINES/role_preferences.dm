//Hour requirements before players can choose to be specific jobs
#define MINUTES_REQUIRED_BASIC 120 			//For jobs that are easy to grief with, but not necessarily hard for new players
#define MINUTES_REQUIRED_INTERMEDIATE 600 	//For jobs that require a more detailed understanding of either the game in general, or a specific department.
#define MINUTES_REQUIRED_ADVANCED 900 		//For jobs that aren't command, but hold a similar level of importance to either their department or the round as a whole.
#define MINUTES_REQUIRED_COMMAND 1200 		//For command positions, to be weighed against the relevant department



//Values for antag preferences, event roles, etc. unified here
//These are synced with the Database, if you change the values of the defines
//then you MUST update the database!

//---------------------------------------------------
// Roundstart antags
#define ROLE_KEY_TRAITOR			"Traitor"
#define ROLE_KEY_BROTHER			"Blood Brother"
#define ROLE_KEY_OPERATIVE			"Nuclear Operative"
#define ROLE_KEY_MALF				"Malf AI"
#define ROLE_KEY_INCURSION			"Incursion Team"
#define ROLE_KEY_EXCOMM				"Excommunicated Syndicate Agent"
#define ROLE_KEY_CHANGELING			"Changeling"
#define ROLE_KEY_HERETIC			"Heretic"
#define ROLE_KEY_WIZARD				"Wizard"
#define ROLE_KEY_CULTIST			"Cultist"
#define ROLE_KEY_SERVANT_OF_RATVAR	"Servant of Ratvar"
#define ROLE_KEY_HIVE				"Hivemind Host"
#define ROLE_KEY_REVOLUTION			"Revolutionary"

// deprecated?
#define ROLE_KEY_INTERNAL_AFFAIRS	"Internal Affairs Agent"
#define ROLE_KEY_GANG				"Gangster"
#define ROLE_KEY_DEVIL				"Devil"
#define ROLE_KEY_OVERTHROW			"Syndicate Mutineer"


// mid-spawn antags
#define ROLE_KEY_ERT             "ERT"
#define ROLE_KEY_OBSESSED        "Obsessed"
#define ROLE_KEY_EXT_SYNDI_AGENT "External Syndicate Agent"
#define ROLE_KEY_SPACE_PIRATE    "Space Pirate"
#define ROLE_KEY_ABDUCTOR        "Abductor"
#define ROLE_KEY_SURVIVALIST     "Survivalist"
#define ROLE_KEY_NINJA           "Space Ninja"
#define ROLE_KEY_NIGHTMARE       "Nightmare"
#define ROLE_KEY_XENOMORPH       "Xenomorph"
#define ROLE_KEY_REVENANT        "Revenant"
#define ROLE_KEY_SLAUGHTER_DEMON "Slaughter Demon"
#define ROLE_KEY_SPACE_DRAGON    "Space Dragon"
#define ROLE_KEY_MORPH           "Morph"
#define ROLE_KEY_BLOB            "Blob"
#define ROLE_KEY_HOLOPARASITE    "Guardian"
#define ROLE_KEY_TERATOMA        "Teratoma"
#define ROLE_KEY_SWARMER         "Swarmer"
#define ROLE_KEY_SPIDER	         "Spider"
#define ROLE_KEY_FUGITIVE_RUNNER  "Fugitive" // fugitive and hunter aren't really against crews. Let them be here.
#define ROLE_KEY_FUGITIVE_CHASER  "Fugitive Hunter"

#define ROLE_KEY_SANTA           "Santa"
#define ROLE_KEY_VALENTINE_HATER "Heartbreaker" // this is not in GLOB role list since it's quite seasonal
#define ROLE_KEY_HIGHLANDER      "Highlander" // this is not in GLOB role list since it's not for standard games

#define ROLE_KEY_UNDEFINED_ANTAG_ROLE "Undefined Antagonist Role" // default for all antag datum

// ghost-self-spawnable roles
#define ROLE_KEY_POSIBRAIN          "Positronic Brain"
#define ROLE_KEY_PAI                "pAI"
#define ROLE_KEY_ASHWALKER          "Ashwalker Lizard" // well, let them be here... as they usually don't interfere a round much
#define ROLE_KEY_LAVALAND_DOCTOR    "Translocated Veterinarian"
#define ROLE_KEY_LAVALAND_LIFEBRINGER "Lifebringer"
#define ROLE_KEY_BEACH_BUM        "Beach Bum"
#define ROLE_KEY_GOLEM               "Sentient Golem"
#define ROLE_KEY_MAROONED_CREW    "Marooned Crew"
#define ROLE_KEY_EXPLORATION_VIP  "Exploration VIP"
#define ROLE_KEY_UNDEAD           "Undead" // I am not sure if it's a thing evne, but I added it anyawy

// ghost-notifying roles
#define ROLE_KEY_SENTIENT         "Sentient Beings" // This one can possibly antag (i.e. lava elite mobs)
#define ROLE_KEY_EXPERIMENTAL_CLONE   "Experimental Clone"
#define ROLE_KEY_DRONE            "Drone"
#define ROLE_KEY_SPLITPERSONALITY "Split Personality"
#define ROLE_KEY_IMAGINARY_FRIEND "Imaginary Friend"
#define ROLE_KEY_MENTOR_RAT       "Mentor Rat (mentor player only)" // TO-DO: we'll change this someday that only mentors can see toggle this
#define ROLE_KEY_LIVING_LEGEND    "The Living Legend" // only use this when a mob role is a legendary person in SS13. (i.e. Yender the Archwizard, Doctor Hilbert, or a member of Nanotrasen Family like "Random_name d'Nanotrasen")


#define ROLE_KEY_UNDEFINED_SPECIAL_ROLE "Undefied Special Role" // default for all ghost roles

// for role title display
#define ROLE_TITLE_EXTERNAL_AFFAIRS   "Syndicate External Affairs Agent"
#define ROLE_TITLE_REV_ENEMY     "revolution enemy"
#define ROLE_TITLE_APPRENTICE    "Apprentice"


//-------------------------------------------------------------------------------------
// Major coverage - used to ban
#define BANCHECK_ROLE_MAJOR_ANTAGONIST "All antagonist types" // bans you from all antag roles. a bit hard coded.
#define BANCHECK_ROLE_REV_HEAD         "Head Revolutionary"
#define BANCHECK_ROLE_BRAINWASHED      "Brainwashed Victim"
#define BANCHECK_ROLE_HIVEVESSEL       "Hivemind Vessel"

#define BANCHECK_ROLE_MAJOR_GHOSTSPAWN "All ghost spawns" // bans you from all ghost roles. a bit hard coded.

#define BANCHECK_BEHAVIOR_MIND_TRANSFER    "Mind Transfer Potion"


//------------------------------------------------------------------------------------
// SECTION: Antagonist
// this is used to check a ban in certain situations
GLOBAL_LIST_INIT(misc_antag_ban_list, list(
	BANCHECK_ROLE_REV_HEAD,
	BANCHECK_ROLE_BRAINWASHED,
	BANCHECK_ROLE_HIVEVESSEL
))

// The same one above, but as 'behavior' check
GLOBAL_LIST_INIT(misc_behavior_ban_list, list(
	BANCHECK_BEHAVIOR_MIND_TRANSFER
))
// major banchecks are hardcoded in sql_ban_system.dm


// this is 'roundstart' antagonists. assigning game_mode value can be removed in the future.
GLOBAL_LIST_INIT(roundstart_antag_prefs, list(
	ROLE_KEY_TRAITOR = /datum/game_mode/traitor,
	ROLE_KEY_BROTHER = /datum/game_mode/traitor/bros,
	ROLE_KEY_OPERATIVE = /datum/game_mode/nuclear,
	ROLE_KEY_MALF = /datum/game_mode/traitor,
	ROLE_KEY_INCURSION = /datum/game_mode/incursion,
	ROLE_KEY_EXCOMM = /datum/game_mode/incursion,
	ROLE_KEY_CHANGELING = /datum/game_mode/changeling,
	ROLE_KEY_HERETIC = /datum/game_mode/heretics,
	ROLE_KEY_WIZARD = /datum/game_mode/wizard,
	ROLE_KEY_CULTIST = /datum/game_mode/cult,
	ROLE_KEY_SERVANT_OF_RATVAR = /datum/game_mode/clockcult,
	ROLE_KEY_HIVE = /datum/game_mode/hivemind,
	ROLE_KEY_REVOLUTION = /datum/game_mode/revolution,
	ROLE_KEY_OVERTHROW = /datum/game_mode/overthrow,
	ROLE_KEY_DEVIL = /datum/game_mode/devil,
	ROLE_KEY_INTERNAL_AFFAIRS = /datum/game_mode/traitor/internal_affairs,
	ROLE_KEY_GANG = /datum/game_mode/gang,
))

// this is 'midround' antagonists. These typically need to send a notification to ghosts
GLOBAL_LIST_INIT(midround_antag_list, list(
	ROLE_KEY_ERT,
	ROLE_KEY_OBSESSED,
	ROLE_KEY_EXT_SYNDI_AGENT,
	ROLE_KEY_SPACE_PIRATE,
	ROLE_KEY_ABDUCTOR,
	ROLE_KEY_SURVIVALIST,
	ROLE_KEY_NINJA,
	ROLE_KEY_NIGHTMARE,
	ROLE_KEY_XENOMORPH,
	ROLE_KEY_REVENANT,
	ROLE_KEY_SLAUGHTER_DEMON,
	ROLE_KEY_SPACE_DRAGON,
	ROLE_KEY_MORPH,
	ROLE_KEY_BLOB,
	ROLE_KEY_HOLOPARASITE,
	ROLE_KEY_TERATOMA,
	ROLE_KEY_SWARMER,
	ROLE_KEY_SPIDER,
	ROLE_KEY_FUGITIVE_RUNNER,
	ROLE_KEY_FUGITIVE_CHASER,
))

// ghost roles that are spawnable by ghosts themselves
GLOBAL_LIST_INIT(ghost_special_roles__spawnable, list(
	ROLE_KEY_POSIBRAIN,
	ROLE_KEY_PAI,
	ROLE_KEY_ASHWALKER,
	ROLE_KEY_LAVALAND_DOCTOR,
	ROLE_KEY_LAVALAND_LIFEBRINGER,
	ROLE_KEY_BEACH_BUM,
	ROLE_KEY_GOLEM,
	ROLE_KEY_MAROONED_CREW,
	ROLE_KEY_EXPLORATION_VIP,
	ROLE_KEY_UNDEAD
))
// ghost roles that send a notification to ghosts for candidates
GLOBAL_LIST_INIT(ghost_special_roles__notifying, list(
	ROLE_KEY_SENTIENT,
	ROLE_KEY_EXPERIMENTAL_CLONE,
	ROLE_KEY_DRONE,
	ROLE_KEY_SPLITPERSONALITY,
	ROLE_KEY_IMAGINARY_FRIEND,
	ROLE_KEY_LIVING_LEGEND
))

// If you get these roles on roundstart, you'll not get geared with station equipment.
GLOBAL_LIST_INIT(no_gearing_roles, list(
	ROLE_KEY_OPERATIVE,
	ROLE_KEY_WIZARD,
	ROLE_KEY_SERVANT_OF_RATVAR
))

//Job defines for what happens when you fail to qualify for any job during job selection
#define BEOVERFLOW 	1
#define BERANDOMJOB 	2
#define RETURNTOLOBBY 	3
