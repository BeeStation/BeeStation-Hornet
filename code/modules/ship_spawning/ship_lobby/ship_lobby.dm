/datum/ship_lobby
	/// The current state of the lobby, has their game
	/// started yet?
	var/lobby_state = LOBBY_MENU

	/// Lobby ID
	var/lobby_id
	/// The owner of the lobby. May be null in cases of it being a debug
	/// lobby.
	var/client/owner
	/// The list of clients inside the lobby
	var/list/members = list()
	/// Is this shuttle private or public
	var/private_lobby = TRUE
	/// List of whitelisted ckeys, players cannot join this ship outside of the whitelist
	var/list/whitelisted_ckeys = list()

/datum/ship_lobby/New(client/creator)
	. = ..()
	owner = creator
	member_join(creator)
	SSship_spawning.game_lobbies += src

/datum/ship_lobby/Destroy(force, ...)
	SSship_spawning.game_lobbies -= src
	. = ..()

/datum/ship_lobby/proc/can_join(client/C)
	if (!private_lobby)
		return TRUE
	if (C in whitelisted_ckeys)
		return TRUE
	return FALSE

/datum/ship_lobby/proc/member_join(client/C)
	members += C
	to_chat(members, "<span class='announcement'>[C.ckey] has joined the lobby.</span>")

/datum/ship_lobby/proc/member_leave(client/C)
	members -= C
	if (C == owner)
		// Transfer host ownership
		if (length(members) > 0)
			owner = members[1]
			to_chat(owner, "<span class='bold announcement'>You are now the host.</span>")
		else
			qdel(src)
	to_chat(members, "<span class='announcement'>[C.ckey] left the lobby.</span>")
