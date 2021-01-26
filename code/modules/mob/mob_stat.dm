#define MAX_ICONS_PER_TILE 50

/client
	var/stat_update_mode = STAT_FAST_UPDATE
	var/stat_update_time = 0
	var/selected_stat_tab = "Status"
	var/list/previous_stat_tabs

/*
 * Overrideable proc which gets the stat content for the selected tab.
 */
 //33.774 CPU time
/mob/proc/get_stat(selected_tab)
	if(IsAdminAdvancedProcCall())
		message_admins("[key_name(usr)] attempted to do something weird with the stat tab (Most likely attempting to exploit it to gain privillages).")
		log_game("[key_name(usr)] attempted to do something weird with the stat tab (Most likely attempting to exploit it to gain privillages).")
		return list()
	var/list/tab_data = list()
	var/requires_holder = FALSE
	switch(selected_tab)
		// ===== STATUS TAB =====
		if("Status")
			client.stat_update_mode = STAT_FAST_UPDATE
			tab_data = get_stat_tab_status()						// ~ 0.525 CPU Time [15000 CALLS] (Depends on which tabs are selected)
		// ===== MASTER CONTROLLER =====
		if("MC")
			client.stat_update_mode = STAT_FAST_UPDATE
			requires_holder = TRUE
			tab_data = get_stat_tab_master_controller()				// ~ 0.037 CPU Time [33 CALLS]
		// ===== ADMIN TICKETS =====
		if("Tickets")
			client.stat_update_mode = STAT_MEDIUM_UPDATE
			requires_holder = TRUE
			tab_data = GLOB.ahelp_tickets.stat_entry()				//  ~ 0 CPU Time [1 CALL]
		// ===== SDQL2 =====
		if("SDQL2")
			client.stat_update_mode = STAT_MEDIUM_UPDATE
			requires_holder = TRUE
			tab_data["Access Global SDQL2 List"] = list(
				text="VIEW VARIABLES (all)",
				action = "sdql2debug",
				type=STAT_BUTTON,
			)
			for(var/i in GLOB.sdql2_queries)
				var/datum/SDQL2_query/Q = i
				tab_data += Q.generate_stat()
		else
			// ===== NON CONSTANT TABS (Tab names which can change) =====
			// ===== LISTEDS TURFS =====
			if(listed_turf && listed_turf.name == selected_tab)
				client.stat_update_mode = STAT_MEDIUM_UPDATE
				var/list/overrides = list()
				for(var/image/I in client.images)
					if(I.loc && I.loc.loc == listed_turf && I.override)
						overrides += I.loc
				tab_data[REF(listed_turf)] = list(
					text="[listed_turf.name]",
					icon=SSstat.get_flat_icon(client, listed_turf),
					type=STAT_ATOM,
				)
				var/sanity = MAX_ICONS_PER_TILE
				for(var/atom/A in listed_turf)
					if(!A.mouse_opacity)
						continue
					if(A.invisibility > see_invisible)
						continue
					if(overrides.len && (A in overrides))
						continue
					if(A.IsObscured())
						continue
					sanity --
					tab_data[REF(A)] = list(
						text="[A.name]",
						icon=SSstat.get_flat_icon(client, A),
						type=STAT_ATOM,
					)
					if(sanity < 0)
						break
			var/list/all_verbs = get_all_verbs()								// ~0.252 CPU Time [14000 CALLS]
			if(selected_tab in all_verbs)
				client.stat_update_mode = STAT_SLOW_UPDATE
				for(var/verb in all_verbs[selected_tab])
					var/procpath/V = verb
					tab_data["[V.name]"] = list(
						action = "verb",
						params = list("verb" = V.name),
						type=STAT_VERB,
					)
			if(mind)
				tab_data += get_spell_stat_data(mind.spell_list, selected_tab)
			tab_data += get_spell_stat_data(mob_spell_list, selected_tab)
	if(requires_holder && !client.holder)
		message_admins("[ckey] attempted to access the [selected_tab] tab without sufficient rights.")
		log_admin("[ckey] attempted to access the [selected_tab] tab without sufficient rights.")
		return list()
	return tab_data

/mob/proc/get_all_verbs()
	var/list/all_verbs = list()
	//An annoying thing to mention:
	// list A [A: ["b", "c"]] +  (list B) [A: ["c", "d"]] will only have A from list B
	all_verbs += sorted_verbs
	for(var/i in client.sorted_verbs)
		if(i in all_verbs)
			all_verbs[i] += client.sorted_verbs[i]
		else
			all_verbs[i] = client.sorted_verbs[i]
	for(var/atom/A as() in contents)
		//As an optimisation we will make it so all verbs on objects will go into the object tab.
		//If you don't want this to happen change this.
		if(!all_verbs.Find("Object"))
			all_verbs["Object"] = list()
		all_verbs["Object"] += A.verbs
	return all_verbs

/*
 * Gets the stat tab contents for the status tab
 */
/mob/proc/get_stat_tab_status()
	var/list/tab_data = list()
	tab_data["Map"] = GENERATE_STAT_TEXT("[SSmapping.config?.map_name || "Loading..."]")
	var/datum/map_config/cached = SSmapping.next_map_config
	if(cached)
		tab_data["Next Map"] = GENERATE_STAT_TEXT(cached.map_name)
	tab_data["Round ID"] = GENERATE_STAT_TEXT("[GLOB.round_id ? GLOB.round_id : "Null"]")
	tab_data["Server Time"] = GENERATE_STAT_TEXT(time2text(world.timeofday,"YYYY-MM-DD hh:mm:ss"))
	tab_data["Round Time"] = GENERATE_STAT_TEXT(worldtime2text())
	tab_data["Station Time"] = GENERATE_STAT_TEXT(station_time_timestamp())
	tab_data["Time Dilation"] = GENERATE_STAT_TEXT("[round(SStime_track.time_dilation_current,1)]% AVG:([round(SStime_track.time_dilation_avg_fast,1)]%, [round(SStime_track.time_dilation_avg,1)]%, [round(SStime_track.time_dilation_avg_slow,1)]%)")
	tab_data["Players Connected"] = GENERATE_STAT_TEXT("[GLOB.clients.len]")
	if(SSshuttle.emergency)
		var/ETA = SSshuttle.emergency.getModeStr()
		if(ETA)
			tab_data[ETA] = GENERATE_STAT_TEXT(SSshuttle.emergency.getTimerStr())
	return tab_data

/mob/proc/get_stat_tab_master_controller()
	var/list/tab_data = list()
	var/turf/T = get_turf(client.eye)
	tab_data["Location"] = GENERATE_STAT_TEXT("[COORD(T)]")
	tab_data["CPU"] = GENERATE_STAT_TEXT("[world.cpu]")
	tab_data["Instances"] = GENERATE_STAT_TEXT("[num2text(world.contents.len, 10)]")
	tab_data["World Time"] = GENERATE_STAT_TEXT("[world.time]")
	tab_data += GLOB.stat_entry()
	tab_data += config.stat_entry()
	tab_data["divider_1"] = GENERATE_STAT_DIVIDER
	if(Master)
		tab_data += Master.stat_entry()
	else
		tab_data["Master Controller"] = GENERATE_STAT_TEXT("ERROR")
	if(Failsafe)
		tab_data += Failsafe.stat_entry()
	else
		tab_data["Failsafe Controller"] = GENERATE_STAT_TEXT("ERROR")
	if(Master)
		tab_data["divider_2"] = list(type=STAT_DIVIDER)
		for(var/datum/controller/subsystem/SS in Master.subsystems)
			tab_data += SS.stat_entry()
	tab_data += GLOB.cameranet.stat_entry()
	return tab_data

/*
 * Gets the stat tabs available to the user.
 * Contents of the stat tabs are got through get_stat()
 */
/mob/proc/get_stat_tabs()
	//Standard
	var/list/tabs = list(
		"Status",
	)
	//Listed turfs
	if(listed_turf && client)
		if(!TurfAdjacent(listed_turf))
			listed_turf = null
		else
			tabs |= listed_turf.name
	//Add spells
	var/list/spells = mob_spell_list
	if(mind)
		spells = mind.spell_list
	for(var/obj/effect/proc_holder/spell/S in spells)
		if(S.can_be_cast_by(src))
			tabs |= S.panel
	//Holder stat tabs
	if(client.holder)
		tabs |= "MC"
		tabs |= "Tickets"
		if(length(GLOB.sdql2_queries))
			tabs |= "SDQL2"
	var/list/additional_tabs = list()
	//Performance increase from only adding keys is better than adding values too.
	for(var/i in get_all_verbs())
		additional_tabs |= i
	additional_tabs = sortList(additional_tabs)
	//Get verbs
	tabs |= additional_tabs
	return tabs

/*
 * Called when a stat button is pressed.
 */
/mob/proc/stat_pressed(button_pressed, params)
	if(IsAdminAdvancedProcCall())
		message_admins("[key_name(usr)] called stat_pressed to potentially exploit the stat_pressed system.")
		log_game("[key_name(usr)] called stat_pressed to potentially exploit the stat_pressed system.")
		return
	switch(button_pressed)
		if("browsetickets")
			GLOB.ahelp_tickets.BrowseTickets(src)
		if("open_ticket")
			var/ticket_id = text2num(params["id"])
			var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(ticket_id)
			if(AH && client.holder)
				AH.ui_interact(src)
		if("atomClick")
			var/atomRef = params["ref"]
			var/atom/atom_actual = locate(atomRef)
			var/mob/actor = client.mob
			if(!atom_actual)
				return
			if(client.keys_held["Alt"])
				actor.AltClickOn(atom_actual)
			else if(client.keys_held["Ctrl"])
				actor.CtrlClickOn(atom_actual)
			else if(client.keys_held["Shift"])
				actor.ShiftClickOn(atom_actual)
			else
				actor.ClickOn(atom_actual)
		if("statClickDebug")
			var/targetRef = params["targetRef"]
			var/class = params["class"]
			var/target = locate(targetRef)
			if(!usr.client.holder)
				message_admins("[usr.client] attempted to interact with the MC without sufficient perms.")
				return
			if(!target)
				to_chat(usr, "<span class='warning'>Could not locate target, report this!</span>")
				log_runtime("[usr] attempted to interact with a statClickDebug, but was unsuccessful due to the target not existing.")
				return
			usr.client.debug_variables(target)
			message_admins("Admin [key_name_admin(usr)] is debugging the [target] [class].")
		if("verb")
			var/verb_name = params["verb"]
			winset(client, null, "command=[replacetext(verb_name, " ", "-")]")
		if("sdql2debug")
			client.debug_variables(GLOB.sdql2_queries)
		if("sdql2delete")
			var/query_id = params["qid"]
			var/datum/SDQL2_query/query = sdqlQueryByID(text2num(query_id))
			if(query)
				query.delete_click()
		if("sdql2toggle")
			var/query_id = params["qid"]
			var/datum/SDQL2_query/query = sdqlQueryByID(text2num(query_id))
			if(query)
				query.action_click()

/*
 * Sets the current stat tab selected.
 */
/mob/proc/set_stat_tab(new_tab)
	client.selected_stat_tab = new_tab
	//Tell tgui panel to update our tab
	client.tgui_panel.set_stat_tab(new_tab)

/*
 * Updates the tab info for the selected tab.
 */
/mob/proc/update_stat_tabs(tabs)
	client.previous_stat_tabs = tabs
	//Tell tgui panel to udpate our data
	client.tgui_panel.set_tab_info(tabs)

/*
 * Called when the tab is changed.
 */
/mob/proc/stat_tab_changed()
	client.stat_update_time = client.stat_update_mode

/**
  * Output an update to the stat panel for the client
  *
  * calculates client ping, round id, server time, time dilation and other data about the round
  * and puts it in the mob status panel on a regular loop
  */
/mob/proc/UpdateMobStat(forced = FALSE)
	if(!client.tgui_panel)
		return
	//It would be nice if we could have things not update,
	//But if the stat panel gets reloaded through fix-chat
	//or other means then nothing will ever appear in the panel.
	if(client.stat_update_time > 0 && !forced)
		client.stat_update_time --
		return
	client.stat_update_time = client.stat_update_mode

	var/list/stat_tabs = get_stat_tabs()
	if(client.previous_stat_tabs != stat_tabs)
		update_stat_tabs(stat_tabs)
	if(!(client.selected_stat_tab in stat_tabs))
		set_stat_tab(stat_tabs[1])
	var/list/status_data = get_stat(client.selected_stat_tab)
	client.tgui_panel.set_panel_infomation(status_data)

#undef MAX_ICONS_PER_TILE
