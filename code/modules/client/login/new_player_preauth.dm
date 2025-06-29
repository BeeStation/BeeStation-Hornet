/mob/dead/new_player/pre_auth/proc/convert_to_authed()
	if(IsAdminAdvancedProcCall())
		log_admin_private("[key_name(usr)] attempted to auth bypass [key_name(src)] via convert_to_authed()")
		return
	if(QDELETED(client))
		qdel(src)
		return
	var/mob/dead/new_player/authenticated/authed = new()
	var/key = client.key
	var/datum/tgui/login_window = SStgui.get_open_ui(src, client.tgui_login)
	if(istype(login_window) && login_window.window?.id)
		SStgui.force_close_window(src, login_window.window.id)
	SStgui.on_transfer(src, authed)
	authed.name = client.display_name()
	authed.key = key
	if(istype(login_window) && login_window.window?.id)
		SStgui.force_close_window(authed, login_window.window.id)
	qdel(src)

/mob/dead/new_player/pre_auth/vv_edit_var(var_name, var_value)
	return FALSE

/mob/dead/new_player/pre_auth/Logout()
	..()
	key = null
	qdel(src)

/mob/dead/new_player/should_show_chat_message(atom/movable/speaker, datum/language/message_language, is_emote, is_heard)
	return CHATMESSAGE_CANNOT_HEAR

/mob/dead/new_player/get_stat_tab_status()
	var/list/tab_data = ..()
	if(src.client && CONFIG_GET(flag/enable_guest_external_auth))
		if(src.client.logged_in)
			if(src.client.key_is_external)
				tab_data["CKEY"] = GENERATE_STAT_TEXT(src.client.ckey)
				if(istype(src.client.external_method))
					tab_data["Authentication Method"] = GENERATE_STAT_TEXT(src.client.external_method::name)
					tab_data["Display Name"] = GENERATE_STAT_TEXT(src.client.external_method.format_display_name(src.client.external_display_name))
			else
				tab_data["CKEY"] = GENERATE_STAT_TEXT(src.client.key)
		else
			tab_data["CKEY"] = GENERATE_STAT_TEXT("Please log in!")
	return tab_data
