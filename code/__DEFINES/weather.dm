//A reference to this list is passed into area sound managers, and it's modified in a manner that preserves that reference in ash_storm.dm
GLOBAL_LIST_EMPTY(ash_storm_sounds)
GLOBAL_LIST_EMPTY(rad_storm_sounds)

#define STARTUP_STAGE 1
#define MAIN_STAGE 2
#define WIND_DOWN_STAGE 3
#define END_STAGE 4

// WEATHER FLAGS
/// If weather will affect mobs
#define WEATHER_MOBS (1<<0)
/// If weather will be allowed to affect indoor areas
#define WEATHER_INDOORS (1<<1)
/// If weather is endless and can only be stopped manually
#define WEATHER_ENDLESS (1<<2)
/// If weather will be detected by a barometer
#define WEATHER_BAROMETER (1<<3)
/// Alerts are only sent to people within affected area rather than on affected z-levels
#define WEATHER_STRICT_ALERT (1<<4)
