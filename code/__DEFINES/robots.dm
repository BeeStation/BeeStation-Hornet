// AI laws
#define LAW_VALENTINES "valentines"
#define LAW_ZEROTH "zeroth"
#define LAW_INHERENT "inherent"
#define LAW_SUPPLIED "supplied"
#define LAW_ION "ion"
#define LAW_HACKED "hacked"

#define DEFAULT_AI_LAWID "default"

//Bot defines, placed here so they can be read by other things!
#define BOT_STEP_DELAY 4 //Delay between movemements
#define BOT_STEP_MAX_RETRIES 5 //Maximum times a bot will retry to step from its position

#define DEFAULT_SCAN_RANGE		7	//default view range for finding targets.

//Mode defines
#define BOT_IDLE 			0	// Idle
#define BOT_HUNT 			1	// Found target, hunting
#define BOT_PREP_ARREST 	2	// At target, preparing to arrest
#define BOT_ARREST			3	// Arresting target
#define BOT_START_PATROL	4	// Start patrol
#define BOT_PATROL			5	// Patrolling
#define BOT_SUMMON			6	// Summoned by PDA
#define BOT_CLEANING 		7	// Cleaning (cleanbots)
#define BOT_REPAIRING		8	// Repairing hull breaches (floorbots)
#define BOT_MOVING			9	// For clean/floor/med bots, when moving.
#define BOT_HEALING			10	// Healing people (medbots)
#define BOT_RESPONDING		11	// Responding to a call from the AI
#define BOT_DELIVER			12	// Moving to deliver
#define BOT_GO_HOME			13	// Returning to home
#define BOT_BLOCKED			14	// Blocked
#define BOT_NAV 			15	// Computing navigation
#define BOT_WAIT_FOR_NAV	16	// Waiting for nav computation
#define BOT_NO_ROUTE		17	// No destination beacon found (or no route)
#define BOT_EMPTY			18  // No fuel/chems inside of them
#define BOT_TIPPED 			19  // Someone tipped a bot over ;_;

//Bot types
#define SEC_BOT (1<<0)
#define MULE_BOT (1<<1)
#define FLOOR_BOT (1<<2)
#define CLEAN_BOT (1<<3)
#define MED_BOT (1<<4)
#define HONK_BOT (1<<5)
#define FIRE_BOT (1<<6)

//transfer_ai() defines. Main proc in ai_core.dm
///Downloading AI to InteliCard
#define AI_TRANS_TO_CARD 1
///Uploading AI from InteliCard
#define AI_TRANS_FROM_CARD 2
///Malfunctioning AI hijacking mecha
#define AI_MECH_HACK 3

//AI notification defines
#define	NEW_BORG 1
#define	NEW_MODEL 2
#define	RENAME 3
#define	AI_SHELL 4
#define	DISCONNECT 5

//Assembly defines
#define ASSEMBLY_FIRST_STEP 	0
#define ASSEMBLY_SECOND_STEP 	1
#define ASSEMBLY_THIRD_STEP     2
#define ASSEMBLY_FOURTH_STEP    3
#define ASSEMBLY_FIFTH_STEP     4

#define MALFUNCTION_DURATION 30 SECONDS
#define MALFUNCTION_DURATION_VINE 10 SECONDS
