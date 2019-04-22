/datum/controller/subsystem/medals/UnlockMedal(medal, client/player)
	set waitfor = FALSE
	if(!medal || !hub_enabled)
		return

	spawn(0)
		var/result = world.SetMedal(medal, player, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))

		if(isnull(result))
			//hub_enabled = FALSE
			log_game("MEDAL ERROR: Could not contact hub to award medal:[medal] player:[player.key]")
			message_admins("Error! Failed to contact hub to award [medal] medal to [player.key]!")
			return

		if (result == 1)
			for(var/client/C in GLOB.clients)
				to_chat(C, "<span class='greenannounce'><B>[player.key] earned the medal: [medal]</B></span>")
