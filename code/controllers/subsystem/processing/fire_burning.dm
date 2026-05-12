/// The subsystem used to tick [/datum/component/burning] instances.
PROCESSING_SUBSYSTEM_DEF(burning)
	name = "Burning"
	dependencies = list(
		/datum/controller/subsystem/atoms
	)
	flags = SS_NO_INIT|SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
