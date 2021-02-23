// SETUP

/proc/TopicHandlers()
	. = list()
	var/list/all_handlers = subtypesof(/datum/world_topic)
	for(var/I in all_handlers)
		var/datum/world_topic/WT = I
		var/keyword = initial(WT.keyword)
		if(!keyword)
			warning("[WT] has no keyword! Ignoring...")
			continue
		var/existing_path = .[keyword]
		if(existing_path)
			warning("[existing_path] and [WT] have the same keyword! Ignoring [WT]...")
		else if(keyword == "key")
			warning("[WT] has keyword 'key'! Ignoring...")
		else
			.[keyword] = WT

// DATUM

/datum/world_topic
	var/keyword
	var/log = TRUE
	var/key_valid
	var/insecure_key = FALSE
	var/require_comms_key = FALSE
	var/permit_insecure = FALSE

/datum/world_topic/proc/TryRun(list/input, addr)
	key_valid = config && (CONFIG_GET(string/comms_key) == input["key"])
	if(!key_valid && permit_insecure)
		key_valid = config && (CONFIG_GET(string/comms_key_insecure) == input["key"])
		insecure_key = key_valid
	if(require_comms_key && !key_valid)
		return "Bad Key"
	if(insecure_key) // ignore the rate limiting if using true comms key
		var/delta = world.time - GLOB.topic_cooldown
		if(delta < CONFIG_GET(number/insecure_topic_cooldown))
			return "Rate Limited"
		GLOB.topic_cooldown = world.time
	input -= "key"
	. = Run(input, addr)
	if(islist(.))
		. = list2params(.)

/datum/world_topic/proc/Run(list/input, addr)
	CRASH("Run() not implemented for [type]!")

// TOPICS

/datum/world_topic/ping
	keyword = "ping"
	log = FALSE

/datum/world_topic/ping/Run(list/input, addr)
	. = 0
	for (var/client/C in GLOB.clients)
		++.

/datum/world_topic/playing
	keyword = "playing"
	log = FALSE

/datum/world_topic/playing/Run(list/input, addr)
	return GLOB.player_list.len

/datum/world_topic/pr_announce
	keyword = "announce"
	require_comms_key = TRUE
	var/static/list/PRcounts = list()	//PR id -> number of times announced this round

/datum/world_topic/pr_announce/Run(list/input, addr)
	var/list/payload = json_decode(input["payload"])
	var/id = "[payload["pull_request"]["id"]]"
	if(!PRcounts[id])
		PRcounts[id] = 1
	else
		++PRcounts[id]
		if(PRcounts[id] > PR_ANNOUNCEMENTS_PER_ROUND)
			return

	var/final_composed = "<span class='announce'>PR: [input[keyword]]</span>"
	for(var/client/C in GLOB.clients)
		C.AnnouncePR(final_composed)

/datum/world_topic/ahelp_relay
	keyword = "Ahelp"
	require_comms_key = TRUE

/datum/world_topic/ahelp_relay/Run(list/input, addr)
	relay_msg_admins("<span class='adminnotice'><b><font color=red>HELP: </font> [input["source"]] [input["message_sender"]]: [input["message"]]</b></span>")

/datum/world_topic/comms_console
	keyword = "Comms_Console"
	require_comms_key = TRUE
	permit_insecure = TRUE

/datum/world_topic/comms_console/Run(list/input, addr)
	if(insecure_key && !CONFIG_GET(flag/insecure_announce))
		return

	if(CHAT_FILTER_CHECK(input["message"])) // prevents any.. diplomatic incidents
		minor_announce("In the interest of station productivity and mental hygiene, a message from [input["message_sender"]] was intercepted by the CCC and determined to be unfit for crew-level access.", "CentCom Communications Commission")
		message_admins("Incomming cross-comms message from [input["message_sender"]] blocked: [input["message"]]")
		return
	minor_announce(input["message"], "Incoming message from [input["message_sender"]]")
	for(var/obj/machinery/computer/communications/CM in GLOB.machines)
		CM.overrideCooldown()

/datum/world_topic/news_report
	keyword = "News_Report"
	require_comms_key = TRUE
	permit_insecure = TRUE

/datum/world_topic/news_report/Run(list/input, addr)
	if(insecure_key && !CONFIG_GET(flag/insecure_newscaster))
		return

	minor_announce(input["message"], "Breaking Update From [input["message_sender"]]")

/datum/world_topic/adminmsg
	keyword = "adminmsg"
	require_comms_key = TRUE

/datum/world_topic/adminmsg/Run(list/input, addr)
	return IrcPm(input[keyword], input["msg"], input["sender"])

/datum/world_topic/namecheck
	keyword = "namecheck"
	require_comms_key = TRUE

/datum/world_topic/namecheck/Run(list/input, addr)
	//Oh this is a hack, someone refactor the functionality out of the chat command PLS
	var/datum/tgs_chat_command/namecheck/NC = new
	var/datum/tgs_chat_user/user = new
	user.friendly_name = input["sender"]
	user.mention = user.friendly_name
	return NC.Run(user, input["namecheck"])

/datum/world_topic/adminwho
	keyword = "adminwho"
	require_comms_key = TRUE

/datum/world_topic/adminwho/Run(list/input, addr)
	return ircadminwho()

/datum/world_topic/playerlist
	keyword = "playerlist"

/datum/world_topic/playerlist/Run(list/input, addr)
	. = list()
	for(var/client/C as() in GLOB.clients)
		. += C.ckey

/datum/world_topic/status
	keyword = "status"

/datum/world_topic/status/Run(list/input, addr)
	. = list()
	.["version"] = GLOB.game_version
	.["mode"] = GLOB.master_mode
	.["respawn"] = config ? !CONFIG_GET(flag/norespawn) : FALSE
	.["enter"] = GLOB.enter_allowed
	.["vote"] = CONFIG_GET(flag/allow_vote_mode)
	.["ai"] = CONFIG_GET(flag/allow_ai)
	.["host"] = world.host ? world.host : null
	.["round_id"] = GLOB.round_id
	.["players"] = GLOB.clients.len
	.["revision"] = GLOB.revdata.commit
	.["revision_date"] = GLOB.revdata.date
	.["hub"] = GLOB.hub_visibility

	var/list/adm = get_admin_counts()
	var/list/presentmins = adm["present"]
	var/list/afkmins = adm["afk"]
	.["admins"] = presentmins.len + afkmins.len //equivalent to the info gotten from adminwho
	.["gamestate"] = SSticker.current_state

	.["map_name"] = SSmapping.config?.map_name || "Loading..."

	if(key_valid)
		.["active_players"] = get_active_player_count()
		if(SSticker.HasRoundStarted())
			.["real_mode"] = SSticker.mode.name
			// Key-authed callers may know the truth behind the "secret"

	.["security_level"] = get_security_level()
	.["round_duration"] = SSticker ? round((world.time-SSticker.round_start_time)/10) : 0
	// Amount of world's ticks in seconds, useful for calculating round duration

	//Time dilation stats.
	.["time_dilation_current"] = SStime_track.time_dilation_current
	.["time_dilation_avg"] = SStime_track.time_dilation_avg
	.["time_dilation_avg_slow"] = SStime_track.time_dilation_avg_slow
	.["time_dilation_avg_fast"] = SStime_track.time_dilation_avg_fast

	//pop cap stats
	.["soft_popcap"] = CONFIG_GET(number/soft_popcap) || 0
	.["hard_popcap"] = CONFIG_GET(number/hard_popcap) || 0
	.["extreme_popcap"] = CONFIG_GET(number/extreme_popcap) || 0
	.["popcap"] = max(CONFIG_GET(number/soft_popcap), CONFIG_GET(number/hard_popcap), CONFIG_GET(number/extreme_popcap)) //generalized field for this concept for use across ss13 codebases

	if(SSshuttle?.emergency)
		.["shuttle_mode"] = SSshuttle.emergency.mode
		// Shuttle status, see /__DEFINES/stat.dm
		.["shuttle_timer"] = SSshuttle.emergency.timeLeft()
		// Shuttle timer, in seconds

/datum/world_topic/identify_uuid
	keyword = "identify_uuid"
	require_comms_key = TRUE
	log = FALSE

/datum/world_topic/identify_uuid/Run(list/input, addr)
	var/uuid = input["uuid"]
	. = list()

	if(!SSdbcore.Connect())
		return null

	var/datum/DBQuery/query_ckey_lookup = SSdbcore.NewQuery(
		"SELECT ckey FROM [format_table_name("player")] WHERE uuid = :uuid",
		list("uuid" = uuid)
	)
	if(!query_ckey_lookup.Execute())
		qdel(query_ckey_lookup)
		return null

	.["identified_ckey"] = null
	if(query_ckey_lookup.NextRow())
		.["identified_ckey"] = query_ckey_lookup.item[1]
	qdel(query_ckey_lookup)
	return .

/datum/world_topic/get_metacoins
	keyword = "get_metacoins"

/datum/world_topic/get_metacoins/Run(list/input, addr)
	var/ckey = input["ckey"]

	if(!ckey || !SSdbcore.Connect())
		return null

	var/datum/DBQuery/query_get_metacoins = SSdbcore.NewQuery(
		"SELECT metacoins FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	var/mc_count = null
	if(query_get_metacoins.warn_execute())
		if(query_get_metacoins.NextRow())
			mc_count = query_get_metacoins.item[1]

	qdel(query_get_metacoins)
	return mc_count ? text2num(mc_count) : null

/datum/world_topic/adjust_metacoins
	keyword = "adjust_metacoins"
	require_comms_key = TRUE

/datum/world_topic/adjust_metacoins/Run(list/input, addr)
	var/ckey = input["ckey"]
	var/amount = input["amount"]
	var/adjuster_ckey = input["id"]

	if(!ckey || !amount || !SSdbcore.Connect())
		return FALSE

	. = TRUE

	var/datum/DBQuery/query_metacoins = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET metacoins = metacoins + :amount WHERE ckey = :ckey",
		list("amount" = amount, "ckey" = ckey)
	)
	if(!query_metacoins.warn_execute())
		. = FALSE

	log_game("[ckey]'s metacoins were adjusted ([amount > 0 ? "+[amount]" : "[amount]"]) via Topic() call by [adjuster_ckey ? "[adjuster_ckey]" : "Unknown"]")

	qdel(query_metacoins)
