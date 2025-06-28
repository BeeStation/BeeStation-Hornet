/client/verb/use_token(token as text)
	set name = "Manual Token Entry"
	set category = "Login"
	login_with_token(token)

/client/verb/get_token()
	set name = "Login with Discord"
	set category = "Login"
	var/list/methods = CONFIG_GET(keyed_list/external_auth_method)
	var/discord_link = methods["discord"]
	if(istext(discord_link))
		var/ip = src.address
		if(is_localhost())
			ip = "127.0.0.1"
		var/port_data = ""
		if(isnum_safe(seeker_port))
			port_data = "&seeker_port=[url_encode(seeker_port)]"
		src << link("[discord_link]?ip=[url_encode(ip)][port_data]")
	else
		to_chat_immediate(src, span_danger("Discord authentication has not been configured!"))

/client/verb/open_login()
	set name = "Open Login UI"
	set category = "Login"
	tgui_login?.open()

/client/proc/log_out()
	set name = "Log Out and Disconnect"
	set category = "Login"
	if(tgui_alert(src.mob, "You will be disconnected from the game and all session tokens will be revoked.", "Are you sure?", list("Yes", "Cancel")) != "Yes")
		return
	tgui_login?.clear_session_token()
	to_chat_immediate(src, span_userdanger("You have been logged out. Your client has been disconnected from the game."))
	db_invalidate_all_sessions_for(src.external_uid)
	spawn(5)
		qdel(src)

/mob/dead/new_player/pre_auth/proc/convert_to_authed()
	if(IsAdminAdvancedProcCall())
		log_admin_private("[key_name(usr)] attempted to auth bypass [key_name(src)] via convert_to_authed()")
		return
	var/mob/dead/new_player/authenticated/authed = new()
	var/key = client.key
	authed.name = client.display_name()
	authed.key = key
	qdel(src)

/mob/dead/new_player/pre_auth/vv_edit_var(var_name, var_value)
	return FALSE

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
	var/external_method = query_check_token.item[1]
	var/external_uid = query_check_token.item[2]
	var/external_display_name = query_check_token.item[3]
	var/new_key = ""
	if(external_method == "discord" && !isnull(external_uid))
		var/list/existing_user = existing_user_for_uid(external_uid)
		if(islist(existing_user) && length(existing_user) == 2) // Discord user has logged in before
			var/known_ckey = existing_user[1]
			var/known_key = existing_user[2]
			if(IS_EXTERNAL_AUTH_KEY(known_ckey)) // UID exists already but is a Discord key
				if(istext(src.byond_authenticated_key) && length(src.byond_authenticated_key)) // they signed in with a CKEY but already created a discord account. yikes.
					new_key = known_ckey
					to_chat_immediate(src, span_userdanger("You connected with the key [byond_authenticated_key], but you already logged in before linking your CKEY and were issued the Discord key @[known_key]! You have been signed in as @[known_key]."))
					byond_authenticated_key = null
				else if(known_ckey != "d[external_uid]")
					to_chat_immediate(src, span_userdanger("Your account key is somehow associated with a different Discord UID [known_ckey] than your login [external_uid]. This shouldn't be possible. Help."))
					return FALSE
				else // connected as a guest and already has logged in with Discord. Use the Discord key.
					new_key = "D[external_uid]"
			else if(IS_GUEST_KEY(known_key))
				to_chat_immediate(src, span_userdanger("Your Discord UID is associated with a Guest key. This shouldn't be possible. Help."))
				return FALSE
			// Real BYOND key
			else if(ckey(known_key) != known_ckey)
				to_chat_immediate(src, span_userdanger("Your associated BYOND key ([known_key]) is inconsistent with your CKEY ([known_ckey]), which should be [ckey(known_key)]. This shouldn't be possible. Help."))
				return FALSE
			else
				new_key = known_key
				// Login CKEY and saved CKEY differ
				if(istext(src.byond_authenticated_key) && length(src.byond_authenticated_key) && ckey(src.byond_authenticated_key) != known_ckey)
					to_chat_immediate(src, span_userdanger("You connected with the key [byond_authenticated_key], but your Discord account is already linked to [known_key]! You have been signed in as [known_key]."))
					message_admins("[key_name_admin(src)] is potentially multikeying. They connected under the BYOND key [byond_authenticated_key], but their [external_method] UID [external_uid] is already linked with the key [known_key].")
					log_admin_private("POTENTIAL MULTIKEYING: [key_name(src)] connected with BYOND key [byond_authenticated_key] but their [external_method] UID [external_uid] is associated with the key [known_key]")
					byond_authenticated_key = null
		// More than one associated key. AHHHHHHHHHHHHHHHHHHHHHHHHHH
		else if(isnum(existing_user) && existing_user == TRUE)
			qdel(query_check_token)
			var/message = "[key_name(src)] successfully authenticated with discord UID [external_uid], but they have more than one associated CKEY!"
			message_admins("[message] Tell a maintainer immedietaly!")
			CRASH(message)
		else // This Discord user has never connected and has no associated BYOND ckey. Make one for them.
			new_key = "D[external_uid]" //capitalize the key because otherwise the client displays as "The d549835457345893475"
			if(istext(src.byond_authenticated_key) && length(src.byond_authenticated_key)) // they have a key already, let's associate it for them on login
				new_key = src.byond_authenticated_key
				src.byond_authenticated_key = null
	if(length(new_key))
		qdel(query_check_token)
		tgui_login?.save_session_token(token)
		// Make sure this stupid thing closes correctly
		spawn(5 SECONDS)
			tgui_login?.close()
		return login_as(new_key, external_method, external_uid, external_display_name)
	qdel(query_check_token)
	return FALSE

/// Equivalent of /client/New() for token login
/// Fully migrates a user to the new key
/client/proc/login_as(new_key, external_method, external_uid, external_display_name)
	if(IsAdminAdvancedProcCall())
		log_admin_private("[key_name(usr)] attempted to log in [key_name(src)] as \"[new_key]\" (ckey: [ckey(new_key)])")
		// WEEEWOOOWEEEEWOOOO
		message_admins("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		message_admins("Auth bypass attempted by [key_name(usr)] for [key_name(src)] (attempted CKEY: [ckey(new_key)])")
		message_admins("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		return FALSE
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
		message_admins("[key_name(src)] has authenticated via [src.external_method] UID [src.external_uid] as banned user <b>[new_key]</b>. They have been informed of this ban and kicked from the server.")
		src << browse(HTML_SKELETON_TITLE("Banned: [ban_reason]", "<span style='white-space:pre-line;'>[ban_desc]</span>"), "window=ban_notice;size=800x250")
		spawn(5 SECONDS)
			qdel(src)
		return FALSE
	var/ckey = ckey(new_key)
	var/client/existing_client = GLOB.directory[ckey]
	if(!QDELETED(existing_client))
		var/usr_msg = "The CKEY [ckey] is already connected with another client! You have been disconnected from the game."
		to_chat_immediate(src, span_userdanger(usr_msg))
		log_admin_private("MULTICONNECTION: [key_name(src)] authenticated as [ckey], who is already playing as [key_name(existing_client)]!")
		message_admins("[span_danger("<B>MULTICONNECTION:</B>")] [span_notice("[key_name_admin(src)] authenticated as [ckey], who is already playing as [key_name_admin(existing_client)]! The authorizing guest has been kicked from the game.")]")
		src << browse(HTML_SKELETON_TITLE("DANGER!", usr_msg), "window=multiconnect_notice")
		spawn(5 SECONDS)
			qdel(src)
		return FALSE
	token_attempts = 0
	remove_verb(/client/verb/get_token)
	remove_verb(/client/verb/use_token)
	remove_verb(/client/verb/open_login)
	add_verb(/client/proc/log_out)
	// Set this early so that we can rely on it in setup (for things like build_ban_cache)
	src.logged_in = TRUE
	src.key_is_external = IS_EXTERNAL_AUTH_KEY(new_key)
	src.external_method = external_method
	src.external_uid = external_uid
	src.external_display_name = external_display_name

	log_access("Authentication: [key_name(src)] has authenticated as [new_key] (ckey: [ckey]) using [external_method] ID [external_uid]")
	GLOB.directory -= src.ckey
	var/mob/my_mob = src.mob
	src.key = new_key
	tgui_panel?.owner_ckey = ckey

	if(!client_pre_login(TRUE, FALSE))
		return FALSE

	// Mob is ready
	// calls /mob/dead/new_player/authenticated/Login()
	// creates mind and such
	if(istype(my_mob, /mob/dead/new_player/pre_auth))
		var/mob/dead/new_player/pre_auth/pre_auth_player = my_mob
		pre_auth_player.convert_to_authed()

	if(!client_post_login(TRUE, FALSE, !!(holder || GLOB.deadmins[ckey])))
		return FALSE

	// send the new CKEY to telemetry
	tgui_panel.on_message("ready")
	// Update stat again
	mob.UpdateMobStat(TRUE)
	return TRUE

/// Returns null if there is no associated byond key.
/// Returns TRUE if the UID has more than one key associated.
/// Otherwise, returns the key stored in the database.
/client/proc/real_byond_key_for_discord_uid(discord_uid)
	if(isnull(discord_uid))
		return null
	var/sql_key = null
	var/datum/db_query/query_check_byond_key = SSdbcore.NewQuery(
		"SELECT ckey,byond_key,COUNT(ckey) FROM [format_table_name("player")] WHERE discord_uid = :discord_uid",
		list("discord_uid" = discord_uid)
	)
	if(!query_check_byond_key.Execute())
		qdel(query_check_byond_key)
		return null
	if(query_check_byond_key.NextRow())
		var/sql_ckey = query_check_byond_key.item[1]
		var/tmp_sql_key = query_check_byond_key.item[2]
		var/ckey_count = query_check_byond_key.item[3]
		// what the fuck, this person has multiple CKEYs linked to one Discord
		// we can't pick one so just throw a fit
		if(ckey_count > 1)
			qdel(query_check_byond_key)
			return TRUE
		// if the ckey doesn't match or is not a real BYOND ckey
		if(ckey_count != 1 || ckey(tmp_sql_key) != sql_ckey || IS_EXTERNAL_AUTH_KEY(sql_ckey) || IS_GUEST_KEY(tmp_sql_key))
			qdel(query_check_byond_key)
			return null
		sql_key = tmp_sql_key
	qdel(query_check_byond_key)
	return sql_key

/// Returns null if there is no associated byond key.
/// Returns TRUE if the UID has more than one key associated.
/// Otherwise, returns list(ckey, key)
/// Warning: this can return fake keys from discord, including discord usernames as the key
/client/proc/existing_user_for_uid(discord_uid)
	if(isnull(discord_uid))
		return null
	var/sql_ckey = null
	var/sql_key = null
	var/datum/db_query/query_check_byond_key = SSdbcore.NewQuery(
		"SELECT ckey,byond_key,COUNT(ckey) FROM [format_table_name("player")] WHERE discord_uid = :discord_uid",
		list("discord_uid" = discord_uid)
	)
	if(!query_check_byond_key.Execute())
		qdel(query_check_byond_key)
		return null
	if(query_check_byond_key.NextRow())
		var/tmp_sql_ckey = query_check_byond_key.item[1]
		var/tmp_sql_key = query_check_byond_key.item[2]
		var/ckey_count = query_check_byond_key.item[3]
		// what the fuck, this person has multiple CKEYs linked to one Discord
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

/// Gets the key of this user, or their external display name.
/// Make sure you differentiate display names from BYOND keys by using client.external_method as a tag
/client/proc/display_name()
	if(src.key_is_external && !isnull(src.external_display_name))
		return "@[src.external_display_name]"
	return src.key

/client/proc/display_name_chat()
	if(src.key_is_external && !isnull(src.external_display_name))
		return "<span class='chat16x16 badge-badge_[src.external_method]' style='vertical-align: -3px;'></span> @[src.external_display_name]"
	return src.key

/datum/mind/proc/full_key()
	return "[key][!isnull(display_name) && display_name != key ? " ([display_name])" : ""]"

/datum/mind/proc/display_key()
	return !isnull(display_name) ? display_name : key

/datum/mind/proc/display_key_chat()
	return !isnull(display_name_chat) ? display_name_chat : key

/proc/db_invalidate_all_sessions_for(external_uid)
	if(IsAdminAdvancedProcCall())
		return
	if(!SSdbcore.Connect())
		return

	var/datum/db_query/query_update_sessions = SSdbcore.NewQuery(
		"UPDATE [format_table_name("session")] SET valid_until = NOW() WHERE external_uid = :external_uid AND valid_until > NOW()",
		list("external_uid" = external_uid)
	)
	query_update_sessions.Execute()
	qdel(query_update_sessions)

/mob/dead/new_player/get_stat_tab_status()
	var/list/tab_data = ..()
	if(src.client && CONFIG_GET(flag/enable_guest_external_auth) && !isnull(src.client.external_uid))
		if(src.client.logged_in)
			if(src.client.key_is_external)
				tab_data["CKEY"] = GENERATE_STAT_TEXT(src.client.ckey)
				tab_data["Authentication Method"] = GENERATE_STAT_TEXT(src.client.external_method)
				tab_data["Display Name"] = GENERATE_STAT_TEXT(src.client.external_display_name)
			else
				tab_data["CKEY"] = GENERATE_STAT_TEXT(src.client.key)
		else
			tab_data["CKEY"] = GENERATE_STAT_TEXT("Please log in!")
	return tab_data
