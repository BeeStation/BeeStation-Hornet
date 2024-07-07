#define RBMK_TEMPERATURE_OPERATING 640 //Celsius
#define RBMK_TEMPERATURE_WARNING 800 //At this point the entire station is alerted to a meltdown.
#define RBMK_TEMPERATURE_CRITICAL 900 //Kablowey

#define RBMK_NO_COOLANT_TOLERANCE 5 //How many process()ing ticks the reactor can sustain without coolant before slowly taking damage

#define RBMK_PRESSURE_OPERATING 6500 //KPA
#define RBMK_PRESSURE_WARNING 8200 //KPA, At this point the entire station is alerted to a meltdown.
#define RBMK_PRESSURE_CRITICAL 10100 //KPA, Kaboom

#define RBMK_MAX_CRITICALITY 3 //No more criticality than N for now.

#define RBMK_POWER_FLAVOURISER 8000 //To turn those KWs into something usable

#define WARNING_TIME_DELAY 60 //to prevent accent sounds from layering
#define REACTOR_COUNTDOWN_TIME 30 SECONDS

///High pressure damage
#define RBMK_PRESSURE_DAMAGE (1<<0)
///High temperature damage
#define RBMK_TEMPERATURE_DAMAGE (1<<1)

#define REACTOR_INACTIVE 0 // No or minimal energy
#define REACTOR_NOMINAL 1 // Normal operation
#define REACTOR_WARNING 2 // Integrity damaged
#define REACTOR_DANGER 3 // Integrity < 50%
#define REACTOR_EMERGENCY 4 // Integrity < 25%
#define REACTOR_MELTING 5 // Pretty obvious.

#define REACTOR_MELTING_PERCENT 5
#define REACTOR_EMERGENCY_PERCENT 25
#define REACTOR_DANGER_PERCENT 50
#define REACTOR_WARNING_PERCENT 100

//Blame Aramix for this monstrosity. In case you are wondering what this is, it is exp(0.005669), which is used for graphing reactor damage calculations (constant)
#define REACTOR_DAMAGE_MAGIC_NUMBER 1.0056850991882220077025096652119341723277747452195921845851
