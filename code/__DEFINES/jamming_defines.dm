
//Radio jammer levels
//They will jam any signals that have the same or lower protection value
#define JAMMER_LEVEL_NONE -1			//Jams nothing
#define RADIO_JAMMER_ABDUCTOR_LEVEL 1	//Power of the abductor radio jammer
#define RADIO_JAMMER_TRAITOR_LEVEL 3	//Power of the traitor radio jammer
#define RADIO_JAMMER_MAINTENANCE_LEVEL 1	// Maintenance jams some signals with minor jamming

//Radio jammer protection level
#define JAMMER_PROTECTION_RADIO_BASIC 0		//Basic comms channels
#define JAMMER_PROTECTION_RADIO_ADVANCED 1	//Superspace comms channels (CC, Syndicate)
#define JAMMER_PROTECTION_SENSOR_NETWORK 0	//Suit sensor network
#define JAMMER_PROTECTION_CAMERAS 2			//Cameras are stronger than abductor jammers
#define JAMMER_PROTECTION_WIRELESS 1		//Wireless networking
#define JAMMER_PROTECTION_AI_SHELL 2		//AI shell protection
#define JAMMER_PROTECTION_SILICON_COMMS 1	//Silicon comms

// Signal jamming
/// Not jammed
#define JAM_NONE 0
/// Some jamming effects, but not completely disabling the device
#define JAM_MINOR 1
/// Fully jammed, cannot function
#define JAM_FULL 2
