SUBSYSTEM_DEF(lag)
	name = "Lag"
	flags = SS_NO_INIT
	wait = 1
	can_fire = FALSE

/datum/controller/subsystem/lag/fire()
	//God I love maths
	while(TRUE)
		var/list/block = block(locate(100, 100, 2), locate(130, 130, 2))
		for(var/turf/T as() in block)
			T.ImmediateDisableAdjacency()
		CHECK_TICK

/client/proc/toggle_lag()
	set name = "Toggle Lag"
	set category = "Debug"

	if(!check_rights(R_DEBUG) && !check_rights(R_SERVER))
		return

	SSlag.can_fire = !SSlag.can_fire

	message_admins("[key_name_admin(src)] TOGGLED LAG TO [SSlag.can_fire ? "ON" : "OFF"]")
	to_chat(world, "[key_name_admin(src)] TOGGLED LAG TO [SSlag.can_fire ? "ON" : "OFF"]")
	log_game("[key_name_admin(src)] TOGGLED LAG TO [SSlag.can_fire ? "ON" : "OFF"]")
