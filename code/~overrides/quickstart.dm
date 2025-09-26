#ifdef QUICKSTART
#warn WARNING: Compiling with QUICKSTART.
/datum/job/assistant/debug
	title = "Debug Job"
	outfit = /datum/outfit/debug

/datum/controller/subsystem/ticker
	start_immediately = TRUE

/datum/controller/subsystem/job/AssignRole(mob/dead/new_player/player, rank, latejoin = FALSE)
	. = ..(player, "Debug Job", rank, latejoin)

/mob/dead/new_player/authenticated
	ready = TRUE
#endif
