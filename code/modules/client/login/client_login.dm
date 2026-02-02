/client/New(TopicData)
	temp_topicdata = TopicData //save this for later use
	TopicData = null							//Prevent calls to client.Topic from connect

	if(connection != "seeker" && connection != "web")//Invalid connection type.
		return null

	var/new_key = null
#ifdef DISABLE_BYOND_AUTH
	if(is_localhost() && CONFIG_GET(flag/localhost_auth_bypass))
		logged_in = TRUE
	else if(CONFIG_GET(flag/enable_guest_external_auth))
		// If auth isn't set up, immediately change their key to a guest key
		// IT IS VERY IMPORTANT THAT IS_GUEST_KEY RETURNS TRUE OTHERWISE THE DB WILL GET POLLUTED
		new_key = "Guest-preauth-[computer_id]-[rand(1000,9999)]"
		logged_in = FALSE
	else
		to_chat_immediate(src, span_dangerbold("Authorization is totally disabled! The game is configured to blindly trust connecting CKEYs!!!"))
		logged_in = TRUE
#else
	// Guests are redirected to secondary auth
	if(IS_GUEST_KEY(key) || !length(key))
		if(is_localhost() && CONFIG_GET(flag/localhost_auth_bypass)) // allow localhost to connect as guest
			logged_in = TRUE
		else if(!CONFIG_GET(flag/guest_ban)) // guests are allowed to connect, no authorization necessary
			logged_in = TRUE
		else if(CONFIG_GET(flag/enable_guest_external_auth)) // guests need to authorize
			new_key = "Guest-preauth-[computer_id]-[rand(1000,9999)]"
			logged_in = FALSE
		else // should be caught by IsBanned, but localhost can get to this point
			src << "NOTICE: Guests are not currently allowed to connect!"
			if(is_localhost()) // inform the developer that they have made a mistake
				log_world("You are localhost and have been denied guest connection. Toggle localhost_auth_bypass, enable_guest_external_auth, or guest_ban in the config to continue.")
			qdel(src)
			return null
	else if(CONFIG_GET(flag/force_byond_external_auth) && CONFIG_GET(flag/enable_guest_external_auth))
		byond_authenticated_key = key
		new_key = "Guest-preauth-[computer_id]-[rand(1000,9999)]"
		logged_in = FALSE
	else
		logged_in = TRUE
#endif
	var/old_key = key

	// Our key has changed
	if(!isnull(new_key))
		src.ckey = ckey(new_key)
		src.key = new_key

	// We connected with a mob that isn't ours.
	// The connection CKEY matches an existing logged in mob's key
	// This means someone got kicked, but it's okay. We'll try to return it to them.
	if(!logged_in && ismob(mob) && !istype(mob, /mob/dead/new_player/pre_auth))
		var/mob/my_old_mob = src.mob
		var/mob/dead/new_player/pre_auth/my_new_mob = new()
		my_new_mob.key = src.key
		my_old_mob.key = old_key // GIVE IT BACK

	if(!logged_in)
		tgui_login = new(src)

	if(!client_pre_login(logged_in, TRUE) || QDELETED(src))
		return null


	. = ..()	//calls mob.Login()

	var/mob/logout_mob = GLOB.disconnected_mobs[src.ckey]
	if(logged_in && ismob(logout_mob) && !isnewplayer(logout_mob))
		var/mob/original_mob = src.mob
		GLOB.disconnected_mobs -= src.ckey
		transfer_preauthenticated_player_mob(original_mob, logout_mob)

	if(QDELETED(src))
		return null

	// if the user logged in directly with a valid key, we can convert them now
	if(logged_in && istype(mob, /mob/dead/new_player/pre_auth))
		transfer_preauthenticated_player_mob(mob, null)

	if(!client_post_login(logged_in, TRUE, logged_in && !!(holder || GLOB.deadmins[ckey])) || QDELETED(src))
		return null
	fully_created = TRUE
	if(logged_in)
		remove_verb(/client/verb/get_token)
		remove_verb(/client/verb/use_token)
		remove_verb(/client/verb/open_login)

/client/proc/add_authenticated_verbs()
	add_verb(collect_client_verbs())

/client/proc/send_client_messages()
	if(ckey in GLOB.clientmessages)
		for(var/message in GLOB.clientmessages[ckey])
			to_chat(src, message)
		GLOB.clientmessages.Remove(ckey)

/client/proc/check_ckey_redirects()
	if(GLOB.ckey_redirects.Find(ckey))
		if(isnewplayer(mob))
			to_chat(src, span_redtext("The server is full. You will be redirected to [CONFIG_GET(string/redirect_address)] in 10 seconds."))
			addtimer(CALLBACK(src, PROC_REF(time_to_redirect)), (10 SECONDS))
		else
			GLOB.ckey_redirects -= ckey

/client/proc/client_pre_login(authenticated, first_run)
	if(IsAdminAdvancedProcCall())
		return FALSE
	if(authenticated)
		if(CONFIG_GET(flag/respect_upstream_bans) || CONFIG_GET(flag/respect_upstream_permabans))
			check_upstream_bans()
	if(QDELETED(src))
		return FALSE
	if(first_run)
		GLOB.clients_unsafe += src
	GLOB.directory[ckey] = src
	GLOB.unique_connected_keys |= ckey
	if(authenticated)
		GLOB.clients += src

	if(first_run && byond_version >= 516)
		winset(src, null, list("browser-options" = "find,refresh,byondstorage"))

	// Instantiate tgui panel
	if(first_run)
		tgui_panel = new(src, "browseroutput")
		initialize_commandbar_spy()

		set_right_click_menu_mode(TRUE)

	if(authenticated)
		tgui_say = new(src, "tgui_say")
		tgui_asay = new(src, "tgui_asay")

	GLOB.ahelp_tickets.ClientLogin(src)
	GLOB.mhelp_tickets.ClientLogin(src)
	GLOB.interviews.client_login(src)
	GLOB.requests.client_login(src)

	// Set up macros before prefs so the macro sets exist on the client
	if(authenticated && SSinput.initialized)
		set_macros()

	if(authenticated)
		//Admin Authorisation
		setup_holder()
		if(!IS_GUEST_KEY(key))
			// This needs to go after admin loading but before prefs
			assign_mentor_datum_if_exists()

			// Retrieve cached metabalance
			get_metabalance_db()
			if(QDELETED(src))
				return FALSE
			// Retrieve cached antag token count
			get_antag_token_count_db()
			if(QDELETED(src))
				return FALSE
		else
			metabalance_cached = 0
			antag_token_count_cached = 0
		//preferences datum - also holds some persistent data for the client (because we may as well keep these datums to a minimum)
		init_client_prefs()
		if(QDELETED(src))
			return FALSE
		setup_player_details()

		if(fexists(roundend_report_file()))
			add_verb(/client/proc/show_previous_roundend_report)

	if(first_run)
		var/full_version = "[byond_version].[byond_build ? byond_build : "xxx"]"
		if(authenticated)
			log_access("Login: [key_name(src)] from [address ? address : "localhost"]-[computer_id] || BYOND v[full_version]")
		else
			log_access("Pre-Login: [key_name(src)] from [address ? address : "localhost"]-[computer_id] || BYOND v[full_version]")
	if(authenticated && src.external_uid)
		to_chat_immediate(src, span_good("Successfully signed in as [span_bold("[src.display_name_chat()]")]"))
	return TRUE

/client/proc/client_post_login(authenticated, first_run, connecting_admin)
	if(IsAdminAdvancedProcCall())
		return FALSE
	if(first_run)
		if(!check_client_blocked_byond_versions(connecting_admin) || QDELETED(src))
			return FALSE

	if(first_run)
		tgui_panel.Initialize()

	if(authenticated)
		tgui_say.initialize()
		tgui_asay.initialize()

	if(!authenticated)
		initialize_login_handler()

	if(authenticated)
		var/list/duplicate_result = check_duplicate_login()
		var/alert_mob_dupe_login = duplicate_result[1]
		var/alert_admin_multikey = duplicate_result[2]
		run_dupe_alerts(alert_mob_dupe_login, alert_admin_multikey)

	if(first_run)
		connection_time = world.time
		connection_realtime = world.realtime
		connection_timeofday = world.timeofday
		winset(src, null, "command=\".configure graphics-hwmode on\"")

	if (connection == "web" && !CONFIG_GET(flag/allow_webclient))
		to_chat_immediate(src, "Web client is disabled")
		qdel(src)
		return FALSE
	if (authenticated && connection == "web" && !connecting_admin)
		if (CONFIG_GET(flag/webclient_only_byond_members) && !IsByondMember())
			to_chat_immediate(src, "Sorry, but the web client is restricted to byond members only.")
			qdel(src)
			return FALSE

	if(authenticated)
		if( (world.address == address || !address) && !GLOB.host )
			GLOB.host = key
			world.update_status()

	if(authenticated)
		init_admin_if_present()

	var/is_guest = IS_GUEST_KEY(key)
	if(authenticated && !is_guest) // guests don't have account ages
		//we have to cache this because other shit may change it and we need its current value now down below.
		var/cached_player_age = set_client_age_from_db()
		// We're done using this now
		temp_topicdata = null
		if(QDELETED(src))
			return FALSE
		// The following is only relevant to BYOND accounts.
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
#ifndef DISABLE_BYOND_AUTH
		if(!src.key_is_external)
			if(CONFIG_GET(flag/use_account_age_for_jobs) && account_age >= 0)
				player_age = account_age
			if(account_age >= 0 && account_age < nnpa)
				message_admins("[key_name_admin(src)] (IP: [address], ID: [computer_id]) is a new BYOND account [account_age] day[(account_age==1?"":"s")] old, created on [account_join_date].")
				if (CONFIG_GET(flag/irc_first_connection_alert))
					send2tgs_adminless_only("new_byond_user", "[key_name(src)] (IP: [address], ID: [computer_id]) is a new BYOND account [account_age] day[(account_age==1?"":"s")] old, created on [account_join_date].")
#endif
		get_message_output("watchlist entry", ckey)

	if(authenticated)
		check_ip_intel()
		sync_db_key_with_byond_key()
		if(QDELETED(src))
			return FALSE

	// If we aren't already generating a ban cache, fire off a build request
	// This way hopefully any users of request_ban_cache will never need to yield
	if(authenticated && !is_guest && !ban_cache_start && SSban_cache?.query_started)
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(build_ban_cache), src)

	if(authenticated && !is_guest)
		fetch_uuid()
		if(QDELETED(src))
			return FALSE
		add_verb(/client/proc/show_account_identifier)

	if(first_run)
		send_resources()

		generate_clickcatcher()
		apply_clickcatcher()

	if(authenticated && prefs && prefs.lastchangelog != GLOB.changelog_hash) //bolds the changelog button on the interface so we know there are updates.
		to_chat(src, span_info("You have unread updates in the changelog."))
		if(CONFIG_GET(flag/aggressive_changelog))
			changelog()
		else
			winset(src, "infowindow.changelog", "font-style=bold")

	send_client_messages()

	if(authenticated && !is_guest && CONFIG_GET(flag/autoconvert_notes))
		convert_notes_sql(ckey)
		if(QDELETED(src))
			return FALSE
	if(authenticated && !is_guest)
		to_chat(src, get_message_output("message", ckey))
	if(first_run)
		if(!winexists(src, "asset_cache_browser")) // The client is using a custom skin, tell them.
			to_chat(src, span_warning("Unable to access asset cache browser, if you are using a custom skin file, please allow DS to download the updated version, if you are not, then make a bug report. This is not a critical issue but can cause issues with resource downloading, as it is impossible to know when extra resources arrived to you."))

		//This is down here because of the browse() calls in tooltip/New()
		if(!tooltips)
			tooltips = new /datum/tooltip(src)

	if(isnull(view_size))
		view_size = new(src, getScreenSize(mob))
	view_size.resetFormat()
	view_size.setZoomMode()
	view_size.apply()
	fit_viewport()

	if(first_run)
		Master.UpdateTickRate()

	check_ckey_redirects()

	if(first_run)
		add_verb(subtypesof(/client/verb), TRUE)

	if(authenticated)
		if(!interviewee)
			add_authenticated_verbs()
			add_verbs_from_config()
		// Create input box templates
		create_preset_input_window("say", show=FALSE)
		create_preset_input_window("me", show=FALSE)

	if(!authenticated)
		spawn(2 SECONDS) // wait a sec for the client to send a valid token
			if(!QDELETED(src) && !src.logged_in) // client did not send a valid token in the last 2 seconds
				tgui_login?.open()

	//Load the TGUI stat in case of TGUI subsystem not ready (startup)
	mob?.UpdateMobStat(TRUE)
	return TRUE

/client/proc/check_client_blocked_byond_versions(connecting_admin)
	if (byond_version < 512)
		if (!byond_build || byond_build < 1386)
			message_admins(span_adminnotice("[key_name(src)] has been detected as spoofing their byond version. Connection rejected."))
			add_system_note("Spoofed-Byond-Version", "Detected as using a spoofed byond version.")
			log_access("Failed Login: [key] - Spoofed byond version")
			qdel(src)
			return FALSE

		if (num2text(byond_build) in GLOB.blacklisted_builds)
			log_access("Failed login: [key] - blacklisted byond version")
			to_chat_immediate(src, span_userdanger("Your version of byond is blacklisted."))
			to_chat_immediate(src, span_danger("Byond build [byond_build] ([byond_version].[byond_build]) has been blacklisted for the following reason: [GLOB.blacklisted_builds[num2text(byond_build)]]."))
			to_chat_immediate(src, span_danger("Please download a new version of byond. If [byond_build] is the latest, you can go to <a href=\"https://secure.byond.com/download/build\">BYOND's website</a> to download other versions."))
			if(connecting_admin)
				to_chat_immediate(src, "As an admin, you are being allowed to continue using this version, but please consider changing byond versions")
			else
				qdel(src)
				return FALSE
	var/max_recommended_client = CONFIG_GET(number/client_max_build)
	if(byond_build > max_recommended_client)
		to_chat(src, span_userdanger("Your version of byond is over the maximum recommended version for clients (build [max_recommended_client]) and may be unstable."))
		to_chat(src, span_danger("Please download an older version of byond. You can go to <a href=\"https://secure.byond.com/download/build\">BYOND's website</a> to download other versions."))
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
			return FALSE
	else if (byond_version < warn_version || (byond_version == warn_version && byond_build < warn_build)) //We have words for this client.
		if(CONFIG_GET(flag/client_warn_popup))
			var/msg = "<b>Your version of byond may be getting out of date:</b><br>"
			msg += CONFIG_GET(string/client_warn_message) + "<br><br>"
			msg += "Your version: [byond_version].[byond_build]<br>"
			msg += "Required version to remove this message: [warn_version].[warn_build] or later<br>"
			msg += "Visit <a href=\"https://secure.byond.com/download\">BYOND's website</a> to get the latest version of BYOND.<br>"
			src << browse(HTML_SKELETON(msg), "window=warning_popup")
		else
			to_chat_immediate(src, span_danger("<b>Your version of byond may be getting out of date:</b>"))
			to_chat_immediate(src, CONFIG_GET(string/client_warn_message))
			to_chat_immediate(src, "Your version: [byond_version].[byond_build]")
			to_chat_immediate(src, "Required version to remove this message: [warn_version].[warn_build] or later")
			to_chat_immediate(src, "Visit <a href=\"https://secure.byond.com/download\">BYOND's website</a> to get the latest version of BYOND.")
	return TRUE

/client/proc/setup_holder()
	var/connecting_admin = FALSE
	if (!IS_GUEST_KEY(key))
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
	if(CONFIG_GET(flag/enable_localhost_rank) && !connecting_admin && is_localhost())
		if(Debugger?.enabled)
			to_chat_immediate(src, span_userdanger("Debugger enabled. Make sure you untick \"Runtime errors\" in the bottom left of VSCode's Run and Debug tab."))
		var/datum/admin_rank/localhost_rank = new("!localhost!", R_EVERYTHING, R_DBRANKS, R_EVERYTHING) //+EVERYTHING -DBRANKS *EVERYTHING
		new /datum/admins(localhost_rank, ckey, 1, 1)

/client/proc/init_admin_if_present()
	if(holder)
		holder.associate(src)
		to_chat(src, get_message_output("memo"))
		adminGreet()

/client/proc/set_client_age_from_db()
	if(IsAdminAdvancedProcCall())
		return
	if(IS_GUEST_KEY(key))
		return
	if(!SSdbcore.Connect())
		return
	var/external_uid = null
	var/external_column = null
	if(istype(src.external_method))
		external_uid = src.external_uid // link BYOND ckeys to external method
		external_column = external_method::db_id_column_name
	var/external_column_selectable = istext(external_column) && length(external_column) ? external_column : "NULL"
	related_accounts_ip = ""
	if(!is_localhost())
		var/datum/db_query/query_get_related_ip = SSdbcore.NewQuery(
			"SELECT ckey FROM [format_table_name("player")] WHERE ip = INET_ATON(:address) AND ckey != :ckey",
			list("address" = address, "ckey" = ckey)
		)
		if(!query_get_related_ip.Execute())
			qdel(query_get_related_ip)
			return
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
		if(!GLOB.deadmins[ckey] && check_randomizer(temp_topicdata))
			return
	var/new_player
	var/datum/db_query/query_client_in_db_plus_uid = SSdbcore.NewQuery(
		"SELECT 1,[external_column_selectable] FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	if(!query_client_in_db_plus_uid.Execute())
		qdel(query_client_in_db_plus_uid)
		return
	var/client_is_in_db = FALSE
	var/external_uid_from_db = null
	if(query_client_in_db_plus_uid.NextRow())
		if(islist(query_client_in_db_plus_uid.item) && length(query_client_in_db_plus_uid.item) == 2)
			client_is_in_db = TRUE
			external_uid_from_db = query_client_in_db_plus_uid.item[2]
	qdel(query_client_in_db_plus_uid)
	if(!isnull(external_uid_from_db) && !isnull(external_uid) && length(external_uid) && length(external_uid_from_db) && external_uid != external_uid_from_db)
		var/msg = "Hey what the fuck, this [key_name(src)] has different external UIDs ([external_column]) than the one they logged in with. This shouldn't even be possible. Some horrible fuckery is happening. login [external_uid] db [external_uid_from_db]"
		to_chat_immediate(src, "Something VERY weird is happening. [msg]")
		message_admins(msg)
		qdel(src)
		CRASH(msg)
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
				var/list/connectiontopic_a = params2list(temp_topicdata)
				var/list/panic_addr = CONFIG_GET(string/panic_server_address)
				if(panic_addr && !connectiontopic_a["redirect"])
					var/panic_name = CONFIG_GET(string/panic_server_name)
					to_chat_immediate(src, span_notice("Sending you to [panic_name ? panic_name : panic_addr]."))
					winset(src, null, "command=.options")
					src << link("[panic_addr]?redirect=1")
				qdel(src)
				return
	var/safe_storage_address = address || "127.0.0.1"
	if(!client_is_in_db)
		new_player = 1
		if(!src.key_is_external)
			account_join_date = get_byond_account_creation_date()
		var/external_insert = istext(external_column) && length(external_column) ? "`[external_column]`, " : ""
		var/datum/db_query/query_add_player = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("player")] (`ckey`, `byond_key`, [external_insert]`firstseen`, `firstseen_round_id`, `lastseen`, `lastseen_round_id`, `ip`, `computerid`, `lastadminrank`, `accountjoindate`)
			VALUES (:ckey, :key, [length(external_insert) ? ":external_uid, " : ""]Now(), :round_id, Now(), :round_id, INET_ATON(:ip), :computerid, :adminrank, :account_join_date)
		"}, list("ckey" = ckey, "key" = key, "external_uid" = external_uid, "round_id" = GLOB.round_id, "ip" = safe_storage_address, "computerid" = computer_id, "adminrank" = admin_rank, "account_join_date" = account_join_date == "Error" || account_join_date == "N/A" ? null : account_join_date || null))
		if(!query_add_player.Execute())
			qdel(query_add_player)
			return
		qdel(query_add_player)
		if(!account_join_date)
			account_join_date = src.key_is_external ? "N/A" : "Error"
			account_age = -1
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
			if(!account_age && !src.key_is_external)
				account_join_date = get_byond_account_creation_date()
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
			else if(!account_age)
				account_join_date = "N/A"
				// dummy large value, this won't be used anywhere on external auth mode anyway
				account_age = 365
	qdel(query_get_client_age)
	if(!new_player)
		// associate with external UID for existing byond users who connect with CKEY and sign in with external method
		var/empty_uid_from_db = isnull(external_uid_from_db) || (istext(external_uid_from_db) && !length(external_uid_from_db))
		var/column_exists = istext(external_column) && length(external_column)
		if(!isnull(external_uid) && column_exists && istype(src.external_method) && !src.key_is_external && empty_uid_from_db)
			var/datum/db_query/query_set_external_uid = SSdbcore.NewQuery(
				"UPDATE [format_table_name("player")] SET [external_column] = :external_uid WHERE ckey = :ckey",
				list("ckey" = ckey, "external_uid" = external_uid)
			)
			query_set_external_uid.Execute()
			var/msg = "You have associated your BYOND CKEY with [external_method::name] UID [external_uid] ([external_method.format_display_name(src.external_display_name)])! Make sure you always log in with this [external_method::name] account from now on to retain your access."
			to_chat_immediate(src, span_good(msg))
			spawn(1) // no sleeping
				alert(src, msg, "Success", "OK")
			qdel(query_set_external_uid)
		var/datum/db_query/query_log_player = SSdbcore.NewQuery(
			"UPDATE [format_table_name("player")] SET lastseen = Now(), lastseen_round_id = :round_id, ip = INET_ATON(:ip), computerid = :computerid, lastadminrank = :admin_rank, accountjoindate = :account_join_date WHERE ckey = :ckey",
			list("round_id" = GLOB.round_id, "ip" = safe_storage_address, "computerid" = computer_id, "admin_rank" = admin_rank, "account_join_date" = account_join_date || null, "ckey" = ckey)
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
	"}, list("server_name" = ssqlname, "internet_address" = world.internet_address || "0", "port" = world.port, "round_id" = GLOB.round_id, "ckey" = ckey, "ip" = safe_storage_address, "computerid" = computer_id))
	query_log_connection.Execute()
	qdel(query_log_connection)
	if(new_player)
		player_age = -1
	. = player_age

/client/proc/get_byond_account_creation_date()
	if(src.key_is_external)
		return
	if(!GLOB.byond_http)
		return
	var/datum/http_request/http = new()
	var/datum/http_response/response = http.get_request("http://byond.com/members/[ckey]?format=text", timeout_seconds=5)

	if(!istype(response) || response.status_code != 200 || !length(response.body))
		log_world("Failed to connect to byond member page to age check [ckey]")
		GLOB.byond_http = FALSE
		return
	var/regex/join_date_regex = regex("joined = \"(\\d{4}-\\d{2}-\\d{2})\"")
	if(join_date_regex.Find(response.body))
		. = join_date_regex.group[1]
	else
		CRASH("Age check regex failed for [ckey]")

/client/proc/sync_db_key_with_byond_key()
	if(IS_GUEST_KEY(key))
		return
	if(src.key_is_external)
		return
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
		if(!GLOB.byond_http)
			return
		var/datum/http_request/http = new()
		var/datum/http_response/response = http.get_request("http://byond.com/members/[ckey]?format=text", timeout_seconds=5)

		if(!istype(response) || response.status_code != 200 || !length(response.body))
			log_world("Failed to connect to byond member page to get changed key for [ckey]")
			GLOB.byond_http = FALSE
			return
		var/regex/key_regex = regex("\\tkey = \"(.+)\"")
		if(key_regex.Find(response.body))
			var/web_key = key_regex.group[1]
			var/datum/db_query/query_update_byond_key = SSdbcore.NewQuery(
				"UPDATE [format_table_name("player")] SET byond_key = :byond_key WHERE ckey = :ckey",
				list("byond_key" = web_key, "ckey" = ckey)
			)
			query_update_byond_key.Execute()
			qdel(query_update_byond_key)
		else
			CRASH("Key check regex failed for [ckey]")

/client/proc/check_duplicate_login()
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
				continue // skip unauthenticated players

			var/client/C = GLOB.directory[joined_player_ckey]
			var/in_round = ""
			if (joined_players[joined_player_ckey])
				in_round = " who has played in the current round"
			var/message_type = "Notice"

			var/matches
			if(!is_localhost() && joined_player_preferences.last_ip == address)
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
	return list(alert_mob_dupe_login, alert_admin_multikey)

/client/proc/run_dupe_alerts(alert_mob_dupe_login, alert_admin_multikey)
	if(!alert_mob_dupe_login || holder)
		return
	var/dupe_login_message = "Your ComputerID has already logged in with another key this round, please log out of this one NOW or risk being banned!"
	if (alert_admin_multikey)
		dupe_login_message += "\nAdmins have been informed."
		message_admins("[span_danger("<B>MULTIKEYING:</B>")] [span_notice("[key_name_admin(src)] has a matching CID+IP with another player and is clearly multikeying. They have been warned to leave the server or risk getting banned.")]")
		log_admin_private("MULTIKEYING: [key_name(src)] has a matching CID+IP with another player and is clearly multikeying. They have been warned to leave the server or risk getting banned.")
	spawn(0.5 SECONDS) //needs to run during world init, do not convert to add timer
		alert(mob, dupe_login_message) //players get banned if they don't see this message, do not convert to tgui_alert (or even tg_alert) please.
		to_chat_immediate(mob, span_danger("[dupe_login_message]"))

/client/proc/init_client_prefs()
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

/client/proc/setup_player_details()
	var/full_version = "[byond_version].[byond_build ? byond_build : "xxx"]"
	if(GLOB.player_details[ckey])
		player_details = GLOB.player_details[ckey]
		player_details.byond_version = full_version
	else
		player_details = new(ckey)
		player_details.byond_version = full_version
		GLOB.player_details[ckey] = player_details

/client/proc/set_right_click_menu_mode(shift_only)
	if(shift_only)
		winset(src, "mapwindow.map", "right-click=true")
		winset(src, "default.ShiftUp", "is-disabled=false")
		winset(src, "default.Shift", "is-disabled=false")
	else
		winset(src, "mapwindow.map", "right-click=false")
		winset(src, "default.Shift", "is-disabled=true")
		winset(src, "default.ShiftUp", "is-disabled=true")
