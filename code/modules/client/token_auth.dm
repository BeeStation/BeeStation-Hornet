/client/verb/test_login()
	set name = "Test Login"
	token_login("Itsmeowdev")

/mob/dead/new_player/pre_auth/proc/convert_to_authed()
	if(IsAdminAdvancedProcCall())
		log_admin_private("[key_name(usr)] attempted to auth bypass [key_name(src)]")
	var/mob/dead/new_player/authenticated/authed = new()
	authed.key = client.key
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
	GLOB.directory -= ckey
	key = new_key
	ckey = ckey(new_key)
	tgui_panel?.owner_ckey = ckey
	GLOB.authed_clients += src
	GLOB.directory[ckey] = src
	if(CONFIG_GET(flag/respect_upstream_bans) || CONFIG_GET(flag/respect_upstream_permabans))
		check_upstream_bans()
	client_pre_login()
	var/list/duplicate_result = check_duplicate_login()
	var/alert_mob_dupe_login = duplicate_result[1]
	var/alert_admin_multikey = duplicate_result[2]
	run_dupe_alerts(alert_mob_dupe_login, alert_admin_multikey)

	// Mob is ready
	// calls /mob/dead/new_player/authenticated/Login()
	// creates mind and such
	if(isnewplayer_preauth(mob))
		var/mob/dead/new_player/pre_auth/pre_auth_player = mob
		pre_auth_player.convert_to_authed()

	init_admin_if_present()
	add_verbs_from_config()
	get_message_output("watchlist entry", ckey)
	if(!ban_cache_start && SSban_cache?.query_started)
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(build_ban_cache), src)
	if(CONFIG_GET(flag/autoconvert_notes))
		convert_notes_sql(ckey)
	send_client_messages()
	check_ckey_redirects()
	src.add_verb(/client/verb/mentorhelp)
	src.add_verb(/client/verb/adminhelp)
	// send the new CKEY to telemetry
	tgui_panel.on_message("ready")
	// update stat if still initializing game
	mob.UpdateMobStat(TRUE)
