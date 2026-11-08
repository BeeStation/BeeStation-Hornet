#define AIRLOCK_SECURITY_NONE			0 //Normal airlock				//Wires are not secured
#define AIRLOCK_SECURITY_IRON			1 //Medium security airlock		//There is a simple iron over wires (use welder)
#define AIRLOCK_SECURITY_PLASTEEL_I_S	2 								//Sliced inner plating (use crowbar), jumps to 0
#define AIRLOCK_SECURITY_PLASTEEL_I		3 								//Removed outer plating, second layer here (use welder)
#define AIRLOCK_SECURITY_PLASTEEL_O_S	4 								//Sliced outer plating (use crowbar)
#define AIRLOCK_SECURITY_PLASTEEL_O		5 								//There is first layer of plasteel (use welder)
#define AIRLOCK_SECURITY_PLASTEEL		6 //Max security airlock		//Fully secured wires (use wirecutters to remove grille, that is electrified)

#define AIRLOCK_WIRE_SECURITY_NONE 0	// Airlocks that are super easy to hack and have mostly labelled wires. No risk.
#define AIRLOCK_WIRE_SECURITY_SIMPLE 1	// Airlock with less labelled wires, takes longer to hack but not shock risk.
#define AIRLOCK_WIRE_SECURITY_PROTECTED 2	// Airlock has no labelled wires and has a single shock wire that is labelled
#define AIRLOCK_WIRE_SECURITY_ADVANCED 3	// Airlock has 1 duds and 1 shock wire
#define AIRLOCK_WIRE_SECURITY_ELITE 4	// Airlock has 1 duds and 2 shock wires
#define AIRLOCK_WIRE_SECURITY_MAXIMUM 5	// Airlock has 2 duds, 2 shock wires and only a single power cable.

// Airlock light states, used for generating the light overlays
#define AIRLOCK_LIGHT_BOLTS "bolts"
#define AIRLOCK_LIGHT_EMERGENCY "emergency"
#define AIRLOCK_LIGHT_DENIED "denied"
#define AIRLOCK_LIGHT_CLOSING "closing"
#define AIRLOCK_LIGHT_OPENING "opening"


#define AIRLOCK_CLOSED 1
#define AIRLOCK_CLOSING 2
#define AIRLOCK_OPEN 3
#define AIRLOCK_OPENING 4
#define AIRLOCK_DENY 5
#define AIRLOCK_EMAG 6

#define AIRLOCK_INTEGRITY_N 300 // Normal airlock integrity
#define AIRLOCK_INTEGRITY_MULTIPLIER 1.5 // How much reinforced doors health increases
#define AIRLOCK_DAMAGE_DEFLECTION_N 21 // Normal airlock damage deflection
#define AIRLOCK_DAMAGE_DEFLECTION_R 30 // Reinforced airlock damage deflection

#define AIRLOCK_DENY_ANIMATION_TIME (0.6 SECONDS) /// The amount of time for the airlock deny animation to show
#define DOOR_CLOSE_WAIT 60 /// Time before a door closes, if not overridden
