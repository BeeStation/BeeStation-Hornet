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
			tab_data = get_stat_tab_master_controller()
		// ===== ADMIN TICKETS =====
		if("Tickets")
			requires_holder = TRUE
			tab_data = GLOB.ahelp_tickets.stat_entry()
		// ===== SDQL2 =====
		if("SDQL2")
			requires_holder = TRUE
	// ===== NON CONSTANT TABS (Tab names which can change) =====
	// ===== LISTEDS TURFS =====
	if(listed_turf && listed_turf.name == selected_tab)
		var/list/overrides = list()
		for(var/image/I in client.images)
			if(I.loc && I.loc.loc == listed_turf && I.override)
				overrides += I.loc
		tab_data[REF(listed_turf)] = list(
			text="[listed_turf.name]",
			icon=icon2base64(getFlatIcon(listed_turf, no_anim=TRUE)),	//TODO: Cache this shit
			type=STAT_ATOM,
		)
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
				icon=icon2base64(getFlatIcon(A, no_anim=TRUE)),	//TODO: Cache this shit
				type=STAT_ATOM,
			)
	var/list/all_verbs = sorted_verbs + client.sorted_verbs
	if(selected_tab in all_verbs)
		for(var/verb in all_verbs[selected_tab])
			var/procpath/V = verb
			tab_data["[V.name]"] = list(
				action = "verb",
				params = list("verb" = V.name),
				type=STAT_VERB,
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

/mob/proc/get_stat_tab_master_controller()
	var/list/tab_data = list()
	var/turf/T = get_turf(client.eye)
	tab_data["Location"] = list(
		text="[COORD(T)]",
		type=STAT_TEXT,
	)
	tab_data["CPU"] = list(
		text="[world.cpu]",
		type=STAT_TEXT,
	)
	tab_data["Instances"] = list(
		text="[num2text(world.contents.len, 10)]",
		type=STAT_TEXT,
	)
	tab_data["World Time"] = list(
		text="[world.time]",
		type=STAT_TEXT,
	)
	tab_data += GLOB.stat_entry()
	tab_data += config.stat_entry()
	tab_data["divider_1"] = list(type=STAT_DIVIDER)
	if(Master)
		tab_data += Master.stat_entry()
	else
		tab_data["Master Controller"] = list(
			text="ERROR",
			type=STAT_TEXT,
		)
	if(Failsafe)
		tab_data += Failsafe.stat_entry()
	else
		tab_data["Failsafe Controller"] = list(
			text="ERROR",
			type=STAT_TEXT,
		)
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
	//Holder stat tabs
	if(client.holder)
		tabs |= "MC"
		tabs |= "Tickets"
		if(length(GLOB.sdql2_queries))
			tabs |= "SDQL2"
	//Get verbs
	tabs |= sorted_verbs + client?.sorted_verbs
	return tabs

/*
 * Called when a stat button is pressed.
 */
/mob/proc/stat_pressed(button_pressed, params)
	switch(button_pressed)
		if("browsetickets")
			GLOB.ahelp_tickets.BrowseTickets(src)
		if("open_ticket")
			var/ticket_id = text2num(params["id"])
			message_admins("Finding ticket with ID [ticket_id]")
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
		if(length(GLOB.sdql2_queries))
			if(statpanel("SDQL2"))
				stat("Access Global SDQL2 List", GLOB.sdql2_vv_statobj)
				for(var/i in GLOB.sdql2_queries)
					var/datum/SDQL2_query/Q = i
					Q.generate_stat()

	if(mind)
		add_spells_to_statpanel(mind.spell_list)
	add_spells_to_statpanel(mob_spell_list)*/
