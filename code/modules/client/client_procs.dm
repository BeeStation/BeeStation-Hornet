	////////////
	//SECURITY//
	////////////


#define UPLOAD_LIMIT		10485760	//Restricts client uploads to the server to 1MB //Could probably do with being lower.

GLOBAL_LIST_INIT(blacklisted_builds, list(
	"1407" = "bug preventing client display overrides from working leads to clients being able to see things/mobs they shouldn't be able to see",
	"1408" = "bug preventing client display overrides from working leads to clients being able to see things/mobs they shouldn't be able to see",
	"1428" = "bug causing right-click menus to show too many verbs that's been fixed in version 1429",
	))

#define LIMITER_SIZE	5
#define CURRENT_SECOND	1
#define SECOND_COUNT	2
#define CURRENT_MINUTE	3
#define MINUTE_COUNT	4
#define ADMINSWARNED_AT	5
	/*
	When somebody clicks a link in game, this Topic is called first.
	It does the stuff in this proc and  then is redirected to the Topic() proc for the src=[0xWhatever]
	(if specified in the link). ie locate(hsrc).Topic()

	Such links can be spoofed.

	Because of this certain things MUST be considered whenever adding a Topic() for something:
		- Can it be fed harmful values which could cause runtimes?
		- Is the Topic call an admin-only thing?
		- If so, does it have checks to see if the person who called it (usr.client) is an admin?
		- Are the processes being called by Topic() particularly laggy?
		- If so, is there any protection against somebody spam-clicking a link?
	If you have any  questions about this stuff feel free to ask. ~Carn

	the undocumented 4th argument is for ?[0x\ref] style topic links. hsrc is set to the reference and anything after the ] gets put into hsrc_command
	*/

/client/Topic(href, href_list, hsrc, hsrc_command)
	if(!usr || usr != mob)	//stops us calling Topic for somebody else's client. Also helps prevent usr=null
		return

#ifndef TESTING
	//disable the integrated byond vv in the client side debugging tools since it doesn't respect vv read protections
	if (LOWER_TEXT(hsrc_command) == "_debug")
		return
#endif

	// asset_cache
	var/asset_cache_job
	if(href_list["asset_cache_confirm_arrival"])
		asset_cache_job = asset_cache_confirm_arrival(href_list["asset_cache_confirm_arrival"])
		if (!asset_cache_job)
			return

	var/mtl = CONFIG_GET(number/minute_topic_limit)
	if (!holder && mtl)
		var/minute = round(world.time, 600)
		if (!topiclimiter)
			topiclimiter = new(LIMITER_SIZE)
		if (minute != topiclimiter[CURRENT_MINUTE])
			topiclimiter[CURRENT_MINUTE] = minute
			topiclimiter[MINUTE_COUNT] = 0
		topiclimiter[MINUTE_COUNT] += 1
		if (topiclimiter[MINUTE_COUNT] > mtl)
			var/msg = "Your previous action was ignored because you've done too many in a minute."
			if (minute != topiclimiter[ADMINSWARNED_AT]) //only one admin message per-minute. (if they spam the admins can just boot/ban them)
				topiclimiter[ADMINSWARNED_AT] = minute
				msg += " Administrators have been informed."
				log_game("[key_name(src)] Has hit the per-minute topic limit of [mtl] topic calls in a given game minute")
				message_admins("[ADMIN_LOOKUPFLW(src)] [ADMIN_KICK(usr)] Has hit the per-minute topic limit of [mtl] topic calls in a given game minute")
			to_chat(src, span_danger("[msg]"))
			return

	var/stl = CONFIG_GET(number/second_topic_limit)
	if (!holder && stl)
		var/second = round(world.time, 10)
		if (!topiclimiter)
			topiclimiter = new(LIMITER_SIZE)
		if (second != topiclimiter[CURRENT_SECOND])
			topiclimiter[CURRENT_SECOND] = second
			topiclimiter[SECOND_COUNT] = 0
		topiclimiter[SECOND_COUNT] += 1
		if (topiclimiter[SECOND_COUNT] > stl)
			to_chat(src, span_danger("Your previous action was ignored because you've done too many in a second"))
			return

	//Logs all hrefs, except chat pings
	if(!(href_list["window_id"] == "browseroutput" && href_list["type"] == "ping" && LAZYLEN(href_list) == 4))
		log_href("[src] (usr:[usr]\[[COORD(usr)]\]) : [hsrc ? "[hsrc] " : ""][href]")

	//byond bug ID:2256651
	if (asset_cache_job && (asset_cache_job in completed_asset_jobs))
		to_chat(src, span_danger("An error has been detected in how your client is receiving resources. Attempting to correct.... (If you keep seeing these messages you might want to close byond and reconnect)"))
		src << browse("...", "window=asset_cache_browser")
		return
	if (href_list["asset_cache_preload_data"])
		asset_cache_preload_data(href_list["asset_cache_preload_data"])
		return

	// Tgui Topic middleware
	if(tgui_Topic(href_list))
		return

	if(href_list["reload_tguipanel"])
		nuke_chat()

	// Admin PM
	if(href_list["priv_msg"])
		cmd_admin_pm(href_list["priv_msg"],null)
		return

	// Mentor PM
	if(href_list["mentor_msg"])
		cmd_mentor_pm(href_list["mentor_msg"], null)
		return TRUE

	if(href_list["commandbar_typing"])
		handle_commandbar_typing(href_list)

	switch(href_list["_src_"])
		if("holder")
			hsrc = holder
		if("mentor")
			hsrc = mentor_datum
		if("usr")
			hsrc = mob
		if("vars")
			return view_var_Topic(href,href_list,hsrc)

	switch(href_list["action"])
		if("openLink")
			src << link(href_list["link"])
	if (hsrc)
		var/datum/real_src = hsrc
		if(QDELETED(real_src))
			return

	..()	//redirect to hsrc.Topic()

/// If this client is BYOND member.
/client/proc/is_content_unlocked()
	return prefs.unlock_content

/*
 * Call back proc that should be checked in all paths where a client can send messages
 *
 * Handles checking for people sending messages too fast.
 *
 * This is defined as sending SPAM_TRIGGER_AUTOMUTE (10) messages within 5 seconds, which gets you auto-muted.
 *
 * You will be warned if you send SPAM_TRIGGER_WARNING(5) messages withing 5 seconds to hopefully prevent false positives.
 *
 */
/client/proc/handle_spam_prevention(message, mute_type)
	if(!(CONFIG_GET(flag/automute_on)))
		return FALSE

	if(COOLDOWN_FINISHED(src, total_count_reset))
		total_message_count = 0 //reset the count if it's been more than 5 seconds since the first message
		COOLDOWN_START(src, total_count_reset, 5 SECONDS) //inside this if so we don't reset it every single message

	total_message_count++

	if(total_message_count >= SPAM_TRIGGER_AUTOMUTE)
		to_chat(src, span_userdanger("You have exceeded the spam filter limit for too many messages. An auto-mute was applied. Make an adminhelp ticket if you think this was in error."))
		cmd_admin_mute(src, mute_type, TRUE)
		return TRUE

	if(total_message_count >= SPAM_TRIGGER_WARNING)
		to_chat(src, span_userdanger("You are nearing the spam filter limit for too many messages in a short period. Slow down."))
		return FALSE

/client/proc/silicon_spam_grace()
	total_message_count = max(total_message_count--, 0)
	// Stating laws isn't spam at all.

/client/proc/silicon_spam_grace_done(total_laws_count)
	if(total_laws_count>2)
		total_laws_count = 2
	total_message_count += total_laws_count
	// Stating laws isn't spam, but doing so much is spam.

//This stops files larger than UPLOAD_LIMIT being sent from client to server via input(), client.Import() etc.
/client/AllowUpload(filename, filelength)
	if(filelength > UPLOAD_LIMIT)
		to_chat(src, "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT/1024]KiB.</font>")
		return FALSE
	return TRUE


	///////////
	//CONNECT//
	///////////

/client/New(TopicData)
	var/tdata = TopicData //save this for later use
	TopicData = null							//Prevent calls to client.Topic from connect

	if(connection != "seeker" && connection != "web")//Invalid connection type.
		return null

	if(CONFIG_GET(flag/respect_upstream_bans) || CONFIG_GET(flag/respect_upstream_permabans))
		check_upstream_bans()

	GLOB.clients += src
	GLOB.directory[ckey] = src

	if(byond_version >= 516)
		winset(src, null, list("browser-options" = "find,refresh,byondstorage"))

	// Instantiate tgui panel
	tgui_panel = new(src, "browseroutput")

	tgui_say = new(src, "tgui_say")
	tgui_asay = new(src, "tgui_asay")

	initialize_commandbar_spy()

	set_right_click_menu_mode(TRUE)

	GLOB.ahelp_tickets.ClientLogin(src)
	GLOB.mhelp_tickets.ClientLogin(src)
	GLOB.interviews.client_login(src)
	GLOB.requests.client_login(src)
	var/connecting_admin = FALSE //because de-admined admins connecting should be treated like admins.
	//Admin Authorisation
	holder = GLOB.admin_datums[ckey]
	if(holder)
		GLOB.admins |= src
		holder.owner = src
		connecting_admin = TRUE
	else if(GLOB.deadmins[ckey])
		add_verb(/client/proc/readmin)
		connecting_admin = TRUE
	if(CONFIG_GET(flag/autoadmin))
		if(!GLOB.admin_datums[ckey])
			var/datum/admin_rank/autorank
			for(var/datum/admin_rank/R in GLOB.admin_ranks)
				if(R.name == CONFIG_GET(string/autoadmin_rank))
					autorank = R
					break
			if(!autorank)
				to_chat(world, "Autoadmin rank not found")
			else
				new /datum/admins(autorank, ckey)
	if(CONFIG_GET(flag/enable_localhost_rank) && !connecting_admin)
		var/localhost_addresses = list("127.0.0.1", "::1")
		if(isnull(address) || (address in localhost_addresses))
			if(Debugger?.enabled)
				to_chat_immediate(src, span_userdanger("Debugger enabled. Make sure you untick \"Runtime errors\" in the bottom left of VSCode's Run and Debug tab."))
			var/datum/admin_rank/localhost_rank = new("!localhost!", R_EVERYTHING, R_DBRANKS, R_EVERYTHING) //+EVERYTHING -DBRANKS *EVERYTHING
			new /datum/admins(localhost_rank, ckey, 1, 1)

	// This needs to go after admin loading but before prefs
	assign_mentor_datum_if_exists()

	// Retrieve cached metabalance
	get_metabalance_db()
	// Retrieve cached antag token count
	get_antag_token_count_db()
	if(!src) // Yes this is possible, because the procs above sleep.
		return
	//preferences datum - also holds some persistent data for the client (because we may as well keep these datums to a minimum)
	prefs = GLOB.preferences_datums[ckey]
	if(prefs)
		prefs.parent = src
		prefs.apply_all_client_preferences()
	else
		prefs = new /datum/preferences(src)
		GLOB.preferences_datums[ckey] = prefs
	prefs.last_ip = address				//these are gonna be used for banning
	prefs.last_id = computer_id			//these are gonna be used for banning

	prefs.handle_donator_items()

	if(fexists(roundend_report_file()))
		add_verb(/client/proc/show_previous_roundend_report)

	var/full_version = "[byond_version].[byond_build ? byond_build : "xxx"]"
	log_access("Login: [key_name(src)] from [address ? address : "localhost"]-[computer_id] || BYOND v[full_version]")

	var/alert_mob_dupe_login = FALSE
	var/alert_admin_multikey = FALSE
	if(CONFIG_GET(flag/log_access))
		var/list/joined_players = list()
		for(var/player_ckey in GLOB.joined_player_list)
			joined_players[player_ckey] = 1

		for(var/joined_player_ckey in (GLOB.directory | joined_players))
			if (!joined_player_ckey || joined_player_ckey == ckey)
				continue

			var/datum/preferences/joined_player_preferences = GLOB.preferences_datums[joined_player_ckey]
			if(!joined_player_preferences)
				continue //this shouldn't happen.

			var/client/C = GLOB.directory[joined_player_ckey]
			var/in_round = ""
			if (joined_players[joined_player_ckey])
				in_round = " who has played in the current round"
			var/message_type = "Notice"

			var/matches
			if(joined_player_preferences.last_ip == address)
				matches += "IP ([address])"
			if(joined_player_preferences.last_id == computer_id)
				if(matches)
					matches = "BOTH [matches] and "
					alert_admin_multikey = TRUE
					message_type = "MULTIKEY"
				matches += "Computer ID ([computer_id])"
				alert_mob_dupe_login = TRUE

			if(matches)
				if(C)
					message_admins("[span_danger("<B>[message_type]:</B>")] [span_notice("Connecting player [key_name_admin(src)] has the same [matches] as [key_name_admin(C)]<b>[in_round]</b>.")]")
					log_admin_private("[message_type]: Connecting player [key_name(src)] has the same [matches] as [key_name(C)][in_round].")
				else
					message_admins("[span_danger("<B>[message_type]: </B>")][span_notice("Connecting player [key_name_admin(src)] has the same [matches] as [joined_player_ckey](no longer logged in)<b>[in_round]</b>.")]")
					log_admin_private("[message_type]: Connecting player [key_name(src)] has the same [matches] as [joined_player_ckey](no longer logged in)[in_round].")
	if(GLOB.player_details[ckey])
		player_details = GLOB.player_details[ckey]
		player_details.byond_version = full_version
	else
		player_details = new(ckey)
		player_details.byond_version = full_version
		GLOB.player_details[ckey] = player_details


	. = ..()	//calls mob.Login()

	if (byond_version >= 512)
		if (!byond_build || byond_build < 1386)
			message_admins(span_adminnotice("[key_name(src)] has been detected as spoofing their byond version. Connection rejected."))
			add_system_note("Spoofed-Byond-Version", "Detected as using a spoofed byond version.")
			log_access("Failed Login: [key] - Spoofed byond version")
			qdel(src)

		if (num2text(byond_build) in GLOB.blacklisted_builds)
			log_access("Failed login: [key] - blacklisted byond version")
			to_chat_immediate(src, span_userdanger("Your version of byond is blacklisted."))
			to_chat_immediate(src, span_danger("Byond build [byond_build] ([byond_version].[byond_build]) has been blacklisted for the following reason: [GLOB.blacklisted_builds[num2text(byond_build)]]."))
			to_chat_immediate(src, span_danger("Please download a new version of byond. If [byond_build] is the latest, you can go to <a href=\"https://secure.byond.com/download/build\">BYOND's website</a> to download other versions."))
			if(connecting_admin)
				to_chat_immediate(src, "As an admin, you are being allowed to continue using this version, but please consider changing byond versions")
			else
				qdel(src)
				return

	var/max_recommended_client = CONFIG_GET(number/client_max_build)
	if(byond_build > max_recommended_client)
		to_chat(src, span_userdanger("Your version of byond is over the maximum recommended version for clients (build [max_recommended_client]) and may be unstable."))
		to_chat(src, span_danger("Please download an older version of byond. You can go to <a href=\"https://secure.byond.com/download/build\">BYOND's website</a> to download other versions."))
	if(SSinput.initialized)
		set_macros()

	// Initialize tgui panel
	tgui_panel.Initialize()
	tgui_say.initialize()
	tgui_asay.initialize()

	if(alert_mob_dupe_login && !holder)
		var/dupe_login_message = "Your ComputerID has already logged in with another key this round, please log out of this one NOW or risk being banned!"
		if (alert_admin_multikey)
			dupe_login_message += "\nAdmins have been informed."
			message_admins("[span_danger("<B>MULTIKEYING:</B>")] [span_notice("[key_name_admin(src)] has a matching CID+IP with another player and is clearly multikeying. They have been warned to leave the server or risk getting banned.")]")
			log_admin_private("MULTIKEYING: [key_name(src)] has a matching CID+IP with another player and is clearly multikeying. They have been warned to leave the server or risk getting banned.")
		spawn(0.5 SECONDS) //needs to run during world init, do not convert to add timer
			alert(mob, dupe_login_message) //players get banned if they don't see this message, do not convert to tgui_alert (or even tg_alert) please.
			to_chat_immediate(mob, span_danger("[dupe_login_message]"))


	connection_time = world.time
	connection_realtime = world.realtime
	connection_timeofday = world.timeofday
	winset(src, null, "command=\".configure graphics-hwmode on\"")

	var/breaking_version = CONFIG_GET(number/client_error_version)
	var/breaking_build = CONFIG_GET(number/client_error_build)
	var/warn_version = CONFIG_GET(number/client_warn_version)
	var/warn_build = CONFIG_GET(number/client_warn_build)

	if (byond_version < breaking_version || (byond_version == breaking_version && byond_build < breaking_build)) //Out of date client.
		to_chat_immediate(src, span_danger("<b>Your version of BYOND is too old:</b>"))
		to_chat_immediate(src, CONFIG_GET(string/client_error_message))
		to_chat_immediate(src, "Your version: [byond_version].[byond_build]")
		to_chat_immediate(src, "Required version: [breaking_version].[breaking_build] or later")
		to_chat_immediate(src, "Visit <a href=\"https://secure.byond.com/download\">BYOND's website</a> to get the latest version of BYOND.")
		if (connecting_admin)
			to_chat_immediate(src, "Because you are an admin, you are being allowed to walk past this limitation, But it is still STRONGLY suggested you upgrade")
		else
			qdel(src)
			return
	else if (byond_version < warn_version || (byond_version == warn_version && byond_build < warn_build)) //We have words for this client.
		if(CONFIG_GET(flag/client_warn_popup))
			var/msg = "<b>Your version of byond may be getting out of date:</b><br>"
			msg += CONFIG_GET(string/client_warn_message) + "<br><br>"
			msg += "Your version: [byond_version].[byond_build]<br>"
			msg += "Required version to remove this message: [warn_version].[warn_build] or later<br>"
			msg += "Visit <a href=\"https://secure.byond.com/download\">BYOND's website</a> to get the latest version of BYOND.<br>"
			src << browse(HTML_SKELETON(msg), "window=warning_popup")
		else
			to_chat(src, span_danger("<b>Your version of byond may be getting out of date:</b>"))
			to_chat(src, CONFIG_GET(string/client_warn_message))
			to_chat(src, "Your version: [byond_version].[byond_build]")
			to_chat(src, "Required version to remove this message: [warn_version].[warn_build] or later")
			to_chat(src, "Visit <a href=\"https://secure.byond.com/download\">BYOND's website</a> to get the latest version of BYOND.")

	if (connection == "web" && !connecting_admin)
		if (!CONFIG_GET(flag/allow_webclient))
			to_chat_immediate(src, "Web client is disabled")
			qdel(src)
			return
		if (CONFIG_GET(flag/webclient_only_byond_members) && !IsByondMember())
			to_chat_immediate(src, "Sorry, but the web client is restricted to byond members only.")
			qdel(src)
			return

	if( (world.address == address || !address) && !GLOB.host )
		GLOB.host = key
		world.update_status()

	if(holder)
		add_admin_verbs()
		to_chat(src, get_message_output("memo"))
		adminGreet()
	add_verbs_from_config()
	var/cached_player_age = set_client_age_from_db(tdata) //we have to cache this because other shit may change it and we need it's current value now down below.

	if(QDELETED(src))
		return null

	if (isnum_safe(cached_player_age) && cached_player_age == -1) //first connection
		player_age = 0
	var/nnpa = CONFIG_GET(number/notify_new_player_age)
	if (isnum_safe(cached_player_age) && cached_player_age == -1) //first connection
		if (nnpa >= 0)
			message_admins("New user: [key_name_admin(src)] is connecting here for the first time.")
			if (CONFIG_GET(flag/irc_first_connection_alert))
				send2tgs_adminless_only("New-user", "[key_name(src)] is connecting for the first time!")
	else if (isnum_safe(cached_player_age) && cached_player_age < nnpa)
		message_admins("New user: [key_name_admin(src)] just connected with an age of [cached_player_age] day[(player_age==1?"":"s")]")
	if(CONFIG_GET(flag/use_account_age_for_jobs) && account_age >= 0)
		player_age = account_age
	if(account_age >= 0 && account_age < nnpa)
		message_admins("[key_name_admin(src)] (IP: [address], ID: [computer_id]) is a new BYOND account [account_age] day[(account_age==1?"":"s")] old, created on [account_join_date].")
		if (CONFIG_GET(flag/irc_first_connection_alert))
			send2tgs_adminless_only("new_byond_user", "[key_name(src)] (IP: [address], ID: [computer_id]) is a new BYOND account [account_age] day[(account_age==1?"":"s")] old, created on [account_join_date].")
	get_message_output("watchlist entry", ckey)
	check_ip_intel()
	validate_key_in_db()
	// If we aren't already generating a ban cache, fire off a build request
	// This way hopefully any users of request_ban_cache will never need to yield
	if(!ban_cache_start && SSban_cache?.query_started)
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(build_ban_cache), src)

	fetch_uuid()
	add_verb(/client/proc/show_account_identifier)

	send_resources()

	generate_clickcatcher()
	apply_clickcatcher()

	if(prefs.lastchangelog != GLOB.changelog_hash) //bolds the changelog button on the interface so we know there are updates.
		to_chat(src, span_info("You have unread updates in the changelog."))
		if(CONFIG_GET(flag/aggressive_changelog))
			changelog()
		else
			winset(src, "infowindow.changelog", "font-style=bold")

	if(ckey in GLOB.clientmessages)
		for(var/message in GLOB.clientmessages[ckey])
			to_chat(src, message)
		GLOB.clientmessages.Remove(ckey)

	if(CONFIG_GET(flag/autoconvert_notes))
		convert_notes_sql(ckey)
	to_chat(src, get_message_output("message", ckey))
	if(!winexists(src, "asset_cache_browser")) // The client is using a custom skin, tell them.
		to_chat(src, span_warning("Unable to access asset cache browser, if you are using a custom skin file, please allow DS to download the updated version, if you are not, then make a bug report. This is not a critical issue but can cause issues with resource downloading, as it is impossible to know when extra resources arrived to you."))

	//This is down here because of the browse() calls in tooltip/New()
	if(!tooltips)
		tooltips = new /datum/tooltip(src)

	view_size = new(src, getScreenSize(mob))
	view_size.resetFormat()
	view_size.setZoomMode()
	fit_viewport()
	Master.UpdateTickRate()

	if(GLOB.ckey_redirects.Find(ckey))
		if(isnewplayer(mob))
			to_chat(src, span_redtext("The server is full. You will be redirected to [CONFIG_GET(string/redirect_address)] in 10 seconds."))
			addtimer(CALLBACK(src, PROC_REF(time_to_redirect)), (10 SECONDS))
		else
			GLOB.ckey_redirects -= ckey

	//Add the default client verbs to the TGUI window
	add_verb(subtypesof(/client/verb), TRUE)

	//Load the TGUI stat in case of TGUI subsystem not ready (startup)
	mob.UpdateMobStat(TRUE)
	fully_created = TRUE

/client/proc/set_right_click_menu_mode(shift_only)
	if(shift_only)
		winset(src, "mapwindow.map", "right-click=true")
		winset(src, "default.ShiftUp", "is-disabled=false")
		winset(src, "default.Shift", "is-disabled=false")
	else
		winset(src, "mapwindow.map", "right-click=false")
		winset(src, "default.Shift", "is-disabled=true")
		winset(src, "default.ShiftUp", "is-disabled=true")

/client/proc/time_to_redirect()
	var/redirect_address = CONFIG_GET(string/redirect_address)
	GLOB.ckey_redirects -= ckey
	if(GLOB.joined_player_list.Find(ckey))
		GLOB.joined_player_list -= ckey
	src << link("[redirect_address]")
	qdel(src)

/client/proc/generate_uuid()
	if(IsAdminAdvancedProcCall())
		log_admin("Attempted admin generate_uuid() proc call blocked.")
		message_admins("Attempted admin generate_uuid() proc call blocked.")
		return FALSE

	var/fiftyfifty = prob(50) ? FEMALE : MALE
	var/hashtext = "[ckey][rand(0,9999)][world.realtime][rand(0,9999)][random_unique_name(fiftyfifty)][rand(0,9999)][address][rand(0,9999)][computer_id][rand(0,9999)][GLOB.round_id]"
	var/uuid = "[rustg_hash_string(RUSTG_HASH_SHA256, hashtext)]"

	if(!SSdbcore.Connect())
		return FALSE

	var/datum/db_query/query_update_uuid = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET uuid = :uuid WHERE ckey = :ckey",
		list("uuid" = uuid, "ckey" = ckey)
	)
	query_update_uuid.Execute()
	qdel(query_update_uuid)

	return uuid

/client/proc/fetch_uuid()
	if(IsAdminAdvancedProcCall())
		log_admin("Attempted admin fetch_uuid() proc call blocked.")
		message_admins("Attempted admin fetch_uuid() proc call blocked.")
		return FALSE

	if(!SSdbcore.Connect())
		return FALSE

	var/datum/db_query/query_get_uuid = SSdbcore.NewQuery(
		"SELECT uuid FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	if(!query_get_uuid.Execute())
		qdel(query_get_uuid)
		return FALSE
	var/uuid = null
	if(query_get_uuid.NextRow())
		uuid = query_get_uuid.item[1]
	qdel(query_get_uuid)
	if(uuid == null)
		return generate_uuid()
	else
		return uuid

//////////////
//DISCONNECT//
//////////////

/client/Del()
	if(!gc_destroyed)
		Destroy() //Clean up signals and timers.
	return ..()

/client/Destroy()
	GLOB.clients -= src
	GLOB.directory -= ckey
	GLOB.mentors -= src
	log_access("Logout: [key_name(src)]")
	GLOB.ahelp_tickets.ClientLogout(src)
	GLOB.mhelp_tickets.ClientLogout(src)
	GLOB.interviews.client_logout(src)

	if(holder)
		adminGreet(1)
		holder.owner = null
		GLOB.admins -= src
		if (!GLOB.admins.len && SSticker.IsRoundInProgress()) //Only report this stuff if we are currently playing.
			var/cheesy_message = pick(
				"I have no admins online!",\
				"I'm all alone :(",\
				"I'm feeling lonely :(",\
				"I'm so lonely :(",\
				"Why does nobody love me? :(",\
				"I want a man :(",\
				"Where has everyone gone?",\
				"I need a hug :(",\
				"Someone come hold me :(",\
				"I need someone on me :(",\
				"What happened? Where has everyone gone?",\
				"Forever alone :("\
			)

			send2tgs("Server", "[cheesy_message] (No admins online)")

	if(isatom(eye)) // admeme vv failproof. eye must be atom
		var/atom/eye_thing = eye
		LAZYREMOVE(eye_thing.eye_users, src)
	GLOB.requests.client_logout(src)

	SSambience.remove_ambience_client(src)
	Master.UpdateTickRate()
	..() //Even though we're going to be hard deleted there are still some things that want to know the destroy is happening
	return QDEL_HINT_HARDDEL_NOW

/client/proc/set_client_age_from_db(connectiontopic)
	if(IS_GUEST_KEY(key))
		return
	if(!SSdbcore.Connect())
		return
	var/datum/db_query/query_get_related_ip = SSdbcore.NewQuery(
		"SELECT ckey FROM [format_table_name("player")] WHERE ip = INET_ATON(:address) AND ckey != :ckey",
		list("address" = address, "ckey" = ckey)
	)
	if(!query_get_related_ip.Execute())
		qdel(query_get_related_ip)
		return
	related_accounts_ip = ""
	while(query_get_related_ip.NextRow())
		related_accounts_ip += "[query_get_related_ip.item[1]], "
	qdel(query_get_related_ip)
	var/datum/db_query/query_get_related_cid = SSdbcore.NewQuery(
		"SELECT ckey FROM [format_table_name("player")] WHERE computerid = :computerid AND ckey != :ckey",
		list("computerid" = computer_id, "ckey" = ckey)
	)
	if(!query_get_related_cid.Execute())
		qdel(query_get_related_cid)
		return
	related_accounts_cid = ""
	while(query_get_related_cid.NextRow())
		related_accounts_cid += "[query_get_related_cid.item[1]], "
	qdel(query_get_related_cid)
	var/admin_rank = "Player"
	if(holder?.rank)
		admin_rank = holder.rank.name
	else
		if(!GLOB.deadmins[ckey] && check_randomizer(connectiontopic))
			return
	var/new_player
	var/datum/db_query/query_client_in_db = SSdbcore.NewQuery(
		"SELECT 1 FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	if(!query_client_in_db.Execute())
		qdel(query_client_in_db)
		return

	var/client_is_in_db = query_client_in_db.NextRow()
	// If we aren't an admin, and the flag is set (the panic bunker is enabled).
	if(CONFIG_GET(flag/panic_bunker) && !holder && !GLOB.deadmins[ckey])
		// The amount of hours needed to bypass the panic bunker.
		var/living_recs = CONFIG_GET(number/panic_bunker_living)
		// This relies on prefs existing, but this proc is only called after that occurs, so we're fine.
		var/minutes = get_exp_living(pure_numeric = TRUE)
		// Check to see if our client should be rejected.
		// If interviews are on, we should let anyone through, ideally.
		if(!CONFIG_GET(flag/panic_bunker_interview))
			// If we don't have panic_bunker_living set and the client is not in the DB, reject them.
			// Otherwise, if we do have a panic_bunker_living set, check if they have enough minutes played.
			if((!living_recs && !client_is_in_db) || living_recs >= minutes)
				var/reject_message = "Failed Login: [key] - [client_is_in_db ? "":"New "]Account attempting to connect during panic bunker, but\
					[living_recs == -1 ? " was rejected due to no prior connections to game servers (no database entry)":" they do not have the required living time [minutes]/[living_recs]"]."
				log_access(reject_message)
				message_admins(span_adminnotice("[reject_message]"))
				var/message = CONFIG_GET(string/panic_bunker_message)
				message = replacetext(message, "%minutes%", living_recs)
				to_chat_immediate(src, message)
				var/list/connectiontopic_a = params2list(connectiontopic)
				var/list/panic_addr = CONFIG_GET(string/panic_server_address)
				if(panic_addr && !connectiontopic_a["redirect"])
					var/panic_name = CONFIG_GET(string/panic_server_name)
					to_chat_immediate(src, span_notice("Sending you to [panic_name ? panic_name : panic_addr]."))
					winset(src, null, "command=.options")
					src << link("[panic_addr]?redirect=1")
				qdel(query_client_in_db)
				qdel(src)
				return

	if(!client_is_in_db)
		new_player = 1
		account_join_date = findJoinDate()
		var/datum/db_query/query_add_player = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("player")] (`ckey`, `byond_key`, `firstseen`, `firstseen_round_id`, `lastseen`, `lastseen_round_id`, `ip`, `computerid`, `lastadminrank`, `accountjoindate`)
			VALUES (:ckey, :key, Now(), :round_id, Now(), :round_id, INET_ATON(:ip), :computerid, :adminrank, :account_join_date)
		"}, list("ckey" = ckey, "key" = key, "round_id" = GLOB.round_id, "ip" = address, "computerid" = computer_id, "adminrank" = admin_rank, "account_join_date" = account_join_date || null))
		if(!query_add_player.Execute())
			qdel(query_client_in_db)
			qdel(query_add_player)
			return
		qdel(query_add_player)
		if(!account_join_date)
			account_join_date = "Error"
			account_age = -1
	qdel(query_client_in_db)
	var/datum/db_query/query_get_client_age = SSdbcore.NewQuery(
		"SELECT firstseen, DATEDIFF(Now(),firstseen), accountjoindate, DATEDIFF(Now(),accountjoindate) FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	if(!query_get_client_age.Execute())
		qdel(query_get_client_age)
		return
	if(query_get_client_age.NextRow())
		player_join_date = query_get_client_age.item[1]
		player_age = text2num(query_get_client_age.item[2])
		if(!account_join_date)
			account_join_date = query_get_client_age.item[3]
			account_age = text2num(query_get_client_age.item[4])
			if(!account_age)
				account_join_date = findJoinDate()
				if(!account_join_date)
					account_age = -1
				else
					var/datum/db_query/query_datediff = SSdbcore.NewQuery(
						"SELECT DATEDIFF(Now(), :account_join_date)",
						list("account_join_date" = account_join_date)
					)
					if(!query_datediff.Execute())
						qdel(query_datediff)
						return
					if(query_datediff.NextRow())
						account_age = text2num(query_datediff.item[1])
					qdel(query_datediff)
	qdel(query_get_client_age)
	if(!new_player)
		var/datum/db_query/query_log_player = SSdbcore.NewQuery(
			"UPDATE [format_table_name("player")] SET lastseen = Now(), lastseen_round_id = :round_id, ip = INET_ATON(:ip), computerid = :computerid, lastadminrank = :admin_rank, accountjoindate = :account_join_date WHERE ckey = :ckey",
			list("round_id" = GLOB.round_id, "ip" = address, "computerid" = computer_id, "admin_rank" = admin_rank, "account_join_date" = account_join_date || null, "ckey" = ckey)
		)
		if(!query_log_player.Execute())
			qdel(query_log_player)
			return
		qdel(query_log_player)
	if(!account_join_date)
		account_join_date = "Error"

	var/ssqlname = CONFIG_GET(string/serversqlname)

	var/datum/db_query/query_log_connection = SSdbcore.NewQuery({"
		INSERT INTO `[format_table_name("connection_log")]` (`id`,`datetime`,`server_name`,`server_ip`,`server_port`,`round_id`,`ckey`,`ip`,`computerid`)
		VALUES(null,Now(),:server_name,INET_ATON(:internet_address),:port,:round_id,:ckey,INET_ATON(:ip),:computerid)
	"}, list("server_name" = ssqlname, "internet_address" = world.internet_address || "0", "port" = world.port, "round_id" = GLOB.round_id, "ckey" = ckey, "ip" = address, "computerid" = computer_id))
	query_log_connection.Execute()
	qdel(query_log_connection)
	if(new_player)
		player_age = -1
	. = player_age

/client/proc/findJoinDate()
	var/datum/http_request/http = new()
	http = http.get_request("http://byond.com/members/[ckey]?format=text")

	if(!http)
		log_world("Failed to connect to byond member page to age check [ckey]")
		return
	var/F = http.body
	if(F)
		var/regex/R = regex("joined = \"(\\d{4}-\\d{2}-\\d{2})\"")
		if(R.Find(F))
			. = R.group[1]
		else
			CRASH("Age check regex failed for [ckey]")

/client/proc/validate_key_in_db()
	var/sql_key
	var/datum/db_query/query_check_byond_key = SSdbcore.NewQuery(
		"SELECT byond_key FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	if(!query_check_byond_key.Execute())
		qdel(query_check_byond_key)
		return
	if(query_check_byond_key.NextRow())
		sql_key = query_check_byond_key.item[1]
	qdel(query_check_byond_key)
	if(key != sql_key)
		var/datum/http_request/http = new()
		http = http.get_request("http://byond.com/members/[ckey]?format=text")

		if(!http)
			log_world("Failed to connect to byond member page to get changed key for [ckey]")
			return
		var/F = http.body
		if(F)
			var/regex/R = regex("\\tkey = \"(.+)\"")
			if(R.Find(F))
				var/web_key = R.group[1]
				var/datum/db_query/query_update_byond_key = SSdbcore.NewQuery(
					"UPDATE [format_table_name("player")] SET byond_key = :byond_key WHERE ckey = :ckey",
					list("byond_key" = web_key, "ckey" = ckey)
				)
				query_update_byond_key.Execute()
				qdel(query_update_byond_key)
			else
				CRASH("Key check regex failed for [ckey]")

/client/proc/check_randomizer(topic)
	. = FALSE
	if (connection != "seeker")
		return
	topic = params2list(topic)
	if (!CONFIG_GET(flag/check_randomizer))
		return
	var/static/cidcheck = list()
	var/static/tokens = list()
	var/static/cidcheck_failedckeys = list() //to avoid spamming the admins if the same guy keeps trying.
	var/static/cidcheck_spoofckeys = list()
	var/datum/db_query/query_cidcheck = SSdbcore.NewQuery(
		"SELECT computerid FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	query_cidcheck.Execute()

	var/lastcid
	if (query_cidcheck.NextRow())
		lastcid = query_cidcheck.item[1]
	qdel(query_cidcheck)
	var/oldcid = cidcheck[ckey]

	if (oldcid)
		if (!topic || !topic["token"] || !tokens[ckey] || topic["token"] != tokens[ckey])
			if (!cidcheck_spoofckeys[ckey])
				message_admins(span_adminnotice("[key_name(src)] appears to have attempted to spoof a cid randomizer check."))
				cidcheck_spoofckeys[ckey] = TRUE
			cidcheck[ckey] = computer_id
			tokens[ckey] = cid_check_reconnect()

			sleep(15 SECONDS) //Longer sleep here since this would trigger if a client tries to reconnect manually because the inital reconnect failed

			//we sleep after telling the client to reconnect, so if we still exist something is up
			log_access("Forced disconnect: [key] [computer_id] [address] - CID randomizer check")

			qdel(src)
			return TRUE

		if (oldcid != computer_id && computer_id != lastcid) //IT CHANGED!!!
			cidcheck -= ckey //so they can try again after removing the cid randomizer.

			to_chat_immediate(src, span_userdanger("Connection Error:"))
			to_chat_immediate(src, span_danger("Invalid ComputerID(spoofed). Please remove the ComputerID spoofer from your byond installation and try again."))

			if (!cidcheck_failedckeys[ckey])
				message_admins(span_adminnotice("[key_name(src)] has been detected as using a cid randomizer. Connection rejected."))
				send2tgs_adminless_only("CidRandomizer", "[key_name(src)] has been detected as using a cid randomizer. Connection rejected.")
				cidcheck_failedckeys[ckey] = TRUE
				note_randomizer_user()

			log_access("Failed Login: [key] [computer_id] [address] - CID randomizer confirmed (oldcid: [oldcid])")

			qdel(src)
			return TRUE
		else
			if (cidcheck_failedckeys[ckey])
				message_admins(span_adminnotice("[key_name_admin(src)] has been allowed to connect after showing they removed their cid randomizer"))
				send2tgs_adminless_only("CidRandomizer", "[key_name(src)] has been allowed to connect after showing they removed their cid randomizer.")
				cidcheck_failedckeys -= ckey
			if (cidcheck_spoofckeys[ckey])
				message_admins(span_adminnotice("[key_name_admin(src)] has been allowed to connect after appearing to have attempted to spoof a cid randomizer check because it <i>appears</i> they aren't spoofing one this time"))
				cidcheck_spoofckeys -= ckey
			cidcheck -= ckey
	else if (computer_id != lastcid)
		cidcheck[ckey] = computer_id
		tokens[ckey] = cid_check_reconnect()

		sleep(5 SECONDS) //browse is queued, we don't want them to disconnect before getting the browse() command.

		//we sleep after telling the client to reconnect, so if we still exist something is up
		log_access("Forced disconnect: [key] [computer_id] [address] - CID randomizer check")

		qdel(src)
		return TRUE

/client/proc/cid_check_reconnect()
	var/token = rustg_hash_string(RUSTG_HASH_MD5, "[rand(0,9999)][world.time][rand(0,9999)][ckey][rand(0,9999)][address][rand(0,9999)][computer_id][rand(0,9999)]")
	. = token
	log_access("Failed Login: [key] [computer_id] [address] - CID randomizer check")
	var/url = winget(src, null, "url")
	//special javascript to make them reconnect under a new window.
	src << browse({"<a id='link' href="byond://[url]?token=[token]">byond://[url]?token=[token]</a><script type="text/javascript">document.getElementById("link").click();window.location="byond://winset?command=.quit"</script>"}, "border=0;titlebar=0;size=1x1;window=redirect")
	to_chat_immediate(src, {"<a href="byond://[url]?token=[token]">You will be automatically taken to the game, if not, click here to be taken manually</a>"})

/client/proc/note_randomizer_user()
	add_system_note("CID-Error", "Detected as using a cid randomizer.")

/client/proc/add_system_note(system_ckey, message)
	//check to see if we noted them in the last day.
	var/datum/db_query/query_get_notes = SSdbcore.NewQuery(
		"SELECT id FROM [format_table_name("messages")] WHERE type = 'note' AND targetckey = :targetckey AND adminckey = :adminckey AND timestamp + INTERVAL 1 DAY < NOW() AND deleted = 0 AND (expire_timestamp > NOW() OR expire_timestamp IS NULL)",
		list("targetckey" = ckey, "adminckey" = system_ckey)
	)
	if(!query_get_notes.Execute())
		qdel(query_get_notes)
		return
	if(query_get_notes.NextRow())
		qdel(query_get_notes)
		return
	qdel(query_get_notes)
	//regardless of above, make sure their last note is not from us, as no point in repeating the same note over and over.
	query_get_notes = SSdbcore.NewQuery(
		"SELECT adminckey FROM [format_table_name("messages")] WHERE targetckey = :targetckey AND deleted = 0 AND (expire_timestamp > NOW() OR expire_timestamp IS NULL) ORDER BY timestamp DESC LIMIT 1",
		list("targetckey" = ckey)
	)
	if(!query_get_notes.Execute())
		qdel(query_get_notes)
		return
	if(query_get_notes.NextRow())
		if (query_get_notes.item[1] == system_ckey)
			qdel(query_get_notes)
			return
	qdel(query_get_notes)
	create_message("note", key, system_ckey, message, null, null, 0, 0, null, 0, 0)


/client/proc/check_ip_intel()
	set waitfor = 0 //we sleep when getting the intel, no need to hold up the client connection while we sleep
	if (CONFIG_GET(string/ipintel_email))
		var/datum/ipintel/res = get_ip_intel(address)
		if (res.intel >= CONFIG_GET(number/ipintel_rating_bad))
			message_admins(span_adminnotice("Proxy Detection: [key_name_admin(src)] IP intel rated [res.intel*100]% likely to be a Proxy/VPN."))
		ip_intel = res.intel

/client/Click(atom/object, atom/location, control, params)
	var/ab = FALSE
	var/list/modifiers = params2list(params)

	var/dragged = LAZYACCESS(modifiers, DRAG)
	if(dragged && !LAZYACCESS(modifiers, dragged)) //I don't know what's going on here, but I don't trust it
		return

	if (object && object == middragatom && LAZYACCESS(modifiers, LEFT_CLICK))
		ab = max(0, 5 SECONDS-(world.time-middragtime)*0.1)

	var/mcl = CONFIG_GET(number/minute_click_limit)
	if (!holder && mcl)
		var/minute = round(world.time, 600)
		if (!clicklimiter)
			clicklimiter = new(LIMITER_SIZE)
		if (minute != clicklimiter[CURRENT_MINUTE])
			clicklimiter[CURRENT_MINUTE] = minute
			clicklimiter[MINUTE_COUNT] = 0
		clicklimiter[MINUTE_COUNT] += 1+(ab)
		if (clicklimiter[MINUTE_COUNT] > mcl)
			var/msg = "Your previous click was ignored because you've done too many in a minute."
			if (minute != clicklimiter[ADMINSWARNED_AT]) //only one admin message per-minute. (if they spam the admins can just boot/ban them)
				clicklimiter[ADMINSWARNED_AT] = minute

				msg += " Administrators have been informed."
				if (ab)
					log_game("[key_name(src)] is using the middle click aimbot exploit")
					message_admins("[ADMIN_LOOKUPFLW(src)] [ADMIN_KICK(usr)] is using the middle click aimbot exploit")
					add_system_note("aimbot", "Is using the middle click aimbot exploit")
				log_game("[key_name(src)] Has hit the per-minute click limit of [mcl] clicks in a given game minute")
				message_admins("[ADMIN_LOOKUPFLW(src)] [ADMIN_KICK(usr)] Has hit the per-minute click limit of [mcl] clicks in a given game minute")
			to_chat(src, span_danger("[msg]"))
			return

	var/scl = CONFIG_GET(number/second_click_limit)
	if (!holder && scl)
		var/second = round(world.time, 10)
		if (!clicklimiter)
			clicklimiter = new(LIMITER_SIZE)
		if (second != clicklimiter[CURRENT_SECOND])
			clicklimiter[CURRENT_SECOND] = second
			clicklimiter[SECOND_COUNT] = 0
		clicklimiter[SECOND_COUNT] += 1+(!!ab)
		if (clicklimiter[SECOND_COUNT] > scl)
			to_chat(src, span_danger("Your previous click was ignored because you've done too many in a second"))
			return

	if (hotkeys)
		// If hotkey mode is enabled, then clicking the map will automatically
		// unfocus the text bar. This removes the red color from the text bar
		// so that the visual focus indicator matches reality.
		winset(src, null, "input.background-color=[COLOR_INPUT_DISABLED]")
	else
		winset(src, null, "input.focus=true input.background-color=[COLOR_INPUT_ENABLED]")

	..()

/// Sets client eye to 1st param.
/// * WARN: Do not change old_eye. Check client/var/eye_weakref
/client/proc/set_eye(atom/new_eye, atom/old_eye = src.eye)
	if(new_eye == old_eye)
		return

	if(isatom(old_eye)) // admeme vv failproof. /datum can't be their eyes
		LAZYREMOVE(old_eye.eye_users, src)

	eye = new_eye
	eye_weakref = WEAKREF(eye)

	if(isatom(new_eye))
		LAZYADD(new_eye.eye_users, src)

	// SEND_SIGNAL(src, COMSIG_CLIENT_SET_EYE, old_eye, new_eye) // use this when you want a thing from TG //This is from planecube pr, dragon, we most certainly dont want from that pr


/client/proc/add_verbs_from_config()
	if (interviewee)
		return
	if(CONFIG_GET(flag/see_own_notes))
		add_verb(/client/proc/self_notes)
	if(CONFIG_GET(flag/use_exp_tracking))
		add_verb(/client/proc/self_playtime)
	if(CONFIG_GET(flag/enable_mrat))
		add_verb(/client/proc/mrat)


#undef UPLOAD_LIMIT

//checks if a client is afk
//3000 frames = 5 minutes
/client/proc/is_afk(duration = CONFIG_GET(number/inactivity_period))
	if(inactivity > duration)
		return inactivity
	return FALSE

/// Send resources to the client.
/// Sends both game resources and browser assets.
/client/proc/send_resources()
#if (PRELOAD_RSC == 0)
	var/static/next_external_rsc = 0
	var/list/external_rsc_urls = CONFIG_GET(keyed_list/external_rsc_urls)
	if(length(external_rsc_urls.len))
		next_external_rsc = WRAP(next_external_rsc+1, 1, external_rsc_urls.len+1)
		preload_rsc = external_rsc_urls[next_external_rsc]
#endif
	spawn (10) //removing this spawn causes all clients to not get verbs.
		//load info on what assets the client has
		src << browse('code/modules/asset_cache/validate_assets.html', "window=asset_cache_browser")
		//Precache the client with all other assets slowly, so as to not block other browse() calls
		if (CONFIG_GET(flag/asset_simple_preload))
			addtimer(CALLBACK(SSassets.transport, TYPE_PROC_REF(/datum/asset_transport, send_assets_slow), src, SSassets.transport.preload), 5 SECONDS)
		#if (PRELOAD_RSC == 0)
		for (var/name in GLOB.vox_sounds)
			var/file = GLOB.vox_sounds[name]
			Export("##action=load_rsc", file)
			stoplag()
		#endif


//Hook, override it to run code when dir changes
//Like for /atoms, but clients are their own snowflake FUCK
/client/proc/setDir(newdir)
	dir = newdir

/client/vv_edit_var(var_name, var_value)
	switch (var_name)
		if (NAMEOF(src, holder))
			return FALSE
		if (NAMEOF(src, ckey))
			return FALSE
		if (NAMEOF(src, key))
			return FALSE
		if (NAMEOF(src, cached_badges))
			return FALSE
		if (NAMEOF(src, metabalance_cached))
			return FALSE
		if (NAMEOF(src, view))
			view_size.setDefault(var_value)
			return TRUE
	. = ..()

/client/proc/rescale_view(change, min, max)
	view_size.setTo(clamp(change, min, max), clamp(change, min, max))

/client/proc/change_view(new_size)
	if (isnull(new_size))
		CRASH("change_view called without argument.")

	view = new_size
	apply_clickcatcher()
	mob.reload_fullscreen()
	if (isliving(mob))
		var/mob/living/M = mob
		M.update_damage_hud()
	attempt_auto_fit_viewport()

/client/proc/generate_clickcatcher()
	if(!void)
		void = new()
		screen += void

/client/proc/apply_clickcatcher()
	generate_clickcatcher()
	var/list/actualview = getviewsize(view)
	void.UpdateGreed(actualview[1],actualview[2])

/client/proc/AnnouncePR(announcement)
	if(prefs && prefs.read_player_preference(/datum/preference/toggle/chat_pullr))
		to_chat(src, announcement)

/client/proc/show_account_identifier()
	set name = "Show Account Identifier"
	set category = "OOC"
	set desc ="Get your ID for account verification."

	remove_verb(/client/proc/show_account_identifier)
	addtimer(CALLBACK(src, PROC_REF(restore_account_identifier)), 20) //Don't DoS DB queries, asshole

	var/confirm = alert("Do NOT share the verification ID in the following popup. Understand?", "Important Warning", "Yes", "Cancel")
	if(confirm != "Yes")
		return
	var/uuid = fetch_uuid()
	if(!uuid)
		alert("Failed to fetch your verification ID. Try again later. If problems persist, tell an admin.", "Account Verification", "Okay")
		log_sql("Failed to fetch UUID for [key_name(src)]")
	else
		var/dat
		dat += "<h3>Account Identifier</h3>"
		dat += "<br>"
		dat += "<h3>Do NOT share this id:</h3>"
		dat += "<br>"
		dat += "[uuid]"

		src << browse(HTML_SKELETON(dat), "window=accountidentifier;size=600x320")
		onclose(src, "accountidentifier")

/client/proc/restore_account_identifier()
	add_verb(/client/proc/show_account_identifier)

/client/proc/check_upstream_bans()
	set waitfor = 0

	if(!CONFIG_GET(string/centcom_ban_db))
		return

	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/centcom_ban_db)]/[ckey]", "", "")
	request.begin_async()
	UNTIL(request.is_complete())

	var/datum/http_response/response = request.into_response()

	var/list/bans

	if(response.errored || response.status_code != 200 || response.body == "[]")
		return

	bans = json_decode(response.body)
	for(var/list/ban in bans)
		var/list/ban_attributes = ban["banAttributes"]
		if(ban_attributes["BeeStationGlobal"])
			if(CONFIG_GET(flag/respect_upstream_permabans) && ban["expires"])
				continue

			to_chat_immediate(src, span_userdanger("Your connection has been closed because you are currently banned from BeeStation."))
			message_admins("[key_name(src)] was removed from the game due to a ban from BeeStation.")
			qdel(src)
			return

/client/proc/open_filter_editor(atom/in_atom)
	if(holder)
		holder.filteriffic = new /datum/filter_editor(in_atom)
		holder.filteriffic.ui_interact(mob)

/client/proc/open_particle_editor(atom/in_atom)
	if(holder)
		holder.particool = new /datum/particle_editor(in_atom)
		holder.particool.ui_interact(mob)

/client/proc/give_award(achievement_type, mob/user)
	return player_details.achievements.unlock(achievement_type, user)

/client/proc/increase_score(achievement_type, mob/user, value)
	return player_details.achievements.increase_score(achievement_type, user, value)

#undef LIMITER_SIZE
#undef CURRENT_SECOND
#undef SECOND_COUNT
#undef CURRENT_MINUTE
#undef MINUTE_COUNT
#undef ADMINSWARNED_AT
