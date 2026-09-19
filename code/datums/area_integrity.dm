/// Surveys an area's structure on one z-level, as list("score", "space"). Weights follow
/// /datum/station_state. Space is counted rather than weighed, a hole is a hole.
/area/proc/get_structure_survey(z)
	var/score = 0
	var/space = 0
	for(var/turf/checked_turf as anything in get_turfs_by_zlevel(z))
		if(isspaceturf(checked_turf))
			space++
		if(istype(checked_turf, /turf/closed/wall/r_wall))
			var/turf/closed/wall/r_wall/reinforced = checked_turf
			score += (reinforced.d_state == INTACT) ? 12 : 6
		else if(iswallturf(checked_turf))
			score += 8
		else if(isfloorturf(checked_turf))
			var/turf/open/floor/checked_floor = checked_turf
			// break_tile_to_plating() leaves the turf behind. Bombed rooms read as intact.
			if(!checked_floor.overfloor_placed)
				score += 4
			else
				score += checked_floor.burnt ? 6 : 12

		for(var/obj/checked_object in checked_turf)
			if(istype(checked_object, /obj/structure/window))
				score += 4
			else if(istype(checked_object, /obj/structure/grille))
				var/obj/structure/grille/checked_grille = checked_object
				if(!checked_grille.broken)
					score += 2
			else if(istype(checked_object, /obj/machinery/door))
				score += 6
			else if(ismachinery(checked_object))
				score += 3
	return list("score" = score, "space" = space)
