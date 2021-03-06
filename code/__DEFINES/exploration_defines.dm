
#define SHIP_INTEGRITY_FACTOR 0.12	//The amount of a ship that has to be damaged before it is considered destroyed (12%) (This seems very low, but damaging a turf only does 20% damage for that turf, with each turf having up to 5 damage levels)

#define FACTION_STATUS_FRIENDLY "friendly"
#define FACTION_STATUS_NEUTRAL "neutral"
#define FACTION_STATUS_HOSTILE "hostile"

//Bluespace drive types

#define BLUESPACE_DRIVE_BSLEVEL 0
#define BLUESPACE_DRIVE_SPACELEVEL 1

//Generating status
#define BS_LEVEL_IDLE 0
#define BS_LEVEL_GENERATING 1
#define BS_LEVEL_USED 2
#define BS_LEVEL_QUEUED 3
