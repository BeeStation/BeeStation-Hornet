SUBSYSTEM_DEF(autotransfer)
	name = "Autotransfer Vote"
	flags = SS_KEEP_TIMING | SS_BACKGROUND
	wait = 2 MINUTES
	runlevels = RUNLEVEL_GAME
	var/time_to_vote
	var/forced_call_time

/datum/controller/subsystem/autotransfer/Initialize()
	if(!CONFIG_GET(flag/vote_autotransfer_enabled))
		can_fire = FALSE
		return SS_INIT_NO_NEED

	time_to_vote = world.time + (CONFIG_GET(number/shuttle_refuel_delay)) + (CONFIG_GET(number/vote_autotransfer_interval))
	forced_call_time = (CONFIG_GET(number/vote_autotransfer_override))
	//Make sure a value has been set before fully initializing it. If this value is zero it needs to stay zero.
	if(forced_call_time)
		forced_call_time += world.time

	return SS_INIT_SUCCESS

/datum/controller/subsystem/autotransfer/fire()
	//No reason to vote if shuttle is already called unless it has been recalled
	if(!SSshuttle.canEvac() && SSshuttle.emergency.mode != SHUTTLE_RECALL)
		return

	//This will fail if forced_call_time is 0, allowing for indefinite round length
	if(forced_call_time && world.time > forced_call_time)
		if(SSshuttle.canEvac() == TRUE) //This must include the == TRUE because all returns for this proc have a value, we specifically want to check for TRUE
			SSshuttle.requestEvac(null, "Crew Transfer Requested.")
			can_fire = FALSE //This system has served its purpose for as long as it can
		SSshuttle.emergencyNoRecall = TRUE
		return

	if(world.time > time_to_vote)
		INVOKE_ASYNC(SSvote, TYPE_PROC_REF(/datum/controller/subsystem/vote, initiate_vote), /datum/vote/shuttle_vote, "Autotransfer", null, TRUE)
		time_to_vote += (CONFIG_GET(number/vote_autotransfer_interval))
