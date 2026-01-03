/datum/admin_player_panel
	var/selected_ckey
	COOLDOWN_DECLARE(update_cooldown)
	/// The text to filter players by, contains name, realname, previous names, job, and ckey
	var/search_text
	/// Seconds selected between updates, 0 is no auto-update
	var/update_interval = 5

/datum/admin_player_panel/ui_state(mob/user)
	return GLOB.admin_holder_state

/datum/admin_player_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		log_admin("[key_name(user)] checked the player panel.")
		search_text = null
		ui = new(user, src, "PlayerPanel", "Player Panel")
		ui.open()

/datum/admin_player_panel/ui_requires_update(mob/user, datum/tgui/ui)
	. = ..()
	if(.)
		return TRUE
	return update_interval ? COOLDOWN_FINISHED(src, update_cooldown) : FALSE

/datum/admin_player_panel/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/antag_hud)
	)

/datum/admin_player_panel/ui_static_data(mob/user)
	var/list/data = ..()
	data["metacurrency_name"] = CONFIG_GET(string/metacurrency_name)
	return data

/datum/admin_player_panel/ui_data(mob/user)
	if(update_interval)
		COOLDOWN_START(src, update_cooldown, max(update_interval, max(length(GLOB.player_list) / 5, 1)) SECONDS)
	var/list/data = ..()
	var/list/players = list()
	var/list/mobs = sortmobs()
	for(var/mob/player in mobs)
		if(!player.ckey)
			continue
		var/normal_ckey = replacetext(player.ckey, "@DC@", "", 1, 5)
		var/list/data_entry = list()
		if(isliving(player))
			if(iscarbon(player))
				if(ishuman(player))
					var/mob/living/carbon/human/tracked_human = player
					data_entry["job"] = player.job
					var/obj/item/card/id/I = tracked_human.wear_id?.GetID()
					if (I)
						data_entry["job"] = I.assignment ? I.assignment : player.job
						if(GLOB.crewmonitor.jobs[I.hud_state] != null)
							data_entry["ijob"] = GLOB.crewmonitor.jobs[I.hud_state]
				else
					data_entry["job"] = initial(player.name) // get the name of their mob type
			else if(issilicon(player))
				data_entry["job"] = player.job
			else
				data_entry["job"] = initial(player.name)
		else if(istype(player, /mob/dead/new_player/pre_auth))
			data_entry["job"] = "PREAUTH"
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
		var/ckey = ckey(normal_ckey)
		data_entry["ckey"] = ckey
		var/search_data = "[player.name] [player.real_name] [ckey] [data_entry["job"]] "
		var/datum/player_details/P = GLOB.player_details[ckey]
		// no using ?. or it breaks shit, it should be undefined, NOT NULL
		if(P)
			data_entry["previous_names"] = P.played_names
			search_data += P.played_names.Join(" ")
		if(player.client?.key_is_external && istype(player.client?.external_method))
			search_data += " [player.client.external_method.format_display_name(player.client.external_display_name)]"
		if(length(search_text) && !findtext(search_data, search_text)) // skip this player, not included in query
			continue
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
			if(player.client.key_is_external && istype(player.client.external_method))
				data_entry["external_method_id"] = player.client.external_method::id
				data_entry["external_method_name"] = player.client.external_method::name
				data_entry["external_display_name"] = player.client.external_display_name
				data_entry["formatted_external_display_name"] = player.client.external_method.format_display_name(player.client.external_display_name)
			if(CONFIG_GET(flag/use_exp_tracking) && player.client.prefs)
				data_entry["living_playtime"] = FLOOR(player.client.prefs.exp[EXP_TYPE_LIVING] / 60, 1)
			data_entry["telemetry"] = player.client.tgui_panel?.get_alert_level()
			data_entry["connected"] = TRUE
			if(ckey == selected_ckey)
				if(player.client.player_details)
					for(var/log_type in player.client.player_details.logging)
						var/list/log_type_data = list()
						var/list/log = player.client.player_details.logging[log_type]
						for(var/entry in log)
							log_type_data[entry] += html_decode(log[entry])
						data_entry["log_client"][log_type] = log_type_data
				data_entry["metacurrency_balance"] = player.client.get_metabalance_unreliable()
				data_entry["antag_tokens"] = player.client.get_antag_token_count_unreliable()
				data_entry["register_date"] = player.client.account_join_date
				data_entry["first_seen"] = player.client.player_join_date
				data_entry["ip"] = player.client.address
				data_entry["cid"] = player.client.computer_id
				data_entry["related_accounts_ip"] = player.client.related_accounts_ip
				data_entry["related_accounts_cid"] = player.client.related_accounts_cid
				if(player.client.byond_version)
					data_entry["byond_version"] = "[player.client.byond_version].[player.client.byond_build ? player.client.byond_build : "xxx"]"
		if(player.mind)
			data_entry["antag_hud"] = player.mind.antag_hud_icon_state
		if(ckey == selected_ckey)
			for(var/log_type in player.logging)
				var/list/log_type_data = list()
				var/list/log = player.logging[log_type]
				for(var/entry in log)
					log_type_data[entry] += html_decode(log[entry])
				data_entry["log_mob"][log_type] = log_type_data
			data_entry["is_cyborg"] = iscyborg(player)
			data_entry["mob_type"] = player.type
			data_entry["antag_rep"] = SSpersistence.antag_rep[ckey]
			if(ishuman(player))
				var/mob/living/carbon/human/tracked_human = player
				// no replacing ?. or I will end you
				if(tracked_human.dna?.species?.name)
					data_entry["species"] = tracked_human.dna.species.name
		players[ckey] = data_entry
	data["players"] = players
	data["selected_ckey"] = selected_ckey
	data["search_text"] = search_text
	data["update_interval"] = isnum_safe(update_interval) ? update_interval : 5
	return data

/datum/admin_player_panel/ui_act(action, params)
	. = ..()
	switch(action)
		if("update")
			return TRUE
		if("set_update_interval")
			update_interval = min(max(params["value"], 0), 120)
			return TRUE
		if("set_search_text")
			search_text = params["text"]
			return TRUE
		if("select_player")
			selected_ckey = params["who"]
			return TRUE
	var/mob/user = usr
	if(!istype(user) || !user.client || !user.client.holder)
		return
	var/datum/admins/holder = user.client.holder
	switch(action)
		if("jump_to")
			var/list/coords = params["coords"]
			if(!istype(coords) || length(coords) != 3)
				return
			var/can_ghost = TRUE
			if(!isobserver(usr))
				can_ghost = user.client.admin_ghost()
			if(!can_ghost)
				return
			user.client.jumptocoord(text2num(coords[1]), text2num(coords[2]), text2num(coords[3]))
		if("check_antagonists")
			if(!check_rights(R_ADMIN))
				return
			user.client.check_antagonists()
		if("check_silicon_laws")
			if(!check_rights(R_ADMIN))
				return
			holder.output_ai_laws()

	var/target_ckey = ckey(params["who"])
	var/client/target_client = GLOB.directory[target_ckey]
	switch(action)
		if("open_telemetry")
			if(target_client?.tgui_panel?.client)
				user.client.debug_variables(target_client.tgui_panel)
			else
				var/list/found = list()
				for(var/datum/tgui_panel/panel in GLOB.tgui_panels)
					if(panel.owner_ckey == target_ckey)
						found += "[REF(panel)]"
				if(!length(found))
					return
				var/choice = input(user, "Select matched telemetry") in found
				if(!choice)
					return
				var/datum/tgui_panel/selected = locate(choice)
				if(selected)
					user.client.debug_variables(selected)
				return
	var/mob/target_mob
	if(target_client)
		target_mob = target_client.mob
	else
		target_mob = get_mob_by_ckey(target_ckey)
	if(!target_mob)
		for(var/mob/M as() in GLOB.mob_list)
			if(M?.ckey == target_ckey)
				target_mob = M
	if(!target_mob)
		var/mob/disconnected_mob = GLOB.disconnected_mobs[target_ckey]
		if(disconnected_mob)
			target_mob = disconnected_mob
	if(!target_mob)
		return
	switch(action)
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
		if("kick")
			if(!check_rights(R_ADMIN))
				return
			holder.Topic(null, list("boot2" = REF(target_mob), "admin_token" = holder.href_token))
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
		if("force_cryo")
			if(!check_rights(R_ADMIN))
				return
			holder.Topic(null, list("force_cryo" = isliving(target_mob) ? REF(target_mob) : target_ckey, "admin_token" = holder.href_token))


/datum/admins/proc/open_player_panel()
	if(!check_rights())
		return
	if(!player_panel)
		player_panel = new(usr)
	player_panel.ui_interact(usr)

/datum/asset/spritesheet_batched/antag_hud
	name = "antag-hud"

/datum/asset/spritesheet_batched/antag_hud/create_spritesheets()
	var/datum/icon_transformer/transform = new()
	// Get the antag hud part
	transform.crop(24, 24, 32, 32)
	// Scale it up
	transform.scale(16, 16)

	for (var/icon_state_name in icon_states('icons/mob/hud.dmi'))
		insert_icon("antag-hud-[icon_state_name]", uni_icon('icons/mob/hud.dmi', icon_state_name, transform=transform))
