/datum/admin_player_panel
	var/selected_ckey
	// Map stuff
	var/atom/movable/screen/map_view/cam_screen
	var/map_name

/datum/admin_player_panel/New(user)
	if(!user)
		return
	setup(user)

/datum/admin_player_panel/proc/setup(user)
	var/client/user_client
	if (istype(user, /client))
		var/client/C = user
		user_client = C
	else
		var/mob/M = user
		user_client = M.client

	if(map_name)
		user_client.clear_map(map_name)

	map_name = "admin_player_panel_[REF(src)]_map"
	// Initialize map objects
	cam_screen = new
	cam_screen.name = "screen"
	cam_screen.assigned_map = map_name
	cam_screen.del_on_map_removal = FALSE
	cam_screen.screen_loc = "[map_name]:1,1"

/datum/admin_player_panel/proc/refresh_view()
	if(!cam_screen)
		setup(usr)
	if(!selected_ckey)
		return
	var/client/target_client = GLOB.directory[selected_ckey]
	var/mob/target_mob = target_client?.mob || get_mob_by_ckey(selected_ckey)
	if(!istype(target_mob))
		return
	if(isAI(target_mob))
		var/mob/living/silicon/ai/ai_mob = target_mob
		target_mob = ai_mob.eyeobj
	if(QDELETED(target_mob))
		return
	if(!(target_mob in cam_screen.vis_contents))
		cam_screen.vis_contents = list(target_mob)
		RegisterSignal(target_mob, COMSIG_PARENT_QDELETING, .proc/target_deleting)

/datum/admin_player_panel/proc/target_deleting(atom/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)
	cam_screen.vis_contents.Cut()
	refresh_view()

/datum/admin_player_panel/ui_close(mob/user)
	. = ..()
	user.client?.clear_map(map_name)

/datum/admin_player_panel/ui_state(mob/user)
	return GLOB.admin_holder_state

/datum/admin_player_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		log_admin("[key_name(user)] checked the player panel.")
		ui = new(user, src, "PlayerPanel", "Player Panel")
		ui.set_autoupdate(TRUE)
		ui.open()
		user.client.register_map_obj(cam_screen)

/datum/admin_player_panel/Destroy()
	usr?.client?.clear_map(map_name)
	QDEL_NULL(cam_screen)
	..()

/datum/admin_player_panel/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/antag_hud)
	)

/datum/admin_player_panel/ui_static_data(mob/user)
	var/list/data = ..()
	data["mapRef"] = map_name
	return data

/datum/admin_player_panel/ui_data(mob/user)
	var/list/data = ..()
	var/list/players = list()
	var/list/mobs = sortmobs()
	for(var/mob/player in mobs)
		if(!player.ckey)
			continue
		var/list/data_entry = list()
		if(isliving(player))
			if(iscarbon(player))
				if(ishuman(player))
					data_entry["job"] = player.job
				else
					data_entry["job"] = initial(player.name) // get the name of their mob type
			else if(issilicon(player))
				data_entry["job"] = player.job
			else
				data_entry["job"] = initial(player.name)
		else if(isnewplayer(player))
			data_entry["job"] = "New Player"
		else if(isobserver(player))
			var/mob/dead/observer/O = player
			if(O.started_as_observer)
				data_entry["job"] = "Observer"
			else
				data_entry["job"] = "Ghost"
		else
			data_entry["job"] = initial(player.name)

		data_entry["name"] = player.name
		data_entry["real_name"] = player.real_name
		var/ckey = ckey(player.ckey)
		data_entry["ckey"] = ckey
		var/datum/player_details/P = GLOB.player_details[ckey]
		data_entry["previous_names"] = P?.played_names
		data_entry["last_ip"] = player.lastKnownIP
		data_entry["is_antagonist"] = is_special_character(player)
		if(ishuman(player))
			var/mob/living/carbon/human/tracked_human = player
			data_entry["oxydam"] = round(tracked_human.getOxyLoss(), 1)
			data_entry["toxdam"] = round(tracked_human.getToxLoss(), 1)
			data_entry["burndam"] = round(tracked_human.getFireLoss(), 1)
			data_entry["brutedam"] = round(tracked_human.getBruteLoss(), 1)
		else if(isliving(player))
			var/mob/living/tracked_living = player
			data_entry["health"] = tracked_living.health
			data_entry["health_max"] = tracked_living.getMaxHealth()
		var/turf/pos = get_turf(player)
		data_entry["position"] = AREACOORD(pos)
		data_entry["has_mind"] = istype(player.mind)
		data_entry["connected"] = FALSE
		data_entry["telemetry"] = "DC"
		data_entry["log_mob"] = list()
		data_entry["log_client"] = list()
		// do not convert to ?., since that makes null while TGUI expects undefined
		if(player.client)
			if(CONFIG_GET(flag/use_exp_tracking) && player.client.prefs)
				data_entry["living_playtime"] = player.client.prefs.exp[EXP_TYPE_LIVING]
			data_entry["telemetry"] = player.client.tgui_panel?.get_alert_level()
			data_entry["connected"] = TRUE
			if(ckey == selected_ckey)
				for(var/log_type in player.client.player_details.logging)
					var/list/log_type_data = list()
					var/list/log = player.client.player_details.logging[log_type]
					for(var/entry in log)
						log_type_data[entry] += log[entry]
					data_entry["log_client"][log_type] = log_type_data
				data_entry["register_date"] = player.client.account_join_date
				data_entry["first_seen"] = player.client.player_join_date
				data_entry["related_accounts_ip"] = player.client.related_accounts_ip
				data_entry["related_accounts_cid"] = player.client.related_accounts_cid
		if(player.mind)
			data_entry["antag_hud"] = player.mind.antag_hud_icon_state
		if(ckey == selected_ckey)
			for(var/log_type in player.logging)
				var/list/log_type_data = list()
				var/list/log = player.logging[log_type]
				for(var/entry in log)
					log_type_data[entry] += log[entry]
				data_entry["log_mob"][log_type] = log_type_data
			data_entry["is_cyborg"] = iscyborg(player)
			data_entry["mob_type"] = player.type
		players[ckey] = data_entry
	data["players"] = players
	data["selected_ckey"] = selected_ckey
	refresh_view()
	return data

/datum/admin_player_panel/ui_act(action, params)
	. = ..()
	if(action == "select_player")
		selected_ckey = params["who"]
		return TRUE
	var/mob/user = usr
	if(!istype(user) || !user.client || !user.client.holder)
		return
	var/datum/admins/holder = user.client.holder
	var/target_ckey = ckey(params["who"])
	var/client/target_client = GLOB.directory[target_ckey]
	var/mob/target_mob
	if(target_client)
		target_mob = target_client.mob
	else
		target_mob = get_mob_by_ckey(target_ckey)
	if(!target_mob)
		return
	switch(action)
		if("open_telemetry")
			if(target_client)
				user.client.debug_variables(target_client.tgui_panel)
		if("open_player_panel")
			holder.show_player_panel(target_mob)
		if("open_hours")
			if(target_client)
				holder.cmd_show_exp_panel(target_client)
		if("open_traitor_panel")
			if(!check_rights(R_ADMIN))
				return
			holder.show_traitor_panel(target_mob)
		if("pm")
			user.client.cmd_admin_pm(target_ckey, null)
		if("open_view_variables")
			user.client.debug_variables(target_mob)
		if("follow")
			holder.admin_follow(target_mob)
		if("open_notes")
			if(!check_rights(R_ADMIN))
				return
			browse_messages(target_ckey = target_ckey, agegate = FALSE)
		if("subtle_message")
			if(!check_rights(R_ADMIN))
				return
			user.client.cmd_admin_subtle_message(target_mob)
		if("headset_message")
			if(!check_rights(R_ADMIN))
				return
			user.client.cmd_admin_headset_message(target_mob)
		if("narrate_to")
			if(!check_rights(R_ADMIN))
				return
			user.client.cmd_admin_direct_narrate(target_mob)
		if("open_ban")
			holder.ban_panel(target_ckey, target_client?.address, target_client?.computer_id)
		if("open_logs")
			show_individual_logging_panel(target_mob)
		if("smite")
			if(!check_rights(R_ADMIN|R_FUN))
				return
			user.client.smite(target_mob)
		if("init_mind")
			if(!check_rights(R_ADMIN))
				return
			if(target_mob.mind)
				to_chat(user, "This can only be used on instances on mindless mobs")
				return
			target_mob.mind_initialize()
		if("open_cyborg_panel")
			if(!check_rights(R_ADMIN))
				return
			if(!iscyborg(target_mob))
				to_chat(user, "This can only be used on cyborgs")
			else
				holder.open_borgopanel(target_mob)
		if("open_language_panel")
			if(!check_rights(R_ADMIN))
				return
			var/datum/language_holder/H = target_mob.get_language_holder()
			H.open_language_menu(user)
		if("open_centcom_bans_database")
			if(!check_rights(R_ADMIN))
				return
			holder.Topic(null, list("centcomlookup" = target_ckey, "admin_token" = holder.href_token))
		if("revive")
			if(!check_rights(R_ADMIN))
				return
			holder.Topic(null, list("revive" = REF(target_mob), "admin_token" = holder.href_token))
		if("jail")
			if(!check_rights(R_ADMIN))
				return
			holder.Topic(null, list("sendtoprison" = REF(target_mob), "admin_token" = holder.href_token))
		if("send_to_lobby")
			if(!check_rights(R_ADMIN))
				return
			holder.Topic(null, list("sendbacktolobby" = REF(target_mob), "admin_token" = holder.href_token))


/datum/admins/proc/player_panel_new()//The new one
	if(!check_rights())
		return
	if(!player_panel)
		player_panel = new(usr)
	player_panel.ui_interact(usr)

/datum/asset/spritesheet/antag_hud
	name = "antag-hud"

/datum/asset/spritesheet/antag_hud/register()
	var/icon/I = icon('icons/mob/hud.dmi')
	// Get the antag hud part
	I.Crop(24, 24, 32, 32)
	// Scale it up
	I.Scale(16, 16)
	InsertAll("antag-hud", I)
	..()
