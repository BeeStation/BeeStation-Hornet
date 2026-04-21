/// General logging for admin actions
/proc/log_admin(text)
	GLOB.admin_log.Add(text)
	if (CONFIG_GET(flag/log_admin))
		WRITE_LOG(GLOB.world_game_log, "ADMIN: [text]")

/// General logging for admin actions
/proc/log_admin_private(text)
	GLOB.admin_log.Add(text)
	if (CONFIG_GET(flag/log_admin))
		WRITE_LOG(GLOB.world_game_log, "ADMINPRIVATE: [text]")

/// Logging for AdminSay (ASAY) messages
/proc/log_adminsay(text)
	GLOB.admin_log.Add(text)
	if (CONFIG_GET(flag/log_adminchat))
		WRITE_LOG(GLOB.world_game_log, "ADMINPRIVATE: ASAY: [text]")

/// Logging for DeadchatSay (DSAY) messages
/proc/log_dsay(text)
	if (CONFIG_GET(flag/log_adminchat))
		WRITE_LOG(GLOB.world_game_log, "ADMIN: DSAY: [text]")
