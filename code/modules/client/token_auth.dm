/client/verb/test_ckey_login()
	set name = "Test CKEY Login"
	set category = "Login"
	token_login("Itsmeowdev")

/client/verb/test_discord_login()
	set name = "Test Discord Login"
	set category = "Login"
	token_login("d126059512611340288")

/mob/dead/new_player/pre_auth/Login()
	. = ..()
	client?.add_verb(/client/verb/test_ckey_login, TRUE)
	client?.add_verb(/client/verb/test_discord_login, TRUE)

/mob/dead/new_player/pre_auth/proc/convert_to_authed()
	if(IsAdminAdvancedProcCall())
		log_admin_private("[key_name(usr)] attempted to auth bypass [key_name(src)]")
		return
	var/mob/dead/new_player/authenticated/authed = new()
	var/key = client.key
	authed.name = key
	authed.key = key
	qdel(src)

/// Equivalent of /client/New() for token login
/// Fully migrates a user to the new key
/client/proc/token_login(new_key)
	if(IsAdminAdvancedProcCall())
		log_admin_private("[key_name(usr)] attempted to log in [key_name(src)] as \"[new_key]\" (ckey: [ckey(new_key)])")
		// WEEEWOOOWEEEEWOOOO
		message_admins("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		message_admins("Auth bypass attempted by [key_name(usr)] for [key_name(src)] (attempted CKEY: [ckey(new_key)])")
		message_admins("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		return
	if(logged_in)
		return
	logged_in = TRUE
	var/ckey = ckey(new_key)
	log_access("Authentication: [key_name(src)] has authenticated as [new_key] (ckey: [ckey])")
	GLOB.directory -= src.ckey
	var/mob/my_mob = src.mob
	src.key = new_key
	tgui_panel?.owner_ckey = ckey

	if(!client_pre_login(TRUE, FALSE))
		return null

	// Mob is ready
	// calls /mob/dead/new_player/authenticated/Login()
	// creates mind and such
	if(isnewplayer_preauth(my_mob))
		var/mob/dead/new_player/pre_auth/pre_auth_player = my_mob
		pre_auth_player.convert_to_authed()

	if(!client_post_login(TRUE, FALSE, !!(holder || GLOB.deadmins[ckey])))
		return null

	// send the new CKEY to telemetry
	tgui_panel.on_message("ready")

/// update byond_key to match the provided username
/client/proc/update_username_in_db(username)
	if(!IS_TOKEN_AUTH_KEY(key) || IS_GUEST_KEY(key))
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
	if(username != sql_key)
		var/datum/db_query/query_update_byond_key = SSdbcore.NewQuery(
			"UPDATE [format_table_name("player")] SET byond_key = :byond_key WHERE ckey = :ckey",
			list("byond_key" = username, "ckey" = ckey)
		)
		query_update_byond_key.Execute()
		qdel(query_update_byond_key)
