/datum/player_details
	var/ckey
	var/list/player_actions = list()
	var/list/logging = list()
	var/list/post_login_callbacks = list()
	var/list/post_logout_callbacks = list()
	var/list/played_names = list() //List of names this key played under this round
	var/byond_version = "Unknown"
	var/datum/achievement_data/achievements
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
