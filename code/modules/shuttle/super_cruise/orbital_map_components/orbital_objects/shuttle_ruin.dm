//====================
// Abandoned shuttle ruin
//====================
/datum/orbital_object/z_linked/beacon/ruin/abandoned_shuttle
	name = "Abandoned Signal"

/datum/orbital_object/z_linked/beacon/ruin/abandoned_shuttle/assign_z_level()
	var/datum/space_level/assigned_space_level = SSzclear.get_free_z_level()
	linked_z_level = list(assigned_space_level)
	assigned_space_level.orbital_body = src
	//Place the abandoned shuttle
	if(length(SSorbits.shuttle_ruin_list))
		var/dmm_file = pick(SSorbits.shuttle_ruin_list)
		var/as_file = file(dmm_file)
		//Get the template
		var/datum/map_template/shuttle/abandoned_template = new("[CONFIG_GET(string/shuttle_ruin_filepath)][as_file]", "abandoned shuttle [rand(1, 99999)]")
		//Only spawn once
		SSorbits.shuttle_ruin_list -= dmm_file
		SSorbits.spawned_shuttle_files += dmm_file
		var/list/loaded_bounds = abandoned_template?.load(locate((world.maxx / 2) + rand(-70, 70), (world.maxy / 2) + rand(-70, 70), assigned_space_level.z_value), TRUE)
		if(loaded_bounds && prob(80))	//Advanced optimisation system
			//What happened?
			//Select one randomly
			var/static/list/datum/generator_settings/generator_settings_cache
			if(!generator_settings_cache)
				generator_settings_cache = list()
				for(var/generator_type in subtypesof(/datum/generator_settings))
					var/datum/generator_settings/instance = new generator_type()
					if(instance.probability != 0)
						generator_settings_cache[instance] = instance.probability
			var/datum/generator_settings/generator_settings = pickweight(generator_settings_cache)

			//Fill with shit
			var/list/floortrash = generator_settings.get_floortrash()
			var/list/directional_walltrash = generator_settings.get_directional_walltrash()
			var/list/nondirectional_walltrash = generator_settings.get_non_directional_walltrash()
			var/structure_damage_prob = generator_settings.structure_damage_prob
			var/floor_break_prob = generator_settings.floor_break_prob

			for(var/turf/T as() in block(
				locate(loaded_bounds[1], loaded_bounds[2], loaded_bounds[3]),
				locate(loaded_bounds[4], loaded_bounds[5], loaded_bounds[6])
				))
				if(isspaceturf(T) || isclosedturf(T))
					continue
				if(locate(/obj) in T)
					if(prob(structure_damage_prob))
						var/obj/structure/S = locate() in T
						if(S)
							S.take_damage(rand(0, S.max_integrity * 1.5))
					continue
				if(prob(floor_break_prob) && istype(T, /turf/open/floor/plasteel))
					T = T.ScrapeAway()
				//Spawn floortrash.
				var/new_floortrash = pickweight(floortrash)
				if(ispath(new_floortrash))
					new new_floortrash(T)
				//Check for walls and spawn walltrash
				for(var/direction in GLOB.cardinals)
					var/turf/T1 = get_step(T, direction)
					if(isclosedturf(T1))
						var/new_directional_walltrash = pickweight(directional_walltrash)
						if(ispath(new_directional_walltrash))
							var/atom/A = new new_directional_walltrash(T)
							A.setDir(direction)
						else
							var/new_nondirectional_walltrash = pickweight(nondirectional_walltrash)
							if(ispath(new_nondirectional_walltrash))
								var/atom/A = new new_nondirectional_walltrash(T)
								switch(direction)
									if(NORTH)
										A.pixel_y = 32
									if(SOUTH)
										A.pixel_y = -32
									if(EAST)
										A.pixel_x = 32
									if(WEST)
										A.pixel_x = -32
						break
				CHECK_TICK


	//Generate mini asteroid field
	generate_asteroids(world.maxx / 2, world.maxy / 2, assigned_space_level.z_value, 70, -0.6, 20)

/datum/orbital_object/z_linked/beacon/ruin/abandoned_shuttle/post_map_setup()
	//Orbit around the systems sun
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 4000 + 250 * rand(25, 35))
