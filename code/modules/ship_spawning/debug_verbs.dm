
/client/verb/create_debug_lobby()
	set name = "Open Debug Lobby"
	set category = "Debug"

	if (!check_rights(R_DEBUG))
		return

	new /datum/ship_lobby(null)
