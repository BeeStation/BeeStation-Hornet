/datum/map_template/ruin/exploration/ruin
	prefix = "_maps/RandomRuins/ExplorationRuins/Ruins/"
	var/limited = TRUE
	var/min_risk = 0	//0 to 10 for danger
	var/max_risk = 10	//0 to 10, measure of danger
	var/list/feature_type = list(FEATURE_DEFAULT)

/datum/map_template/ruin/exploration/ruin/asteroid
	description = "An asteroid."
	cost = 2
	limited = FALSE
	feature_type = list(FEATURE_ASTEROIDS)

/datum/map_template/ruin/exploration/ruin/asteroid/one
	id = "asteroid-one"
	suffix = "asteroid-1.dmm"

/datum/map_template/ruin/exploration/ruin/asteroid/two
	id = "asteroid-two"
	suffix = "asteroid-2.dmm"

/datum/map_template/ruin/exploration/ruin/asteroid/three
	id = "asteroid-three"
	suffix = "asteroid-3.dmm"
	limited = TRUE

/datum/map_template/ruin/exploration/ruin/asteroid/four
	id = "asteroid-four"
	suffix = "asteroid-4.dmm"

/datum/map_template/ruin/exploration/ruin/asteroid/five
	id = "asteroid-five"
	suffix = "asteroid-5.dmm"
	limited = TRUE

/datum/map_template/ruin/exploration/ruin/asteroid/six
	id = "asteroid-six"
	suffix = "asteroid-6.dmm"

/datum/map_template/ruin/exploration/ruin/asteroid/seven
	id = "asteroid-seven"
	suffix = "asteroid-7.dmm"

/datum/map_template/ruin/exploration/ruin/asteroid/eight
	id = "asteroid-eight"
	suffix = "asteroid-8.dmm"

/datum/map_template/ruin/exploration/ruin/asteroid/tow
	id = "asteroid-tow"
	suffix = "asteroid-tow.dmm"
	limited = TRUE
	cost = 4

/datum/map_template/ruin/exploration/ruin/try_to_place(z,allowed_areas)
	var/sanity = PLACEMENT_TRIES
	while(sanity > 0)
		sanity--
		var/width_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(width / 2)
		var/height_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(height / 2)
		var/turf/central_turf = locate(rand(width_border, world.maxx - width_border), rand(height_border, world.maxy - height_border), z)
		var/valid = TRUE

		for(var/turf/check in get_affected_turfs(central_turf,1))
			var/area/new_area = get_area(check)
			if(!(istype(new_area, allowed_areas)) || check.flags_1 & NO_RUINS_1)
				valid = FALSE
				break

		if(!valid)
			CHECK_TICK
			continue

		testing("Ruin \"[name]\" placed at ([central_turf.x], [central_turf.y], [central_turf.z])")

		for(var/i in get_affected_turfs(central_turf, 1))
			var/turf/T = i
			for(var/mob/living/simple_animal/monster in T)
				qdel(monster)
			for(var/obj/structure/flora/ash/plant in T)
				qdel(plant)

		load(central_turf,centered = TRUE)
		loaded++

		for(var/turf/T in get_affected_turfs(central_turf, 1))
			T.flags_1 |= NO_RUINS_1

		new /obj/effect/landmark/ruin(central_turf, src)
		return TRUE
	return FALSE
