GLOBAL_DATUM_INIT(ahelp_tickets, /datum/help_tickets/admin, new)

/// Client Stuff

/client/var/adminhelptimerid = 0	//a timer id for returning the ahelp verb
/client/var/datum/help_ticket/current_adminhelp_ticket	//the current ticket the (usually) not-admin client is dealing with

/client/proc/openTicketManager()
	set name = "Ticket Manager"
	set desc = "Opens the ticket manager"
	set category = "Admin"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	GLOB.ahelp_tickets.BrowseTickets(usr)

/datum/help_tickets/admin/BrowseTickets(mob/user)
	var/client/C = user.client
	if(!C)
		return
	var/datum/admins/admin_datum = GLOB.admin_datums[C.ckey]
	if(!admin_datum)
		message_admins("[C.ckey] attempted to browse tickets, but had no admin datum")
		return
	if(!admin_datum.admin_interface)
		admin_datum.admin_interface = new(user)
	admin_datum.admin_interface.ui_interact(user)

/client/proc/giveadminhelpverb()
	if(!src)
		return
	src.add_verb(/client/verb/adminhelp)
	deltimer(adminhelptimerid)
	adminhelptimerid = 0

/client/verb/adminhelp()
	set category = "Admin"
	set name = "Adminhelp"
	var/msg

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return

	//handle muting and automuting
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, span_danger("Error: Admin-PM: You cannot send adminhelps (Muted)."))
		return
	if(handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	msg = trim(tgui_input_text(src, "Please describe your problem concisely and an admin will help as soon as they're able. Include the names of the people you are ahelping against if applicable.", "Adminhelp contents", multiline = TRUE, encode = FALSE))

	if(!msg)
		return

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Adminhelp") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	if(current_adminhelp_ticket)
		if(tgui_alert(usr, "You already have a ticket open. Is this for the same issue?", buttons = list("Yes", "No")) != "No")
			if(current_adminhelp_ticket)
				current_adminhelp_ticket.MessageNoRecipient(msg)
				current_adminhelp_ticket.TimeoutVerb()
				return
			else
				to_chat(usr, span_warning("Ticket not found, creating new one..."))
		else
			current_adminhelp_ticket.AddInteraction("yellow", "[usr] opened a new ticket.")
			current_adminhelp_ticket.Close()

	var/datum/help_ticket/admin/ticket = new(src)
	ticket.Create(msg, FALSE)

/// Ticket List UI

/datum/help_ui/admin/ui_state(mob/user)
	return GLOB.admin_state

/datum/help_ui/admin/get_data_glob()
	return GLOB.ahelp_tickets

/datum/help_ui/admin/add_additional_ticket_data(data)
	// Add mentorhelp tickets to admin panel
	var/datum/help_tickets/data_glob = GLOB.mhelp_tickets
	data["unclaimed_tickets_mentor"] = data_glob.get_ui_ticket_data(TICKET_UNCLAIMED)
	data["open_tickets_mentor"] = data_glob.get_ui_ticket_data(TICKET_ACTIVE)
	data["closed_tickets_mentor"] = data_glob.get_ui_ticket_data(TICKET_CLOSED)
	data["resolved_tickets_mentor"] = data_glob.get_ui_ticket_data(TICKET_RESOLVED)
	return data

/datum/help_ui/admin/get_additional_ticket_data(ticket_id)
	return GLOB.mhelp_tickets.TicketByID(ticket_id) // make sure mhelp tickets can be retrieved for actions

/datum/help_ui/admin/check_permission(mob/user)
	return !!GLOB.admin_datums[user.ckey]

/datum/help_ui/admin/reply(whom)
	usr.client.cmd_ahelp_reply(whom)

/// Tickets Holder

/datum/help_tickets/admin

/datum/help_tickets/admin/get_active_ticket(client/C)
	return C.current_adminhelp_ticket

/datum/help_tickets/admin/set_active_ticket(client/C, datum/help_ticket/ticket)
	C.current_adminhelp_ticket = ticket

/// Ticket Datum

/datum/help_ticket/admin
	var/heard_by_no_admins = FALSE
	/// is the ahelp player to admin (not bwoink) or admin to player (bwoink)
	var/bwoink

/datum/help_ticket/admin/get_data_glob()
	return GLOB.ahelp_tickets

/datum/help_ticket/admin/check_permission(mob/user)
	return !!GLOB.admin_datums[user.ckey]

/datum/help_ticket/admin/check_permission_act(mob/user)
	return !!GLOB.admin_datums[user.ckey] && check_rights(R_ADMIN)

/datum/help_ticket/admin/ui_state(mob/user)
	return GLOB.admin_state

/datum/help_ticket/admin/reply(whom, msg)
	usr.client.cmd_ahelp_reply_instant(whom, msg)

/datum/help_ticket/admin/Create(msg, sanitized = FALSE, is_bwoink)
	if(!..())
		return FALSE
	if(is_bwoink)
		AddInteraction("blue", name, usr.ckey, initiator_key_name, "Administrator", "You")
		message_admins("<font color='blue'>Ticket [TicketHref("#[id]")] created</font>")
		Claim()	//Auto claim bwoinks
	else
		MessageNoRecipient(msg, sanitized = sanitized)

		//send it to tgs if nobody is on and tell us how many were on
		var/admin_number_present = send2tgs_adminless_only(initiator_ckey, "Ticket #[id]: [msg]")
		log_admin_private("Ticket #[id]: [key_name(initiator)]: [name] - heard by [admin_number_present] non-AFK admins who have +BAN.")
		if(admin_number_present <= 0)
			to_chat(initiator, span_notice("No active admins are online, your adminhelp was sent through TGS to admins who are available. This may use IRC or Discord."), type = message_type)
			heard_by_no_admins = TRUE

	bwoink = is_bwoink
	if(!bwoink)
		sendadminhelp2ext("**ADMINHELP: (#[id]) [initiator.key]: ** \"[msg]\" [heard_by_no_admins ? "**(NO ADMINS)**" : "" ]")
	return TRUE

/datum/help_ticket/admin/NewFrom(datum/help_ticket/old_ticket)
	if(!..())
		return FALSE
	MessageNoRecipient(initial_msg, FALSE)
	//send it to tgs if nobody is on and tell us how many were on
	var/admin_number_present = send2tgs_adminless_only(initiator_ckey, "Ticket #[id]: [initial_msg]")
	log_admin_private("Ticket #[id]: [key_name(initiator)]: [name] - heard by [admin_number_present] non-AFK admins who have +BAN.")
	if(admin_number_present <= 0)
		to_chat(initiator, span_notice("No active admins are online, your adminhelp was sent through TGS to admins who are available. This may use IRC or Discord."))
		heard_by_no_admins = TRUE
	sendadminhelp2ext("**ADMINHELP: (#[id]) [initiator.key]: ** \"[initial_msg]\" [heard_by_no_admins ? "**(NO ADMINS)**" : "" ]")
	return TRUE

/datum/help_ticket/admin/AddInteraction(msg_color, message, name_from, name_to, safe_from, safe_to)
	if(heard_by_no_admins && usr && usr.ckey != initiator_ckey)
		heard_by_no_admins = FALSE
		send2tgs(initiator_ckey, "Ticket #[id]: Answered by [key_name(usr)]")
	..()

/datum/help_ticket/admin/TimeoutVerb()
	initiator.remove_verb(/client/verb/adminhelp)
	initiator.adminhelptimerid = addtimer(CALLBACK(initiator, TYPE_PROC_REF(/client, giveadminhelpverb)), 1200, TIMER_STOPPABLE)

/datum/help_ticket/admin/get_ticket_additional_data(mob/user, list/data)
	data["antag_status"] = "None"
	if(initiator)
		var/mob/living/M = initiator.mob
		if(M?.mind?.antag_datums)
			var/datum/antagonist/AD = M.mind.antag_datums[1]
			data["antag_status"] = AD.name
	return data

/datum/help_ticket/admin/key_name_ticket(mob/user)
	return key_name_admin(user)

/datum/help_ticket/admin/message_ticket_managers(msg)
	message_admins(msg)

/datum/help_ticket/admin/MessageNoRecipient(msg, add_to_ticket = TRUE, sanitized = FALSE)
	var/ref_src = "[REF(src)]"
	var/sanitized_msg = sanitized ? msg : sanitize(msg)

	//Message to be sent to all admins
	var/admin_msg = span_adminnotice("[span_adminhelp("Ticket [TicketHref("#[id]", ref_src)]")]<b>: [LinkedReplyName(ref_src)] [FullMonty(ref_src)]:</b> [span_linkify("[keywords_lookup(sanitized_msg)]")]")

	if(add_to_ticket)
		AddInteraction("red", msg, initiator_key_name, claimee_key_name, "You", "Administrator")
	log_admin_private("Ticket #[id]: [key_name(initiator)]: [msg]")

	//send this msg to all admins
	for(var/client/X in GLOB.admins)
		if(X.prefs.read_player_preference(/datum/preference/toggle/sound_adminhelp))
			SEND_SOUND(X, sound(reply_sound))
		window_flash(X, ignorepref = TRUE)
		to_chat(X,
			type = message_type,
			html = admin_msg)

	//show it to the person adminhelping too
	if(add_to_ticket)
		to_chat(initiator,
			type = message_type,
			html = span_adminnotice("PM to-<b>Admins</b>: [span_linkify("[sanitized_msg]")]"))


/datum/help_ticket/admin/proc/FullMonty(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	. = ADMIN_FULLMONTY_NONAME(initiator.mob)
	if(state <= TICKET_ACTIVE)
		. += ClosureLinks(ref_src)

/datum/help_ticket/admin/proc/ClosureLinks(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	. = " (<A HREF='BYOND://?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=reject'>REJT</A>)"
	. += " (<A HREF='BYOND://?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=icissue'>IC</A>)"
	. += " (<A HREF='BYOND://?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=close'>CLOSE</A>)"
	. += " (<A HREF='BYOND://?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=resolve'>RSLVE</A>)"
	. += " (<A HREF='BYOND://?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=mhelp'>MHELP</A>)"

/datum/help_ticket/admin/LinkedReplyName(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	return "<A HREF='BYOND://?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=reply'>[initiator_key_name]</A>"

/datum/help_ticket/admin/TicketHref(msg, ref_src, action = "ticket")
	if(!ref_src)
		ref_src = "[REF(src)]"
	return "<A HREF='BYOND://?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=[action]'>[msg]</A>"

/datum/help_ticket/admin/blackbox_feedback(increment, data)
	SSblackbox.record_feedback("tally", "ahelp_stats", increment, data)

/// Resolve ticket with IC Issue message
/datum/help_ticket/admin/proc/ICIssue(key_name = key_name_ticket(usr))
	if(state > TICKET_ACTIVE)
		return

	if(!claimee)
		Claim(silent = TRUE)

	if(initiator)
		addtimer(CALLBACK(initiator, TYPE_PROC_REF(/client,giveadminhelpverb)), 5 SECONDS)
		SEND_SOUND(initiator, sound(reply_sound))
		resolve_message(status = "marked as IC Issue!", message = "\A [handling_name] has handled your ticket and has determined that the issue you are facing is an in-character issue and does not require [handling_name] intervention at this time.<br />\
		For further resolution, you should pursue options that are in character, such as filing a report with security or a head of staff.<br />\
		Thank you for creating a ticket, the adminhelp verb will be returned to you shortly.")

	blackbox_feedback(1, "IC")
	var/msg = "<span class='[span_class]'>Ticket [TicketHref("#[id]")] marked as IC by [key_name]</span>"
	message_admins(msg)
	log_admin_private(msg)
	AddInteraction("red", "Marked as IC issue by [key_name]")
	Resolve(silent = TRUE)

	if(!bwoink)
		sendadminhelp2ext("Ticket #[id] marked as IC by [key_name(usr, include_link = FALSE)]")

/datum/help_ticket/admin/proc/MHelpThis(key_name = key_name_ticket(usr))
	if(state > TICKET_ACTIVE)
		return

	if(!claimee)
		Claim(silent = TRUE)

	if(initiator)
		initiator.giveadminhelpverb()
		SEND_SOUND(initiator, sound(reply_sound))
		resolve_message(status = "De-Escalated to Mentorhelp!", message = "This question may regard <b>game mechanics or how-tos</b>. Such questions should be asked with <b>Mentorhelp</b>.")

	blackbox_feedback(1, "mhelp this")
	var/msg = "<span class='[span_class]'>Ticket [TicketHref("#[id]")] transferred to mentorhelp by [key_name]</span>"
	AddInteraction("red", "Transferred to mentorhelp by [key_name].")
	if(!bwoink)
		sendadminhelp2ext("Ticket #[id] transferred to mentorhelp by [key_name(usr, include_link = FALSE)]")
	Close(silent = TRUE, hide_interaction = TRUE)
	if(initiator.prefs.muted & MUTE_MHELP)
		message_admins(src, span_danger("Attempted de-escalation to mentorhelp failed because [initiator_key_name] is mhelp muted."))
		return
	message_admins(msg)
	log_admin_private(msg)
	var/datum/help_ticket/mentor/ticket = new(initiator)
	ticket.NewFrom(src)

/// Forwarded action from admin/Topic
/datum/help_ticket/admin/proc/Action(action)
	testing("Ahelp action: [action]")
	switch(action)
		if("ticket")
			TicketPanel()
		if("retitle")
			Retitle()
		if("reject")
			Reject()
		if("reply")
			usr.client.cmd_ahelp_reply(initiator)
		if("icissue")
			ICIssue()
		if("close")
			Close()
		if("resolve")
			Resolve()
		if("reopen")
			Reopen()
		if("mhelp")
			MHelpThis()

/datum/help_ticket/admin/Claim(key_name = key_name_ticket(usr), silent = FALSE)
	..()
	if(!bwoink && !silent && !claimee)
		sendadminhelp2ext("Ticket #[id] is being investigated by [key_name(usr, include_link = FALSE)]")

/datum/help_ticket/admin/Close(key_name = key_name_ticket(usr), silent = FALSE, hide_interaction = FALSE)
	..()
	if(!bwoink && !silent)
		sendadminhelp2ext("Ticket #[id] closed by [key_name(usr, include_link = FALSE)]")

/datum/help_ticket/admin/Resolve(key_name = key_name_ticket(usr), silent = FALSE)
	..()
	addtimer(CALLBACK(initiator, TYPE_PROC_REF(/client, giveadminhelpverb)), 5 SECONDS)
	if(!bwoink)
		sendadminhelp2ext("Ticket #[id] resolved by [key_name(usr, include_link = FALSE)]")

/datum/help_ticket/admin/Reject(key_name = key_name_ticket(usr), extra_text = ", and clearly state the names of anybody you are reporting")
	..()
	if(initiator)
		initiator.giveadminhelpverb()
	if(!bwoink)
		sendadminhelp2ext("Ticket #[id] rejected by [key_name(usr, include_link = FALSE)]")

/datum/help_ticket/admin/resolve_message(status = "Resolved", message = null, extratext = " If your ticket was a report, then the appropriate action has been taken where necessary.")
	..()
