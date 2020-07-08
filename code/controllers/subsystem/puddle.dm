SUBSYSTEM_DEF(puddle)
	name = "Puddle"
	wait = 5
	runlevels = RUNLEVEL_GAME
	var/list/puddlelist = list()

/datum/controller/subsystem/puddle/fire(resumed)
	set waitfor = FALSE
	var/list/puddles = list()
	for(var/obj/puddle/puddle in puddlelist)
		puddles |= puddle
	for(var/obj/puddle/puddle in puddles)
		puddle.called()
	/*
		INVOKE_ASYNC(puddle, /obj/puddle/proc/spread)
		INVOKE_ASYNC(puddle, /obj/puddle/proc/update)
		*/
