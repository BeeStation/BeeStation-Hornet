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
	set name = "Log Out & Disconnect"
	set category = "Login"
	if(tgui_alert(src.mob, "You will be disconnected from the game and all your sessions will be immediately revoked.", "Are you sure?", list("Yes", "Cancel")) != "Yes")
		return
	tgui_login?.clear_session_token()
	to_chat_immediate(src, span_userdanger("You have been logged out. Your client has been disconnected from the game."))
	db_invalidate_all_sessions_for(src.external_uid)
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
			tgui_alert(src.mob, "Maximum number of login attempts reached. Try again later.", "Warning", list("OK"))
		// Reset attempts after delay
		if(token_attempts == 4)
			spawn(60 SECONDS) token_attempts = 0
		return FALSE
	if(!istext(token) || !length(token) || length(token) > 128)
		to_chat_immediate(src, span_userdanger("Submitted token is not formatted correctly."))
		if(from_ui)
			tgui_alert(src.mob, "Submitted token is not formatted correctly.", "Warning", list("OK"))
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
			tgui_alert(src.mob, "Invalid session token. Make sure your IP address has not changed since the token was issued.", "Warning", list("OK"))
		qdel(query_check_token)
		return FALSE
	var/external_method = query_check_token.item[1]
	var/external_uid = query_check_token.item[2]
	var/external_display_name = query_check_token.item[3]
	var/new_key = ""
	if(external_method == "discord" && !isnull(external_uid))
		// Log in as known BYOND key
		var/existing_byond_key = real_byond_key_for_discord_uid(external_uid)
		// More than one associated key. AHHHHHHHHHHHHHHHHHHHHHHHHHH
		if(isnum(existing_byond_key) && existing_byond_key == TRUE)
			qdel(query_check_token)
			var/message = "[key_name(src)] successfully authenticated with discord UID [external_uid], but they have more than one associated CKEY!"
			message_admins("[message] Tell a maintainer immedietaly!")
			CRASH(message)
		if(istext(existing_byond_key) && length(existing_byond_key))
			new_key = existing_byond_key
		else // otherwise make a new one for them
			new_key = "d[external_uid]"
	if(length(new_key))
		qdel(query_check_token)
		tgui_login?.save_session_token(token)
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
	var/ckey = ckey(new_key)
	log_access("Authentication: [key_name(src)] has authenticated as [new_key] (ckey: [ckey]) using [external_method] ID [external_uid]")
	GLOB.directory -= src.ckey
	var/mob/my_mob = src.mob
	src.key = new_key
	tgui_panel?.owner_ckey = ckey

	if(!client_pre_login(TRUE, FALSE))
		return FALSE

	to_chat_immediate(src, span_good("Successfully signed in as [span_bold("[src.display_name_chat()]")]"))
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
		if(ckey_count != 1 || ckey(tmp_sql_key) != sql_ckey || IS_EXTERNAL_AUTH_KEY(sql_ckey))
			qdel(query_check_byond_key)
			return null
		sql_key = tmp_sql_key
	qdel(query_check_byond_key)
	return sql_key

/// update byond_key to match the provided username
/client/proc/update_username_in_db()
	if(!src.key_is_external || isnull(src.external_display_name))
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
	if(src.external_display_name != sql_key)
		var/datum/db_query/query_update_byond_key = SSdbcore.NewQuery(
			"UPDATE [format_table_name("player")] SET byond_key = :byond_key WHERE ckey = :ckey",
			list("byond_key" = src.external_display_name, "ckey" = ckey)
		)
		query_update_byond_key.Execute()
		qdel(query_update_byond_key)

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
	return "[key][!isnull(display_name) && display_name != key ? " (@[display_name])" : ""]"

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
