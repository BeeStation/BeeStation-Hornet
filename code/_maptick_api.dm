#define MAPTICK_LAST_INTERNAL_TICK_USAGE ((GLOB.maptick.last_internal_tick_usage / world.tick_lag) * 100)

/datum/maptick_helper
	var/last_internal_tick_usage = 0

/datum/maptick_helper/New()
	last_internal_tick_usage = 0.2 * world.tick_lag // default value of 20%

/proc/maptick_initialize()
#ifdef TRAVISBUILDING
	return FALSE
#else
	if(!GLOB.maptick)
		world << "MAPTICK DATUM NOT FOUND"
		world.log << "MAPTICK DATUM NOT FOUND"
		return FALSE
	if(!fexists("maptick.dll"))
		world << "MAPTICK DLL NOT FOUND"
		world.log << "MAPTICK DLL NOT FOUND"
		return FALSE
	var/result = call("maptick.dll", "initialize")("\ref[GLOB.maptick]")
	world << result
	world.log << result
	if(findtext(result, "MAPTICK ERROR"))
		return FALSE
	return TRUE
#endif
/proc/maptick_shutdown()
#ifdef TRAVISBUILDING
	return FALSE
#else
	call("maptick.dll", "cleanup")()
#endif
