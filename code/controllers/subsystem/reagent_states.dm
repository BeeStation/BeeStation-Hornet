PROCESSING_SUBSYSTEM_DEF(reagent_states)
	name = "Reagents"
	priority = 40
	flags = SS_NO_INIT|SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	var/deleting = FALSE

/datum/controller/subsystem/processing/reagent_states/fire(resumed = FALSE)
	. = ..()
	if(MC_TICK_CHECK)//if subsystems pause
		if(!deleting && cost > 1000)
			deleting = TRUE
			//for(var/I in GLOB.smoke)
			//	qdel(I)
			//for(var/I in GLOB.vapour)
			//	qdel(I)
			deleting = FALSE
		return
