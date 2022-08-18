/turf/open/space/deep_space
	density = TRUE
	var/direction = 0
	var/lasttime = 0

/turf/open/space/deep_space/CanBuildHere()
	return FALSE

/turf/open/space/deep_space/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	to_chat(world, "ENTERED DEEP SPACE TURF")

/turf/open/space/deep_space/Bumped(atom/movable/AM)
	. = ..()

	if(world.time - lasttime < 10 SECONDS)
		return

	if(!istype(AM, /mob/living))
		var/turf/T = pick(block(locate(20, 20, SSmapping.trash_level.z_value), locate(200, 200, SSmapping.trash_level.z_value)))
		to_chat(world, "TRASH TELEPORTED TO TURF: [T]")
		AM.forceMove(T)
		LAZYADD(SSmapping.trash_level.trash_atoms, AM)
		return

	var/list/current_collision_zone = SSorbits.get_collision_zone_by_zlevel(AM.z)
	var/datum/orbital_map/primary_orbital_map = SSorbits.orbital_maps[SSorbits.orbital_maps[1]]

	var/list/collision_zones = primary_orbital_map.collision_zone_bodies

	var/list/deep_space_dirs = list(TEXT_NORTH = list("x" = list("min" = 3, "max"= 3), "y" = list("min" = 1000, "max"= -1)),
									TEXT_SOUTH = list("x" = list("min" = 3, "max"= 3), "y" = list("min" = -1, "max"= 1000)),
									TEXT_EAST = list("x" = list("min" = -1, "max"= 1000), "y" = list("min" = 3, "max"= 3)),
									TEXT_WEST = list("x" = list("min" = 1000, "max"= -1), "y" = list("min" = 3, "max"= 3)),)

	var/list/collision_zone_coords = list()

	var/list/collision_zones_to_consider = list()

	var/_dir = deep_space_dirs["[direction]"]

	var/current_x_min = current_collision_zone["x"] - _dir["x"]["min"]
	var/current_x_max = current_collision_zone["x"] + _dir["x"]["max"]
	var/current_y_min = current_collision_zone["y"] - _dir["y"]["min"]
	var/current_y_max = current_collision_zone["y"] + _dir["y"]["max"]

	for(var/collision_zone in collision_zones)
		collision_zone_coords = splittext(collision_zone, ",")

		if(ISINRANGE(text2num(collision_zone_coords[1]), current_x_min, current_x_max) && ISINRANGE(text2num(collision_zone_coords[2]), current_y_min, current_y_max))
			collision_zones_to_consider += collision_zones[collision_zone]
			to_chat(world, "<span class='boldannounce'>CONSIDERING ZONE: [collision_zone]</span>")
		var/list/datum/orbital_object/orbital_objects = collision_zones[collision_zone]

	while(collision_zones_to_consider.len > 0)
		var/datum/orbital_object/orbital_object = pick_n_take(collision_zones_to_consider)
		if(istype(orbital_object, /datum/orbital_object/z_linked/beacon/ruin))
			var/datum/orbital_object/z_linked/beacon/ruin/ruin = orbital_object
			ruin.assign_z_level()
			var/turf/T = locate(20, 20, ruin.linked_z_level[1].z_value)
			lasttime = world.time
			AM.forceMove(T)
			break

	var/test

