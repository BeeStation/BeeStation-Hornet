///How much power emergency lights will consume per tick
#define LIGHT_EMERGENCY_POWER_USE 5 WATT
// status values shared between lighting fixtures and items
#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3

///Min time for a spark to happen in a broken light
#define BROKEN_SPARKS_MIN (30 SECONDS)
///Max time for a spark to happen in a broken light
#define BROKEN_SPARKS_MAX (90 SECONDS)

///Amount of time that takes an ethereal to take energy from the lights
#define LIGHT_DRAIN_TIME 2.5 SECONDS
///Amount of charge the ethereal gain after the drain
#define LIGHT_POWER_GAIN 35
