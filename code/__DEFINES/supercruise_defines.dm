//The amount of a ship that has to be damaged before it is considered destroyed (45%) (This seems very low, but damaging a turf only does 20% damage for that turf, with each turf having up to 5 damage levels)
#define SHIP_INTEGRITY_FACTOR_NPC 0.8
#define SHIP_INTEGRITY_FACTOR_PLAYER 0.45

//Faction status
#define FACTION_STATUS_FRIENDLY "friendly"
#define FACTION_STATUS_NEUTRAL "neutral"
#define FACTION_STATUS_HOSTILE "hostile"

//How AIs should aproach combat
#define BATTLE_POLICY_AVOID 0.7			//For ships that don't wanna combat
#define BATTLE_POLICY_CAREFUL 0.45		//For ships that don't mind a fight, but would rather not die
#define BATTLE_POLICY_SUSTAINED 0.15	//Will keep a fight going and will only retreat when very, very low
#define BATTLE_POLICY_NO_RETREAT 0		//Death to nanotrasen
