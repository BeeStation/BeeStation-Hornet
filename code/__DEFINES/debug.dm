
/// Tick overrun debug define
/// This will cause stoplag() to be tracked, and when the MC freezes
/// anything running stoplag() will be logged.
/// Will incur a performance overhead when the controller is frozen, otherwise
/// shouldn't be that intensive.
//#define TICK_OVERRUN_DEBUG

#ifdef TICK_OVERRUN_DEBUG
GLOBAL_VAR_INIT(controller_frozen, FALSE)
#endif
