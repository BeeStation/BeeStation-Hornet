#define COOLANT_INPUT_GATE airs[1]
#define MODERATOR_INPUT_GATE airs[2]
#define COOLANT_OUTPUT_GATE airs[3]

#define RBMK_TEMPERATURE_OPERATING 640 //Celsius
#define RBMK_TEMPERATURE_CRITICAL 800 //At this point the entire ship is alerted to a meltdown. This may need altering
#define RBMK_TEMPERATURE_MELTDOWN 900 //Kablowey

#define RBMK_NO_COOLANT_TOLERANCE 5 //How many process()ing ticks the reactor can sustain without coolant before slowly taking damage

#define RBMK_PRESSURE_OPERATING 6500 //KPA
#define RBMK_PRESSURE_WARNING 8200 //KPA
#define RBMK_PRESSURE_CRITICAL 10100 //KPA

#define RBMK_MAX_CRITICALITY 3 //No more criticality than N for now.

#define RBMK_POWER_FLAVOURISER 8000 //To turn those KWs into something usable

#define REACTOR_COUNTDOWN_TIME 30 SECONDS
