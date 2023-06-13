

//Values for antag preferences, event roles, etc. unified here

//Hour requirements before players can choose to be specific jobs

#define MINUTES_REQUIRED_BASIC 120 			//For jobs that are easy to grief with, but not necessarily hard for new players
#define MINUTES_REQUIRED_INTERMEDIATE 600 	//For jobs that require a more detailed understanding of either the game in general, or a specific department.
#define MINUTES_REQUIRED_ADVANCED 900 		//For jobs that aren't command, but hold a similar level of importance to either their department or the round as a whole.
#define MINUTES_REQUIRED_COMMAND 1200 		//For command positions, to be weighed against the relevant department


// Banning snowflake - global antag ban. Badly named.
#define ROLE_SYNDICATE			"Syndicate"

//These are synced with the Database, if you change the values of the defines
//then you MUST update the database!
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

GLOBAL_LIST_INIT(poll, list(

))


#define POLL_IGNORE_ALIEN_LARVA "alien_larva"
#define POLL_IGNORE_ASHWALKER "ashwalker"
#define POLL_IGNORE_CLOCKWORK "clockwork"
#define POLL_IGNORE_CONSTRUCT "construct"
#define POLL_IGNORE_CONTRACTOR_SUPPORT "contractor_support"
#define POLL_IGNORE_DEFECTIVECLONE "defective_clone"
#define POLL_IGNORE_DRONE "drone"
#define POLL_IGNORE_EXPERIMENTAL_CLONE "experimental_clone"
#define POLL_IGNORE_GOLEM "golem"
#define POLL_IGNORE_HOLOPARASITE "holoparasite"
#define POLL_IGNORE_HOLYCARP "holy_carp"
#define POLL_IGNORE_HOLYUNDEAD "holy_undead"
#define POLL_IGNORE_IMAGINARYFRIEND "imaginary_friend"
#define POLL_IGNORE_PAI "pai"
#define POLL_IGNORE_POSIBRAIN "posibrain"
#define POLL_IGNORE_POSSESSED_BLADE "possessed_blade"
#define POLL_IGNORE_PYROSLIME "slime"
#define POLL_IGNORE_SENTIENCE_POTION "sentience_potion"
#define POLL_IGNORE_SHADE "shade"
#define POLL_IGNORE_SPECTRAL_BLADE "spectral_blade"
#define POLL_IGNORE_SPIDER "spider"
#define POLL_IGNORE_SPLITPERSONALITY "split_personality"
#define POLL_IGNORE_SWARMER "swarmer"
#define POLL_IGNORE_SYNDICATE "syndicate"

GLOBAL_LIST_INIT(poll_ignore_desc, list(
	POLL_IGNORE_ALIEN_LARVA = "Xenomorph larva",
	POLL_IGNORE_ASHWALKER = "Ashwalker eggs",
	POLL_IGNORE_CONSTRUCT = "Construct",
	POLL_IGNORE_CONTRACTOR_SUPPORT = "Contractor Support Unit",
	POLL_IGNORE_DEFECTIVECLONE = "Defective clone",
	POLL_IGNORE_DRONE = "Drone shells",
	POLL_IGNORE_EXPERIMENTAL_CLONE = "Experimental clone",
	POLL_IGNORE_GOLEM = "Golems",
	POLL_IGNORE_HOLOPARASITE = "Holoparasite",
	POLL_IGNORE_HOLYCARP = "Holy Carp",
	POLL_IGNORE_HOLYUNDEAD = "Holy Undead",
	POLL_IGNORE_IMAGINARYFRIEND = "Imaginary Friend",
	POLL_IGNORE_PAI = "Personal AI",
	POLL_IGNORE_POSIBRAIN = "Positronic brain",
	POLL_IGNORE_POSSESSED_BLADE = "Possessed blade",
	POLL_IGNORE_PYROSLIME = "Slime",
	POLL_IGNORE_SENTIENCE_POTION = "Sentience potion",
	POLL_IGNORE_SHADE = "Shade",
	POLL_IGNORE_SPECTRAL_BLADE = "Spectral blade",
	POLL_IGNORE_SPIDER = "Spiders",
	POLL_IGNORE_SPLITPERSONALITY = "Split Personality",
	POLL_IGNORE_SWARMER = "Swarmer shells",
	POLL_IGNORE_SYNDICATE = "Syndicate",
))
GLOBAL_LIST_INIT(poll_ignore, init_poll_ignore())


/proc/init_poll_ignore()
	. = list()
	for (var/k in GLOB.poll_ignore_desc)
		.[k] = list()

//Job defines for what happens when you fail to qualify for any job during job selection
#define BEOVERFLOW 	1
#define BERANDOMJOB 	2
#define RETURNTOLOBBY 	3

#define ROLE_PREFERENCE_CATEGORY_ANAGONIST "Antagonists"
#define ROLE_PREFERENCE_CATEGORY_MIDROUND_LIVING "Midrounds (Living)"
#define ROLE_PREFERENCE_CATEGORY_MIDROUND_GHOST "Midrounds (Ghost Poll)"
