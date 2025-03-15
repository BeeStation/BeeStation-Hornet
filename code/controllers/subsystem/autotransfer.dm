SUBSYSTEM_DEF(autotransfer)
	name = "Autotransfer Vote"
	flags = SS_KEEP_TIMING | SS_BACKGROUND
	wait = 1 MINUTES

	var/reminder_time
	var/checkvotes_time
	var/decay_start
	var/decay_count = 0
	var/connected_votes_to_leave = 0
	var/required_votes_to_leave = 0

/datum/controller/subsystem/autotransfer/Initialize()
	reminder_time = REALTIMEOFDAY + CONFIG_GET(number/autotransfer_decay_start)
	checkvotes_time = REALTIMEOFDAY + 5 MINUTES
	required_votes_to_leave = length(GLOB.clients) * (CONFIG_GET(number/autotransfer_percentage) - CONFIG_GET(number/autotransfer_decay_amount) * decay_count)

	if(!CONFIG_GET(flag/vote_autotransfer_enabled))
		can_fire = FALSE

	return SS_INIT_SUCCESS

/datum/controller/subsystem/autotransfer/fire()
	// Calculate always to account for disconnected/reconnected players
	// Alternatively this could just hook into client/new and client/destroy, but
	// it doesn't matter that much if we lose count for a bit
	connected_votes_to_leave = 0
	for(var/client/c in GLOB.clients)
		if (c.player_details.voted_to_leave)
			connected_votes_to_leave ++

	if(REALTIMEOFDAY > checkvotes_time)
		if(decay_start)
			decay_count++

		required_votes_to_leave = max(length(GLOB.clients) * (CONFIG_GET(number/autotransfer_percentage) - CONFIG_GET(number/autotransfer_decay_amount) * decay_count), 1)

		if(connected_votes_to_leave >= required_votes_to_leave)
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
		to_chat(world, "<font color='purple'>Don't forget you can vote to leave by pushing the button on the status tab if you're ready for the round to end!</font>")
		reminder_time = reminder_time + CONFIG_GET(number/autotransfer_decay_start)
