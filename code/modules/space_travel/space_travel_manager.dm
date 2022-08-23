GLOBAL_DATUM_INIT(spaceTravelManager, /datum/space_travel_manager, new)

/datum/space_travel_manager

	var/list/deep_space_dirs

	var/is_space_travel_allowed = TRUE

	var/datum/map_template/space_travel_transit/space_travel_transit_template

	var/list/storedTransitTemplates = list()

/datum/space_travel_manager/New()
	deep_space_dirs = list(	TEXT_NORTH = list("x" = list("min" = 3, "max"= 3), "y" = list("min" = 1000, "max"= -1)),
							TEXT_SOUTH = list("x" = list("min" = 3, "max"= 3), "y" = list("min" = -1, "max"= 1000)),
							TEXT_EAST = list("x" = list("min" = -1, "max"= 1000), "y" = list("min" = 3, "max"= 3)),
							TEXT_WEST = list("x" = list("min" = 1000, "max"= -1), "y" = list("min" = 3, "max"= 3)),)

/datum/space_travel_manager/proc/atom_entered_deep_space(atom/movable/AM, var/direction)

	if(!is_space_travel_allowed)
		return

	if(!istype(AM, /mob/living))
		var/turf/T = pick(block(locate(20, 20, SSmapping.trash_level.z_value), locate(200, 200, SSmapping.trash_level.z_value)))
		to_chat(world, "TRASH TELEPORTED TO TURF: [T]")
		AM.forceMove(T)
		LAZYADD(SSzclear.trash_atoms, AM)
		return

	if(!do_after(AM, 20, target = AM))
		return

	var/list/current_collision_zone = SSorbits.get_collision_zone_by_zlevel(AM.z)

	var/datum/orbital_map/primary_orbital_map = SSorbits.orbital_maps[SSorbits.orbital_maps[1]]

	var/list/collision_zones = primary_orbital_map.collision_zone_bodies

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

	while(collision_zones_to_consider.len > 0)
		var/datum/orbital_object/orbital_object = pick_n_take(collision_zones_to_consider)
		if(istype(orbital_object, /datum/orbital_object/z_linked))
			var/datum/orbital_object/z_linked/z_linked_object = orbital_object
			var/z_level_to_travel = null
			if(istype(z_linked_object, /datum/orbital_object/z_linked/beacon/ruin))
				var/datum/orbital_object/z_linked/beacon/ruin/ruin = z_linked_object
				var/datum/space_level/space_level = ruin.linked_z_level == null ? null : ruin.linked_z_level[1]

				send_to_transit(AM, direction)

				if(space_level == null)
					ruin.assign_z_level()

				space_level = ruin.linked_z_level[1]
				z_level_to_travel = space_level.z_value

				SSzclear.temp_keep_z(AM.z)
				SSzclear.temp_keep_z(z_level_to_travel)

				var/start_time = world.time
				UNTIL((!space_level.generating) || world.time > start_time + 3 MINUTES)

			else if(istype(z_linked_object, /datum/orbital_object/z_linked/station))

				z_level_to_travel = z_linked_object.linked_z_level[1].z_value


			if(z_level_to_travel != null)
				var/turf/T = locate(20, 20, z_level_to_travel)
				AM.forceMove(T)
				break


/datum/space_travel_manager/proc/send_to_transit(var/mob/living/L, var/direction)
	space_travel_transit_template = new()
	var/datum/turf_reservation/spaceTransitReservation = SSmapping.RequestBlockReservation(space_travel_transit_template.width, space_travel_transit_template.height)
	space_travel_transit_template.load(locate(spaceTransitReservation.bottom_left_coords[1], spaceTransitReservation.bottom_left_coords[2], spaceTransitReservation.bottom_left_coords[3]))
	storedTransitTemplates += space_travel_transit_template
	L.forceMove(locate(spaceTransitReservation.bottom_left_coords[1] + space_travel_transit_template.landingZoneRelativeX, spaceTransitReservation.bottom_left_coords[2] + space_travel_transit_template.landingZoneRelativeY, spaceTransitReservation.bottom_left_coords[3]))
	var/area/A = get_area(L.client.eye)
	A.parallax_movedir = direction
	L.update_parallax_teleport()
	sleep(100)

/datum/map_template/space_travel_transit
	name = "Space travel transit"
	mappath = '_maps/templates/space_travel_transit.dmm'
	var/landingZoneRelativeX = 8
	var/landingZoneRelativeY = 8

/area/space_travel_transit_area
    name = "Space travel transit"
    icon_state = "hilbertshotel"
    requires_power = FALSE
    has_gravity = TRUE
    teleport_restriction = TELEPORT_ALLOW_NONE
    area_flags = HIDDEN_AREA
    //dynamic_lighting = DYNAMIC_LIGHTING_FORCED
