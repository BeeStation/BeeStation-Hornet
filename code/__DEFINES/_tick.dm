#define TICK_LIMIT_SENDMAPS_HEADROOM 10 //Percentage of tick to leave unused in addition to byond internal tick usage

#define TICK_LIMIT_RUNNING (100 - TICK_LIMIT_SENDMAPS_HEADROOM - MAPTICK_LAST_INTERNAL_TICK_USAGE)
#define TICK_LIMIT_TO_RUN 70
#define TICK_LIMIT_MC 70
#define TICK_LIMIT_MC_INIT_DEFAULT 98

#define TICK_USAGE world.tick_usage //for general usage
#define TICK_USAGE_REAL world.tick_usage    //to be used where the result isn't checked

#define TICK_CHECK ( TICK_USAGE > Master.current_ticklimit )
#define CHECK_TICK ( TICK_CHECK ? stoplag() : 0 )

#define TICK_CHECK_HIGH_PRIORITY ( TICK_USAGE > 95 )
#define CHECK_TICK_HIGH_PRIORITY ( TICK_CHECK_HIGH_PRIORITY? stoplag() : 0 )
