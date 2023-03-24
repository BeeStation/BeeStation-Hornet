

//Values for antag preferences, event roles, etc. unified here

//Hour requirements before players can choose to be specific jobs

#define MINUTES_REQUIRED_BASIC 120 			//For jobs that are easy to grief with, but not necessarily hard for new players
#define MINUTES_REQUIRED_INTERMEDIATE 600 	//For jobs that require a more detailed understanding of either the game in general, or a specific department.
#define MINUTES_REQUIRED_ADVANCED 900 		//For jobs that aren't command, but hold a similar level of importance to either their department or the round as a whole.
#define MINUTES_REQUIRED_COMMAND 1200 		//For command positions, to be weighed against the relevant department

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

//Job defines for what happens when you fail to qualify for any job during job selection
#define BEOVERFLOW 	1
#define BERANDOMJOB 	2
#define RETURNTOLOBBY 	3
