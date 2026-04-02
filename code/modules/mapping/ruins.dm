/datum/map_template/ruin/proc/try_to_place(z, list/allowed_areas_typecache, turf/forced_turf, clear_below)
	var/sanity = forced_turf ? 1 : PLACEMENT_TRIES
	if(SSmapping.level_trait(z,ZTRAIT_ISOLATED_RUINS))
		return place_on_isolated_level(z)
	while(sanity > 0)
		sanity--
		var/width_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(width / 2)
		var/height_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(height / 2)
		var/turf/central_turf = forced_turf ? forced_turf : locate(rand(width_border, world.maxx - width_border), rand(height_border, world.maxy - height_border), z)
		var/valid = TRUE
		var/list/affected_turfs = get_affected_turfs(central_turf, TRUE)
		var/list/affected_areas = list()

		for(var/turf/check as anything in affected_turfs)
			// Use assoc lists to move this out, it's easier that way
			if(check.turf_flags & NO_RUINS)
				valid = FALSE // set to false before we check
				break
			var/area/new_area = get_area(check)
			affected_areas[new_area] = TRUE

		// This is faster yes. Only BARELY but it is faster
		for(var/area/affct_area as anything in affected_areas)
			if(!allowed_areas_typecache[affct_area.type])
				valid = FALSE
				break

		if(!valid)
			continue

		testing("Ruin \"[name]\" placed at ([central_turf.x], [central_turf.y], [central_turf.z])")

		for(var/turf/T as anything in affected_turfs)
			T.turf_flags |= NO_RUINS
			if(clear_below) //Clear out nests and monsters
				var/static/list/clear_below_typecache = typecacheof(list(
					/obj/structure/spawner,
					/mob/living/simple_animal,
					/obj/structure/flora
				))
				for(var/atom/thing as anything in T)
					if(clear_below_typecache[thing.type])
						qdel(thing)

		var/datum/async_map_generator/map_placer = load(central_turf,centered = TRUE)
		map_placer.on_completion(CALLBACK(src, PROC_REF(after_ruin_generation), central_turf))
		return central_turf

/datum/map_template/ruin/proc/after_ruin_generation(turf/central_turf)
	loaded++

	new /obj/effect/landmark/ruin(central_turf, src)

/datum/map_template/ruin/proc/place_on_isolated_level(z)
	var/datum/turf_reservation/reservation = SSmapping.request_turf_block_reservation(width, height, z) //Make the new level creation work with different traits.
	if(!reservation)
		return
	var/turf/placement = locate(reservation.bottom_left_coords[1],reservation.bottom_left_coords[2],reservation.bottom_left_coords[3])
	load(placement)
	loaded++
	for(var/turf/T in get_affected_turfs(placement))
		T.turf_flags |= NO_RUINS
	var/turf/center = locate(placement.x + round(width/2),placement.y + round(height/2),placement.z)
	new /obj/effect/landmark/ruin(center, src)
	return center


/proc/seedRuins(
	list/z_levels = null,
	budget = 0,
	whitelist = list(/area/space),
	list/potentialRuins,
	clear_below = FALSE,
	ruins_type = ZTRAIT_STATION,
	minimum_ghost_roles = 0,
	blacklist_ghost_roles = FALSE,
)
	if(!length(z_levels))
		CRASH("No Z levels provided - Not generating ruins")
	for(var/z_level in z_levels)
		if(isnull(locate(1, 1, z_level)))
			CRASH("Z level [z_level] does not exist - Not generating ruins")

	var/list/whitelist_typecache = typecacheof(whitelist)

	var/list/ruins = potentialRuins.Copy()
	shuffle(ruins)

	var/placed_ruins = 0 // our count of how many ruins have been placed
	var/ghost_roles_forced = 0 // how many ruins that have space ruins have been placed
	var/list/forced_ruins = list() //These go first on the z level associated (same random one by default) or if the assoc value is a turf to the specified turf.
	var/list/ruins_available = list() //we can try these in the current pass

	//Set up the starting ruin list
	for(var/key in ruins)
		var/datum/map_template/ruin/R = ruins[key]
		if(R.cost > budget) //Why would you do that
			continue
		if(R.has_ghost_roles && blacklist_ghost_roles)
			continue

		if(R.has_ghost_roles && ghost_roles_forced < minimum_ghost_roles)
			forced_ruins[R] = -1
			ghost_roles_forced++
		else if(R.always_place)
			forced_ruins[R] = -1

		if(R.unpickable)
			continue
		ruins_available[R] = R.placement_weight

	while(budget > 0 && (ruins_available.len || forced_ruins.len))
		var/datum/map_template/ruin/current_pick
		var/forced = FALSE
		var/forced_z //If set we won't pick z level and use this one instead.
		var/forced_turf //If set we place the ruin centered on the given turf
		if(forced_ruins.len) //We have something we need to load right now, so just pick it
			for(var/ruin in forced_ruins)
				current_pick = ruin
				if(isturf(forced_ruins[ruin]))
					var/turf/T = forced_ruins[ruin]
					forced_z = T.z //In case of chained ruins
					forced_turf = T
				else if(forced_ruins[ruin] > 0) //Load into designated z
					forced_z = forced_ruins[ruin]
				forced = TRUE
				break
		else //Otherwise just pick random one
			current_pick = pick_weight(ruins_available)

		var/placement_tries = forced_turf ? 1 : PLACEMENT_TRIES //Only try once if we target specific turf
		var/failed_to_place = TRUE
		var/target_z = 0
		var/turf/placed_turf //Where the ruin ended up if we succeeded
		outer:
			while(placement_tries > 0)
				placement_tries--
				target_z = pick(z_levels)
				if(forced_z)
					target_z = forced_z
				if(current_pick.always_spawn_with) //If the ruin has part below, make sure that z exists.
					for(var/v in current_pick.always_spawn_with)
						if(current_pick.always_spawn_with[v] == PLACE_BELOW)
							var/turf/T = locate(1,1,target_z)
							if(!GET_TURF_BELOW(T))
								if(forced_z)
									continue outer
								else
									break outer

				placed_turf = current_pick.try_to_place(target_z,whitelist_typecache,forced_turf,clear_below)
				if(!placed_turf)
					continue
				else
					failed_to_place = FALSE
					break

		//That's done remove from priority even if it failed
		if(forced)
			//TODO : handle forced ruins with multiple variants
			forced_ruins -= current_pick

		if(failed_to_place)
			for(var/datum/map_template/ruin/R in ruins_available)
				if(R.id == current_pick.id)
					ruins_available -= R
			log_world("Failed to place [current_pick.name] ruin.")
			continue

		placed_ruins++
		budget -= current_pick.cost

		if(!current_pick.allow_duplicates)
			for(var/datum/map_template/ruin/R in ruins_available)
				if(R.id == current_pick.id)
					ruins_available -= R

		if(length(current_pick.never_spawn_with))
			for(var/datum/map_template/ruin/blacklisted_type as anything in current_pick.never_spawn_with)
				for(var/available_ruin in ruins_available)
					if(istype(available_ruin, blacklisted_type))
						ruins_available -= available_ruin

		if(current_pick.always_spawn_with)
			for(var/v in current_pick.always_spawn_with)
				for(var/ruin_name in SSmapping.ruins_templates) //Because we might want to add space templates as linked of lava templates.
					var/datum/map_template/ruin/linked = SSmapping.ruins_templates[ruin_name] //why are these assoc, very annoying.
					if(istype(linked,v))
						switch(current_pick.always_spawn_with[v])
							if(PLACE_SAME_Z)
								forced_ruins[linked] = target_z //I guess you might want a chain somehow
							if(PLACE_LAVA_RUIN)
								forced_ruins[linked] = pick(SSmapping.levels_by_trait(ZTRAIT_LAVA_RUINS))
							if(PLACE_DEFAULT)
								forced_ruins[linked] = -1
							if(PLACE_BELOW)
								forced_ruins[linked] = GET_TURF_BELOW(placed_turf)
							if(PLACE_ISOLATED)
								forced_ruins[linked] = SSmapping.get_isolated_ruin_z()

		var/bottom_left_x = placed_turf.x - round(current_pick.width/2)
		var/bottom_left_y = placed_turf.y - round(current_pick.height/2)
		var/top_right_x = bottom_left_x + current_pick.width - 1
		var/top_right_y = bottom_left_y + current_pick.height - 1
		log_world("Successfully placed [current_pick.name] ruin ([bottom_left_x],[bottom_left_y],[placed_turf.z] to [top_right_x],[top_right_y],[placed_turf.z]).")

		//Update the available list
		for(var/datum/map_template/ruin/R in ruins_available)
			if(R.cost > budget)
				ruins_available -= R

	log_world("[ruins_type] loader finished placing [placed_ruins]/[ruins.len] ruins with [budget] left to spend.")
