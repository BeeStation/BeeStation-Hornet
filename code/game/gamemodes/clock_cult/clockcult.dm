/datum/game_mode/clockcult
	name = "clockcult"
	config_tag = "clockcult"

//==========================
//==== Clock cult procs ====
//==========================

/proc/is_clock_cultist(mob/living/M)
	return M?.mind?.has_antag_datum(/datum/antagonist/clockcult)
