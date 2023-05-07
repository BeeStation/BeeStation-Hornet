//TODO: Low priority but someone please
//refactor this and make it not so absolutely abysmal to read.
//This comment has been here since 09/09/2022 and yet still nobody has done this.

#define OPEN_CONNECTION 1
#define ROOM_CONNECTION 16

/*
 * Generates a random space ruin.
 * Dimensions of maps need to be 4n+1 by 4n+1
 * Params:
 * center_x - The x coordinate of the center of the ruin.
 * center_y - The y coordinate of the center of the ruin.
 * center_z - The z level the ruin is on.
 * border_x - The distance from the edge of the world in which the ruin will be forced to stop.
 * border_y - See above.
 * linked_objective - Will spawn special objective stuff if this is part of an objective.
 * Note: The ruin can generate past the border. The border prevents rooms from attaching past that point,
 * however if a room attachment point is not past the border, the room it generates on that attachment point
 * can go past the border. No attachment points can be generated past the border.
 */
/proc/generate_space_ruin(center_x, center_y, center_z, border_x, border_y, datum/orbital_objective/linked_objective, forced_decoration, datum/ruin_event/ruin_event)
	var/datum/map_generator/space_ruin/ruin = new(center_x, center_y, center_z, border_x, border_y, linked_objective, forced_decoration, ruin_event)
	ruin.generate()

/datum/map_generator/space_ruin
	/// The X position to start generating the ruin at
	var/center_x
	/// The Y position to start generating the ruin at
	var/center_y
	/// The Z level to generate the ruin on
	var/center_z
	/// The distance from the edge of the world in which the ruin will be forced to stop generating
	/// The larger this is, the smaller the ruin will be
	var/border_x
	/// The distance from the edge of the world in which the ruin will be forced to stop generating
	/// The larger this is, the smaller the ruin will be
	var/border_y
	/// The objective linked to the generation of this ruin
	var/datum/orbital_objective/linked_objective
	/// The generator settings to use
	var/datum/generator_settings/generator_settings
	/// The ruin event to trigger throughout generation
	var/datum/ruin_event/ruin_event

	//We need doors
	var/list/placed_room_entrances = list()
	var/list/placed_hallway_entrances = list()

	var/list/room_connections = list()			//Assoc list of door connection coords, [x]_[y] = dir
	var/list/hallway_connections = list()		//Assoc list of hallway connection coords, [x]_[y] = dir
	//Blocked turfs = Walls and floors
	var/list/blocked_turfs = list()				//Assoc list of blocked coords [x]_[y] = TRUE
	//Floor turfs = Open turfs only. Walls should be allowed to overlap.
	var/list/floor_turfs = list()				//Assoc list as above, except doesn't includ walls.

	var/sanity = 1000

	var/list/valid_ruin_parts

	//Fill with shit
	var/list/floortrash
	var/list/directional_walltrash
	var/list/nondirectional_walltrash
	var/structure_damage_prob
	var/floor_break_prob

	var/shit_index = 1

	var/stage = 0

/datum/map_generator/space_ruin/New(center_x, center_y, center_z, border_x, border_y, datum/orbital_objective/linked_objective, forced_decoration, datum/ruin_event/ruin_event)
	. = ..()
	src.center_x = center_x
	src.center_y = center_y
	src.center_z = center_z
	src.border_x = border_x
	src.border_y = border_y
	src.linked_objective = linked_objective
	src.generator_settings = forced_decoration
	src.ruin_event = ruin_event

	var/datum/space_level/space_level = SSmapping.get_level(center_z)
	space_level.generating = TRUE

	//Select ruin type
	var/datum/generator_settings/generator_settings = forced_decoration
	if(!istype(generator_settings))
		//Select one randomly
		var/static/list/datum/generator_settings/generator_settings_cache
		if(!generator_settings_cache)
			generator_settings_cache = list()
			for(var/generator_type in subtypesof(/datum/generator_settings))
				var/datum/generator_settings/instance = new generator_type()
				if(instance.probability != 0)
					generator_settings_cache[instance] = instance.probability
		generator_settings = pick_weight(generator_settings_cache)

	//Pause the air on the target z-level
	SSair.pause_z(center_z)

	//Try and catch errors so that critical actions (unpausing the Z atmos) can happen.
	log_mapping("Generating random ruin at [center_x], [center_y], [center_z]")

	//Load ruin parts
	if(!length(GLOB.loaded_ruin_parts))
		load_ruin_parts()

	//First point
	//Place one facing up and one facing down.
	hallway_connections["[center_x]_[center_y]"] = NORTH
	placed_hallway_entrances["[center_x]_[center_y]"] = NORTH

	ruin_event?.pre_spawn(center_z)

	valid_ruin_parts = generator_settings.get_valid_rooms()

	floortrash = generator_settings.get_floortrash()
	directional_walltrash = generator_settings.get_directional_walltrash()
	nondirectional_walltrash = generator_settings.get_non_directional_walltrash()
	structure_damage_prob = generator_settings.structure_damage_prob
	floor_break_prob = generator_settings.floor_break_prob

/datum/map_generator/space_ruin/complete()
	..()
	var/datum/space_level/space_level = SSmapping.get_level(center_z)
	space_level.generating = FALSE

/datum/map_generator/space_ruin/execute_run()
	..()
	switch (stage)
		if (0)
			if (ruin_placer_run())
				stage = 1
		if (1)
			post_generation()
			stage = 2
		if (2)
			put_shit_everywhere()
			if (shit_index > length(blocked_turfs))
				stage = 3
		if (3)
			finalize()
			return TRUE
		else
			. = TRUE
			CRASH("Ruin generator in invalid state: [stage]")
	return FALSE

/datum/map_generator/space_ruin/proc/ruin_placer_run()
	// Lets pause for a bit to let the map generator catch up
	if (length(SSmap_generator.executing_generators) > 15)
		return FALSE
	sanity --
	if(sanity < 0)
		message_admins("Ruin sanity limit reached.")
		return TRUE
	var/ishallway = length(hallway_connections)
	var/list/list_to_use = ishallway ? hallway_connections : room_connections
	//Generate rooms.
	var/first_coord = list_to_use[list_to_use.len]
	var/first_dir =  list_to_use[first_coord]
	var/room_connection_x = text2num(splittext(first_coord, "_")[1])
	var/room_connection_y = text2num(splittext(first_coord, "_")[2])
	var/looking_for_dir = invertDir(first_dir)
	//Find a list of valid rooms.
	var/list/valid_ruins = list()
	//Get all loaded ruins
	for(var/datum/map_template/ruin_part/ruin_part as() in valid_ruin_parts)
		//Get every connection point in the loaded ruin
		for(var/connection_point in ruin_part.connection_points)
			var/splitconn = splittext(connection_point, "_")
			var/connection_x = text2num(splitconn[1])
			var/connection_y = text2num(splitconn[2])
			var/value = ruin_part.connection_points[connection_point]
			var/connection_type = value >= 16 ? ROOM_CONNECTION : OPEN_CONNECTION
			var/connection_dir = value / connection_type
			//Not an open connection
			if(connection_type != (ishallway ? OPEN_CONNECTION : ROOM_CONNECTION))
				continue
			//Check to make sure direction is valid.
			if(connection_dir != looking_for_dir)
				//Invalid connection
				continue
			var/valid = TRUE
			//=======================================================
			//Make sure connection points dont overlap blocked parts.
			//VALIDATE OUR NEW PORTS ARE OK
			//=======================================================
			for(var/subconnection_point in ruin_part.connection_points)
				var/splitsubconn = splittext(subconnection_point, "_")
				//Get subconnection positions
				var/subconnection_x = text2num(splitsubconn[1])
				var/subconnection_y = text2num(splitsubconn[2])
				var/subconnection_type = ruin_part.connection_points[subconnection_point] >= 16
				//Calculate the subconnection offset to the rooms main connection
				var/offset_x = subconnection_x - connection_x
				var/offset_y = subconnection_y - connection_y
				//Add on the world offset of the room
				offset_x += room_connection_x
				offset_y += room_connection_y
				//Port is on a blocked turf, and there isnt a connection on that blocked turf. (Essentially, the port is on a wall.)
				if(blocked_turfs["[offset_x]_[offset_y]"] && !(subconnection_type ? room_connections["[offset_x]_[offset_y]"] : hallway_connections["[offset_x]_[offset_y]"]))
					valid = FALSE
					break
				//Check if the port is outside the valid world border.
				if(offset_x < border_x || offset_x > world.maxx - border_x || offset_y < border_y || offset_y > world.maxx - border_y)
					valid = FALSE
					break
			//Something is blocked.
			if(!valid)
				continue
			//=======================================================
			//Make sure floors dont overlap existing floors or walls.
			//Make sure that there are no global connection points inside us that aren't linked
			//Get the ruin origin position
			//VALIDATE THAT THE ROOM DOESNT OVERLAP ANOTHER ROOM.
			//=======================================================
			var/ruin_offset_x = room_connection_x - connection_x
			var/ruin_offset_y = room_connection_y - connection_y
			for(var/x in ruin_offset_x + 2 to ruin_offset_x + ruin_part.width - 1)
				for(var/y in ruin_offset_y + 2 to ruin_offset_y + ruin_part.height - 1)
					var/world_point = "[x]_[y]"
					//Check to see if the point in which we have a floor is blocked
					if(blocked_turfs[world_point])
						valid = FALSE
						break
			//=======================================================
			//VALIDATE THAT EXISTING PORTS LINK TO THIS ROOM.
			//=======================================================
			for(var/x in ruin_offset_x + 1 to ruin_offset_x + ruin_part.width)
				for(var/y in ruin_offset_y + 1 to ruin_offset_y + ruin_part.height)
					var/world_point = "[x]_[y]"
					//Check to see if there is a blocked room or hall connection
					if((room_connections[world_point] || hallway_connections[world_point]) && !ruin_part.connection_points["[x - ruin_offset_x]_[y - ruin_offset_y]"])
						valid = FALSE
						break
			//Something is disconnected or blocked.
			if(!valid)
				continue
			valid_ruins += list(list(
				"ruindata" = ruin_part,
				"weight" = ruin_part.weight,
				"port_offset_x" = connection_x,
				"port_offset_y" = connection_y,
			))
	if(!length(valid_ruins))
		log_mapping("Fuck. Ruin generation failed (No valid ruins). Continuing as if everything is actually ok.")
		ishallway ? hallway_connections.len-- : room_connections.len--
		return !length(hallway_connections) && !length(room_connections)
	//Pick a ruin and spawn it.
	var/list/selected_ruin = pick_weight_ruin(valid_ruins)
	//Spawn the ruin
	//Get the port offset position
	var/port_offset_x = selected_ruin["port_offset_x"]
	var/port_offset_y = selected_ruin["port_offset_y"]
	//Get the ruin origin position
	var/ruin_offset_x = room_connection_x - port_offset_x
	var/ruin_offset_y = room_connection_y - port_offset_y

	var/datum/map_template/ruin_part/ruin_part = selected_ruin["ruindata"]

	//If its a loot room, remove all loot rooms.
	if(ruin_part.loot_room)
		for(var/datum/map_template/ruin_part/otherpart as() in valid_ruin_parts)
			if(otherpart.loot_room)
				valid_ruin_parts.Remove(otherpart)
	//Otherwise subtract it from amount used
	else
		if(!valid_ruin_parts.Find(ruin_part))
			stack_trace("Error, ruin part wasnt in valid ruin parts somehow.")
		else
			valid_ruin_parts[ruin_part] --
			if(valid_ruin_parts[ruin_part] <= 0)
				valid_ruin_parts.Remove(ruin_part)

	//Actual spawn
	ruin_part.load(locate(ruin_offset_x + 1, ruin_offset_y + 1, center_z), FALSE, FALSE)
	//Simulate spawning
	//Remove filled connection points
	for(var/point in ruin_part.connection_points)
		var/splitpoint = splittext(point, "_")
		//Get offset in ruin map
		var/point_x = text2num(splitpoint[1])
		var/point_y = text2num(splitpoint[2])
		//Convert to offset in the world
		var/world_x = ruin_offset_x + point_x
		var/world_y = ruin_offset_y + point_y
		//Remove connection points
		var/removed_point = FALSE
		if(hallway_connections.Find("[world_x]_[world_y]"))
			removed_point = TRUE
			hallway_connections.Remove("[world_x]_[world_y]")
		if(room_connections.Find("[world_x]_[world_y]"))
			removed_point = TRUE
			room_connections.Remove("[world_x]_[world_y]")
		if(!removed_point)
			//Port needs adding
			if(ruin_part.connection_points[point] >= 16)
				if(hallway_connections.Find("[world_x]_[world_y]"))
					message_admins("Trying to put a room connection at a hallway connection")
				else
					room_connections["[world_x]_[world_y]"] = ruin_part.connection_points[point] / 16
					placed_room_entrances["[world_x]_[world_y]"] = ruin_part.connection_points[point] / 16
			else
				if(room_connections.Find("[world_x]_[world_y]"))
					message_admins("Trying to put a hallway connection at a room connection")
				else
					hallway_connections["[world_x]_[world_y]"] = ruin_part.connection_points[point]
					placed_hallway_entrances["[world_x]_[world_y]"] = ruin_part.connection_points[point]
	//Block turfs
	for(var/x in ruin_offset_x + 1 to ruin_offset_x + ruin_part.width)
		for(var/y in ruin_offset_y + 1 to ruin_offset_y + ruin_part.height)
			blocked_turfs["[x]_[y]"] = TRUE
	//Block floors
	for(var/point in ruin_part.floor_locations)
		var/splitpoint = splittext(point, "_")
		//Get offset in ruin map
		var/point_x = text2num(splitpoint[1])
		var/point_y = text2num(splitpoint[2])
		//Convert to offset in the world
		var/world_x = ruin_offset_x + point_x
		var/world_y = ruin_offset_y + point_y
		//Block
		floor_turfs["[world_x]_[world_y]"] = TRUE
	//We are done with that.
	ishallway ? hallway_connections.Remove(first_coord) : room_connections.Remove(first_coord)

	//Place first one again
	//Wow doing this based off sanity is bad
	if(sanity == 999)
		hallway_connections["[center_x]_[center_y]"] = SOUTH

	return !length(hallway_connections) && !length(room_connections)

/datum/map_generator/space_ruin/proc/post_generation()
	//Lets place doors
	for(var/door_pos in placed_room_entrances)
		var/splitextdoor = splittext(door_pos, "_")
		var/turf/T = locate(text2num(splitextdoor[1]), text2num(splitextdoor[2]), center_z)
		var/valid = isopenturf(T)
		switch(placed_room_entrances[door_pos])
			if(EAST, WEST)
				if(isopenturf(locate(text2num(splitextdoor[1]), text2num(splitextdoor[2]) + 1, center_z)) || isopenturf(locate(text2num(splitextdoor[1]), text2num(splitextdoor[2]) - 1, center_z)))
					valid = FALSE
			if(NORTH, SOUTH)
				if(isopenturf(locate(text2num(splitextdoor[1]) + 1, text2num(splitextdoor[2]), center_z)) || isopenturf(locate(text2num(splitextdoor[1]) - 1, text2num(splitextdoor[2]), center_z)))
					valid = FALSE
			else
				message_admins("Why the fuck is this thing [door_pos] have a direction of [placed_room_entrances[door_pos]]??? TELL ME!!!!")
				valid = FALSE
		if(valid)
			new /obj/machinery/door/airlock/hatch(T)
			switch(placed_room_entrances[door_pos])
				if(SOUTH, NORTH)
					var/obj/machinery/door/firedoor/border_only/b1 = new(T)
					var/obj/machinery/door/firedoor/border_only/b2 = new(T)
					b1.setDir(NORTH)
					b2.setDir(SOUTH)
				if(EAST, WEST)
					var/obj/machinery/door/firedoor/border_only/b1 = new(T)
					var/obj/machinery/door/firedoor/border_only/b2 = new(T)
					b1.setDir(EAST)
					b2.setDir(WEST)

	//Repopulate areas
	repopulate_sorted_areas()

/datum/map_generator/space_ruin/proc/put_shit_everywhere()
	//Place trash
	var/place = blocked_turfs[shit_index]
	//Increment shit index
	shit_index ++
	//Perform the actual process of putting shit everywhere
	var/splitplace = splittext(place, "_")
	var/x = text2num(splitplace[1])
	var/y = text2num(splitplace[2])
	var/turf/T = locate(x, y, center_z)
	if(isspaceturf(T) || isclosedturf(T))
		return
	if(locate(/obj) in T)
		if(prob(structure_damage_prob))
			var/obj/structure/S = locate() in T
			if(S)
				S.take_damage(rand(0, S.max_integrity * 1.5))
		return
	if(prob(floor_break_prob) && istype(T, /turf/open/floor/plasteel))
		T = T.ScrapeAway()
	//Spawn floortrash.
	var/new_floortrash = pick_weight(floortrash)
	if(ispath(new_floortrash))
		new new_floortrash(T)
	//Check for walls and spawn walltrash
	for(var/direction in GLOB.cardinals)
		var/turf/T1 = get_step(T, direction)
		if(isclosedturf(T1))
			var/new_directional_walltrash = pick_weight(directional_walltrash)
			if(ispath(new_directional_walltrash))
				var/atom/A = new new_directional_walltrash(T)
				A.setDir(direction)
			else
				var/new_nondirectional_walltrash = pick_weight(nondirectional_walltrash)
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

/datum/map_generator/space_ruin/proc/finalize()

	//Generate objective stuff
	if(linked_objective)
		var/obj_sanity = 100
		//Spawn in a sane place.
		while(obj_sanity > 0)
			obj_sanity --
			var/objective_turf = pick(floor_turfs)
			var/split_loc = splittext(objective_turf, "_")
			var/turf/T = locate(text2num(split_loc[1]), text2num(split_loc[2]), center_z)
			if(isspaceturf(T))
				continue
			if(T.is_blocked_turf(FALSE))
				continue
			linked_objective.generate_objective_stuff(T)
			break
		if(!obj_sanity)
			stack_trace("ruin generator failed to find a non-blocked turf to spawn an object")
			var/objective_turf = pick(floor_turfs)
			var/split_loc = splittext(objective_turf, "_")
			var/turf/T = locate(text2num(split_loc[1]), text2num(split_loc[2]), center_z)
			linked_objective.generate_objective_stuff(T)

	//Generate research disks
	for(var/i in 1 to rand(1, 5))
		var/objective_turf = pick(floor_turfs)
		var/split_loc = splittext(objective_turf, "_")
		new /obj/effect/spawner/lootdrop/ruinloot/important(locate(text2num(split_loc[1]), text2num(split_loc[2]), center_z))

	//Spawn dead mosb
	for(var/mob/M as() in SSzclear.nullspaced_mobs)
		var/objective_turf = pick(floor_turfs)
		var/split_loc = splittext(objective_turf, "_")
		M.forceMove(locate(text2num(split_loc[1]), text2num(split_loc[2]), center_z))
	SSzclear.nullspaced_mobs.Cut()

	ruin_event?.post_spawn(floor_turfs, center_z)

	//Start running event
	if(ruin_event)
		SSorbits.ruin_events += ruin_event

	SSair.unpause_z(center_z)

	log_mapping("Finished generating ruin at [center_x], [center_y], [center_z]")

/proc/pick_weight_ruin(list/L)
	var/total = 0
	for (var/list/ruin_part as() in L)
		total += ruin_part["weight"]

	total *= rand()
	for (var/list/ruin_part as() in L)
		total -= ruin_part["weight"]
		if (total <= 0)
			return ruin_part

	return pick(L)
