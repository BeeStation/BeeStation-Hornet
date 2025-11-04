SUBSYSTEM_DEF(autotransfer)
	name = "Autotransfer Vote"
	flags = SS_KEEP_TIMING | SS_BACKGROUND
	wait = 2 MINUTES
	var/time_to_vote

/datum/controller/subsystem/autotransfer/Initialize()
	if(!CONFIG_GET(flag/vote_autotransfer_enabled))
		can_fire = FALSE
		return SS_INIT_NO_NEED

	time_to_vote = REALTIMEOFDAY + 60 MINUTES
	return SS_INIT_SUCCESS

/datum/controller/subsystem/autotransfer/fire()
	if(SSshuttle.emergencyNoRecall == TRUE)
		can_fire = FALSE //The shuttle has already been called with no option to recall. Only admin fuckery can stop it.
		return

	if(REALTIMEOFDAY > time_to_vote)
		INVOKE_ASYNC(SSvote, TYPE_PROC_REF(/datum/controller/subsystem/vote, initiate_vote), /datum/vote/shuttle_vote, "Autotransfer Subsystem", null, TRUE)
		time_to_vote += (CONFIG_GET(number/vote_autotransfer_interval) MINUTES)
