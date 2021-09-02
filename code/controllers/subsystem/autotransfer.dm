SUBSYSTEM_DEF(autotransfer)
	name = "Autotransfer Vote"
	flags = SS_KEEP_TIMING | SS_BACKGROUND
	wait = 1 MINUTES

	var/starttime
	var/targettime

	var/cooldown_time

/datum/controller/subsystem/autotransfer/Initialize(timeofday)
	starttime = world.time
	targettime = starttime + CONFIG_GET(number/vote_autotransfer_initial)

	if(!CONFIG_GET(flag/vote_autotransfer_enabled))
		can_fire = FALSE

	. = ..()

/datum/controller/subsystem/autotransfer/fire()
	if(world.time > targettime)
		SSvote.initiate_vote("transfer", null)
		targettime = targettime + CONFIG_GET(number/vote_autotransfer_interval)

/datum/controller/subsystem/autotransfer/proc/try_vote(mob/user, vote_name)
	if(!CONFIG_GET(flag/head_transfer_vote))
		return
	if(!SSshuttle.canEvac(user))
		return
	if(world.time < cooldown_time)
		to_chat(user, "<span class='warning'>A transfer vote has been triggered recently. Please wait [DisplayTimeText(cooldown_time - world.time)] or contact your station's captain for emergency evacuation.</span>")
		return
	cooldown_time = world.time + CONFIG_GET(number/vote_transfer_cooldown)
	SSvote.initiate_vote("transfer", vote_name)
