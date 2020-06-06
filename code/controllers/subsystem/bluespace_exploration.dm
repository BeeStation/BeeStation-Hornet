SUBSYSTEM_DEF(bluespace_exploration)
	name = "Bluespace Exploration"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_BS_EXPLORATION

	var/datum/space_level/reserved_bs_level

//====================================
//These procs are ~~likely~~ (they just straight are) to be very expensive
//Thus have a lot of check ticks.
//Bluespace Drives take a long time, so loading of the new z_levels
//can be slowly done in the back ground while in transit.
//However, it should be noted if the server is under high load,
//We still want new z_levels to be generated otherwise they will be
//locked in transit forever.
//====================================

//Checks the z-level to see if any mobs with minds will be left behind when jumping
//Returns TRUE if it is safe to warp away from (Mobs are on shuttle)
/datum/controller/subsystem/bluespace_exploration/proc/check_z_level()
	return TRUE

/datum/controller/subsystem/bluespace_exploration/proc/wipe_z_level()
	return TRUE

/datum/controller/subsystem/bluespace_exploration/proc/generate_z_level(difficulty = 0)
	wipe_z_level()
