// VERSION

// Update topic version whenever changes are made
// The Version Number follows SemVer http://semver.org/
#define TOPIC_VERSION_MAJOR		2	//	Major Version Number --> Increment when implementing breaking changes
#define TOPIC_VERSION_MINOR		0	//	Minor Version Number --> Increment when adding features
#define TOPIC_VERSION_PATCH		0	//	Patchlevel --> Increment when fixing bugs

// DATUM

/datum/world_topic
	var/key // query key
	var/anonymous = FALSE // can be used with anonymous authentication
	var/list/required_params = list()
	var/statuscode = null
	var/response = null
	var/data = null

/datum/world_topic/proc/CheckParams(list/params)
	var/list/missing_params = list()
	var/errorcount = 0

	for(var/param in required_params)
		if(!params[param])
			errorcount++
			missing_params += param

	if(errorcount)
		statuscode = 400
		response = "Bad Request - Missing parameters"
		data = missing_params
		return errorcount

/datum/world_topic/proc/Run(list/input)
	// Always returns true; actual details in statuscode, response and data variables
	return TRUE

// API INFO TOPICS

/datum/world_topic/api_get_version
	key = "api_get_version"
	anonymous = TRUE

/datum/world_topic/api_get_version/Run(list/input)
	. = ..()
	var/list/version = list()
	var/versionstring = null

	version["major"] = TOPIC_VERSION_MAJOR
	version["minor"] = TOPIC_VERSION_MINOR
	version["patch"] = TOPIC_VERSION_PATCH

	versionstring = "[version["major"]].[version["minor"]].[version["patch"]]"

	statuscode = 200
	response = versionstring
	data = version

/datum/world_topic/api_get_authed_functions
	key = "api_get_authed_functions"
	anonymous = TRUE

/datum/world_topic/api_get_authed_functions/Run(list/input)
	. = ..()
	var/list/functions = GLOB.topic_tokens[input["auth"]]
	if(functions)
		statuscode = 200
		response = "Authorized functions retrieved"
		data = functions
	else
		statuscode = 401
		response = "Unauthorized - No functions found"
		data = null

/datum/world_topic/api_do_handshake
	key = "api_do_handshake"
	anonymous = TRUE

/datum/world_topic/api_do_handshake/Run(list/input)
	. = ..()
	var/list/functions = GLOB.topic_tokens[input["auth"]]
	var/list/servers = CONFIG_GET(keyed_list/cross_server)
	var/fmt_addr = "byond://[input["addr"]]"
	var/token = servers[fmt_addr]
	if(!token || !functions) // Handshake requires both servers to have each other's deets
		statuscode = 401
		response = "Unauthorized - Handshake Failed"
		data = null
	else
		statuscode = 200
		response = "Handshake Successful"
		data = list("token" = token, "functions" = functions)
		if(!GLOB.topic_servers[fmt_addr]) // part of the ad-hoc connection system
			SStopic.handshake_server(fmt_addr, token)

// TOPICS

/datum/world_topic/ping
	key = "ping"
	anonymous = TRUE

/datum/world_topic/ping/Run(list/input)
	. = ..()
	statuscode = 200
	response = "Pong!"
	data = length(GLOB.clients_unsafe)

/datum/world_topic/playing
	key = "playing"
	anonymous = TRUE

/datum/world_topic/playing/Run(list/input)
	. = ..()
	statuscode = 200
	response = "Player count retrieved"
	data = length(GLOB.player_list)

/datum/world_topic/pr_announce
	key = "announce"
	required_params = list("id", "announce")
	var/static/list/PRcounts = list()	//PR id -> number of times announced this round

/datum/world_topic/pr_announce/Run(list/input)
	. = ..()
	if(!PRcounts[input["id"]])
		PRcounts[input["id"]] = 1
	else
		PRcounts[input["id"]]++
		if(PRcounts[input["id"]] > PR_ANNOUNCEMENTS_PER_ROUND)
			statuscode = 429
			response = "Rate Limited - PR Spam blocked"
			return

	var/final_composed = span_announce("PR: [input["announce"]]")
	for(var/client/C in GLOB.clients)
		C.AnnouncePR(final_composed)
	statuscode = 200
	response = "PR Announced"

/datum/world_topic/ahelp_relay
	key = "ahelp"
	required_params = list("source", "message", "message_sender")

/datum/world_topic/ahelp_relay/Run(list/input)
	. = ..()
	relay_msg_admins(span_adminnotice("<b><font color=red>HELP:</font> <font color=orange>[input["source"]]:</font> [input["message_sender"]]: [input["message"]]</b>"))
	statuscode = 200
	response = "Ahelp relayed"

/datum/world_topic/comms_console
	key = "comms_console"
	required_params = list("message", "message_sender")

/datum/world_topic/comms_console/Run(list/input)
	. = ..()
	if(CHAT_FILTER_CHECK(input["message"])) // prevents any.. diplomatic incidents
		minor_announce("In the interest of station productivity and mental hygiene, a message from [input["message_sender"]] was intercepted by the CCC and determined to be unfit for crew-level access.", "CentCom Communications Commission")
		message_admins("Incoming cross-comms message from [input["message_sender"]] blocked: [input["message"]]")
		statuscode = 451 // "Unavailable for legal reasons" ahaha; i.e. censored
		response = "Censored - Message blocked by chat filter"
		return

	minor_announce(input["message"], "Incoming message from [input["message_sender"]]")
	for(var/obj/machinery/computer/communications/CM in GLOB.machines)
		CM.override_cooldown()
	statuscode = 200
	response = "Message received"

/datum/world_topic/news_report
	key = "news_report"
	required_params = list("message", "message_sender")

/datum/world_topic/news_report/Run(list/input)
	. = ..()
	minor_announce(input["message"], "Breaking Update From [input["message_sender"]]")
	statuscode = 200
	response = "Message received"

/datum/world_topic/namecheck
	key = "namecheck"
	required_params = list("target")

/datum/world_topic/namecheck/Run(list/input)
	. = ..()
	statuscode = 200
	response = "Names fetched"
	data = keywords_lookup(input["target"], TRUE)

/datum/world_topic/adminwho
	key = "adminwho"

/datum/world_topic/adminwho/Run(list/input)
	. = ..()
	var/list/admins = list()
	for(var/client/admin in GLOB.admins)
		admins[++admins.len] = list("ckey" = admin.ckey,
						"key" = admin.key,
						"rank" = admin.holder.rank.name,
						"stealth" = admin.holder.fakekey ? TRUE : FALSE,
						"afk" = admin.is_afk())
	statuscode = 200
	response = "Admin list fetched"
	data = admins

/datum/world_topic/playerlist
	key = "playerlist"
	anonymous = TRUE

/datum/world_topic/playerlist/Run(list/input)
	. = ..()
	data = list()
	for(var/client/C as() in GLOB.clients_unsafe)
		data += C.ckey
	statuscode = 200
	response = "Player list fetched"

/datum/world_topic/status
	key = "status"
	anonymous = TRUE

/datum/world_topic/status/Run(list/input)
	. = ..()
	data = list()
	data["version"] = GLOB.game_version
	data["respawn"] = config ? !CONFIG_GET(flag/norespawn) : FALSE
	data["enter"] = GLOB.enter_allowed
	data["ai"] = CONFIG_GET(flag/allow_ai)
	data["host"] = world.host ? world.host : null
	data["round_id"] = text2num(GLOB.round_id) // I don't know who's fault it is that round id is loaded as a string but screw you
	data["players"] = GLOB.clients_unsafe.len
	data["revision"] = GLOB.revdata.commit
	data["revision_date"] = GLOB.revdata.date
	data["hub"] = GLOB.hub_visibility

	var/list/adm = get_admin_counts()
	var/list/presentmins = adm["present"]
	var/list/afkmins = adm["afk"]
	data["admins"] = presentmins.len + afkmins.len //equivalent to the info gotten from adminwho
	data["gamestate"] = SSticker.current_state

	data["map_name"] = SSmapping.current_map?.map_name || "Loading..."

	data["security_level"] = SSsecurity_level.get_current_level_as_text()
	data["round_duration"] = SSticker?.round_start_timeofday ? round((world.timeofday - SSticker.round_start_timeofday)/10) : 0
	// Amount of world's ticks in seconds, useful for calculating round duration

	//Time dilation stats.
	data["time_dilation_current"] = SStime_track.time_dilation_current
	data["time_dilation_avg"] = SStime_track.time_dilation_avg
	data["time_dilation_avg_slow"] = SStime_track.time_dilation_avg_slow
	data["time_dilation_avg_fast"] = SStime_track.time_dilation_avg_fast

	//pop cap stats
	data["soft_popcap"] = CONFIG_GET(number/soft_popcap) || 0
	data["hard_popcap"] = CONFIG_GET(number/hard_popcap) || 0
	data["extreme_popcap"] = CONFIG_GET(number/extreme_popcap) || 0
	data["popcap"] = max(CONFIG_GET(number/soft_popcap), CONFIG_GET(number/hard_popcap), CONFIG_GET(number/extreme_popcap)) //generalized field for this concept for use across ss13 codebases
	data["bunkered"] = CONFIG_GET(flag/panic_bunker) || 0
	data["interviews"] = CONFIG_GET(flag/panic_bunker_interview) || 0

	if(SSshuttle?.emergency)
		data["shuttle_mode"] = SSshuttle.emergency.mode
		// Shuttle status, see /__DEFINES/stat.dm
		data["shuttle_timer"] = SSshuttle.emergency.timeLeft()
		// Shuttle timer, in seconds
	statuscode = 200
	response = "Status retrieved"

/datum/world_topic/status/authed
	key = "status_authed"
	anonymous = FALSE

/datum/world_topic/status/authed/Run(list/input)
	. = ..()
	// Add on a little extra data for our "special" patrons
	data["active_players"] = get_active_player_count()

/datum/world_topic/identify_uuid
	key = "identify_uuid"
	required_params = list("uuid")

/datum/world_topic/identify_uuid/Run(list/input)
	var/uuid = input["uuid"]
	var/discord_uid = input["discord_uid"]
	data = list()

	if(!SSdbcore.Connect())
		statuscode = 500
		response = "Failed to reach database"
		data = null
		return

	var/datum/db_query/query_ckey_lookup = SSdbcore.NewQuery(
		"SELECT ckey,discord_uid FROM [format_table_name("player")] WHERE uuid = :uuid",
		list("uuid" = uuid)
	)
	if(!query_ckey_lookup.Execute())
		qdel(query_ckey_lookup)
		statuscode = 500
		response = "Database query failed"
		return

	statuscode = 200
	response = "UUID Checked against database"
	data["identified_ckey"] = null
	if(query_ckey_lookup.NextRow())
		var/identified_discord_uid = query_ckey_lookup.item[2]
		var/identified_ckey = query_ckey_lookup.item[1]
		if(!istext(identified_ckey))
			qdel(query_ckey_lookup)
			return
		// No associated UID (unlinked account), a UID was not sent (outdated cog), or the UIDs match
		// If the UIDs do not match, we error
		if(!isnull(identified_discord_uid) && !isnull(discord_uid) && identified_discord_uid != discord_uid)
			qdel(query_ckey_lookup)
			statuscode = 401
			response = "Discord ID mismatch"
			return
		// Update the UID in the database if it's blank.
		if(!isnull(discord_uid) && isnull(identified_discord_uid))
			var/datum/db_query/query_select_discord_uid = SSdbcore.NewQuery(
				"SELECT ckey FROM [format_table_name("player")] WHERE discord_uid = :discord_uid",
				list("discord_uid" = discord_uid)
			)
			if(!query_select_discord_uid.Execute())
				qdel(query_ckey_lookup)
				qdel(query_select_discord_uid)
				statuscode = 500
				response = "Database query failed"
				return
			// Only set it if no one else already has this Discord UID.
			if(!query_select_discord_uid.NextRow())
				var/datum/db_query/query_update_discord_uid = SSdbcore.NewQuery(
					"UPDATE [format_table_name("player")] SET discord_uid = :discord_uid WHERE uuid = :uuid",
					list("uuid" = uuid, "discord_uid" = discord_uid)
				)
				if(!query_update_discord_uid.Execute())
					qdel(query_ckey_lookup)
					qdel(query_select_discord_uid)
					qdel(query_update_discord_uid)
					statuscode = 500
					response = "Database query failed"
					return
				qdel(query_update_discord_uid)
			qdel(query_select_discord_uid)
		data["identified_ckey"] = identified_ckey
	qdel(query_ckey_lookup)


/datum/world_topic/d_ooc_send
	key = "discord_send"
	required_params = list("message", "message_sender")

/datum/world_topic/d_ooc_send/Run(list/input)
	. = ..()
	var/msg = input["message"]
	var/unm = input["message_sender"]
	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	unm = copytext(sanitize(unm), 1, MAX_MESSAGE_LEN)
	msg = emoji_parse(msg)
	log_ooc("DISCORD: [unm]: [msg]")
	for(var/client/C in GLOB.clients_unsafe)
		if(C.prefs.read_player_preference(/datum/preference/toggle/chat_ooc))
			if(!("discord-[unm]" in C.prefs.ignoring))
				to_chat(C, span_dooc("<b>[span_prefix("OOC: ")] <EM>[unm]:</EM> [span_messagelinkify("[msg]")]</b>"))
	statuscode = 200
	response = "Message forwarded to OOC"

/datum/world_topic/get_metacoins
	key = "get_metacoins"
	required_params = list("ckey")

/datum/world_topic/get_metacoins/Run(list/input)
	. = ..()

	var/ckey = input["ckey"]

	if(!ckey || !SSdbcore.Connect())
		statuscode = 500
		response = "Database query failed"
		data = null
		return

	var/datum/db_query/query_get_metacoins = SSdbcore.NewQuery(
		"SELECT metacoins FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	var/mc_count = null
	if(query_get_metacoins.warn_execute())
		if(query_get_metacoins.NextRow())
			mc_count = query_get_metacoins.item[1]
	else
		statuscode = 500
		response = "Database query failed"
		data = null
		return

	qdel(query_get_metacoins)

	statuscode = 200
	response = "Metacoin count retrieved"
	data = mc_count ? text2num(mc_count) : 0

/datum/world_topic/adjust_metacoins
	key = "adjust_metacoins"
	required_params = list("ckey", "amount", "id")

/datum/world_topic/adjust_metacoins/Run(list/input)
	. = ..()

	var/ckey = input["ckey"]
	var/amount = input["amount"]
	var/adjuster_ckey = input["id"]

	if(!SSdbcore.Connect())
		statuscode = 500
		response = "Database query failed"
		data = null
		return

	var/datum/db_query/query_metacoins = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET metacoins = metacoins + :amount WHERE ckey = :ckey",
		list("amount" = amount, "ckey" = ckey)
	)
	if(!query_metacoins.warn_execute())
		statuscode = 500
		response = "Database query failed"
		data = null
		return

	log_game("[ckey]'s metacoins were adjusted ([amount > 0 ? "+[amount]" : "[amount]"]) via Topic() call by [adjuster_ckey ? "[adjuster_ckey]" : "Unknown"]")

	qdel(query_metacoins)

	statuscode = 200
	response = "Metacoin count updated"

#undef TOPIC_VERSION_MAJOR
#undef TOPIC_VERSION_MINOR
#undef TOPIC_VERSION_PATCH
