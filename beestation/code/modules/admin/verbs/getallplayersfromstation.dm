
/client/proc/GetAllPlayersFromStation()
	set category = "Admin"
	set name = "Get All on Station"
	set desc = "Teleport all players on the station level to you"

	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return

	for(var/mob/M in GLOB.player_list)
		if(M)
			var/turf/T = get_turf(M)
			if is_station_level(T.z)
				M.forceMove(get_turf(usr))
				usr.forceMove(M.loc)
			
	log_admin("[key_name(usr)] teleported all players on station")
	var/msg = "[key_name_admin(usr)] teleported all players on station"
	message_admins(msg)
