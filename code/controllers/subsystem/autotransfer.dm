SUBSYSTEM_DEF(autotransfer)
	name = "Autotransfer Vote"
	flags = SS_KEEP_TIMING | SS_BACKGROUND
	wait = 2 MINUTES
	var/time_to_vote
	var/override_limit

/datum/controller/subsystem/autotransfer/Initialize()
	if(!CONFIG_GET(flag/vote_autotransfer_enabled))
		can_fire = FALSE
		return SS_INIT_NO_NEED

	time_to_vote = REALTIMEOFDAY + (CONFIG_GET(number/shuttle_refuel_delay)) + (CONFIG_GET(number/vote_autotransfer_interval))
	override_limit = (CONFIG_GET(number/vote_autotransfer_override))
	//Make sure a value has been set before fully initializing it. If this value is zero it needs to stay zero.
	if(override_limit)
		override_limit += REALTIMEOFDAY

	return SS_INIT_SUCCESS

/datum/controller/subsystem/autotransfer/fire()
	if(SSshuttle.emergencyNoRecall == TRUE)
		can_fire = FALSE //The shuttle has already been called with no option to recall
		return

	//This will fail if override_limit is 0, allowing for indefinite round length
	if(override_limit && REALTIMEOFDAY > override_limit)
		if(SSshuttle.canEvac() == TRUE) //This must include the == TRUE because all returns for this proc have a value, we specifically want to check for TRUE
			SSshuttle.requestEvac(null, "Crew Transfer Requested.")
			can_fire = FALSE //This system has served its purpose for as long as it can
		SSshuttle.emergencyNoRecall = TRUE
		return

	if(REALTIMEOFDAY > time_to_vote)
		INVOKE_ASYNC(SSvote, TYPE_PROC_REF(/datum/controller/subsystem/vote, initiate_vote), /datum/vote/shuttle_vote, "Autotransfer Subsystem", null, TRUE)
		time_to_vote += (CONFIG_GET(number/vote_autotransfer_interval))
