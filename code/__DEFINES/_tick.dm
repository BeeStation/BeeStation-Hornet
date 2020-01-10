var/internal_tick_usage = 0.2 * world.tick_lag //if you find a better place for this please let me know

#define MAPTICK_LAST_INTERNAL_TICK_USAGE ((internal_tick_usage / world.tick_lag) * 100) //internal_tick_usage is updated every tick by extools
#define TICK_LIMIT_RUNNING (max(90 - MAPTICK_LAST_INTERNAL_TICK_USAGE, 40))
#define TICK_LIMIT_TO_RUN 70
#define TICK_LIMIT_MC 70
#define TICK_LIMIT_MC_INIT_DEFAULT 98

#define TICK_USAGE world.tick_usage //for general usage
#define TICK_USAGE_REAL world.tick_usage    //to be used where the result isn't checked

#define TICK_CHECK ( TICK_USAGE > Master.current_ticklimit )
#define CHECK_TICK ( TICK_CHECK ? stoplag() : 0 )

#define TICK_CHECK_HIGH_PRIORITY ( TICK_USAGE > 95 )
#define CHECK_TICK_HIGH_PRIORITY ( TICK_CHECK_HIGH_PRIORITY? stoplag() : 0 )
