GLOBAL_DATUM_INIT(spaceTravelManager, /datum/space_travel_manager, new)

#define DISTANCE_COST_IN_MOLES(distance) distance / 100
#define DISTANCE_COST_IN_SECONDS(distance) distance / 1000
#define BASE_TRAVEL_TIME 10 SECONDS
#define MAX_TRAVEL_TIME 90 SECONDS

/datum/space_travel_manager

	var/list/deep_space_dirs

	var/is_space_travel_allowed = TRUE

	var/datum/map_template/space_travel_transit/space_travel_transit_template

	var/list/stored_transit_templates = list()

	var/list/allowed_orbital_types = list()

	var/list/arrival_dirs = list()

	var/list/safe_turf_directions = list()

/datum/space_travel_manager/New()
	deep_space_dirs = list(	TEXT_NORTH = list("x" = list("min" = 3, "max"= 3), "y" = list("min" = 1000, "max"= -1)),
							TEXT_SOUTH = list("x" = list("min" = 3, "max"= 3), "y" = list("min" = -1, "max"= 1000)),
							TEXT_EAST = list("x" = list("min" = -1, "max"= 1000), "y" = list("min" = 3, "max"= 3)),
							TEXT_WEST = list("x" = list("min" = 1000, "max"= -1), "y" = list("min" = 3, "max"= 3)),)

	arrival_dirs = list(TEXT_NORTH = list("x" = 0, "y" = 2),
						TEXT_SOUTH = list("x" = 0, "y" = world.maxy - 1),
						TEXT_EAST = list("x" = 2, "y" = 0),
						TEXT_WEST = list("x" = world.maxx - 1, "y" = 0),)

	safe_turf_directions = list(TEXT_NORTH = list("x" = 0, "y" = world.maxy - DEEP_SPACE_BORDER_RANGE - 2),
								TEXT_SOUTH = list("x" = 0, "y" = DEEP_SPACE_BORDER_RANGE + 3),
								TEXT_EAST = list("x" = world.maxx - DEEP_SPACE_BORDER_RANGE - 2, "y" = 0),
								TEXT_WEST = list("x" = DEEP_SPACE_BORDER_RANGE + 3, "y" = 0),)

	allowed_orbital_types = list(/datum/orbital_object/z_linked/beacon/ruin, /datum/orbital_object/z_linked/station)

/datum/space_travel_manager/proc/atom_entered_deep_space(atom/movable/AM, var/direction)

	if(!is_space_travel_allowed)
		return

	var/mob/living/L = istype(AM, /mob/living) ? AM : null

	if(!istype(AM, /mob/living) || L != null && L.stat == DEAD)
		var/turf/T = pick(block(locate(20, 20, SSmapping.trash_level.z_value), locate(200, 200, SSmapping.trash_level.z_value)))
		AM.visible_message("<span class = 'warning'>[AM.name] vanishes into the void!</span>")
		AM.forceMove(T)
		LAZYADD(SSzclear.trash_atoms, AM)
		return

	if(!do_after(AM, 50, target = AM))
		return

	var/datum/space_level/current_space_level = SSmapping.z_list[AM.z]

	var/list/current_collision_zone = SSorbits.get_collision_zone_by_zlevel(current_space_level)

	var/datum/orbital_object/current_orbital_object = current_space_level.orbital_body

	var/datum/orbital_map/primary_orbital_map = SSorbits.orbital_maps[SSorbits.orbital_maps[1]]

	var/list/collision_zones = primary_orbital_map.collision_zone_bodies

	var/list/collision_zone_coords = list()

	var/list/collision_zones_to_consider = list()

	var/_dir = deep_space_dirs["[direction]"]

	var/current_x_min = current_collision_zone["x"] - _dir["x"]["min"]
	var/current_x_max = current_collision_zone["x"] + _dir["x"]["max"]
	var/current_y_min = current_collision_zone["y"] - _dir["y"]["min"]
	var/current_y_max = current_collision_zone["y"] + _dir["y"]["max"]

	var/departure_x = AM.x
	var/departure_y = AM.y

	var/travel_message = null
	var/no_target_message = "You stare into the void and see nothing, it would be a bad idea to try to travel in this direction!"
	var/no_oxygen_message = "You can't travel that far!"
	var/message_shown = FALSE

	for(var/collision_zone in collision_zones)
		collision_zone_coords = splittext(collision_zone, ",")

		if(ISINRANGE(text2num(collision_zone_coords[1]), current_x_min, current_x_max) && ISINRANGE(text2num(collision_zone_coords[2]), current_y_min, current_y_max))
			collision_zones_to_consider += collision_zones[collision_zone]
			to_chat(world, "<span class='boldannounce'>CONSIDERING ZONE: [collision_zone]</span>")

	if(collision_zones_to_consider.len == 0)
		to_chat(AM, "<span class = 'warning'>[no_target_message]</span>")
		return

	while(collision_zones_to_consider.len > 0)

		var/datum/orbital_object/orbital_object = pick_n_take(collision_zones_to_consider)

		var/list/calculate_travel_return_data = list()
		var/list/tanks = list()
		var/cost_in_moles = 0

		if(is_type_in_list(orbital_object, allowed_orbital_types))

			var/datum/orbital_object/z_linked/z_linked_object = orbital_object
			var/datum/space_level/z_level_to_travel = z_linked_object.linked_z_level == null ? null : z_linked_object.linked_z_level[1]
			var/distance = current_orbital_object.position.DistanceTo(orbital_object.position)

			calculate_travel_return_data = calculate_travel_cost(AM, distance)

			var/time_to_generate = 0

			var/can_travel = calculate_travel_return_data["can_travel"]
			//Not enough O2 to travel there? Find something else
			if(!can_travel)
				travel_message = no_oxygen_message
				continue

			tanks = calculate_travel_return_data["tanks"]
			cost_in_moles = calculate_travel_return_data["cost_in_moles"]

			message_shown = TRUE
			to_chat(AM, "<span class = 'warning'>You start your travel into the unknown!</span>")

			stored_transit_templates += send_to_transit(AM, direction)

			if(istype(z_linked_object, /datum/orbital_object/z_linked/beacon/ruin))

				var/datum/orbital_object/z_linked/beacon/ruin/ruin = z_linked_object

				var/start_time = world.time

				if(z_level_to_travel == null)
					ruin.assign_z_level()

				z_level_to_travel = ruin.linked_z_level[1]

				SSzclear.temp_keep_z(AM.z)
				SSzclear.temp_keep_z(z_level_to_travel.z_value)

				UNTIL((!z_level_to_travel.generating) || world.time > start_time + 3 MINUTES)

				time_to_generate = world.time - start_time

			else if(istype(z_linked_object, /datum/orbital_object/z_linked/station))

				z_level_to_travel = z_linked_object.linked_z_level[1]
				SSzclear.temp_keep_z(AM.z)
				SSzclear.temp_keep_z(z_level_to_travel.z_value)

			var/target_travel_time = BASE_TRAVEL_TIME * DISTANCE_COST_IN_SECONDS(distance)

			if(time_to_generate < target_travel_time)
				var/travel_time = CLAMP(((target_travel_time) - time_to_generate), 0, MAX_TRAVEL_TIME)
				SSzclear.temp_keep_z(AM.z)
				SSzclear.temp_keep_z(z_level_to_travel.z_value)
				sleep(travel_time)

			if(z_level_to_travel != null)

				var/arrival_x = arrival_dirs["[direction]"]["x"] == 0 ? departure_x : arrival_dirs["[direction]"]["x"]
				var/arrival_y = arrival_dirs["[direction]"]["y"] == 0 ? departure_y : arrival_dirs["[direction]"]["y"]
				var/turf/T = locate(arrival_x, arrival_y, z_level_to_travel.z_value)
				AM.forceMove(T)
				handle_travel_cost(AM, tanks, DISTANCE_COST_IN_MOLES(distance))
				break

	if(!message_shown)
		travel_message = travel_message == null ? no_target_message : travel_message

		to_chat(AM, "<span class = 'warning'>[travel_message]</span>")


/datum/space_travel_manager/proc/send_to_transit(var/mob/living/L, var/direction)

	var/datum/turf_reservation/space_transit_reservation

	if(stored_transit_templates.len > 0)

		space_transit_reservation = stored_transit_templates[1]
		stored_transit_templates.Remove(space_transit_reservation)
	else

		if(space_travel_transit_template == null)

			space_travel_transit_template = new()

		space_transit_reservation = SSmapping.RequestBlockReservation(space_travel_transit_template.width, space_travel_transit_template.height)
		space_travel_transit_template.load(locate(space_transit_reservation.bottom_left_coords[1], space_transit_reservation.bottom_left_coords[2], space_transit_reservation.bottom_left_coords[3]))

	L.forceMove(locate(space_transit_reservation.bottom_left_coords[1] + space_travel_transit_template.landingZoneRelativeX, space_transit_reservation.bottom_left_coords[2] + space_travel_transit_template.landingZoneRelativeY, space_transit_reservation.bottom_left_coords[3]))

	L.hud_used.set_parallax_movedir(direction, FALSE)

	return space_transit_reservation

/datum/space_travel_manager/proc/calculate_travel_cost(var/mob/living/L, var/distance)

	var/list/return_data = list("can_travel" = TRUE, "tanks" = list())

	. = return_data

	var/list/mob_contents = L.get_contents()

	var/cost_in_moles = DISTANCE_COST_IN_MOLES(distance)

	var/total_moles = 0

	for(var/item in mob_contents)

		if(istype(item, /obj/item/tank))
			var/obj/item/tank/tank = item
			var/moles_in_tank = tank.air_contents.get_moles(GAS_O2)
			var/amount_to_take = cost_in_moles - moles_in_tank > 0 ? moles_in_tank : moles_in_tank - cost_in_moles
			var/list/tanks = return_data["tanks"]
			tanks["[tanks.len]"] += list("tank" = tank, "moles" = moles_in_tank)

			cost_in_moles -= amount_to_take
			total_moles += moles_in_tank

	//Not enough juice to travel
	if(cost_in_moles > 0)
		return_data["can_travel"] = FALSE
		return .

	if(total_moles - cost_in_moles < 5)
		switch(tgalert(L, "It seems like you may end up with very little oxygen, do you wish to proceed regardless?", "Space travel alert", "Yes", "No", Timeout = 5))
			if("No")
				return_data["can_travel"] = FALSE

	return .

/datum/space_travel_manager/proc/handle_travel_cost(var/mob/living/L, var/list/tanks, var/cost_in_moles)

	for(var/key in tanks)
		var/obj/item/tank/tank = tanks[key]["tank"]
		var/moles_in_tank = tanks[key]["moles"]

		var/amount_to_take = cost_in_moles - moles_in_tank > 0 ? moles_in_tank : moles_in_tank - cost_in_moles

		if(moles_in_tank < cost_in_moles || tanks.len == 0)
			tanks["[tanks.len]"] = list("tank" = tank, "moles" = moles_in_tank)
			tank.air_contents.adjust_moles(GAS_O2, -amount_to_take)
		cost_in_moles -= amount_to_take


/datum/space_travel_manager/proc/teleport_atom_to_safety(atom/movable/AM, var/direction)

	var/safe_x = safe_turf_directions["[direction]"]["x"] == 0 ? AM.x : safe_turf_directions["[direction]"]["x"]
	var/safe_y = safe_turf_directions["[direction]"]["y"] == 0 ? AM.y : safe_turf_directions["[direction]"]["y"]
	var/turf/T = locate(safe_x, safe_y, AM.z)
	AM.forceMove(T)

/datum/map_template/space_travel_transit
	name = "Space travel transit"
	mappath = '_maps/templates/space_travel_transit.dmm'
	var/landingZoneRelativeX = 8
	var/landingZoneRelativeY = 8

/area/space_travel_transit_area //TODO: make it /area/space
    name = "Space travel transit"
    icon_state = "hilbertshotel"
    requires_power = FALSE
    has_gravity = TRUE
    teleport_restriction = TELEPORT_ALLOW_NONE
    area_flags = HIDDEN_AREA

#undef DISTANCE_COST_IN_MOLES
#undef BASE_TRAVEL_TIME
#undef DISTANCE_COST_IN_SECONDS
