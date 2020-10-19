#define PROFILER_FILENAME "profiler.json"

SUBSYSTEM_DEF(profiler)
	name = "Profiler"
	init_order = INIT_ORDER_PROFILER
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	wait = 600

/datum/controller/subsystem/profiler/Initialize()
	if(CONFIG_GET(flag/auto_profile))
		StartProfiling()
	else
		StopProfiling() //Stop the early start from world/New
	return ..()

/datum/controller/subsystem/profiler/fire()
	if(CONFIG_GET(flag/auto_profile))
		DumpFile()

/datum/controller/subsystem/profiler/Shutdown()
	if(CONFIG_GET(flag/auto_profile))
		DumpFile()
	return ..()

/datum/controller/subsystem/profiler/proc/StartProfiling()
	world.Profile(PROFILE_START)

/datum/controller/subsystem/profiler/proc/StopProfiling()
	world.Profile(PROFILE_STOP)

/datum/controller/subsystem/profiler/proc/DumpFile()
	var/current_profile_data = world.Profile(PROFILE_REFRESH,format="json")
	if(!length(current_profile_data)) //Would be nice to have explicit proc to check this
		stack_trace("Warning, profiling stopped manually before dump.")
	var/json_file = file("[GLOB.log_directory]/[PROFILER_FILENAME]")
	if(fexists(json_file))
		fdel(json_file)
	WRITE_FILE(json_file, current_profile_data)
