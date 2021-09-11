
/*
 * Converts a shuttle to TGM data format.
 */
/obj/docking_port/mobile/proc/get_shuttle_tgm_data()
	var/list/turfs = return_turfs()
	//Converts shuttle turfs to TGM map format
	return convert_map_to_tgm(
		turfs,
		SAVE_DEFAULT | SAVE_RANDOMIZED_STACKS,
		SAVE_SHUTTLEAREA_ONLY,
		list(
			"pixel_x" = MAPEXPORTER_VAR_NUM,
			"pixel_y" = MAPEXPORTER_VAR_NUM,
			"dir" = MAPEXPORTER_VAR_NUM,
			"req_access" = MAPEXPORTER_VAR_ACCESS_LIST,
			"req_one_access" = MAPEXPORTER_VAR_ACCESS_LIST,
			"piping_layer" = MAPEXPORTER_VAR_NUM,
			"color" = MAPEXPORTER_VAR_COLOUR,
			"pipe_color" = MAPEXPORTER_VAR_COLOUR,
			"amount" = MAPEXPORTER_VAR_NUM,
			"fingerprintlast" = MAPEXPORTER_VAR_CKEY,
		),
	)
