/datum/admin_player_panel
	var/selected_ckey
	var/use_view = FALSE
	// Map stuff
	var/atom/movable/screen/map_view/cam_screen
	var/list/cam_plane_masters
	var/atom/movable/screen/background/cam_background
	var/renderLighting = FALSE
	var/map_name
	var/last_update_loc
	var/map_range = 1
	// Icon stuff
	var/list/cached_mob_icons = list()
	/// Updates every max(population / 5, 5) seconds
	COOLDOWN_DECLARE(update_cooldown)
	/// The text to filter players by, contains name, realname, previous names, job, and ckey
	var/search_text

/datum/admin_player_panel/New(user)
	if(!user)
		return
	setup(user)

/datum/admin_player_panel/proc/setup(user)
	var/client/user_client
	if (istype(user, /client))
		var/client/C = user
		user_client = C
	else if(istype(user, /mob))
		var/mob/M = user
		user_client = M.client
	else
		return
	if(map_name)
		user_client.clear_map(map_name)

	map_name = "admin_player_panel_[REF(src)]_map"
	// Initialize map objects
	cam_screen = new
	cam_screen.name = "screen"
	cam_screen.assigned_map = map_name
	cam_screen.del_on_map_removal = FALSE
	cam_screen.screen_loc = "[map_name]:1,1"
	cam_plane_masters = list()
	for(var/plane in subtypesof(/atom/movable/screen/plane_master))
		var/atom/movable/screen/instance = new plane()
		if (!renderLighting && instance.plane == LIGHTING_PLANE)
			instance.alpha = 100
		instance.assigned_map = map_name
		instance.del_on_map_removal = FALSE
		instance.screen_loc = "[map_name]:CENTER"
		cam_plane_masters += instance
	cam_background = new
	cam_background.assigned_map = map_name
	cam_background.del_on_map_removal = FALSE

/datum/admin_player_panel/process()
	refresh_view()

/datum/admin_player_panel/proc/refresh_view(force = FALSE)
	if(!cam_screen)
		setup(usr)
	if(!selected_ckey || !use_view)
		return
	var/client/target_client = GLOB.directory[selected_ckey]
	var/mob/target_mob
	if(target_client)
		target_mob = target_client.mob
	else
		target_mob = get_mob_by_ckey(selected_ckey)
	if(!target_mob)
		for(var/mob/M as() in GLOB.mob_list)
			if(M?.ckey == selected_ckey)
				target_mob = M
	if(!istype(target_mob))
		return
	if(isAI(target_mob))
		var/mob/living/silicon/ai/ai_mob = target_mob
		target_mob = ai_mob.eyeobj
	var/turf/current_turf = get_turf(target_mob)
	if(REF(current_turf) == last_update_loc && !force)
		return // no changes
	last_update_loc = REF(current_turf)
	var/list/turf/visible_turfs = list()
	for(var/turf/vis in range(map_range, target_mob))
		visible_turfs += vis
	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	var/size_x = bbox[3] - bbox[1] + 1
	var/size_y = bbox[4] - bbox[2] + 1

	cam_screen.vis_contents = visible_turfs
	cam_background.icon_state = "clear"
	cam_background.fill_rect(1, 1, size_x, size_y)

/datum/admin_player_panel/proc/set_use_view(do_use_view)
	if(!do_use_view && use_view)
		usr?.client?.clear_map(map_name)
		STOP_PROCESSING(SSprocessing, src)
	if(do_use_view && !use_view)
		usr?.client.register_map_obj(cam_screen)
		for(var/plane in cam_plane_masters)
			usr?.client.register_map_obj(plane)
		usr?.client.register_map_obj(cam_background)
		START_PROCESSING(SSprocessing, src)
	use_view = !!do_use_view

/datum/admin_player_panel/ui_close(mob/user)
	. = ..()
	user.client?.clear_map(map_name)
	STOP_PROCESSING(SSprocessing, src)

/datum/admin_player_panel/ui_state(mob/user)
	return GLOB.admin_holder_state

/datum/admin_player_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		log_admin("[key_name(user)] checked the player panel.")
		ui = new(user, src, "PlayerPanel", "Player Panel")
		ui.open()
		if(use_view)
			refresh_view()
			user.client.register_map_obj(cam_screen)
			for(var/plane in cam_plane_masters)
				user.client.register_map_obj(plane)
			user.client.register_map_obj(cam_background)
			START_PROCESSING(SSprocessing, src)

/datum/admin_player_panel/Destroy()
	usr?.client?.clear_map(map_name)
	QDEL_NULL(cam_screen)
	QDEL_LIST(cam_plane_masters)
	QDEL_NULL(cam_background)
	..()

/datum/admin_player_panel/ui_requires_update(mob/user, datum/tgui/ui)
	. = ..()
	if(.)
		return TRUE
	return COOLDOWN_FINISHED(src, update_cooldown)

/datum/admin_player_panel/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/antag_hud)
	)

/datum/admin_player_panel/ui_static_data(mob/user)
	var/list/data = ..()
	data["mapRef"] = map_name
	data["metacurrency_name"] = CONFIG_GET(string/metacurrency_name)
	return data

/datum/admin_player_panel/ui_data(mob/user)
	COOLDOWN_START(src, update_cooldown, max(length(GLOB.player_list) / 5, 5) SECONDS)
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
		var/search_data = "[player.name] [player.real_name] [ckey] [data_entry["job"]] "
		// no using ?. or it breaks shit, it should be undefined, NOT NULL
		if(P)
			data_entry["previous_names"] = P.played_names
			search_data += P.played_names.Join(" ")
		if(length(search_text) && !findtextEx(search_data, search_text)) // skip this player, not included in query
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
			if(CONFIG_GET(flag/use_exp_tracking) && player.client.prefs)
				data_entry["living_playtime"] = FLOOR(player.client.prefs.exp[EXP_TYPE_LIVING] / 60, 1)
			data_entry["telemetry"] = player.client.tgui_panel?.get_alert_level()
			data_entry["connected"] = TRUE
			if(ckey == selected_ckey)
				for(var/log_type in player.client.player_details.logging)
					var/list/log_type_data = list()
					var/list/log = player.client.player_details.logging[log_type]
					for(var/entry in log)
						log_type_data[entry] += log[entry]
					data_entry["log_client"][log_type] = log_type_data
				data_entry["metacurrency_balance"] = player.client.get_metabalance()
				data_entry["antag_tokens"] = player.client.get_antag_token_count()
				data_entry["register_date"] = player.client.account_join_date
				data_entry["first_seen"] = player.client.player_join_date
				data_entry["ip"] = player.client.address
				data_entry["cid"] = player.client.computer_id
				data_entry["related_accounts_ip"] = player.client.related_accounts_ip
				data_entry["related_accounts_cid"] = player.client.related_accounts_cid
				if(player.client.byond_version)
					data_entry["byond_version"] = "[player.client.byond_version].[player.client.byond_build ? player.client.byond_build : "xxx"]"
				if(!(REF(player) in cached_mob_icons))
					var/icon/I = getFlatIcon(player, defdir = SOUTH, no_anim = TRUE)
					if(I)
						var/uid = rand(1, 999)
						user << browse_rsc(I, "playerpanel_img_[REF(player)][uid].png")
						cached_mob_icons[REF(player)] = uid // this uid does a rerender in TGUI, otherwise it doesn't know it updated
				if(REF(player) in cached_mob_icons)
					var/uid = cached_mob_icons[REF(player)]
					data_entry["photo_path"] = "playerpanel_img_[REF(player)][uid].png"
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
			data_entry["antag_rep"] = SSpersistence.antag_rep[ckey]
		players[ckey] = data_entry
	data["players"] = players
	data["selected_ckey"] = selected_ckey
	data["map_range"] = map_range
	data["use_view"] = use_view
	data["search_text"] = search_text
	return data

/datum/admin_player_panel/ui_act(action, params)
	. = ..()
	switch(action)
		if("set_search_text")
			search_text = params["text"]
			return TRUE
		if("set_map_range")
			map_range = min(max(params["range"], 0), 5)
			refresh_view(force = TRUE)
			return TRUE
		if("select_player")
			selected_ckey = params["who"]
			refresh_view()
			return TRUE
		if("set_use_view")
			set_use_view(!!params["value"])
		if("refresh_view")
			setup(usr)
			refresh_view(force = TRUE)
			return TRUE
		if("reload_images")
			cached_mob_icons.Cut()
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


/datum/admins/proc/player_panel_new()//The new one
	if(!check_rights())
		return
	var/choice = alert(usr, "Legacy or TM Candidate?", "Player Panel Selection", "Legacy", "TM Candidate")
	if(choice == "Legacy")
		player_panel_legacy()
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




// ---------- LEGACY PANEL -----------
// FOR USE DURING TESTMERGE

/datum/admins/proc/player_panel_legacy()
	if(!check_rights())
		return
	log_admin("[key_name(usr)] checked the player panel.")
	var/dat = "<html><head><meta http-equiv='X-UA-Compatible' content='IE=edge; charset=UTF-8'/><title>Player Panel</title></head>"

	//javascript, the part that does most of the work~
	dat += {"
		<head>
			<script type='text/javascript'>
				var locked_tabs = new Array();
				function updateSearch(){
					var filter_text = document.getElementById('filter');
					var filter = filter_text.value.toLowerCase();
					if(complete_list != null && complete_list != ""){
						var mtbl = document.getElementById("maintable_data_archive");
						mtbl.innerHTML = complete_list;
					}
					if(filter.value == ""){
						return;
					}else{
						var maintable_data = document.getElementById('maintable_data');
						var ltr = maintable_data.getElementsByTagName("tr");
						for ( var i = 0; i < ltr.length; ++i )
						{
							try{
								var tr = ltr\[i\];
								if(tr.getAttribute("id").indexOf("data") != 0){
									continue;
								}
								var ltd = tr.getElementsByTagName("td");
								var td = ltd\[0\];
								var lsearch = td.getElementsByClassName("filter_data");
								var search = lsearch\[0\];
								if ( search.innerText.toLowerCase().indexOf(filter) == -1 )
								{
									tr.innerHTML = "";
									i--;
								}
							}catch(err) {   }
						}
					}
					var count = 0;
					var index = -1;
					var debug = document.getElementById("debug");
					locked_tabs = new Array();
				}
				function expand(id,job,name,real_name,old_names,key,ip,antagonist,ref){
					clearAll();
					var span = document.getElementById(id);
					var ckey = key.toLowerCase().replace(/\[^a-z@0-9\]+/g,"");
					body = "<table><tr><td>";
					body += "</td><td align='center'>";
					body += "<font size='2'><b>"+job+" "+name+"</b><br><b>Real name "+real_name+"</b><br><b>Played by "+key+" ("+ip+")</b><br><b>Old names :"+old_names+"</b></font>";
					body += "</td><td align='center'>";
					body += "<a href='?_src_=holder;[HrefToken()];adminplayeropts="+ref+"'>PP</a> - "
					body += "<a href='?_src_=holder;[HrefToken()];showmessageckey="+ckey+"'>N</a> - "
					body += "<a href='?_src_=vars;[HrefToken()];Vars="+ref+"'>VV</a> - "
					body += "<a href='?_src_=holder;[HrefToken()];traitor="+ref+"'>TP</a> - "
					if (job == "Cyborg")
						body += "<a href='?_src_=holder;[HrefToken()];borgpanel="+ref+"'>BP</a> - "
					body += "<a href='?priv_msg="+ckey+"'>PM</a> - "
					body += "<a href='?_src_=holder;[HrefToken()];subtlemessage="+ref+"'>SM</a> - "
					body += "<a href='?_src_=holder;[HrefToken()];adminplayerobservefollow="+ref+"'>FLW</a> - "
					body += "<a href='?_src_=holder;[HrefToken()];individuallog="+ref+"'>LOGS</a><br>"
					if(antagonist > 0)
						body += "<font size='2'><a href='?_src_=holder;[HrefToken()];check_antagonist=1'><font color='red'><b>Antagonist</b></font></a></font>";
					body += "</td></tr></table>";
					span.innerHTML = body
				}
				function clearAll(){
					var spans = document.getElementsByTagName('span');
					for(var i = 0; i < spans.length; i++){
						var span = spans\[i\];
						var id = span.getAttribute("id");
						if(!id || !(id.indexOf("item")==0))
							continue;
						var pass = 1;
						for(var j = 0; j < locked_tabs.length; j++){
							if(locked_tabs\[j\]==id){
								pass = 0;
								break;
							}
						}
						if(pass != 1)
							continue;
						span.innerHTML = "";
					}
				}
				function addToLocked(id,link_id,notice_span_id){
					var link = document.getElementById(link_id);
					var decision = link.getAttribute("name");
					if(decision == "1"){
						link.setAttribute("name","2");
					}else{
						link.setAttribute("name","1");
						removeFromLocked(id,link_id,notice_span_id);
						return;
					}
					var pass = 1;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 0;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs.push(id);
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "<font color='red'>Locked</font> ";
				}
				function attempt(ab){
					return ab;
				}
				function removeFromLocked(id,link_id,notice_span_id){
					//document.write("a");
					var index = 0;
					var pass = 0;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 1;
							index = j;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs\[index\] = "";
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "";
				}
				function selectTextField(){
					var filter_text = document.getElementById('filter');
					filter_text.focus();
					filter_text.select();
				}
			</script>
		</head>
	"}

	//body tag start + onload and onkeypress (onkeyup) javascript event calls
	dat += "<body onload='selectTextField(); updateSearch();' onkeyup='updateSearch();'>"

	//title + search bar
	dat += {"
		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable'>
			<tr id='title_tr'>
				<td align='center'>
					<font size='5'><b>Player panel</b></font><br>
					Hover over a line to see more information - <a href='?_src_=holder;[HrefToken()];check_antagonist=1'>Check antagonists</a> - Kick <a href='?_src_=holder;[HrefToken()];kick_all_from_lobby=1;afkonly=0'>everyone</a>/<a href='?_src_=holder;[HrefToken()];kick_all_from_lobby=1;afkonly=1'>AFKers</a> in lobby
					<p>
				</td>
			</tr>
			<tr id='search_tr'>
				<td align='center'>
					<b>Search:</b> <input type='text' id='filter' value='' style='width:300px;'>
				</td>
			</tr>
	</table>
	"}

	//player table header
	dat += {"
		<span id='maintable_data_archive'>
		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable_data'>"}

	var/list/mobs = sortmobs()
	var/i = 1
	for(var/mob/M in mobs)
		if(M.ckey)

			var/color = "#e6e6e6"
			if(i%2 == 0)
				color = "#f2f2f2"
			var/is_antagonist = is_special_character(M)

			var/M_job = ""

			if(isliving(M))

				if(iscarbon(M)) //Carbon stuff
					if(ishuman(M))
						M_job = M.job
					else if(ismonkey(M))
						M_job = "Monkey"
					else if(isalien(M)) //aliens
						if(islarva(M))
							M_job = "Alien larva"
						else
							M_job = ROLE_ALIEN
					else
						M_job = "Carbon-based"

				else if(issilicon(M)) //silicon
					if(isAI(M))
						M_job = JOB_NAME_AI
					else if(ispAI(M))
						M_job = ROLE_PAI
					else if(iscyborg(M))
						M_job = JOB_NAME_CYBORG
					else
						M_job = "Silicon-based"

				else if(isanimal(M)) //simple animals
					if(iscorgi(M))
						M_job = "Corgi"
					else if(isslime(M))
						M_job = "slime"
					else
						M_job = "Animal"

				else
					M_job = "Living"

			else if(isnewplayer(M))
				M_job = "New player"

			else if(isobserver(M))
				var/mob/dead/observer/O = M
				if(O.started_as_observer)//Did they get BTFO or are they just not trying?
					M_job = "Observer"
				else
					M_job = "Ghost"

			var/M_name = html_encode(M.name)
			var/M_rname = html_encode(M.real_name)
			var/M_key = html_encode(M.key)
			var/previous_names = ""
			if(M_key)
				var/datum/player_details/P = GLOB.player_details[ckey(M_key)]
				if(P)
					previous_names = P.played_names.Join(",")
			previous_names = html_encode(previous_names)

			//output for each mob
			dat += {"
				<tr id='data[i]' name='[i]' onClick="addToLocked('item[i]','data[i]','notice_span[i]')">
					<td align='center' bgcolor='[color]'>
						<span id='notice_span[i]'></span>
						<a id='link[i]'
						onmouseover='expand("item[i]","[M_job]","[M_name]","[M_rname]","[previous_names]","[M_key]","[M.lastKnownIP]",[is_antagonist],"[REF(M)]")'
						>
						<b id='search[i]'>[M_name] - [M_rname] - [M_key] ([M_job])</b>
						<span hidden class='filter_data'>[M_name] [M_rname] [M_key] [M_job] [previous_names]</span>
						</a>
						<br><span id='item[i]'></span>
					</td>
				</tr>
			"}

			i++


	//player table ending
	dat += {"
		</table>
		</span>
		<script type='text/javascript'>
			var maintable = document.getElementById("maintable_data_archive");
			var complete_list = maintable.innerHTML;
		</script>
	</body></html>
	"}

	usr << browse(dat, "window=players;size=600x480")
