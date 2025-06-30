/client/verb/use_token(token as text)
	set name = "Manual Token Entry"
	set category = "Login"
	login_with_token(token)

/client/verb/get_token()
	set name = "Manual Login"
	set category = "Login"
	var/list/method_ids = CONFIG_GET(keyed_list/external_auth_method)
	if(length(method_ids) == 1)
		for(var/method_id in method_ids)
			login_with_method(GLOB.login_methods[method_id])
			break
	else if(length(method_ids) > 1)
		var/selected_item = input(src, "Select login method", "Login") as null|anything in method_ids
		if(!(selected_item in method_ids))
			return
		login_with_method(GLOB.login_methods[selected_item])
	else
		to_chat_immediate(src, span_danger("No authentication methods have been configured!"))

/client/verb/open_login()
	set name = "Log In"
	set category = "Login"
	tgui_login?.open()

/client/proc/log_out()
	set name = "Log Out and Disconnect"
	set category = "Login"
	if(!istype(external_method))
		to_chat(src, span_bad("You did not sign in with any external login method!"))
		return
	if(tgui_alert(src.mob, "You will be disconnected from the game and all session tokens will be revoked.", "Are you sure?", list("Yes", "Cancel")) != "Yes")
		return
	clear_saved_session_token()
	to_chat_immediate(src, span_userdanger("You have been logged out. Your client has been disconnected from the game."))
	db_invalidate_all_sessions_for(src.external_method, src.external_uid)
	spawn(5)
		qdel(src)
