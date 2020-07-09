SUBSYSTEM_DEF(puddle)
	name = "Puddle"
	wait = 5
	runlevels = RUNLEVEL_GAME
	var/list/puddlelist

/datum/controller/subsystem/puddle/Initialize(start_timeofday)
	. = ..()
	puddlelist = list()

/datum/controller/subsystem/puddle/stat_entry(msg)
	..("P: [length(puddlelist)]")

/datum/controller/subsystem/puddle/fire(resumed)
	set waitfor = FALSE
	for(var/obj/puddle/puddle in puddlelist)
		puddle.called()
	/*
		INVOKE_ASYNC(puddle, /obj/puddle/proc/spread)
		INVOKE_ASYNC(puddle, /obj/puddle/proc/update)
		*/
