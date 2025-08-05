/proc/transfer_preauthenticated_player_mob(mob/source, mob/target)
	if(IsAdminAdvancedProcCall())
		log_admin_private("[key_name(usr)] attempted to auth bypass [key_name(source)] via transfer_preauthenticated_player_mob()")
		return
	if(isnewplayer(source) && QDELETED(source.client))
		qdel(source)
		return
	if(!ismob(target))
		target = new /mob/dead/new_player/authenticated()
	var/key = source.client.key
	var/datum/tgui/login_window = SStgui.get_open_ui(source, source.client.tgui_login)
	if(istype(login_window) && login_window.window?.id)
		SStgui.force_close_window(source, login_window.window.id)
	SStgui.on_transfer(source, target)
	if(isnewplayer(target))
		target.name = source.client.display_name()
	target.key = key
	if(istype(login_window) && login_window.window?.id)
		SStgui.force_close_window(target, login_window.window.id)
	if(isnewplayer(source))
		qdel(source)

/mob/dead/new_player/pre_auth/vv_edit_var(var_name, var_value)
	return FALSE

/mob/dead/new_player/pre_auth/Logout()
	..()
	key = null
	qdel(src)

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
