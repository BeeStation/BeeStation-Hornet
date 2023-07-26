#define CLAIM_DONTCLAIM 0
#define CLAIM_CLAIMIFNONE 1
#define CLAIM_OVERRIDE 2

//
// Ticket manager
//

/datum/help_tickets
	var/list/unclaimed_tickets = list()
	var/list/active_tickets = list()
	var/list/closed_tickets = list()
	var/list/resolved_tickets = list()

/datum/help_tickets/Destroy()
	QDEL_LIST(unclaimed_tickets)
	QDEL_LIST(active_tickets)
	QDEL_LIST(closed_tickets)
	QDEL_LIST(resolved_tickets)
	return ..()

/datum/help_tickets/proc/BrowseTickets(mob/user)
	return

/datum/help_tickets/proc/TicketByID(id)
	var/list/lists = list(unclaimed_tickets, active_tickets, closed_tickets, resolved_tickets)
	for(var/I in lists)
		for(var/datum/help_ticket/AH in I)
			if(AH.id == id)
				return AH

/datum/help_tickets/proc/TicketsByCKey(ckey)
	. = list()
	var/list/lists = list(unclaimed_tickets, active_tickets, closed_tickets, resolved_tickets)
	for(var/I in lists)
		for(var/datum/help_ticket/AH in I)
			if(AH.initiator_ckey == ckey)
				. += AH

//private
/datum/help_tickets/proc/ListInsert(datum/help_ticket/new_ticket)
	var/list/ticket_list
	switch(new_ticket.state)
		if(TICKET_UNCLAIMED)
			ticket_list = unclaimed_tickets
		if(TICKET_ACTIVE)
			ticket_list = active_tickets
		if(TICKET_CLOSED)
			ticket_list = closed_tickets
		if(TICKET_RESOLVED)
			ticket_list = resolved_tickets
		else
			CRASH("Invalid ticket state: [new_ticket.state]")
	var/num_closed = ticket_list.len
	if(num_closed)
		for(var/I in 1 to num_closed)
			var/datum/help_ticket/AH = ticket_list[I]
			if(AH.id > new_ticket.id)
				ticket_list.Insert(I, new_ticket)
				return
	ticket_list += new_ticket

//TGUI TICKET THINGS

// UI holder for admins
/datum/help_ui

/datum/help_ui/proc/get_data_glob()
	return

/datum/help_ui/proc/check_permission(mob/user)
	return FALSE

/datum/help_ui/ui_state(mob/user)
	return GLOB.never_state

/datum/help_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		log_admin_private("[user.ckey] opened the ticket panel.")
		ui = new(user, src, "TicketBrowser", "Ticket Browser")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/help_ui/ui_data(mob/user)
	if(!check_permission(user))
		log_admin_private("[user] sent a request to interact with the ticket browser without sufficient rights.")
		message_admins("[user] sent a request to interact with the ticket browser without sufficient rights.")
		return
	var/list/data = list()
	data["admin_ckey"] = user.ckey
	var/datum/help_tickets/data_glob = get_data_glob()
	if(!istype(data_glob))
		return
	data["is_admin_panel"] = istype(data_glob, /datum/help_tickets/admin)
	data["unclaimed_tickets"] = data_glob.get_ui_ticket_data(TICKET_UNCLAIMED)
	data["open_tickets"] = data_glob.get_ui_ticket_data(TICKET_ACTIVE)
	data["closed_tickets"] = data_glob.get_ui_ticket_data(TICKET_CLOSED)
	data["resolved_tickets"] = data_glob.get_ui_ticket_data(TICKET_RESOLVED)
	data = add_additional_ticket_data(data)
	return data

/datum/help_ui/proc/add_additional_ticket_data(data)
	return data

/datum/help_ui/proc/get_additional_ticket_data(ticket_id)
	return

/datum/help_ui/proc/reply(whom)
	return

/datum/help_ui/ui_act(action, params)
	if(!check_permission(usr))
		message_admins("[usr] sent a request to interact with the ticket browser without sufficient rights.")
		log_admin_private("[usr] sent a request to interact with the ticket browser without sufficient rights.")
		return
	var/ticket_id = text2num(params["id"])
	var/datum/help_tickets/data_glob = get_data_glob()
	if(!istype(data_glob))
		return
	var/datum/help_ticket/ticket = data_glob.TicketByID(ticket_id)
	if(!ticket)
		ticket = get_additional_ticket_data(ticket_id)
	if(!ticket)
		return
	//Doing action on a ticket claims it
	var/claim_ticket = CLAIM_DONTCLAIM
	switch(action)
		if("claim")
			if(ticket.claimee)
				var/confirm = tgui_alert(usr, "This ticket is already claimed, override claim?", buttons = list("Yes", "No"))
				if(confirm != "Yes")
					return
			claim_ticket = CLAIM_OVERRIDE
		if("reject")
			claim_ticket = CLAIM_OVERRIDE
			ticket.Reject()
		if("resolve")
			claim_ticket = CLAIM_OVERRIDE
			ticket.Resolve()
		if("reopen")
			claim_ticket = CLAIM_OVERRIDE
			ticket.Reopen()
		if("view")
			ticket.TicketPanel()
		if("pm")
			reply(ticket.initiator)
			claim_ticket = CLAIM_CLAIMIFNONE
	claim_ticket = additional_act(action, ticket, claim_ticket)
	if(claim_ticket == CLAIM_OVERRIDE || (claim_ticket == CLAIM_CLAIMIFNONE && !ticket.claimee))
		ticket.Claim()


/datum/help_ui/proc/additional_act(action, datum/help_ticket/ticket, claim_ticket)
	return

// has to be here because defines
/datum/help_ui/admin/additional_act(action, datum/help_ticket/ticket, claim_ticket)
	switch(action)
		if("ic")
			claim_ticket = CLAIM_OVERRIDE
			if(istype(ticket, /datum/help_ticket/admin))
				var/datum/help_ticket/admin/a_ticket = ticket
				a_ticket.ICIssue()
		if("close")
			claim_ticket = CLAIM_OVERRIDE
			ticket.Close()
		if("mhelp")
			claim_ticket = CLAIM_OVERRIDE
			if(istype(ticket, /datum/help_ticket/admin))
				var/datum/help_ticket/admin/a_ticket = ticket
				a_ticket.MHelpThis()
		if("flw")
			var/datum/admins/admin_datum = GLOB.admin_datums[usr.ckey]
			if(!admin_datum)
				return
			admin_datum.admin_follow(get_mob_by_ckey(ticket.initiator_ckey))
	return claim_ticket

/datum/help_ui/mentor/additional_act(action, datum/help_ticket/ticket, claim_ticket)
	switch(action)
		if("ahelp")
			claim_ticket = CLAIM_OVERRIDE
			if(istype(ticket, /datum/help_ticket/mentor))
				var/datum/help_ticket/mentor/m_ticket = ticket
				m_ticket.AHelpThis()
	return claim_ticket

/datum/help_tickets/proc/get_ui_ticket_data(state)
	var/list/l2b
	switch(state)
		if(TICKET_UNCLAIMED)
			l2b = unclaimed_tickets
		if(TICKET_ACTIVE)
			l2b = active_tickets
		if(TICKET_CLOSED)
			l2b = closed_tickets
		if(TICKET_RESOLVED)
			l2b = resolved_tickets
	if(!l2b)
		return
	var/list/dat = list()
	for(var/datum/help_ticket/AH in l2b)
		var/list/ticket = list(
			"id" = AH.id,
			"initiator_key_name" = AH.initiator_key_name,
			"name" = AH.name,
			"claimed_key_name" = AH.claimee_key_name,
			"disconnected" = AH.initiator ? FALSE : TRUE,
			"state" = AH.state,
			"is_admin_type" = istype(AH, /datum/help_ticket/admin)
		)
		dat += list(ticket)
	return dat

//End

//Tickets statpanel
/datum/help_tickets/proc/stat_entry()
	var/list/tab_data = list()
	tab_data["Tickets"] = list(
		text = "Open Ticket Browser",
		type = STAT_BUTTON,
		action = "browsetickets",
	)
	tab_data["Active Tickets"] = list(
		text = "[active_tickets.len]",
		type = STAT_BUTTON,
		action = "browsetickets",
	)
	var/num_disconnected = 0
	for(var/l in list(active_tickets, unclaimed_tickets))
		for(var/datum/help_ticket/AH in l)
			if(AH.initiator)
				tab_data["#[AH.id]. [AH.initiator_key_name]"] = list(
					text = AH.name,
					type = STAT_BUTTON,
					action = "open_ticket",
					params = list("id" = AH.id),
				)
			else
				++num_disconnected
	if(num_disconnected)
		tab_data["Disconnected"] = list(
			text = "[num_disconnected]",
			type = STAT_BUTTON,
			action = "browsetickets",
		)
	tab_data["Closed Tickets"] = list(
		text = "[closed_tickets.len]",
		type = STAT_BUTTON,
		action = "browsetickets",
	)
	tab_data["Resolved Tickets"] = list(
		text = "[resolved_tickets.len]",
		type = STAT_BUTTON,
		action = "browsetickets",
	)
	return tab_data

//Reassociate still open ticket if one exists
/datum/help_tickets/proc/ClientLogin(client/C)
	var/datum/help_ticket/active_ticket = CKey2ActiveTicket(C.ckey)
	if(active_ticket)
		active_ticket.initiator = C
		active_ticket.AddInteraction("green", "Client reconnected.")
	set_active_ticket(C, active_ticket)

//Dissasociate ticket
/datum/help_tickets/proc/ClientLogout(client/C)
	var/datum/help_ticket/active_ticket = get_active_ticket(C)
	if(active_ticket)
		active_ticket.AddInteraction("red", "Client disconnected.")
		active_ticket.initiator = null
		set_active_ticket(C, null)

//Get a ticket given a ckey
/datum/help_tickets/proc/CKey2ActiveTicket(ckey)
	for(var/l in list(unclaimed_tickets, active_tickets))
		for(var/datum/help_ticket/AH in l)
			if(AH.initiator_ckey == ckey)
				return AH

/datum/help_tickets/proc/get_active_ticket(client/C)
	return

/datum/help_tickets/proc/set_active_ticket(client/C, datum/help_ticket/ticket)
	return

//
// Ticket interaction
//

/datum/ticket_interaction
	var/time_stamp
	var/message_color = "default"
	var/from_user
	var/to_user
	var/message
	var/from_user_safe
	var/to_user_safe

/datum/ticket_interaction/New()
	. = ..()
	time_stamp = time_stamp()

//
// Ticket datum
//

/datum/help_ticket
	var/id
	var/name
	var/state = TICKET_UNCLAIMED
	/// The first (sanitized) message for this ticket
	var/initial_msg

	var/opened_at
	var/closed_at

	/// The person who a/mhelped OR was bwoinked (the non-admin/mentor)
	var/client/initiator
	var/initiator_ckey
	var/initiator_key_name

	/// The person that has claimed this ticket
	var/client/claimee
	var/claimee_key_name

	/// Do not add to directly. Use AddInteraction() or, preferably, admin_ticket_log()
	var/list/_interactions

	var/static/ticket_counter = 0
	/// Class used on message spans
	var/span_class = "adminhelp"
	/// What type of staff is handling the ticket ("Your ticket has been resolved by the _s")
	var/handling_name = "administrator"
	/// The help verb that is used to open this ticket type
	var/verb_name = "Adminhelp"
	/// The sound used for ticket actions and replies (bwoink!)
	var/reply_sound = "sound/effects/adminhelp.ogg"
	/// The message type used for resolve messages
	var/message_type = MESSAGE_TYPE_ADMINPM

/datum/help_ticket/New(client/C)
	initiator = C
	initiator_ckey = initiator.ckey
	initiator_key_name = key_name(initiator, FALSE, TRUE)

/// Call this on its own to create a ticket, don't manually assign current_ticket, msg is the title of the ticket: usually the ahelp text
/datum/help_ticket/proc/Create(msg)
	//Clean the input message
	msg = sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN))
	if(!msg || !initiator || !initiator.mob)
		qdel(src)
		return FALSE
	initial_msg = msg
	id = ++ticket_counter
	opened_at = world.time

	name = copytext_char(msg, 1, 100)

	var/datum/help_tickets/data_glob = get_data_glob()
	if(!istype(data_glob))
		return FALSE
	var/datum/help_ticket/active_ticket = data_glob.get_active_ticket(initiator)
	if(active_ticket)	//This is a bug
		stack_trace("Multiple current_tickets in ticket of type [verb_name]")
		active_ticket.AddInteraction("red", "Ticket erroneously left open by code")
		active_ticket.Close()
	data_glob.set_active_ticket(initiator, src)

	TimeoutVerb()

	_interactions = list()

	data_glob.unclaimed_tickets += src
	return TRUE

/datum/help_ticket/proc/NewFrom(datum/help_ticket/old_ticket)
	initial_msg = old_ticket.initial_msg
	id = ++ticket_counter
	opened_at = old_ticket.opened_at

	name = old_ticket.name

	var/datum/help_tickets/data_glob = get_data_glob()
	if(!istype(data_glob))
		ticket_counter--
		qdel(src)
		return FALSE
	var/datum/help_ticket/active_ticket = data_glob.get_active_ticket(initiator)
	if(active_ticket)
		to_chat(initiator, "<span class='warning'>Your ticket could not be transferred because you already have a ticket of the same type open. Please make another ticket at a later time, or bring up whatever the issue was in your current ticket.</span>", type = message_type)
		old_ticket.message_ticket_managers("<span class='[old_ticket.span_class]'>Could not transfer Ticket [old_ticket.TicketHref("#[old_ticket.id]")], [old_ticket.key_name_ticket(old_ticket.initiator)] already has a ticket open of the same type.</span>")
		ticket_counter--
		qdel(src)
		return FALSE
	data_glob.set_active_ticket(initiator, src)

	TimeoutVerb()

	_interactions = old_ticket._interactions.Copy()

	data_glob.unclaimed_tickets += src
	return TRUE

/datum/help_ticket/Destroy()
	RemoveActive()
	var/datum/help_tickets/data_glob = get_data_glob()
	if(!istype(data_glob))
		return ..()
	data_glob.closed_tickets -= src
	data_glob.resolved_tickets -= src
	return ..()

/datum/help_ticket/proc/get_data_glob()
	return

/datum/help_ticket/proc/check_permission(mob/user)
	return FALSE

/datum/help_ticket/proc/check_permission_act(mob/user)
	return FALSE

/datum/help_ticket/proc/AddInteraction(msg_color, message, name_from, name_to, safe_from, safe_to)
	var/datum/ticket_interaction/interaction_message = new /datum/ticket_interaction
	interaction_message.message_color = msg_color
	interaction_message.message = message
	interaction_message.from_user = name_from
	interaction_message.to_user = name_to
	interaction_message.from_user_safe = safe_from
	interaction_message.to_user_safe = safe_to
	_interactions += interaction_message
	SStgui.update_uis(src)

/datum/help_ticket/proc/TimeoutVerb()
	return

/datum/help_ticket/proc/TicketPanel()
	ui_interact(usr)

/datum/help_ticket/ui_interact(mob/user, datum/tgui/ui = null)
	//Support multiple tickets open at once
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		log_admin_private("[user.ckey] opened the ticket panel.")
		ui = new(user, src, "TicketMessenger", "Ticket Messenger")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/help_ticket/ui_state(mob/user)
	return GLOB.never_state

/datum/help_ticket/ui_data(mob/user)
	if(!check_permission(user))
		message_admins("[user] sent a request to interact with the ticket window without sufficient rights.")
		log_admin_private("[user] sent a request to interact with the ticket window without sufficient rights.")
		return
	var/list/data = list()
	//Messages
	data["disconected"] = initiator
	data["time_opened"] = opened_at
	data["open"] = state <= TICKET_ACTIVE
	data["time_closed"] = closed_at
	data["ticket_state"] = state
	data["claimee"] = claimee
	data["claimee_key"] = claimee_key_name
	data["id"] = id
	data["sender"] = initiator_key_name
	data["world_time"] = world.time
	data["is_admin_type"] = TRUE
	data["messages"] = list()
	for(var/datum/ticket_interaction/message in _interactions)
		var/list/msg = list(
			"time" = message.time_stamp,
			"color" = message.message_color,
			"from" = message.from_user,
			"to" = message.to_user,
			"message" = message.message
		)
		data["messages"] += list(msg)
	data = get_ticket_additional_data(user, data)
	return data

/datum/help_ticket/proc/get_ticket_additional_data(mob/user, list/data)
	return data

/datum/help_ticket/proc/reply(whom, msg)
	return

/datum/help_ticket/ui_act(action, params)
	if(!check_permission_act(usr))
		message_admins("[usr] sent a request to interact with the ticket window without sufficient rights.")
		log_admin_private("[usr] sent a request to interact with the ticket window without sufficient rights.")
		return
	//Doing action on a ticket claims it
	var/claim_ticket = CLAIM_DONTCLAIM
	switch(action)
		if("sendpm")
			reply(initiator, params["text"])
			claim_ticket = CLAIM_CLAIMIFNONE
		if("reject")
			Reject()
			claim_ticket = CLAIM_OVERRIDE
		if("resolve")
			Resolve()
			claim_ticket = CLAIM_OVERRIDE
		if("retitle")
			Retitle()
		if("reopen")
			Reopen()
			claim_ticket = CLAIM_OVERRIDE
	claim_ticket = additional_act(action, claim_ticket)
	if(claim_ticket == CLAIM_OVERRIDE || (claim_ticket == CLAIM_CLAIMIFNONE && !claimee))
		Claim()

/datum/help_ticket/proc/additional_act(action, claim_ticket)
	return

// has to be here because defines
/datum/help_ticket/admin/additional_act(action, claim_ticket)
	var/datum/admins/admin_datum = GLOB.admin_datums[usr.ckey]
	if(!admin_datum)
		message_admins("[usr] sent a request to interact with the ticket window without sufficient rights.")
		log_admin_private("[usr] sent a request to interact with the ticket window without sufficient rights.")
		return
	switch(action)
		if("close")
			Close()
			claim_ticket = CLAIM_OVERRIDE
		if("moreinfo")
			admin_datum.admin_more_info(get_mob_by_ckey(initiator.ckey))
		if("playerpanel")
			admin_datum.show_player_panel(get_mob_by_ckey(initiator.ckey))
		if("viewvars")
			usr.client.debug_variables(get_mob_by_ckey(initiator.ckey))
		if("subtlemsg")
			usr.client.cmd_admin_subtle_message(get_mob_by_ckey(initiator.ckey))
		if("flw")
			admin_datum.admin_follow(get_mob_by_ckey(initiator.ckey))
		if("traitorpanel")
			admin_datum.show_traitor_panel(get_mob_by_ckey(initiator.ckey))
		if("viewlogs")
			show_individual_logging_panel(get_mob_by_ckey(initiator.ckey))
		if("smite")
			usr.client.smite(get_mob_by_ckey(initiator.ckey))
		if("mentorhelp")
			MHelpThis()
			claim_ticket = CLAIM_OVERRIDE
		if("markic")
			ICIssue()
			claim_ticket = CLAIM_OVERRIDE
	return claim_ticket

/datum/help_ticket/mentor/additional_act(action, claim_ticket)
	if(action == "adminhelp")
		AHelpThis()
		claim_ticket = CLAIM_OVERRIDE
	return claim_ticket

/datum/help_ticket/proc/MessageNoRecipient(msg, sanitized = FALSE)
	return

/datum/help_ticket/proc/key_name_ticket(mob/user)
	return

/datum/help_ticket/proc/message_ticket_managers(msg)
	return

/datum/help_ticket/proc/LinkedReplyName(ref_src)
	return "[initiator_key_name]"

/datum/help_ticket/proc/TicketHref(msg, ref_src, action = "ticket")
	return "[msg]"

/datum/help_ticket/proc/blackbox_feedback(increment, data)
	return

//Reopen a closed ticket
/datum/help_ticket/proc/Reopen()
	if(state <= TICKET_ACTIVE)
		to_chat(usr, "<span class='warning'>This ticket is already open.</span>")
		return

	var/datum/help_tickets/data_glob = get_data_glob()
	if(!istype(data_glob))
		return

	if(data_glob.CKey2ActiveTicket(initiator_ckey))
		to_chat(usr, "<span class='warning'>This user already has an active ticket, cannot reopen this one.</span>")
		return

	data_glob.active_tickets += src
	data_glob.closed_tickets -= src
	data_glob.resolved_tickets -= src
	switch(state)
		if(TICKET_CLOSED)
			blackbox_feedback(-1, "closed")
		if(TICKET_RESOLVED)
			blackbox_feedback(-1, "resolved")
	state = TICKET_ACTIVE
	closed_at = null
	if(initiator)
		data_glob.set_active_ticket(initiator, src)

	AddInteraction("purple", "Reopened by [key_name_ticket(usr)]")
	var/msg = "<span class='[span_class]'>Ticket [TicketHref("#[id]")] reopened by [key_name_ticket(usr)].</span>"
	message_ticket_managers(msg)
	log_admin_private(msg)
	blackbox_feedback(1, "reopened")
	TicketPanel()	//can only be done from here, so refresh it

/// Don't call this, internal use only. Use Close/Resolve instead
/datum/help_ticket/proc/RemoveActive()
	if(state > TICKET_ACTIVE)
		return
	closed_at = world.time
	var/datum/help_tickets/data_glob = get_data_glob()
	if(!istype(data_glob))
		return
	if(state == TICKET_ACTIVE)
		data_glob.active_tickets -= src
	else
		data_glob.unclaimed_tickets -= src
	if(initiator && data_glob.get_active_ticket(initiator) == src)
		data_glob.set_active_ticket(initiator, null)

/datum/help_ticket/proc/Claim(key_name = key_name_ticket(usr), silent = FALSE)
	if(claimee == usr)
		return
	if(initiator && !claimee && !silent)
		to_chat(initiator, "<font color='red'>Your issue is being investigated by \a [handling_name], please stand by.</span>", type = message_type)
	var/datum/help_tickets/data_glob = get_data_glob()
	if(!istype(data_glob))
		return
	if(state == TICKET_UNCLAIMED)
		data_glob.unclaimed_tickets -= src
		state = TICKET_ACTIVE
		data_glob.ListInsert(src)
	var/updated = claimee?.ckey
	if(updated)
		AddInteraction("blue", "Claimed by [key_name] (Overwritten from [updated])")
	else
		AddInteraction("blue", "Claimed by [key_name]")
	claimee = usr
	claimee_key_name = usr.ckey
	if(!silent && !updated)
		blackbox_feedback(1, "claimed")
		var/msg = "<span class='[span_class]'>Ticket [TicketHref("#[id]")] claimed by [key_name].</span>"
		message_ticket_managers(msg)
		log_admin_private(msg)

/// Mark open ticket as closed/meme
/datum/help_ticket/proc/Close(key_name = key_name_ticket(usr), silent = FALSE, hide_interaction = FALSE)
	if(state > TICKET_ACTIVE)
		return
	if(!claimee)
		Claim(silent = TRUE)
	RemoveActive()
	state = TICKET_CLOSED
	var/datum/help_tickets/data_glob = get_data_glob()
	if(!istype(data_glob))
		return
	data_glob.ListInsert(src)
	if(!hide_interaction)
		AddInteraction("red", "Closed by [key_name].")
	if(!silent)
		blackbox_feedback(1, "closed")
		var/msg = "<span class='[span_class]'>Ticket [TicketHref("#[id]")] closed by [key_name].</span>"
		message_ticket_managers(msg)
		log_admin_private(msg)

/// Mark open ticket as resolved/legitimate, returns ahelp verb
/datum/help_ticket/proc/Resolve(key_name = key_name_ticket(usr), silent = FALSE)
	if(state > TICKET_ACTIVE)
		return
	if(!claimee)
		Claim(silent = TRUE)
	RemoveActive()
	state = TICKET_RESOLVED
	var/datum/help_tickets/data_glob = get_data_glob()
	if(!istype(data_glob))
		return
	data_glob.ListInsert(src)

	AddInteraction("green", "Resolved by [key_name].")
	if(!silent)
		resolve_message()
		blackbox_feedback(1, "resolved")
		var/msg = "<span class='[span_class]'>Ticket [TicketHref("#[id]")] resolved by [key_name]</span>"
		message_ticket_managers(msg)
		log_admin_private(msg)

/// Close and return ahelp verb, use if ticket is incoherent
/datum/help_ticket/proc/Reject(key_name = key_name_ticket(usr), extra_text)
	if(state > TICKET_ACTIVE)
		return
	if(!claimee)
		Claim(silent = TRUE)
	if(initiator)
		SEND_SOUND(initiator, sound(reply_sound))
		resolve_message(status = "Rejected!", message = "The [handling_name]s could not resolve your ticket.</b> The [verb_name] verb has been returned to you so that you may try again.<br /> \
		Please try to be calm, clear, and descriptive in your [verb_name], do not assume the [handling_name] has seen any related events[extra_text].")
	blackbox_feedback(1, "rejected")
	var/msg = "<span class='[span_class]'>Ticket [TicketHref("#[id]")] rejected by [key_name]</span>"
	message_ticket_managers(msg)
	log_admin_private(msg)
	AddInteraction("red", "Rejected by [key_name].")
	Close(silent = TRUE)

/datum/help_ticket/proc/Retitle(key_name = key_name_ticket(usr))
	var/new_title = capped_input(usr, "Enter a title for the ticket", "Rename Ticket", name)
	if(new_title)
		name = new_title
		//not saying the original name cause it could be a long ass message
		var/msg = "<span class='[span_class]'>Ticket [TicketHref("#[id]")] titled [name] by [key_name]</span>"
		message_ticket_managers(msg)
		log_admin_private(msg)
	TicketPanel()	//we have to be here to do this

/datum/help_ticket/proc/resolve_message(status = "Resolved", message = null, extratext = "")
	var/output = "<span class='[span_class]_conclusion'><span class='big'><b>[verb_name] [status]</b></span><br />"
	output += message || "\A [handling_name] has handled your ticket.[extratext]<br />\
		Thank you for creating a ticket, the [verb_name] verb will be returned to you shortly."
	if(claimee)
		output += "<br />Your ticket was handled by: <span class='adminooc'>[claimee.ckey]</span></span>"
	to_chat(initiator, output, type = message_type)

//
// LOGGING
//

/// Use this proc when an admin takes action that may be related to an open ticket on "what" - "what" can be a client, ckey, or mob
/proc/admin_ticket_log(what, message, whofrom = "", whoto = "", color = "white", isSenderAdmin = FALSE, safeSenderLogged = FALSE, is_admin_ticket = TRUE)
	var/client/C
	var/mob/mob = what
	if(istype(mob))
		C = mob.client
	else if(istype(what, /client))
		C = what
	else if(istext(what) && (what in GLOB.directory))
		C = GLOB.directory[what]
	if(!istype(C))
		return
	var/datum/help_ticket/ticket = is_admin_ticket ? C.current_adminhelp_ticket : C.current_mentorhelp_ticket
	if(!ticket)
		return
	if(safeSenderLogged)
		var/send_name = is_admin_ticket ? "Administrator" : "Mentor"
		ticket.AddInteraction(color, message, whofrom, whoto, isSenderAdmin ? send_name : "You", isSenderAdmin ? "You" : send_name)
	else
		ticket.AddInteraction(color, message, whofrom, whoto)
	return ticket

//
// HELPER PROCS
//

/proc/get_admin_counts(requiredflags = R_BAN)
	. = list("total" = list(), "noflags" = list(), "afk" = list(), "stealth" = list(), "present" = list())
	for(var/client/X in GLOB.admins)
		.["total"] += X
		if(requiredflags != 0 && !check_rights_for(X, requiredflags))
			.["noflags"] += X
		else if(X.is_afk())
			.["afk"] += X
		else if(X.holder.fakekey)
			.["stealth"] += X
		else
			.["present"] += X

/proc/send2tgs_adminless_only(source, msg, requiredflags = R_BAN)
	var/list/adm = get_admin_counts(requiredflags)
	var/list/activemins = adm["present"]
	. = activemins.len
	if(. <= 0)
		var/final = ""
		var/list/afkmins = adm["afk"]
		var/list/stealthmins = adm["stealth"]
		var/list/powerlessmins = adm["noflags"]
		var/list/allmins = adm["total"]
		if(!afkmins.len && !stealthmins.len && !powerlessmins.len)
			final = "[msg] - No admins online"
		else
			final = "[msg] - All admins stealthed\[[english_list(stealthmins)]\], AFK\[[english_list(afkmins)]\], or lacks +BAN\[[english_list(powerlessmins)]\]! Total: [allmins.len] "
		send2tgs(source,final)
		SStopic.crosscomms_send("ahelp", final, source)


/proc/send2tgs(msg,msg2)
	msg = replacetext(replacetext(msg, "\proper", ""), "\improper", "")
	msg2 = replacetext(replacetext(msg2, "\proper", ""), "\improper", "")
	world.TgsTargetedChatBroadcast("[msg] | [msg2]", TRUE)

/proc/tgsadminwho()
	var/list/message = list("Admins: ")
	var/list/admin_keys = list()
	for(var/adm in GLOB.admins)
		var/client/C = adm
		admin_keys += "[C][C.holder.fakekey ? "(Stealth)" : ""][C.is_afk() ? "(AFK)" : ""]"

	for(var/admin in admin_keys)
		if(LAZYLEN(message) > 1)
			message += ", [admin]"
		else
			message += "[admin]"

	return jointext(message, "")

/proc/keywords_lookup(msg,external)

	//This is a list of words which are ignored by the parser when comparing message contents for names. MUST BE IN LOWER CASE!
	var/list/adminhelp_ignored_words = list("unknown","the","a","an","of","monkey","alien","as", "i")

	//explode the input msg into a list
	var/list/msglist = splittext(msg, " ")

	//generate keywords lookup
	var/list/surnames = list()
	var/list/forenames = list()
	var/list/ckeys = list()
	var/list/founds = list()
	for(var/mob/M in GLOB.mob_list)
		if(istype(M, /mob/living/carbon/human/dummy))
			continue

		var/list/indexing = list(M.real_name, M.name)
		if(M.mind)
			indexing += M.mind.name

		for(var/string in indexing)
			var/list/L = splittext(string, " ")
			var/surname_found = 0
			//surnames
			for(var/i=L.len, i>=1, i--)
				var/word = ckey(L[i])
				if(word)
					surnames[word] = M
					surname_found = i
					break
			//forenames
			for(var/i in 1 to surname_found-1)
				var/word = ckey(L[i])
				if(word)
					forenames[word] = M
			//ckeys
			ckeys[M.ckey] = M

	var/ai_found = 0
	msg = ""
	var/list/mobs_found = list()
	for(var/original_word in msglist)
		var/word = ckey(original_word)
		if(word)
			if(!(word in adminhelp_ignored_words))
				if(word == "ai")
					ai_found = 1
				else
					var/mob/found = ckeys[word]
					if(!found)
						found = surnames[word]
						if(!found)
							found = forenames[word]
					if(found)
						if(!(found in mobs_found))
							mobs_found += found
							if(!ai_found && isAI(found))
								ai_found = 1
							var/is_antag = 0
							if(found.mind?.special_role)
								is_antag = 1
							founds[++founds.len] = list("name" = found.name,
								            "real_name" = found.real_name,
								            "ckey" = found.ckey,
								            "key" = found.key,
								            "antag" = is_antag)
							msg += "[original_word]<font size='1' color='[is_antag ? "red" : "black"]'>(<A HREF='?_src_=holder;[HrefToken(TRUE)];adminmoreinfo=[REF(found)]'>?</A>|<A HREF='?_src_=holder;[HrefToken(TRUE)];adminplayerobservefollow=[REF(found)]'>F</A>)</font> "
							continue
		msg += "[original_word] "
	if(external)
		return founds

	return msg
