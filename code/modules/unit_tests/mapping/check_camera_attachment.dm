/datum/unit_test/map_test/camera/check_turf(turf/check_turf, is_map_border)
	var/found = FALSE
	for (var/obj/machinery/camera/camera in check_turf)
		if (found)
			return "Multiple cameras detected"
		if (!isclosedturf(get_step(check_turf, camera.dir)))
			return "Camera not attached to a wall"
		found = TRUE
