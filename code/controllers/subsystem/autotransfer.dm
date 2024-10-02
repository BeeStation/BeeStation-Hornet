SUBSYSTEM_DEF(autotransfer)
	name = "Autotransfer Vote"
	flags = SS_KEEP_TIMING | SS_BACKGROUND
	wait = 1 MINUTES

	var/reminder_time
	var/checkvotes_time
	var/decay_start
	var/decay_count = 0
	var/list/connected_votes_to_leave = list()


/datum/controller/subsystem/autotransfer/Initialize()
	reminder_time = REALTIMEOFDAY + CONFIG_GET(number/autotransfer_decay_start)
	checkvotes_time = REALTIMEOFDAY + 5 MINUTES

	if(!CONFIG_GET(flag/vote_autotransfer_enabled))
		can_fire = FALSE

	return SS_INIT_SUCCESS

/datum/controller/subsystem/autotransfer/fire()
	if(REALTIMEOFDAY > checkvotes_time)
		if(decay_start)
			decay_count++

		var/list/connected_ckeys = list()
		for(var/client/c in GLOB.clients)
			connected_ckeys += c.ckey
		connected_votes_to_leave = connected_ckeys & GLOB.total_votes_to_leave

		if(length(connected_votes_to_leave) >= (length(connected_ckeys) * (CONFIG_GET(number/autotransfer_percentage) - CONFIG_GET(number/autotransfer_decay_amount) * decay_count)))
			if(SSshuttle.canEvac() == TRUE) //This must include the == TRUE because all returns for this proc have a value, we specifically want to check for TRUE
				SSshuttle.requestEvac(null, "Crew Transfer Requested.")
				SSshuttle.emergencyNoRecall = TRUE
				can_fire = FALSE //The only way out of this shuttle call is admin override. They probably don't care about democracy anymore.
			return

	//Reset the next vote check
	checkvotes_time = REALTIMEOFDAY + 5 MINUTES

	if(REALTIMEOFDAY > reminder_time)
		decay_start = TRUE
		sound_to_playing_players('sound/misc/server-ready.ogg')
		to_chat(world, "\n<font color='purple'>Don't forget to adjust your vote to leave if you're ready for the round to end!</font>")
		reminder_time = reminder_time + CONFIG_GET(number/autotransfer_decay_start)
