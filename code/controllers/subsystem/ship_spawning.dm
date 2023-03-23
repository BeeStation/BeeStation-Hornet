SUBSYSTEM_DEF(ship_spawning)
	name = "Ship Spawning"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_SHIP_SPAWNING

	// List of starter ships
	var/list/starter_ships = list()
	// List of current game lobbies.
	// Contains menu lobbies and game lobbies. Lobbies should be
	// removed when the ship is destroyed.
	var/list/game_lobbies = list()
	// A list of spawn points that we can place shuttles at
	var/list/spawn_points = list()

/datum/controller/subsystem/ship_spawning/Initialize(start_timeofday)
	. = ..()
	starter_ships = list()
	for (var/template in subtypesof(/datum/starter_ship_template))
		var/datum/starter_ship_template/type = template
		// Create the starter ship if it isn't abstract
		if (initial(type.spawned_template))
			starter_ships += new template()

/datum/controller/subsystem/ship_spawning/proc/get_lobby(lobby_id)
	for (var/datum/ship_lobby/lobby in game_lobbies)
		if (lobby.lobby_id == lobby_id)
			return lobby

/datum/controller/subsystem/ship_spawning/proc/try_join_lobby(client/C, lobby_id)
	for (var/datum/ship_lobby/lobby in game_lobbies)
		if (lobby.lobby_id == lobby_id)
			if (!lobby.can_join(C))
				return null
			lobby.member_join(C)
			return lobby

/datum/controller/subsystem/ship_spawning/proc/spawn_ship(datum/map_template/shuttle/selected_ship)
	var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(selected_ship.width, selected_ship.height, SSmapping.transit.z_value, /datum/turf_reservation/transit)
	if (!reservation)
		CRASH("Failed to reserve an area for shuttle placement")
	var/turf/BL = TURF_FROM_COORDS_LIST(reservation.bottom_left_coords)
	// Create the docking port
	return selected_ship.load(BL, FALSE, TRUE)

/datum/controller/subsystem/ship_spawning/proc/get_spawn_point(faction_tag, obj/docking_port/mobile/shuttle)
	RETURN_TYPE(/obj/docking_port/stationary)
	for (var/obj/docking_port/stationary/spawn_point/start in spawn_points)
		if (!start.can_spawn_here(faction_tag))
			continue
		if (shuttle.canDock(start) != SHUTTLE_CAN_DOCK)
			continue
		// Looks good to me!
		return start
	// Could not locate a valid spawn point
	return null
