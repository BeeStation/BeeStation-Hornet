SUBSYSTEM_DEF(demand)
	name = "Demand"
	wait = 2.5 MINUTES
	init_order = SS_NO_INIT
	runlevels = RUNLEVEL_GAME


/datum/controller/subsystem/demand/fire()
	if(world.time < SSticker.round_start_time + 10 MINUTES)
		return
	recover_obj_demands()
