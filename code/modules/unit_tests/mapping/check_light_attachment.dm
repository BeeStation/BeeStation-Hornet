/datum/unit_test/map_test/lights/check_turf(turf/check_turf, is_map_border)
	var/found = FALSE
	for (var/obj/machinery/light/light in check_turf)
		if (istype(light, /obj/machinery/light/floor))
			continue
		if (found)
			return "Multiple lights detected"
		if (!isclosedturf(get_step(check_turf, light.dir)))
			return "Light not attached to a wall"
		found = TRUE
