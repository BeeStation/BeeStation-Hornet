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

// midround antags
#define ROLE_KEY_ABDUCTOR			"Abductor"
#define ROLE_KEY_BRAINWASHED		"Brainwashed Victim"
#define ROLE_KEY_BLOB				"Blob"
#define ROLE_KEY_SLAUGHTER_DEMON    "Slaughter Demon"
#define ROLE_KEY_SPACE_DRAGON       "Space Dragon"
#define ROLE_KEY_NINJA				"Space Ninja"
#define ROLE_KEY_NIGHTMARE          "Nightmare"
#define ROLE_KEY_XENOMORPH          "Xenomorph"
#define ROLE_KEY_REVENANT			"Revenant"
#define ROLE_KEY_OBSESSED			"Obsessed"
#define ROLE_KEY_MORPH              "Morph"
#define ROLE_KEY_TERATOMA			"Teratoma"
#define ROLE_KEY_HOLOPARASITE		"Guardian"
#define ROLE_KEY_SPACE_PIRATE       "Space Pirate"
#define ROLE_KEY_EXT_SYNDI_AGENT    "External Syndicate Agent"

#define ROLE_KEY_UNDEFINED_ANTAG_ROLE "Undefined Antagonist Role" // default for all antag datum

// non-antag & ghost spawn & special roles
#define ROLE_KEY_POSIBRAIN        "Positronic Brain"
#define ROLE_KEY_PAI				"pAI"
#define ROLE_KEY_ASHWALKER			"Ashwalker Lizard"
#define ROLE_KEY_LAVALAND_DOCTOR      "Translocated Veterinarian"
#define ROLE_KEY_LAVALAND_LIFEBRINGER "Lifebringer"
#define ROLE_KEY_EXPERIMENTAL_CLONE   "Experimental Clone"
#define ROLE_KEY_GOLEMS               "Sentient Golems"
#define ROLE_KEY_BEACH_BUM        "Beach Bum"
#define ROLE_KEY_EXPLORATION_VIP  "Exploration VIP"
#define ROLE_KEY_MAROONED_CREW    "Marooned Crew"
#define ROLE_KEY_FUGITIVE         "Fugitive"
#define ROLE_KEY_FUGITIVE_HUNTER  "Fugitive Hunter"
#define ROLE_KEY_SENTIENCE        "Sentient Creature"
#define ROLE_KEY_DRONE            "Drone"
#define ROLE_KEY_UNDEAD           "Undead"
#define ROLE_KEY_ERT              "ERT"
#define ROLE_KEY_SURVIVALIST      "Survivalist"
#define ROLE_KEY_LIVING_LEGEND    "The Living Legend" // only use this when a mob role is a legendary person in SS13. (i.e. Yender the Archwizard, Doctor Hilbert, or a member of Nanotrasen Family like 'Randomname Von Nanotrasen')

#define ROLE_KEY_UNDEFINED_SPECIAL_ROLE "Undefied Special Role" // default for all ghost roles

// these are used for ban system
#define ROLE_KEY_REV_HEAD			"Head Revolutionary"
#define ROLE_KEY_REV_ENEMY          "revolution enemy"
#define ROLE_KEY_POSIBRAIN			"Positronic Brain"

// deprecated?
#define ROLE_KEY_INTERNAL_AFFAIRS	"Internal Affairs Agent"
#define ROLE_KEY_GANG				"Gangster"
#define ROLE_KEY_DEVIL				"Devil"
#define ROLE_KEY_OVERTHROW			"Syndicate Mutineer"
#define ROLE_KEY_DEMONIC_FRIEND     "SuperFriend"


// for role title display
#define ROLE_TITLE_EXTERNAL_AFFAIRS "Syndicate External Affairs Agent"



// Major coverage - used to ban
#define ROLE_BANCHECK_MAJOR_ANTAGONIST "All antagonist type"
#define ROLE_BANCHECK_MAJOR_GHOSTSPAWN "All ghost spawns"
#define ROLE_BANCHECK_MIND_TRANSFER    "Mind Transfer Potion"

GLOBAL_LIST_INIT(roundstart_antag_prefs, list(
	ROLE_KEY_TRAITOR = /datum/game_mode/traitor,
	ROLE_KEY_BROTHER = /datum/game_mode/traitor/bros,
	ROLE_KEY_OPERATIVE = /datum/game_mode/nuclear,
	ROLE_KEY_MALF,
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

GLOB_LIST_INIT(misc_ban_list, list(
	ROLE_KEY_REV_HEAD,
	ROLE_BANCHECK_MIND_TRANSFER
))

GLOBAL_LIST_INIT(midround_antag_list, list(
	ROLE_KEY_ERT,
	ROLE_KEY_XENOMORPH,
	ROLE_KEY_ABDUCTOR,
	ROLE_KEY_SPACE_PIRATE,
	ROLE_KEY_EXT_SYNDI_AGENT,
	ROLE_KEY_NINJA,
	ROLE_KEY_NIGHTMARE,
	ROLE_KEY_BRAINWASHED,
	ROLE_KEY_REVENANT,
	ROLE_KEY_OBSESSED,
	ROLE_KEY_SLAUGHTER_DEMON,
	ROLE_KEY_MORPH,
	ROLE_KEY_BLOB,
	ROLE_KEY_SPACE_DRAGON ,
	ROLE_KEY_HOLOPARASITE,
	ROLE_KEY_TERATOMA
))

GLOBAL_LIST_INIT(ghost_special_roles, list(
	ROLE_KEY_POSIBRAIN,
	ROLE_KEY_PAI,
	ROLE_KEY_SENTIENCE,
	ROLE_KEY_ASHWALKER,
	ROLE_KEY_LAVALAND_DOCTOR,
	ROLE_KEY_LAVALAND_LIFEBRINGER,
	ROLE_KEY_BEACH_BUM,
	ROLE_KEY_GOLEMS,
	ROLE_KEY_EXPERIMENTAL_CLONE,
	ROLE_KEY_EXPLORATION_VIP,
	ROLE_KEY_MAROONED_CREW,
	ROLE_KEY_FUGITIVE ,
	ROLE_KEY_FUGITIVE_HUNTER,
	ROLE_KEY_DRONE,
	ROLE_KEY_UNDEAD,
	ROLE_KEY_SURVIVALIST,
	ROLE_KEY_LIVING_LEGEND
))

//Job defines for what happens when you fail to qualify for any job during job selection
#define BEOVERFLOW 	1
#define BERANDOMJOB 	2
#define RETURNTOLOBBY 	3




//Missing assignment means it's not a gamemode specific role, IT'S NOT A BUG OR ERROR.
//The gamemode specific ones are just so the gamemodes can query whether a player is old enough
//(in game days played) to play that role
GLOBAL_LIST_INIT(special_roles, list(
	ROLE_KEY_TRAITOR = /datum/game_mode/traitor,
	ROLE_KEY_BROTHER = /datum/game_mode/traitor/bros,
	ROLE_KEY_INCURSION = /datum/game_mode/incursion,
	ROLE_KEY_EXCOMM = /datum/game_mode/incursion,
	ROLE_KEY_OPERATIVE = /datum/game_mode/nuclear,
	ROLE_KEY_CHANGELING = /datum/game_mode/changeling,
	ROLE_KEY_WIZARD = /datum/game_mode/wizard,
	ROLE_KEY_MALF,
	ROLE_KEY_REVOLUTION = /datum/game_mode/revolution,
	ROLE_KEY_XENOMORPH,
	ROLE_KEY_PAI,
	ROLE_KEY_CULTIST = /datum/game_mode/cult,
	ROLE_KEY_SERVANT_OF_RATVAR = /datum/game_mode/clockcult,
	ROLE_KEY_BLOB,
	ROLE_KEY_NINJA,
	ROLE_KEY_OBSESSED,
	ROLE_KEY_REVENANT,
	ROLE_KEY_ABDUCTOR,
	ROLE_KEY_DEVIL = /datum/game_mode/devil,
	ROLE_KEY_OVERTHROW = /datum/game_mode/overthrow,
	ROLE_KEY_HIVE = /datum/game_mode/hivemind,
	ROLE_KEY_INTERNAL_AFFAIRS = /datum/game_mode/traitor/internal_affairs,
	ROLE_KEY_SENTIENCE,
	ROLE_KEY_GANG = /datum/game_mode/gang,
	ROLE_KEY_HOLOPARASITE,
	ROLE_KEY_HERETIC = /datum/game_mode/heretics,
	ROLE_KEY_TERATOMA
))

GLOBAL_LIST_INIT(antagonist_positions, list(
	ROLE_KEY_ABDUCTOR,
	ROLE_KEY_XENOMORPH,
	ROLE_KEY_BLOB,
	ROLE_KEY_BROTHER,
	ROLE_KEY_CHANGELING,
	ROLE_KEY_CULTIST,
	ROLE_KEY_HERETIC,
	ROLE_KEY_DEVIL,
	ROLE_KEY_INTERNAL_AFFAIRS,
	ROLE_KEY_MALF,
	ROLE_KEY_NINJA,
	ROLE_KEY_OPERATIVE,
	ROLE_KEY_SERVANT_OF_RATVAR,
	ROLE_KEY_OVERTHROW,
	ROLE_KEY_REVOLUTION,
	ROLE_KEY_REVENANT,
	ROLE_KEY_REV_HEAD,
	ROLE_KEY_TRAITOR,
	ROLE_KEY_WIZARD,
	ROLE_KEY_HIVE,
	ROLE_KEY_GANG,
	ROLE_KEY_TERATOMA
))

//Job defines for what happens when you fail to qualify for any job during job selection
#define BEOVERFLOW 	1
#define BERANDOMJOB 	2
#define RETURNTOLOBBY 	3
