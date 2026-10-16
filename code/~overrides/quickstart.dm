#ifdef QUICKSTART
#warn WARNING: Compiling with QUICKSTART.
/datum/job/debugger
	title = "Debug Job"
	outfit = /datum/outfit/debug

/datum/controller/subsystem/ticker
	start_immediately = TRUE

/datum/controller/subsystem/job/assign_role(mob/dead/new_player/authenticated/player, datum/job/job, latejoin = FALSE, do_eligibility_checks = TRUE)
	return ..(player, get_job_type(/datum/job/debugger), latejoin, do_eligibility_checks)

/mob/dead/new_player/authenticated
	ready = TRUE
#endif
