
/*
 * Converts a shuttle to TGM data format.
 */
/obj/docking_port/mobile/proc/get_shuttle_tgm_data()
	var/list/turfs = return_turfs()
	//Converts shuttle turfs to TGM map format
	return convert_map_to_tgm(
		turfs,
		SAVE_DEFAULT,
		SAVE_SHUTTLEAREA_ONLY
	)
