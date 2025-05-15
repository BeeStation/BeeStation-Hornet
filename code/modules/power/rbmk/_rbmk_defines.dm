#define RBMK_TEMPERATURE_OPERATING 640 //Celsius
#define RBMK_TEMPERATURE_WARNING 800 //At this point the entire station is alerted to a meltdown.
#define RBMK_TEMPERATURE_CRITICAL 900 //Kablowey

#define RBMK_NO_COOLANT_TOLERANCE 5 //How many process()ing ticks the reactor can sustain without coolant before slowly taking damage

#define RBMK_PRESSURE_OPERATING 6500 //KPA
#define RBMK_PRESSURE_WARNING 8200 //KPA, At this point the entire station is alerted to a meltdown.
#define RBMK_PRESSURE_CRITICAL 10100 //KPA, Kaboom

#define RBMK_MAX_CRITICALITY 3 //No more criticality than N for now.

#define RBMK_POWER_FLAVOURISER_LOW 0.6 // To turn into something usable (kW), used at lower powers as a square law, transitions to high power linear relationship
#define RBMK_POWER_FLAVOURISER_HIGH 800 // used at high powers, linear relationship


#define RBMK_BASE_COOLING_FACTOR 1.00 // How well the coolant gas cools the reactor. A value of 1 (excluding gas absorption effectiveness and random gas absorption constant) will immediately set the reactor temperature to coolant temperature
#define RBMK_COOLANT_TEMPERATURE_MULTIPLIER 2.5 // a penalty to increase the output gas temperature beyond what the internal temperature is (makes it so there is more of a challenge to cool down output gases)
#define RBMK_COOLANT_FLOW_RESTRICTION 0.9 // How well can the coolant gas flow through the reactor, a value of 1.0 assumes there is no restriction (gas will immediately equalise from input to output buffers)
#define RBMK_TEMPERATURE_MULTIPLIER 2.0 // How much based on the rate of reaction do we heat up in kelvin (signifying the heat dissipation from fuel of the reactor)
#define RBMK_POWER_TO_TEMPERATURE_MULTIPLIER 0.02 // how much does produced power increase our internal temperature

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

#define REACTOR_NEW_SEALS 0.875
#define REACTOR_CRACKED_SEALS 0.5

#define SAFE_POWER_LEVEL 20
