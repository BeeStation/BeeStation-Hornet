// client is deleted upon logout, but we want to keep some data
/datum/client_data

	// just a placeholder variable for vv editor because we want to read ckey name first
	var/aa0_hint_ckey
	var/ckey

	/// Used to cache this client's bans to save on DB queries
	var/ban_cache = null
	///If we are currently building this client's ban cache, this var stores the timeofday we started at
	var/ban_cache_start = 0


	/// Used to determine how old the account is - in days.
	var/player_age = -1
	/// Date that this account was first seen in the server
	var/player_join_date = null
	var/related_accounts_ip = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/related_accounts_cid = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id
	/// Date of byond account creation in ISO 8601 format
	var/account_join_date = null
	/// Age of byond account in days
	var/account_age = -1

	// why here? it'd be good for admins if a player was disconnected because of bad ping
	var/lastping = 0
	var/avgping = 0

	/// world.time they connected
	var/connection_time
	/// world.realtime they connected
	var/connection_realtime
	/// world.timeofday they connected
	var/connection_timeofday

	/// world.time they connected
	var/disconnection_time
	/// world.realtime they connected
	var/disconnection_realtime
	/// world.timeofday they connected
	var/disconnection_timeofday

	//Tick when ghost roles are useable again
	var/next_ghost_role_tick = 0

/datum/client_data/New(ckey, client/cli)
	aa0_hint_ckey = ckey
	src.ckey = ckey

/datum/client_data/proc/on_login()
	connection_time = world.time
	connection_realtime = world.realtime
	connection_timeofday = world.timeofday

/datum/client_data/proc/on_logout()
	disconnection_time = world.time
	disconnection_realtime = world.realtime
	disconnection_timeofday = world.timeofday
