/// Tracks information about a client between log in and log outs
/datum/player_details
	var/ckey
	/// Action datums assigned to this player
	var/list/player_actions = list()
	var/list/logging = list()
	/// Callbacks invoked when this client logs in again
	var/list/post_login_callbacks = list()
	/// Callbacks invoked when this client logs out
	var/list/post_logout_callbacks = list()
	/// List of names this key played under this round
	var/list/played_names = list()
	/// Lazylists of preference slots and jobs this client has joined the round under
	/// Numbers are stored as strings
	var/list/joined_as_slots
	var/list/joined_as_jobs
	/// Version of byond this client is using
	var/byond_version = "Unknown"
	/// Tracks achievements they have earned
	var/datum/achievement_data/achievements
	/// World.time this player last died
	var/time_of_death = 0
	/// Whether or not this client has voted to leave
	var/voted_to_leave = FALSE
	/// How many commendations we have received
	var/commendations_received = 0
	/// How many criticisms have we received?
	var/criticisms_received = 0
	/// Have we criticized?
	var/has_criticized = FALSE
	/// Bitflags for communications that are muted
	var/muted = NONE

/datum/player_details/New(ckey)
	src.ckey = ckey
	achievements = new(ckey)

/datum/player_details/proc/find_client()
	for (var/client/client in GLOB.clients)
		if (client.ckey == ckey)
			return client
	return null

/proc/log_played_names(ckey, ...)
	if(!ckey)
		return
	if(args.len < 2)
		return
	var/list/names = args.Copy(2)
	var/datum/player_details/P = GLOB.player_details[ckey]
	if(P)
		for(var/name in names)
			if(name)
				P.played_names |= name
