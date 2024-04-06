// client is deleted upon logout, but we want to keep some data
/datum/client_data
	// just a placeholder variable for vv editor because we want to read ckey name first
	var/aa0_hint_ckey
	var/ckey

	// simple variable to tell if they're playing
	var/client/client

	/// Used to cache this client's bans to save on DB queries
	var/ban_cache = null
	///If we are currently building this client's ban cache, this var stores the timeofday we started at
	var/ban_cache_start = 0

	// intentionally made with c_ prefix because it's just for read only when client is gone (but you can use it in general)
	var/c_computer_id
	var/c_address

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

	/// world.time they disconnected
	var/disconnection_time
	/// world.realtime they disconnected
	var/disconnection_realtime
	/// world.timeofday they disconnected
	var/disconnection_timeofday

	/// Tick when ghost roles are useable again
	var/next_ghost_role_tick = 0


	// easy access without client
	var/datum/player_details/player_details
	var/datum/preferences/prefs

/datum/client_data/New(ckey)
	aa0_hint_ckey = ckey
	src.ckey = ckey

/datum/client_data/proc/on_login(client/cli)
	connection_time = world.time
	connection_realtime = world.realtime
	connection_timeofday = world.timeofday

	client = cli // do not move out this from on_login. New() is called only once.
	c_computer_id = cli.computer_id
	c_address = cli.address

/datum/client_data/proc/on_logout()
	client = null
	disconnection_time = world.time
	disconnection_realtime = world.realtime
	disconnection_timeofday = world.timeofday
