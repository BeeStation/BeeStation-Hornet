SUBSYSTEM_DEF(ship_spawning)
	name = "Ship Spawning"
	flags = SS_NO_FIRE | SS_NO_INIT

	// List of current game lobbies.
	// Contains menu lobbies and game lobbies. Lobbies should be
	// removed when the ship is destroyed.
	var/list/game_lobbies = list()

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
