/client/proc/login_with_token(token, from_ui)
	if(IsAdminAdvancedProcCall())
		log_admin_private("[key_name(usr)] attempted to check session token: \"[token]\"")
		message_admins("[key_name(usr)] performed a proccall that attempts to test a session token!")
		return
	if(logged_in)
		return FALSE
	if(!CONFIG_GET(flag/enable_guest_external_auth))
		to_chat_immediate(src, span_userdanger("External auth is currently disabled!"))
		return FALSE
	token_attempts++
	if(token_attempts > 3)
		log_access("[ckey] has been rate-limited while performing token authentication ([token_attempts] attempts)")
		to_chat_immediate(src, span_userdanger("Maximum number of login attempts reached. Try again later."))
		if(from_ui)
			tgui_alert_async(src.mob, "Maximum number of login attempts reached. Try again later.", "Warning", list("OK"))
		// Reset attempts after delay
		if(token_attempts == 4)
			spawn(60 SECONDS) token_attempts = 0
		return FALSE
	if(!istext(token) || !length(token) || length(token) > 128)
		to_chat_immediate(src, span_userdanger("Submitted token is not formatted correctly."))
		if(from_ui)
			tgui_alert_async(src.mob, "Submitted token is not formatted correctly.", "Warning", list("OK"))
		return FALSE
	var/hashed_token = rustg_hash_string(RUSTG_HASH_SHA256, token)
	if(!istext(hashed_token) || !length(hashed_token))
		return FALSE
	var/ip = isnull(src.address) || src.address == "::1" ? "127.0.0.1" : src.address
	var/datum/db_query/query_check_token = SSdbcore.NewQuery(
		"SELECT external_method,external_uid,external_display_name FROM [format_table_name("session")] WHERE `ip` = INET_ATON(:ip) AND `session_token` = :session_token AND `valid_until` > NOW() LIMIT 1",
		list("ip" = ip, "session_token" = hashed_token)
	)
	if(!query_check_token.Execute() || !query_check_token.NextRow())
		to_chat_immediate(src, span_userdanger("Login failed: Invalid session! Log in again with a new token."))
		if(from_ui)
			tgui_alert_async(src.mob, "Invalid session token. Make sure your IP address has not changed since the token was issued.", "Warning", list("OK"))
		qdel(query_check_token)
		return FALSE
	var/external_method_db = query_check_token.item[1]
	var/external_uid = query_check_token.item[2]
	var/external_display_name = query_check_token.item[3]
	qdel(query_check_token)
	var/new_key = ""
	var/datum/external_login_method/external_method = GLOB.login_methods[external_method_db]
	if(!istype(external_method) || isnull(external_uid))
		to_chat_immediate(src, span_userdanger("Invalid login method: '[external_method_db]'."))
		return FALSE
	var/list/existing_user = existing_user_for_uid(external_method, external_uid)
	if(islist(existing_user) && length(existing_user) == 2) // External user has logged in before
		var/known_ckey = existing_user[1]
		var/known_key = existing_user[2]
		if(external_method.is_fake_key(known_ckey)) // UID exists already but is an External key
			if(istext(src.byond_authenticated_key) && length(src.byond_authenticated_key)) // they signed in with a CKEY but already created an external account. yikes.
				new_key = known_ckey
				to_chat_immediate(src, span_userdanger("You connected with the key [byond_authenticated_key], but you already logged in before linking your CKEY and were issued the [external_method::name] key [known_key]! You have been signed in as [known_key]."))
			else if(known_ckey != external_method.to_fake_ckey(external_uid))
				to_chat_immediate(src, span_userdanger("Your account key is somehow associated with a different [external_method::name] UID [known_ckey] than your login [external_uid]. This shouldn't be possible. Help."))
				return FALSE
			else // connected as a guest and already has logged in with External. Use the External key.
				new_key = external_method.to_fake_key(external_uid)
		else if(IS_GUEST_KEY(known_key))
			to_chat_immediate(src, span_userdanger("Your [external_method::name] UID is associated with a Guest key. This shouldn't be possible. Help."))
			return FALSE
		// Real BYOND key
		else if(ckey(known_key) != known_ckey)
			to_chat_immediate(src, span_userdanger("Your associated BYOND key ([known_key]) is inconsistent with your CKEY ([known_ckey]), which should be [ckey(known_key)]. This shouldn't be possible. Help."))
			return FALSE
		// External UID is associated with another account, but we verifiably own the current CKEY.
		// Note that this occurs after checking if the old account is an external key - we can only unlink from BYOND CKEYs as unlinking an external key would break it.
		else if(istext(src.byond_authenticated_key) && length(src.byond_authenticated_key) && ckey(src.byond_authenticated_key) != known_ckey)
			// First let's let the admins know about the old CKEY.
			message_admins("[key_name_admin(src)] is potentially multikeying. They connected under the BYOND Hub key <b>[byond_authenticated_key]</b>, but their [external_method::name] UID [external_uid] ([external_method.format_display_name(external_display_name)]) is already linked with the key <b>[known_key]</b>. Asking if they wish to unlink their [external_method::name] account from <b>[known_key]</b>.")
			log_admin_private("POTENTIAL MULTIKEYING: [key_name(src)] authenticated with BYOND key [byond_authenticated_key] but their [external_method::name] UID [external_uid] ([external_method.format_display_name(external_display_name)]) is associated with the key [known_key]")
			// Prompt user to unlink the external account from the other CKEY.
			// If they choose not to unlink they will need a new external account to link and the login is cancelled.
			var/link_choice = tgui_alert(src,
				"Your [external_method::name] account is already associated with the CKEY \"[known_key]\". \
				Would you like to unlink it from \"[known_key]\"?",
				"Previous CKEY",
				list("Unlink [known_key]", "Cancel Login")
			)
			if(link_choice != "Unlink [known_key]")
				message_admins("[key_name_admin(src)] (authenticated by BYOND Hub as <b>[byond_authenticated_key]</b>) cancelled their login.")
				return FALSE
			var/external_column = external_method::db_id_column_name
			if(!istext(external_column) || !length(external_column))
				return FALSE
			var/datum/db_query/query_update_external_uid = SSdbcore.NewQuery(
				"UPDATE [format_table_name("player")] SET [external_column] = NULL WHERE ckey = :ckey",
				list("ckey" = known_ckey)
			)
			query_update_external_uid.Execute()
			var/msg = "You have unlinked your [external_method::name] account from the CKEY \"[known_key]\"."
			to_chat_immediate(src, span_good(msg))
			tgui_alert_async(src, msg, "Success", list("OK"))
			qdel(query_update_external_uid)
			message_admins("[key_name_admin(src)] (authenticated by BYOND Hub as <b>[byond_authenticated_key]</b>) unlinked [external_method::name] UID [external_uid] ([external_method.format_display_name(external_display_name)]) from the BYOND CKEY <b>[known_key]</b>. This is likely because they had a previous CKEY that is no longer used. Check that multikey policy is being followed.")
			log_admin_private("[key_name(src)] (authenticated by BYOND HUB as [byond_authenticated_key]) unlinked [external_method::name] UID [external_uid] ([external_method.format_display_name(external_display_name)]) from the BYOND CKEY [known_key]")
			new_key = src.byond_authenticated_key
		else // The user just has a CKEY tied to this external UID and wants to sign into it. Expected use.
			new_key = known_key
	// More than one associated key. AHHHHHHHHHHHHHHHHHHHHHHHHHH
	else if(isnum(existing_user) && existing_user == TRUE)
		var/message = "[key_name(src)] successfully authenticated with [external_method::name] UID [external_uid], but they have more than one associated CKEY!"
		message_admins("[message] Tell a maintainer immedietaly!")
		CRASH(message)
	else // This External user has never connected and has no associated BYOND ckey. Make one for them.
		new_key = external_method.to_fake_key(external_uid)
		if(istext(src.byond_authenticated_key) && length(src.byond_authenticated_key)) // they have a key already, let's associate it for them on login
			new_key = src.byond_authenticated_key
	if(length(new_key) && src.can_login_as(new_key) && src.byond_authenticated_update_external_uid(new_key, external_method, external_uid, external_display_name))
		save_session_token(token)
		return login_as(new_key, external_method, external_uid, external_display_name)
	return FALSE

/client/proc/can_login_as(new_key)
	if(!CONFIG_GET(flag/enable_guest_external_auth))
		return FALSE
	if(logged_in)
		return FALSE
	var/list/ban = world.IsBanned(new_key, src.address, src.computer_id, src.connection, FALSE, from_auth=TRUE)
	if(islist(ban))
		var/ban_reason = ban["reason"]
		var/ban_desc = ban["desc"]
		to_chat_immediate(src, span_userdanger("Login: Access denied."))
		to_chat_immediate(src, "Banned by host: [ban_reason] - [ban_desc]")
		message_admins("[key_name(src)] has authenticated via [external_method::name] UID [external_uid] as banned user <b>[new_key]</b>. They have been informed of this ban and kicked from the server.")
		src << browse(HTML_SKELETON_TITLE("Banned: [ban_reason]", "<span style='white-space:pre-line;'>[ban_desc]</span>"), "window=ban_notice;size=800x250")
		spawn(5 SECONDS)
			qdel(src)
		return FALSE
	var/ckey = ckey(new_key)
	var/client/existing_client = GLOB.directory[ckey]
	if(!QDELETED(existing_client) && existing_client != src) // directory can already contain their CKEY if they connected with a valid BYOND key
		var/usr_msg = "The CKEY [ckey] is already connected with another client! You have been disconnected from the game."
		to_chat_immediate(src, span_userdanger(usr_msg))
		log_admin_private("MULTICONNECTION: [key_name(src)] authenticated as [ckey], who is already playing as [key_name(existing_client)]!")
		message_admins("[span_danger("<B>MULTICONNECTION:</B>")] [span_notice("[key_name_admin(src)] authenticated as [ckey], who is already playing as [key_name_admin(existing_client)]! The authorizing guest has been kicked from the game.")]")
		src << browse(HTML_SKELETON_TITLE("DANGER!", usr_msg), "window=multiconnect_notice")
		spawn(5 SECONDS)
			qdel(src)
		return FALSE
	return TRUE

/// Allows BYOND authenticated users to relink their External UIDs.
/// FALSE: No login allowed.
/// TRUE: Continue
/client/proc/byond_authenticated_update_external_uid(new_key, datum/external_login_method/external_method, external_uid, external_display_name)
	if(IsAdminAdvancedProcCall())
		return FALSE
	if(IS_GUEST_KEY(new_key))
		return FALSE
	if(!SSdbcore.Connect())
		return FALSE
	if(!istype(external_method) || isnull(external_uid) || !length(external_uid))
		return FALSE
	if(external_method.is_fake_key(new_key))
		return TRUE
	// User has to have an authenticated key to overwrite their external UID.
	// At this point we know that the external UID is not associated with any other account.
	// We also know that the existing external UID only belongs to this authenticated CKEY
	// So we can safely dissociate it and lose no data, as we know that the user who originally linked the account is just updating the link.
	if(!istext(src.byond_authenticated_key) || !length(src.byond_authenticated_key))
		// They didn't authenticate with BYOND, we can skip this check.
		return TRUE
	// We can only update it if they're actually signing in with their BYOND authenticated key.
	if(ckey(src.byond_authenticated_key) != ckey(new_key))
		return TRUE // this check can't be hit at the time of writing, but may be necessary in the future
	var/external_column = external_method::db_id_column_name
	if(!istext(external_column) || !length(external_column))
		return FALSE
	// Check account linking assocation and update if they're BYOND authenticated
	var/datum/db_query/query_current_external_uid = SSdbcore.NewQuery(
		"SELECT [external_column] FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey(new_key))
	)
	if(!query_current_external_uid.Execute())
		qdel(query_current_external_uid)
		return FALSE
	var/external_uid_from_db = null
	if(query_current_external_uid.NextRow() && islist(query_current_external_uid.item) && length(query_current_external_uid.item) == 1)
		external_uid_from_db = query_current_external_uid.item[1]
	qdel(query_current_external_uid)
	// CKEY doesn't exist in the database or has no associated external UID. We can associate it with the typical process.
	if(isnull(external_uid_from_db) || !length(external_uid_from_db))
		return TRUE
	if(external_uid != external_uid_from_db)
		var/formatted_display_name = external_method.format_display_name(external_display_name)
		var/account_selection = tgui_alert(
			src,
			"Linking [external_method::name] account ID \"[external_uid]\" ([formatted_display_name]), \
			will overwrite previous linked [external_method::name] account ID: \"[external_uid_from_db]\". \n\n\
			Are you sure you want to unlink your previous [external_method::name] account?",
			"Account Association",
			list("Overwrite", "Cancel Login")
		)
		if(account_selection != "Overwrite")
			return FALSE
		var/datum/db_query/query_update_external_uid = SSdbcore.NewQuery(
			"UPDATE [format_table_name("player")] SET [external_column] = :external_uid WHERE ckey = :ckey",
			list("ckey" = ckey(new_key), "external_uid" = external_uid)
		)
		query_update_external_uid.Execute()
		var/msg = "You have overwritten your account's associated [external_method::name] UID to [external_uid] ([external_method.format_display_name(external_display_name)])! Make sure you always log in with this [external_method::name] account from now on to retain your access."
		to_chat_immediate(src, span_good(msg))
		tgui_alert_async(src, msg, "Success", list("OK"))
		qdel(query_update_external_uid)
	return TRUE

/// Equivalent of /client/New() for token login
/// Fully migrates a user to the new key
/client/proc/login_as(new_key, datum/external_login_method/external_method, external_uid, external_display_name)
	if(IsAdminAdvancedProcCall())
		log_admin_private("[key_name(usr)] attempted to log in [key_name(src)] as \"[new_key]\" (ckey: [ckey(new_key)])")
		// WEEEWOOOWEEEEWOOOO
		message_admins("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		message_admins("Auth bypass attempted by [key_name(usr)] for [key_name(src)] (attempted CKEY: [ckey(new_key)])")
		message_admins("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		return FALSE
	token_attempts = 0
	remove_verb(/client/verb/get_token)
	remove_verb(/client/verb/use_token)
	remove_verb(/client/verb/open_login)
	add_verb(/client/proc/log_out)
	// Set this early so that we can rely on it in setup (for things like build_ban_cache)
	src.logged_in = TRUE
	src.key_is_external = is_external_auth_key(new_key)
	src.external_method = external_method
	src.external_uid = external_uid
	src.external_display_name = external_display_name

	log_access("Authentication: [key_name(src)] has authenticated as [new_key] (ckey: [ckey(new_key)]) using [external_method] ID [external_uid]")
	GLOB.directory -= src.ckey
	var/mob/my_mob = src.mob
	src.ckey = ckey
	src.key = new_key
	tgui_panel?.owner_ckey = ckey

	if(!client_pre_login(TRUE, FALSE))
		return FALSE

	if(QDELETED(src))
		return FALSE

	var/mob/logout_mob = GLOB.disconnected_mobs[src.ckey]
	if(ismob(logout_mob) && !isnewplayer(logout_mob))
		var/mob/original_mob = src.mob
		GLOB.disconnected_mobs -= src.ckey
		transfer_preauthenticated_player_mob(original_mob, logout_mob)
	// Mob is ready
	// calls /mob/dead/new_player/authenticated/Login()
	// creates mind and such
	else if(istype(my_mob, /mob/dead/new_player/pre_auth))
		transfer_preauthenticated_player_mob(my_mob, null)

	if(!client_post_login(TRUE, FALSE, !!(holder || GLOB.deadmins[ckey])))
		return FALSE

	// send the new CKEY to telemetry
	tgui_panel.on_message("ready")
	// Update stat again
	mob.UpdateMobStat(TRUE)
	return TRUE

/client/proc/initialize_login_handler()
	var/static/login_html
	if(isnull(login_html))
		login_html = rustg_file_read("html/login_handler.html")
		login_html = replacetext(login_html, "<!--- SERVER --->", CONFIG_GET(string/server) || "beestation")
	src << browse(login_html, "window=login;file=login.html;can_minimize=0;auto_format=0;titlebar=0;can_resize=0;")
	winshow(src, "login", FALSE)

/client/proc/save_session_token(token)
	if(!istext(token))
		return
	src << output("store&[token]", "login.browser:login_listener")

/client/proc/clear_saved_session_token()
	src << output("clear", "login.browser:login_listener")

/client/proc/send_saved_session_token()
	if(IsAdminAdvancedProcCall())
		return
	src << output("login", "login.browser:login_listener")

/// Returns null if there is no associated byond key.
/// Returns TRUE if the UID has more than one key associated.
/// Otherwise, returns list(ckey, key)
/proc/existing_user_for_uid(datum/external_login_method/method, external_uid)
	if(isnull(external_uid) || !istype(method))
		return null
	var/sql_ckey = null
	var/sql_key = null
	var/datum/db_query/query_check_byond_key = SSdbcore.NewQuery(
		"SELECT ckey,byond_key,COUNT(ckey) FROM [format_table_name("player")] WHERE [method::db_id_column_name] = :external_uid",
		list("external_uid" = external_uid)
	)
	if(!query_check_byond_key.Execute())
		qdel(query_check_byond_key)
		return null
	if(query_check_byond_key.NextRow())
		var/tmp_sql_ckey = query_check_byond_key.item[1]
		var/tmp_sql_key = query_check_byond_key.item[2]
		var/ckey_count = query_check_byond_key.item[3]
		// what the fuck, this person has multiple CKEYs linked to one external method
		// we can't pick one so just throw a fit
		if(ckey_count > 1)
			qdel(query_check_byond_key)
			return TRUE
		// if there are zero ckeys
		if(ckey_count != 1)
			qdel(query_check_byond_key)
			return null
		sql_ckey = tmp_sql_ckey
		sql_key = tmp_sql_key
	qdel(query_check_byond_key)
	return list(sql_ckey, sql_key)

/proc/db_invalidate_all_sessions_for(datum/external_login_method/external_method, external_uid)
	if(IsAdminAdvancedProcCall())
		return
	if(!SSdbcore.Connect() || !istype(external_method) || !istext(external_uid) || !length(external_uid))
		return

	var/datum/db_query/query_update_sessions = SSdbcore.NewQuery(
		"UPDATE [format_table_name("session")] SET valid_until = NOW() WHERE external_uid = :external_uid AND external_method = :external_method_id AND valid_until > NOW()",
		list("external_uid" = external_uid, "external_method_id" = external_method::id)
	)
	query_update_sessions.Execute()
	qdel(query_update_sessions)

/client/proc/login_with_method_id(method_id)
	var/datum/external_login_method/method = GLOB.login_methods[method_id]
	if(istype(method))
		login_with_method(method)
	else
		to_chat_immediate(src, span_danger("Invalid login method: [method_id]"))

/client/proc/login_with_method(datum/external_login_method/method)
	if(!istype(method))
		to_chat_immediate(src, span_danger("Method not implemented!"))
		return
	var/ip = src.address
	if(is_localhost())
		ip = "127.0.0.1"
	var/seeker_port_in = src.seeker_port
	if(!isnum_safe(seeker_port_in) || seeker_port_in < 1024 || seeker_port_in > 65535)
		seeker_port_in = null
	var/my_nonce = add_session_creation_nonce()
	if(!istext(my_nonce) || !length(my_nonce))
		to_chat_immediate(src, span_userdanger("Login not available at this time. Please contact the host."))
		return
	var/link = method.get_url(ip, seeker_port_in, my_nonce)
	if(istext(link))
		src << link(link)
	else
		to_chat_immediate(src, span_danger("[method::name] authentication has not been configured!"))

/client/proc/add_session_creation_nonce()
	var/ip = src.address
	if(is_localhost())
		ip = "127.0.0.1"
	if(!length(ip))
		return null
	if(!SSdbcore.Connect())
		return null
	var/seeker_port_in = src.seeker_port
	if(!isnum_safe(seeker_port_in) || seeker_port_in < 1024 || seeker_port_in > 65535)
		seeker_port_in = null
	var/fiftyfifty = prob(50) ? FEMALE : MALE
	// sufficiently entropic, unguessable string unique to this user's current connection
	var/hashtext = "[ckey][ip][rand(0,9999)][world.realtime][rand(0,9999)][world.address][generate_random_name(fiftyfifty)][rand(0,9999)][rand(0,9999)][computer_id][rand(0,9999)][GLOB.round_id]"
	var/nonce = rustg_hash_string(RUSTG_HASH_SHA256, hashtext)
	var/datum/db_query/insert_nonce_query = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("session_creation_nonce")] (`ip`, `seeker_port`, `session_nonce`) VALUES (:ip, :seeker_port, :nonce)",
		list("ip" = ip, "seeker_port" = seeker_port_in, "nonce" = nonce)
	)
	insert_nonce_query.Execute()
	qdel(insert_nonce_query)
	return nonce
