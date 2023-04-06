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
//Hour requirements before players can choose to be specific jobs

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
#define ROLE_KEY_SANTA           "Santa"
#define MINUTES_REQUIRED_BASIC 120 			//For jobs that are easy to grief with, but not necessarily hard for new players
#define MINUTES_REQUIRED_INTERMEDIATE 600 	//For jobs that require a more detailed understanding of either the game in general, or a specific department.
#define MINUTES_REQUIRED_ADVANCED 900 		//For jobs that aren't command, but hold a similar level of importance to either their department or the round as a whole.
#define MINUTES_REQUIRED_COMMAND 1200 		//For command positions, to be weighed against the relevant department

#define ROLE_KEY_UNDEFINED_ANTAG_ROLE "Undefined Antagonist Role" // default for all antag datum
//These are synced with the Database, if you change the values of the defines
//then you MUST update the database!
#define ROLE_SYNDICATE			"Syndicate"
#define ROLE_TRAITOR			"Traitor"
#define ROLE_OPERATIVE			"Operative"
#define ROLE_CHANGELING			"Changeling"
#define ROLE_WIZARD				"Wizard"
#define ROLE_MALF				"Malf AI"
#define ROLE_INCURSION			"Incursion Team"
#define ROLE_EXCOMM				"Excommunicated Syndicate Agent"
#define ROLE_REV				"Revolutionary"
#define ROLE_REV_HEAD			"Head Revolutionary"
#define ROLE_REV_SUCCESSFUL		"Victorious Revolutionary"
#define ROLE_ALIEN				"Xenomorph"
#define ROLE_PAI				"pAI"
#define ROLE_CULTIST			"Cultist"
#define ROLE_SERVANT_OF_RATVAR	"Servant of Ratvar"
#define ROLE_HERETIC			"Heretic"
#define ROLE_BLOB				"Blob"
#define ROLE_NINJA				"Space Ninja"
#define ROLE_ABDUCTOR			"Abductor"
#define ROLE_REVENANT			"Revenant"
#define ROLE_DEVIL				"Devil"
#define ROLE_BROTHER			"Blood Brother"
#define ROLE_BRAINWASHED		"Brainwashed Victim"
#define ROLE_HYPNOTIZED			"Hypnotized Victim"
#define ROLE_OVERTHROW			"Syndicate Mutineer"
#define ROLE_HIVE				"Hivemind Host"
#define ROLE_HIVE_VESSEL		"Awakened Vessel"
#define ROLE_OBSESSED			"Obsessed"
#define ROLE_SPACE_DRAGON		"Space Dragon"
#define ROLE_SENTIENCE			"Sentience Potion Spawn"
#define ROLE_MIND_TRANSFER		"Mind Transfer Potion"
#define ROLE_POSIBRAIN			"Posibrain"
#define ROLE_DRONE				"Drone"
#define ROLE_DEATHSQUAD			"Deathsquad"
#define ROLE_LAVALAND			"Lavaland"
#define ROLE_INTERNAL_AFFAIRS	"Internal Affairs Agent"
#define ROLE_GANG				"Gangster"
#define ROLE_HOLOPARASITE		"Holoparasite"
#define ROLE_TERATOMA			"Teratoma"
#define ROLE_EXPERIMENTAL_CLONE "Experimental Clone"
#define ROLE_SPIDER				"Spider"
#define ROLE_SWARMER			"Swarmer"
#define ROLE_MORPH				"Morph"
#define ROLE_NIGHTMARE			"Nightmare"
#define ROLE_SPACE_PIRATE		"Space Pirate"
#define ROLE_FUGITIVE			"Fugitive"
#define ROLE_FUGITIVE_HUNTER	"Fugitive Hunter"

// mid-spawn NON-antags
#define ROLE_KEY_POSIBRAIN          "Positronic Brain"
#define ROLE_KEY_PAI                "pAI"
#define ROLE_KEY_ASHWALKER          "Ashwalker Lizard" // well, let them be here... as they usually don't interfere a round much
#define ROLE_KEY_LAVALAND_DOCTOR    "Translocated Veterinarian"
#define ROLE_KEY_LAVALAND_LIFEBRINGER "Lifebringer"
#define ROLE_KEY_EXPERIMENTAL_CLONE   "Experimental Clone"
#define ROLE_KEY_GOLEMS               "Sentient Golems"
#define ROLE_KEY_BEACH_BUM        "Beach Bum"
#define ROLE_KEY_EXPLORATION_VIP  "Exploration VIP"
#define ROLE_KEY_MAROONED_CREW    "Marooned Crew"
#define ROLE_KEY_FUGITIVE         "Fugitive" // fugitive and hunter aren't really against crews. Let them be here.
#define ROLE_KEY_FUGITIVE_HUNTER  "Fugitive Hunter"
#define ROLE_KEY_SENTIENT         "Sentient Beings" // This one can possibly antag (i.e. lava elite mobs)
#define ROLE_KEY_DRONE            "Drone"
#define ROLE_KEY_UNDEAD           "Undead" // I am not sure if it's a thing evne, but I added it anyawy
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
#define BANCHECK_ROLE_HIVEVESSEL       "Hivemind Vessel"
#define BANCHECK_ROLE_BRAINWASHED      "Brainwashed Victim"

#define BANCHECK_ROLE_MAJOR_GHOSTSPAWN "All ghost spawns" // bans you from all ghost roles. a bit hard coded.

#define BANCHECK_BEHAVIOR_MIND_TRANSFER    "Mind Transfer Potion"


//------------------------------------------------------------------------------------
// SECTION: Antagonist
// this is used to check a ban in certain situations
GLOBAL_LIST_INIT(misc_antag_ban_list, list(
	BANCHECK_ROLE_REV_HEAD,
	BANCHECK_ROLE_BRAINWASHED,
	BANCHECK_ROLE_HIVEVESSEL
//Missing assignment means it's not a gamemode specific role, IT'S NOT A BUG OR ERROR.
//The gamemode specific ones are just so the gamemodes can query whether a player is old enough
//(in game days played) to play that role
GLOBAL_LIST_INIT(special_roles, list(
	ROLE_TRAITOR = /datum/game_mode/traitor,
	ROLE_BROTHER = /datum/game_mode/traitor/bros,
	ROLE_INCURSION = /datum/game_mode/incursion,
	ROLE_EXCOMM = /datum/game_mode/incursion,
	ROLE_OPERATIVE = /datum/game_mode/nuclear,
	ROLE_CHANGELING = /datum/game_mode/changeling,
	ROLE_WIZARD = /datum/game_mode/wizard,
	ROLE_MALF,
	ROLE_REV = /datum/game_mode/revolution,
	ROLE_ALIEN,
	ROLE_SPIDER,
	ROLE_PAI,
	ROLE_CULTIST = /datum/game_mode/cult,
	ROLE_SERVANT_OF_RATVAR = /datum/game_mode/clockcult,
	ROLE_BLOB,
	ROLE_NINJA,
	ROLE_OBSESSED,
	ROLE_SPACE_DRAGON,
	ROLE_REVENANT,
	ROLE_ABDUCTOR,
	ROLE_DEVIL = /datum/game_mode/devil,
	ROLE_OVERTHROW = /datum/game_mode/overthrow,
	ROLE_HIVE = /datum/game_mode/hivemind,
	ROLE_INTERNAL_AFFAIRS = /datum/game_mode/traitor/internal_affairs,
	ROLE_SENTIENCE,
	ROLE_GANG = /datum/game_mode/gang,
	ROLE_HOLOPARASITE,
	ROLE_HERETIC = /datum/game_mode/heretics,
	ROLE_TERATOMA,
	ROLE_MORPH,
	ROLE_NIGHTMARE,
	ROLE_SWARMER,
	ROLE_SPACE_PIRATE,
	ROLE_FUGITIVE,
	ROLE_FUGITIVE_HUNTER,
))

// The same one above, but as 'behavior' check
GLOBAL_LIST_INIT(misc_behavior_ban_list, list(
	BANCHECK_BEHAVIOR_MIND_TRANSFER
))


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

// this is 'midround' antagonists. These are also ghost roles.
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
	ROLE_KEY_SPIDER
))

// ghost roles without antag objective
GLOBAL_LIST_INIT(ghost_special_roles, list(
	ROLE_KEY_POSIBRAIN,
	ROLE_KEY_PAI,
	ROLE_KEY_SENTIENT,
	ROLE_KEY_ASHWALKER,
	ROLE_KEY_LAVALAND_DOCTOR,
	ROLE_KEY_LAVALAND_LIFEBRINGER,
	ROLE_KEY_BEACH_BUM,
	ROLE_KEY_GOLEMS,
	ROLE_KEY_EXPERIMENTAL_CLONE,
	ROLE_KEY_EXPLORATION_VIP,
	ROLE_KEY_MAROONED_CREW,
	ROLE_KEY_FUGITIVE,
	ROLE_KEY_FUGITIVE_HUNTER,
	ROLE_KEY_DRONE,
	ROLE_KEY_LIVING_LEGEND
))

// identical to `ghost_special_roles` but only with pinging roles. This should be used in preference option instead of using `ghost_special_roles`, because, as an example, 'ashwalker' isn't a ghost role that needs a candidate.
// So, Only put roles that pinging people here.
GLOBAL_LIST_INIT(notifying_ghost_roles, list(
	ROLE_KEY_PAI,
	ROLE_KEY_SENTIENT,
	ROLE_KEY_EXPERIMENTAL_CLONE,
	ROLE_KEY_EXPLORATION_VIP,
	ROLE_KEY_FUGITIVE,
	ROLE_KEY_FUGITIVE_HUNTER,
	ROLE_KEY_DRONE,
	ROLE_KEY_LIVING_LEGEND
))

//Job defines for what happens when you fail to qualify for any job during job selection
#define BEOVERFLOW 	1
#define BERANDOMJOB 	2
#define RETURNTOLOBBY 	3
