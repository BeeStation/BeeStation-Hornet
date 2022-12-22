

//Values for antag preferences, event roles, etc. unified here



//These are synced with the Database, if you change the values of the defines
//then you MUST update the database!
//---------------------------------------------------
// Roundstart antags
#define ROLE_SYNDICATE			"Syndicate"
#define ROLE_TRAITOR			"Traitor"
#define ROLE_BROTHER			"Blood Brother"
#define ROLE_OPERATIVE			"Nuclear Operative"
#define ROLE_OPERATIVE_CLOWN	"Clown Operative"
#define ROLE_MALF				"Malf AI"
#define ROLE_INCURSION			"Incursion Team"
#define ROLE_EXCOMM				"Excommunicated Syndicate Agent"
#define ROLE_CHANGELING			"Changeling"
#define ROLE_CULTIST			"Cultist"
#define ROLE_SERVANT_OF_RATVAR	"Servant of Ratvar"
#define ROLE_WIZARD				"Wizard"
#define ROLE_HERETIC			"Heretic"
#define ROLE_HIVE				"Hivemind Host"
#define ROLE_HIVE_VESSEL		"Awakened Vessel"
#define ROLE_REV				"Revolutionary"
#define ROLE_REV_HEAD			"Head Revolutionary"
#define ROLE_GANG				"Gangster"


// midround antags
#define ROLE_ABDUCTOR			"Abductor"
#define ROLE_BRAINWASHED		"Brainwashed Victim"
#define ROLE_BLOB				"Blob"
#define ROLE_SLAUGHTER_DEMON    "Slaughter Demon"
#define ROLE_SPACE_DRAGON       "Space Dragon"
#define ROLE_NINJA				"Space Ninja"
#define ROLE_NIGHTMARE          "Nightmare"
#define ROLE_ALIEN				"Xenomorph"
#define ROLE_REVENANT			"Revenant"
#define ROLE_OBSESSED			"Obsessed"
#define ROLE_TERATOMA			"Teratoma"
#define ROLE_HOLOPARASITE		"Holoparasite"
#define ROLE_LAVALAND			"Lavaland"
#define ROLE_ASHWALKER			"Ashwalker Lizard"
#define ROLE_ERT				"ERT"
#define ROLE_DEATHSQUAD			"Deathsquad"
#define ROLE_UNDEFINED_ANTAG_ROLE "Undefined Antagonist Role" // default for all antag datum

// non-antag roles
#define ROLE_EXPERIMENTAL_CLONE "Experimental Clone"
#define ROLE_SENTIENCE			"High Intelligence Creature (Sentience Potion)"
#define ROLE_MIND_TRANSFER		"Mind Transfer Potion"
#define ROLE_POSIBRAIN			"Positronic Brain"
#define ROLE_DRONE				"Drone"
#define ROLE_PAI				"pAI"
#define ROLE_GOLEMS             "Sentient Golems"
#define ROLE_FUGITIVE_N_CHASERS "Fugitive and Chasers"

// deprecated?
#define ROLE_INTERNAL_AFFAIRS	"Internal Affairs Agent"
#define ROLE_DEVIL				"Devil"
#define ROLE_OVERTHROW			"Syndicate Mutineer"


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
	ROLE_PAI,
	ROLE_CULTIST = /datum/game_mode/cult,
	ROLE_SERVANT_OF_RATVAR = /datum/game_mode/clockcult,
	ROLE_BLOB,
	ROLE_NINJA,
	ROLE_OBSESSED,
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
	ROLE_TERATOMA
))

GLOBAL_LIST_INIT(antagonist_positions, list(
	ROLE_ABDUCTOR,
	ROLE_ALIEN,
	ROLE_BLOB,
	ROLE_BROTHER,
	ROLE_CHANGELING,
	ROLE_CULTIST,
	ROLE_HERETIC,
	ROLE_DEVIL,
	ROLE_INTERNAL_AFFAIRS,
	ROLE_MALF,
	ROLE_NINJA,
	ROLE_OPERATIVE,
	ROLE_SERVANT_OF_RATVAR,
	ROLE_OVERTHROW,
	ROLE_REV,
	ROLE_REVENANT,
	ROLE_REV_HEAD,
	ROLE_SYNDICATE,
	ROLE_TRAITOR,
	ROLE_WIZARD,
	ROLE_HIVE,
	ROLE_GANG,
	ROLE_TERATOMA
))

//Job defines for what happens when you fail to qualify for any job during job selection
#define BEOVERFLOW 	1
#define BERANDOMJOB 	2
#define RETURNTOLOBBY 	3
