/client
	var/selected_stat_tab = "Status"
	var/list/previous_stat_tabs

/*
 * Overrideable proc which gets the stat content for the selected tab.
 */
/mob/proc/get_stat(selected_tab)
	var/list/tab_data = list()
	var/requires_holder = FALSE
	switch(selected_tab)
		// ===== STATUS TAB =====
		if("Status")
			tab_data = get_stat_tab_status()
		// ===== MASTER CONTROLLER =====
		if("MC")
			requires_holder = TRUE
		// ===== ADMIN TICKETS =====
		if("Tickets")
			requires_holder = TRUE
			tab_data = GLOB.ahelp_tickets.stat_entry()
		// ===== SDQL2 =====
		if("SDQL2")
			requires_holder = TRUE
	// ===== NON CONSTANT TABS (Tab names which can change) =====
	// ===== LISTEDS TURFS =====
	// TODO: Contains images too!
	if(listed_turf && listed_turf.name == selected_tab)
		var/list/overrides = list()
		for(var/image/I in client.images)
			if(I.loc && I.loc.loc == listed_turf && I.override)
				overrides += I.loc
		for(var/atom/A in listed_turf)
			if(!A.mouse_opacity)
				continue
			if(A.invisibility > see_invisible)
				continue
			if(overrides.len && (A in overrides))
				continue
			if(A.IsObscured())
				continue
			tab_data[REF(A)] = list(
				text="[A.name]",
				icon=icon2base64(icon(A.icon, A.icon_state, frame=1)),	//TODO: Cache this shit
				type=STAT_ATOM,
			)
	if(requires_holder && !client.holder)
		message_admins("[ckey] attempted to access the MC tab without sufficient rights.")
		log_admin("[ckey] attempted to access the MC tab without sufficient rights.")
		return list()
	return tab_data

/*
 * Gets the stat tab contents for the status tab
 */
/mob/proc/get_stat_tab_status()
	var/list/tab_data = list()
	tab_data["Map"] = list("[SSmapping.config?.map_name || "Loading..."]", STAT_TEXT)
	var/datum/map_config/cached = SSmapping.next_map_config
	if(cached)
		tab_data["Next Map"] = list(
			text=cached.map_name,
			type=STAT_TEXT,
		)
	tab_data["Server Time"] = list(
		text=time2text(world.timeofday,"YYYY-MM-DD hh:mm:ss"),
		type=STAT_TEXT,
	)
	tab_data["Round Time"] = list(
		text=worldtime2text(),
		type=STAT_TEXT,
	)
	tab_data["Station Time"] = list(
		text=station_time_timestamp(),
		type=STAT_TEXT,
	)
	tab_data["Time Dilation"] = list(
		text="[round(SStime_track.time_dilation_current,1)]% AVG:([round(SStime_track.time_dilation_avg_fast,1)]%, [round(SStime_track.time_dilation_avg,1)]%, [round(SStime_track.time_dilation_avg_slow,1)]%)",
		type=STAT_TEXT,
	)
	tab_data["Players Connected"] = list(
		text="[GLOB.clients.len]",
		type=STAT_TEXT,
	)
	if(SSshuttle.emergency)
		var/ETA = SSshuttle.emergency.getModeStr()
		if(ETA)
			tab_data["ETA"] = list(
				text=SSshuttle.emergency.getTimerStr(),
				type=STAT_TEXT,
				)
	return tab_data

/*
 * Gets the stat tabs available to the user.
 * Contents of the stat tabs are got through get_stat()
 */
/mob/proc/get_stat_tabs()
	var/list/tabs = list(
		"Status",
	)
	if(client.holder)
		tabs |= "MC"
		tabs |= "Tickets"
		if(length(GLOB.sdql2_queries))
			tabs |= "SDQL2"
	if(listed_turf && client)
		if(!TurfAdjacent(listed_turf))
			listed_turf = null
		else
			tabs |= listed_turf.name
	return tabs

/*
 * Called when a stat button is pressed.
 */
/mob/proc/stat_pressed(button_pressed, params)
	message_admins("[button_pressed] pressed, with parameters [list2params(params)]")
	switch(button_pressed)
		if("browsetickets")
			GLOB.ahelp_tickets.BrowseTickets(src)
		if("statPanelData")
			var/ticket_id = text2num(params["id"])
			var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(ticket_id)
			if(AH)
				AH.TicketPanel()
		if("atomClick")
			var/atomRef = params["ref"]

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

/**
  * Output an update to the stat panel for the client
  *
  * calculates client ping, round id, server time, time dilation and other data about the round
  * and puts it in the mob status panel on a regular loop
  */
/mob/Stat()
	..()

	if(!client.tgui_panel)
		return

	var/list/stat_tabs = get_stat_tabs()
	if(client.previous_stat_tabs != stat_tabs)
		update_stat_tabs(stat_tabs)
	if(!(client.selected_stat_tab in stat_tabs))
		set_stat_tab(stat_tabs[1])

	var/list/status_data = get_stat(client.selected_stat_tab)
	client.tgui_panel.set_panel_infomation(status_data)

	/*

	if(client?.holder)
		var/list/master_controller = list()
		var/turf/T = get_turf(client.eye)
		master_controller["Location"] = COORD(T)
		master_controller["CPU"] = "[world.cpu]"
		master_controller["Instances"] = "[num2text(world.contents.len, 10)]"
		master_controller["World Time"] = "[world.time]"

		status_data["MC"] = master_controller

		if(statpanel("MC"))
			var/turf/T = get_turf(client.eye)
			stat("Location:", COORD(T))
			stat("CPU:", "[world.cpu]")
			stat("Instances:", "[num2text(world.contents.len, 10)]")
			stat("World Time:", "[world.time]")
			GLOB.stat_entry()
			config.stat_entry()
			stat(null)
			if(Master)
				Master.stat_entry()
			else
				stat("Master Controller:", "ERROR")
			if(Failsafe)
				Failsafe.stat_entry()
			else
				stat("Failsafe Controller:", "ERROR")
			if(Master)
				stat(null)
				for(var/datum/controller/subsystem/SS in Master.subsystems)
					SS.stat_entry()
			GLOB.cameranet.stat_entry()
		if(statpanel("Tickets"))
			GLOB.ahelp_tickets.stat_entry()
		if(length(GLOB.sdql2_queries))
			if(statpanel("SDQL2"))
				stat("Access Global SDQL2 List", GLOB.sdql2_vv_statobj)
				for(var/i in GLOB.sdql2_queries)
					var/datum/SDQL2_query/Q = i
					Q.generate_stat()

	if(listed_turf && client)
		if(!TurfAdjacent(listed_turf))
			listed_turf = null
		else
			statpanel(listed_turf.name, null, listed_turf)
			var/list/overrides = list()
			for(var/image/I in client.images)
				if(I.loc && I.loc.loc == listed_turf && I.override)
					overrides += I.loc
			for(var/atom/A in listed_turf)
				if(!A.mouse_opacity)
					continue
				if(A.invisibility > see_invisible)
					continue
				if(overrides.len && (A in overrides))
					continue
				if(A.IsObscured())
					continue
				statpanel(listed_turf.name, null, A)


	if(mind)
		add_spells_to_statpanel(mind.spell_list)
	add_spells_to_statpanel(mob_spell_list)*/
