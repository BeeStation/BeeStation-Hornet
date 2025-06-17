/// How many items per tile until we just completely give up?
#define MAX_ITEMS_TO_READ 500
/// How many unique entries should we show per-tile before giving up?
#define MAX_ICONS_PER_TILE 50

/// Determine the priority of this item in the stat panel
/// I decided to do it this way to reduce the amount of memory wasted on all atoms.
/// There is a reason for this madness
#define STAT_PANEL_TAG(atom) ishuman(atom) \
	? "Human" \
	: ismob(atom) \
		? "Mob" \
		: isitem(atom) \
			? "Item" \
			: isstructure(atom) \
				? "Structure" \
				: ismachinery(atom) \
					? "Machinery" \
					: isturf(atom) \
						? "Turf" \
						: "Other"

#define STAT_TAB_ACTIONS "Actions"

/client
	var/stat_update_mode = STAT_FAST_UPDATE
	var/stat_update_time = 0
	var/selected_stat_tab = "Status"
	var/list/previous_stat_tabs
	var/last_adminhelp_reply = 0

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
		if("Interviews")
			client.stat_update_mode = STAT_MEDIUM_UPDATE
			requires_holder = TRUE
			tab_data = GLOB.interviews.stat_entry()
		if ("Combat")
			client.stat_update_mode = STAT_SLOW_UPDATE
			requires_holder = TRUE
			tab_data = SScombat_logging.generate_stat_tab()
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
		// ===== ADMIN PMS =====
		if("(!) Admin PM")
			client.stat_update_mode = STAT_MEDIUM_UPDATE
			var/datum/help_ticket/ticket = client.current_adminhelp_ticket
			tab_data["ckey"] = key_name(client, FALSE, FALSE)
			tab_data["admin_name"] = key_name(ticket.claimee, FALSE, FALSE)
			//Messages:
			tab_data["messages"] = list()
			for(var/datum/ticket_interaction/message as() in ticket._interactions)
				//Only non-private messages have safe users.
				//Only admins can see adminbus logs.
				if(message.from_user_safe && message.to_user_safe)
					var/list/msg = list(
						"time" = message.time_stamp,
						"color" = message.message_color,
						"from" = message.from_user_safe,
						"to" = message.to_user_safe,
						"message" = message.message
					)
					tab_data["messages"] += list(msg)
		if (STAT_TAB_ACTIONS)
			for(var/datum/action/action in actions)
				tab_data["[action.name]"] = list(
					text = action.get_stat_label(),
					type = STAT_BUTTON,
					action = "do_action",
					params = list("ref" = REF(action))
				)
		else
			// ===== NON CONSTANT TABS (Tab names which can change) =====
			// ===== LISTEDS TURFS =====
			if(listed_turf && sanitize(listed_turf.name) == selected_tab)
				// Check if we can actually see the turf
				listed_turf.render_stat_information(client, tab_data)
	if(requires_holder && !client.holder)
		message_admins("[ckey] attempted to access the [selected_tab] tab without sufficient rights.")
		log_admin("[ckey] attempted to access the [selected_tab] tab without sufficient rights.")
		return list()
	return tab_data

/turf/proc/render_stat_information(client/client, list/tab_data)
	client.stat_update_mode = STAT_MEDIUM_UPDATE
	// Display the turf
	var/list/overrides = list()
	for(var/image/I in client.images)
		if(I.loc && I.loc.loc == src && I.override)
			overrides[I.loc] = I
	tab_data[REF(src)] = list(
		text="[name]",
		tag = STAT_PANEL_TAG(src),
		image = FAST_REF(src),
		type=STAT_ATOM
	)
	var/max_item_sanity = MAX_ITEMS_TO_READ
	var/icon_count_sanity = MAX_ICONS_PER_TILE
	var/list/atom_count = list()
	var/list/image_overrides = list()
	// Caching for A.IsObscured to improve performance, in is faster than dictionary lookups for
	// small (and even quite large) lists.
	var/list/checked_layers = list()
	var/list/obscured_layers = list()
	// Find items and group them by both name and count
	for (var/atom/A as() in src)
		// Too many items read
		if(max_item_sanity-- < 0)
			break
		if(!A.mouse_opacity)
			continue
		if(A.invisibility > client.mob.see_invisible)
			continue
		if(A.layer in checked_layers)
			if (A.layer in obscured_layers)
				continue
		else
			checked_layers += A.layer
			if (A.IsObscured())
				obscured_layers += A.layer
		var/atom_type = A.type
		var/atom_name = A.name
		if(overrides.len && overrides[A])
			var/image/override_image = overrides[A]
			atom_name = override_image.name
			image_overrides[A] = override_image
		// use the max item sanity as an extention if the unique flag is set, since its unique
		var/extension = (A.flags_1 & STAT_UNIQUE_1) && max_item_sanity
		var/list/item_group = atom_count["[atom_type][atom_name][extension]"]
		if (item_group)
			item_group += A
		else
			atom_count["[A.type][A.name][extension]"] = list(A)
			// To many icon types per tile
			if (icon_count_sanity-- <= 0)
				break
	// Display the atoms
	for(var/atom_type in atom_count)
		var/atom_items = atom_count[atom_type]
		var/item_count = length(atom_items)
		var/atom/first_atom = atom_items[1]
		if (istype(first_atom, /obj/item/stack))
			item_count = 0
			for (var/obj/item/stack/stack_item as() in atom_items)
				item_count += stack_item.amount
		var/atom_name = first_atom.name
		var/image_icon
		if (image_overrides[first_atom])
			var/image/override_image = image_overrides[first_atom]
			atom_name = override_image.name
			image_icon = FAST_REF(override_image)
		else
			image_icon = FAST_REF(first_atom)
		tab_data[REF(first_atom)] = list(
			text = "[atom_name][item_count > 1 ? " (x[item_count])" : ""]",
			tag = STAT_PANEL_TAG(first_atom),
			image = image_icon,
			type = STAT_ATOM
		)
	// Display self
	tab_data[REF(client.mob)] = list(
		text = client.mob.name,
		tag = "You",
		image = FAST_REF(client.mob),
		type = STAT_ATOM
	)

/mob/proc/get_all_verbs()
	var/list/all_verbs = new

	if(!client)
		return all_verbs

	if(client.interviewee)
		return list("Interview" = list(/mob/dead/new_player/proc/open_interview))

	if(sorted_verbs)
		all_verbs = deep_copy_list(sorted_verbs)
	//An annoying thing to mention:
	// list A [A: ["b", "c"]] +  (list B) [A: ["c", "d"]] will only have A from list B
	for(var/i in client.sorted_verbs)
		if(i in all_verbs)
			all_verbs[i] += client.sorted_verbs[i]
		else
			var/list/verbs_to_copy = client.sorted_verbs[i]
			all_verbs[i] = verbs_to_copy.Copy()
	//TODO: Call tgui_panel/add_verbs on pickup and remove on drop.
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
	tab_data["Station Time"] = GENERATE_STAT_TEXT(station_time_timestamp())
	tab_data["divider_1"] = GENERATE_STAT_BLANK

	tab_data["Time Dilation"] = GENERATE_STAT_TEXT("[round(SStime_track.time_dilation_current,1)]% AVG:([round(SStime_track.time_dilation_avg_fast,1)]%, [round(SStime_track.time_dilation_avg,1)]%, [round(SStime_track.time_dilation_avg_slow,1)]%)")
	if (SSticker.round_start_time)
		tab_data["Internal Round Timer"] = GENERATE_STAT_TEXT(time2text(world.time - SSticker.round_start_time, "hh:mm:ss", 0))
		tab_data["Actual Round Timer"] = GENERATE_STAT_TEXT(time2text(world.timeofday - SSticker.round_start_timeofday, "hh:mm:ss", 0))
	else
		tab_data["Lobby Timer"] = GENERATE_STAT_TEXT(worldtime2text())
	tab_data["divider_2"] = GENERATE_STAT_BLANK

	if(!SSticker.HasRoundStarted())
		tab_data["Players Ready/Connected"] = GENERATE_STAT_TEXT("[SSticker.totalPlayersReady]/[GLOB.clients.len]")
	else
		tab_data["Players Playing/Connected"] = GENERATE_STAT_TEXT("[get_active_player_count()]/[GLOB.clients.len]")
	if(SSticker.round_start_time)
		tab_data["Security Level"] = GENERATE_STAT_TEXT("[capitalize(SSsecurity_level.get_current_level_as_text())]")

	tab_data["divider_3"] = GENERATE_STAT_DIVIDER
	if(SSshuttle.emergency)
		var/ETA = SSshuttle.emergency.getModeStr()
		if(ETA)
			tab_data[ETA] = GENERATE_STAT_TEXT(SSshuttle.emergency.getTimerStr())
	if (!isnewplayer(src) && SSautotransfer.can_fire)
		if (SSautotransfer.required_votes_to_leave && SSshuttle.canEvac() == TRUE) //THIS MUST BE "== TRUE" TO WORK. canEvac() ALWAYS RETURNS A VALUE.
			tab_data["Vote to leave"] = GENERATE_STAT_BUTTON("[client?.player_details.voted_to_leave ? "Yes" : "No"] ([SSautotransfer.connected_votes_to_leave]/[CEILING(SSautotransfer.required_votes_to_leave, 1)])", "votetoleave")
		else
			tab_data["Vote to leave"] = GENERATE_STAT_BUTTON("[client?.player_details.voted_to_leave ? "Yes" : "No"]", "votetoleave")
	return tab_data

/mob/proc/get_stat_tab_master_controller()
	var/list/tab_data = list()
	var/turf/T = get_turf(client.eye)
	tab_data["Location"] = GENERATE_STAT_TEXT("[COORD(T)]")
	tab_data["CPU"] = GENERATE_STAT_TEXT("[world.cpu]")
	tab_data["Tick Usage"] = GENERATE_STAT_TEXT("[TICK_USAGE] / [Master.current_ticklimit]")
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
		tab_data["divider_2"] = GENERATE_STAT_DIVIDER
		for(var/datum/controller/subsystem/SS in Master.subsystems)
			tab_data += SS.stat_entry()
		tab_data["divider_3"] = GENERATE_STAT_DIVIDER
		var/datum/controller/subsystem/queue_node = Master.last_type_processed
		if (queue_node)
			tab_data["Last Processed:"] = GENERATE_STAT_TEXT("[queue_node.name] \[FI: [queue_node.next_fire - world.time]ds\] [(queue_node.flags & SS_TICKER) ? " (Ticker)" : ""][(queue_node.flags & SS_BACKGROUND) ? " (Background)" : ""][(queue_node.flags & SS_KEEP_TIMING) ? " (Keep Timing)" : ""]")
		queue_node = Master.queue_head
		var/i = 0
		while (queue_node)
			tab_data["Queue [i++]:"] = GENERATE_STAT_TEXT("[queue_node.name] \[FI: [queue_node.next_fire - world.time]ds\] [(queue_node.flags & SS_TICKER) ? " (Ticker)" : ""][(queue_node.flags & SS_BACKGROUND) ? " (Background)" : ""][(queue_node.flags & SS_KEEP_TIMING) ? " (Keep Timing)" : ""]")
			queue_node = queue_node.queue_next
		tab_data["divider_4"] = GENERATE_STAT_DIVIDER
		for (var/j in 1 to length(Master.previous_ticks))
			var/datum/mc_tick/tick = Master.previous_ticks[(Master.circular_queue_head - j + length(Master.previous_ticks)) % length(Master.previous_ticks) + 1]
			tab_data["Tick [tick.tick_number]"] = GENERATE_STAT_TEXT(tick.get_stat_text())
	tab_data["divider_5"] = GENERATE_STAT_DIVIDER
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
	//Get Tickets
	if(client.current_adminhelp_ticket)
		//Bwoinks come after status
		tabs += "(!) Admin PM"
	//Listed turfs
	if(listed_turf && client)
		if(!TurfAdjacent(listed_turf))
			listed_turf = null
		else
			tabs |= sanitize(listed_turf.name)
	//Spells we have
	if (length(actions))
		tabs += STAT_TAB_ACTIONS
	//Holder stat tabs
	if(client.holder)
		tabs |= "MC"
		tabs |= "Tickets"
		tabs |= "Combat"
		if(CONFIG_GET(flag/panic_bunker_interview))
			tabs |= "Interviews"
		if(length(GLOB.sdql2_queries))
			tabs |= "SDQL2"
	else if(client.interviewee)
		tabs |= "Interview"

	var/list/additional_tabs = list()
	//Performance increase from only adding keys is better than adding values too.
	for(var/i in get_all_verbs())
		additional_tabs |= i
	additional_tabs = sort_list(additional_tabs)
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
			if (!client.holder)
				return
			GLOB.ahelp_tickets.BrowseTickets(src)
		if("browserequests")
			if (!client.holder)
				return
			GLOB.requests.ui_interact(usr)
		if("browseinterviews")
			if (!check_rights(R_ADMIN))
				return
			GLOB.interviews.BrowseInterviews(src)
		if("open_interview")
			if (!check_rights(R_ADMIN))
				return
			var/datum/interview/I = GLOB.interviews.interview_by_id(text2num(params["id"]))
			if (I && client.holder)
				I.ui_interact(src)
		if("open_ticket")
			if (!client.holder)
				return
			var/ticket_id = text2num(params["id"])
			var/datum/help_ticket/AH = GLOB.ahelp_tickets.TicketByID(ticket_id)
			if(AH && client.holder)
				AH.ui_interact(src)
		if ("claim_ticket")
			if (!check_rights(R_ADMIN))
				return
			var/ticket_id = text2num(params["id"])
			var/datum/help_ticket/AH = GLOB.ahelp_tickets.TicketByID(ticket_id)
			if(AH && client.holder)
				AH.Claim()
		if ("orbit")
			if (!check_rights(R_ADMIN))
				return
			var/mob_ref = params["ref"]
			usr.client.holder?.admin_follow(locate(mob_ref))
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
		if("atomDrop")
			var/atomRef1 = params["ref"]
			var/atomRef2 = params["ref_other"]
			var/atom/atom_actual1 = locate(atomRef1)
			var/atom/atom_actual2 = locate(atomRef2)
			if(!atom_actual1 || !atom_actual2)
				return
			client.MouseDrop(atom_actual2, atom_actual1)
		if("statClickDebug")
			var/targetRef = params["targetRef"]
			var/class = params["class"]
			var/target = locate(targetRef)
			if(!usr.client.holder)
				message_admins("[usr.client] attempted to interact with the MC without sufficient perms.")
				return
			if(!target)
				to_chat(usr, span_warning("Could not locate target, report this!"))
				log_runtime("[usr] attempted to interact with a statClickDebug, but was unsuccessful due to the target not existing.")
				return
			usr.client.debug_variables(target)
			message_admins("Admin [key_name_admin(usr)] is debugging the [target] [class].")
		if("verb")
			var/verb_name = params["verb"]
			winset(client, null, "command=[replacetext(verb_name, " ", "-")]")
		if("sdql2debug")
			if (!check_rights(R_DEBUG))
				return
			client.debug_variables(GLOB.sdql2_queries)
		if("sdql2delete")
			if (!check_rights(R_DEBUG))
				return
			var/query_id = params["qid"]
			var/datum/SDQL2_query/query = sdqlQueryByID(text2num(query_id))
			if(query)
				query.delete_click()
		if("sdql2toggle")
			if (!check_rights(R_DEBUG))
				return
			var/query_id = params["qid"]
			var/datum/SDQL2_query/query = sdqlQueryByID(text2num(query_id))
			if(query)
				query.action_click()
		if("ticket_message")
			var/message = sanitize(params["msg"])
			if(message)
				if(world.time > client.last_adminhelp_reply + 10 SECONDS)
					client.last_adminhelp_reply = world.time
					if(client.current_adminhelp_ticket)
						client.current_adminhelp_ticket.MessageNoRecipient(message, sanitized = TRUE)
					else
						to_chat(src, span_warning("Your issue has already been resolved!"))
				else
					to_chat(src, span_warning("You are sending messages too fast!"))
		if("start_br")
			if(client.holder && check_rights(R_FUN))
				client.battle_royale()
		if ("votetoleave")
			client.vote_to_leave()
		if ("do_action")
			var/datum/action/action = locate(params["ref"]) in actions
			if (!action)
				return
			action.trigger()

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

#undef MAX_ITEMS_TO_READ
#undef MAX_ICONS_PER_TILE

#undef STAT_PANEL_TAG
#undef STAT_TAB_ACTIONS
