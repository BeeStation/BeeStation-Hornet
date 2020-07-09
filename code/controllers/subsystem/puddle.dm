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
	// used on the machines subsystem, apparently makes this faster
	var/list/pudl = src.puddlelist
	
	for(var/obj/puddle/puddle in pudl)
		puddle.called()
	/*
		INVOKE_ASYNC(puddle, /obj/puddle/proc/spread)
		INVOKE_ASYNC(puddle, /obj/puddle/proc/update)
		*/
