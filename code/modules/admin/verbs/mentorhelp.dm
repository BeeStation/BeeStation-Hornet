GLOBAL_DATUM_INIT(mhelp_tickets, /datum/help_tickets/mentor, new)

/// Client Stuff

/client/var/mentorhelptimerid = 0	//a timer id for returning the mhelp verb
/client/var/datum/help_ticket/current_mentorhelp_ticket	//the current ticket the (usually) not-admin client is dealing with

/client/proc/openMentorTicketManager()
	set name = "Mentor Ticket Manager"
	set desc = "Opens the mentor ticket manager"
	set category = "Mentor"
	GLOB.mhelp_tickets.BrowseTickets(usr)

/datum/help_tickets/mentor/BrowseTickets(mob/user)
	var/client/C = user.client
	if(!C)
		return
	var/datum/mentors/mentor_datum = GLOB.mentor_datums[C.ckey]
	if(!mentor_datum)
		message_admins("[C.ckey] attempted to browse mentor tickets, but had no mentor datum")
		return
	if(!mentor_datum.mentor_interface)
		mentor_datum.mentor_interface = new(user)
	mentor_datum.mentor_interface.ui_interact(user)

/client/proc/givementorhelpverb()
	if(!src)
		return
	src.add_verb(/client/verb/mentorhelp)
	deltimer(mentorhelptimerid)
	mentorhelptimerid = 0

/client/verb/mentorhelp()
	set category = "Mentor"
	set name = "Mentorhelp"
	var/msg

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return

	//handle muting and automuting
	if(prefs.muted & MUTE_MHELP)
		to_chat(src, span_danger("Error: Mentor-PM: You cannot send mentorhelps (Muted)."))
		return
	if(handle_spam_prevention(msg, MUTE_MHELP))
		return

	msg = trim(tgui_input_text(src, "Please describe your problem concisely and a mentor will help as soon as they're able. Remember: Mentors cannot see you or what you're doing. Describe the problem in full detail.", "Mentorhelp contents", multiline = TRUE, encode = FALSE))

	if(!msg)
		return

	SSblackbox.record_feedback("tally", "mentor_verb", 1, "Mentorhelp") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	if(current_mentorhelp_ticket)
		if(tgui_alert(usr, "You already have a ticket open. Is this for the same issue?", buttons = list("Yes", "No")) != "No")
			if(current_mentorhelp_ticket)
				current_mentorhelp_ticket.MessageNoRecipient(msg)
				current_mentorhelp_ticket.TimeoutVerb()
				return
			else
				to_chat(usr, span_warning("Ticket not found, creating new one..."))
		else
			current_mentorhelp_ticket.AddInteraction("yellow", "[usr] opened a new ticket.")
			current_mentorhelp_ticket.Close()

	var/datum/help_ticket/mentor/ticket = new(src)
	ticket.Create(msg)

/// Ticket List UI

/datum/help_ui/mentor/ui_state(mob/user)
	return GLOB.mentor_state

/datum/help_ui/mentor/get_data_glob()
	return GLOB.mhelp_tickets

/datum/help_ui/mentor/check_permission(mob/user)
	return !!GLOB.mentor_datums[user.ckey]

/datum/help_ui/mentor/reply(whom)
	usr.client.cmd_mhelp_reply(whom)

/// Tickets Holder

/datum/help_tickets/mentor

/datum/help_tickets/mentor/get_active_ticket(client/C)
	return C.current_mentorhelp_ticket

/datum/help_tickets/mentor/set_active_ticket(client/C, datum/help_ticket/ticket)
	C.current_mentorhelp_ticket = ticket

/// Ticket Datum

/datum/help_ticket/mentor
	span_class = "mentorhelp"
	handling_name = "mentor"
	verb_name = "Mentorhelp"
	reply_sound = "sound/items/bikehorn.ogg"
	message_type = MESSAGE_TYPE_MENTORPM

/datum/help_ticket/mentor/New(client/C)
	..()
	initiator_key_name = key_name_mentor(initiator, FALSE)

/datum/help_ticket/mentor/get_data_glob()
	return GLOB.mhelp_tickets

/datum/help_ticket/mentor/check_permission(mob/user)
	return !!GLOB.mentor_datums[user.ckey]

/datum/help_ticket/mentor/check_permission_act(mob/user)
	return !!GLOB.mentor_datums[user.ckey]// && check_rights(R_MENTOR) once this exists

/datum/help_ticket/mentor/ui_state(mob/user)
	return GLOB.mentor_state

/datum/help_ticket/mentor/get_ticket_additional_data(mob/user, list/data)
	data["is_admin_type"] = FALSE
	return data

/datum/help_ticket/mentor/reply(whom, msg)
	usr.client.cmd_mhelp_reply_instant(whom, msg)

/datum/help_ticket/mentor/Create(msg)
	if(!..())
		return FALSE
	MessageNoRecipient(msg)
	return TRUE

/datum/help_ticket/mentor/NewFrom(datum/help_ticket/old_ticket)
	if(!..())
		return FALSE
	MessageNoRecipient(initial_msg, add_to_ticket = FALSE, sanitized = TRUE) // initial_msg is sanitized already
	return TRUE

/datum/help_ticket/mentor/TimeoutVerb()
	initiator.remove_verb(/client/verb/mentorhelp)
	initiator.mentorhelptimerid = addtimer(CALLBACK(initiator, TYPE_PROC_REF(/client, givementorhelpverb)), 1200, TIMER_STOPPABLE)

/datum/help_ticket/mentor/key_name_ticket(mob/user)
	return key_name_mentor(user)

/datum/help_ticket/mentor/message_ticket_managers(msg)
	message_mentors(msg, target = claimee)

/datum/help_ticket/mentor/MessageNoRecipient(msg, add_to_ticket = TRUE, sanitized = FALSE)
	var/ref_src = "[REF(src)]"
	var/sanitized_msg = sanitized ? msg : sanitize(msg)

	//Message to be sent to all admins
	var/admin_msg = span_mentornotice("[span_mentorhelp("Mentor Ticket [TicketHref("#[id]", ref_src)]")]: [LinkedReplyName(ref_src)] [ClosureLinks(ref_src)]: [span_linkify("[sanitized_msg]")]")

	if(add_to_ticket)
		AddInteraction("red", msg, initiator_key_name, claimee_key_name, "You", "Mentor")
	log_admin_private("Mentor Ticket #[id]: [key_name_ticket(initiator)]: [msg]")

	//send this msg to all admins
	for(var/client/X in GLOB.mentors | GLOB.admins)
		if(X.prefs.read_player_preference(/datum/preference/toggle/sound_adminhelp))
			SEND_SOUND(X, sound(reply_sound))
		window_flash(X, ignorepref = TRUE)
		to_chat(X, admin_msg, type = message_type)

	//show it to the person adminhelping too
	if(add_to_ticket)
		to_chat(initiator, span_mentornotice("PM to-<b>Mentors</b>: [span_linkify("[sanitized_msg]")]"), type = message_type)

/datum/help_ticket/mentor/proc/ClosureLinks(ref_src)
	if(state > TICKET_ACTIVE)
		return ""
	if(!ref_src)
		ref_src = "[REF(src)]"
	. = " (<A HREF='BYOND://?_src_=mentor;[MentorHrefToken(TRUE)];mhelp=[ref_src];mhelp_action=reject'>REJT</A>)"
	. += " (<A HREF='BYOND://?_src_=mentor;[MentorHrefToken(TRUE)];mhelp=[ref_src];mhelp_action=resolve'>RSLVE</A>)"
	. += " (<A HREF='BYOND://?_src_=mentor;[MentorHrefToken(TRUE)];mhelp=[ref_src];mhelp_action=ahelp'>AHELP</A>)"

/datum/help_ticket/mentor/LinkedReplyName(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	return "<A HREF='BYOND://?_src_=mentor;[MentorHrefToken(TRUE)];mhelp=[ref_src];mhelp_action=reply'>[initiator_key_name]</A>"

/datum/help_ticket/mentor/TicketHref(msg, ref_src, action = "ticket")
	if(!ref_src)
		ref_src = "[REF(src)]"
	return "<A HREF='BYOND://?_src_=mentor;[MentorHrefToken(TRUE)];mhelp=[ref_src];mhelp_action=[action]'>[msg]</A>"

/datum/help_ticket/mentor/blackbox_feedback(increment, data)
	SSblackbox.record_feedback("tally", "mhelp_stats", increment, data)

/// Close ticket and escalate to adminhelp, auto-converts and creates a new admin ticket with the same history
/datum/help_ticket/mentor/proc/AHelpThis(key_name = key_name_ticket(usr))
	if(state > TICKET_ACTIVE)
		return

	if(!claimee)
		Claim(silent = TRUE)

	if(initiator)
		initiator.givementorhelpverb()
		SEND_SOUND(initiator, sound(reply_sound))
		resolve_message(status = "Escalated to Adminhelp!", message = "This question is for administrators. Such questions should be asked with <b>Adminhelp</b>.")

	blackbox_feedback(1, "ahelp this")
	var/msg = "<span class='[span_class]'>Mentor Ticket [TicketHref("#[id]")] transferred to adminhelp by [key_name]</span>"
	AddInteraction("red", "Transferred to adminhelp by [key_name].")
	Close(silent = TRUE, hide_interaction = TRUE)
	if(initiator.prefs.muted & MUTE_ADMINHELP)
		message_ticket_managers(src, span_danger("Attempted escalation to adminhelp failed because [initiator_key_name] is ahelp muted. It's possible the user is attempting to abuse the mhelp system to get around this."))
		log_admin_private(src, span_danger("[initiator_ckey] blocked from mhelp escalation (performed by [key_name]) to ahelp due to mute. Possible abuse of mhelp system."))
		return
	message_ticket_managers(msg)
	log_admin_private(msg)
	var/datum/help_ticket/admin/ticket = new(initiator)
	ticket.NewFrom(src)

/// Forwarded action from mentor/Topic
/datum/help_ticket/mentor/proc/Action(action)
	testing("Mhelp action: [action]")
	switch(action)
		if("ticket")
			TicketPanel()
		if("retitle")
			Retitle()
		if("reject")
			Reject()
		if("reply")
			usr.client.cmd_mhelp_reply(initiator)
		if("close")
			Close()
		if("resolve")
			Resolve()
		if("reopen")
			Reopen()
		if("ahelp")
			AHelpThis()

/datum/help_ticket/mentor/Resolve(key_name = key_name_ticket(usr), silent = FALSE)
	..()
	addtimer(CALLBACK(initiator, TYPE_PROC_REF(/client, givementorhelpverb)), 50)

/datum/help_ticket/mentor/Reject(key_name = key_name_ticket(usr))
	..()
	if(initiator)
		initiator.givementorhelpverb()
