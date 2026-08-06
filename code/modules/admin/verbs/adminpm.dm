#define EXTERNALREPLYCOUNT 2
#define EXTERNAL_PM_USER "IRCKEY"

// HEY FUCKO, IMPORTANT NOTE!
// This file, and pretty much everything that directly handles ahelps, is VERY important
// An admin pm dropping by coding error is disastrous, because it gives no feedback to admins, so they think they're being ignored
// It is imperative that this does not happen. Therefore, runtimes are not allowed in this file
// Additionally, any runtimes here would cause admin tickets to leak into the runtime logs
// This is less of a big deal, but still bad
//
// In service of this goal of NO RUNTIMES then, we make ABSOLUTELY sure to never trust the nullness of a value
// That's why variables are so separated from logic here. It's not a good pattern typically, but it helps make assumptions clear here
// We also make SURE to fail loud, IE: if something stops the message from reaching the recipient, the sender HAS to know
// If you "refactor" this to make it "cleaner" I will send you to hell

/// Allows right clicking mobs to send an admin PM to their client, forwards the selected mob's client to cmd_admin_pm
/client/proc/cmd_admin_pm_context(mob/M in GLOB.mob_list)
	set category = null
	set name = "Admin PM Mob"
	if(!holder)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Context: Only administrators may use this command."))
		return
	if(!ismob(M))
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Context: Target mob is not a mob, somehow."))
		return
	if(!M.client)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Context: Target mob has no client."))
		return
	cmd_admin_pm(M.client, null)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Admin PM Mob") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/// Shows a list of clients we could send PMs to, then forwards our choice to cmd_admin_pm
/client/proc/cmd_admin_pm_panel()
	set category = "Admin"
	set name = "Admin PM"
	if(!holder)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Panel: Only administrators may use this command."))
		return

	var/list/targets = list()
	for(var/client/client as anything in GLOB.clients)
		var/nametag = ""
		var/mob/lad = client.mob
		var/mob_name = lad?.name
		var/real_mob_name = lad?.real_name
		if(!lad)
			nametag = "(No Mob)"
		else if(isnewplayer(lad))
			nametag = "(New Player)"
		else if(isobserver(lad))
			nametag = "[mob_name](Ghost)"
		else
			nametag = "[real_mob_name](as [mob_name])"
		targets["[nametag] - [client]"] = client

	var/target = tgui_input_list(src, "To whom shall we send a message?", "Admin PM", items = sort_list(targets))
	if (isnull(target))
		return
	cmd_admin_pm(targets[target], null)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Admin PM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/// Replies to some existing ahelp, reply to whom, which can be a client or ckey
/client/proc/cmd_ahelp_reply(whom)
	if(IsAdminAdvancedProcCall())
		return

	if(player_details.muted & MUTE_ADMINHELP)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Reply: You are unable to use admin PM-s (muted)."))
		return

	// We use the ckey here rather than keeping the client to ensure resistance to client logouts mid execution
	if(istype(whom, /client))
		var/client/boi = whom
		whom = boi.ckey

	var/ambiguous_recipient = disambiguate_client(whom)
	if(!istype(ambiguous_recipient, /client))
		if(holder)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM-Reply: Client not found."))
		return

	// Existing client case
	var/client/recipient = ambiguous_recipient

	// The ticket our recipient is using
	var/datum/help_ticket/recipient_ticket = recipient?.current_adminhelp_ticket
	// Our recipient's admin holder, if one exists
	var/datum/admins/recipient_holder = recipient?.holder
	// Our recipient's fake key, if they are faking their ckey
	var/recipient_fake_key = recipient_holder?.fakekey
	// Our ckey, with our mob's name if one exists, formatted with a reply link
	var/our_linked_name = key_name_admin(src)
	// The recipient's ckey, formatted with a reply link
	var/recipient_linked_ckey = key_name_admin(recipient, FALSE, FALSE)
	// The recipient's ckey, formatted slightly with html
	var/formatted_recipient_ckey = key_name(recipient, FALSE, FALSE)

	if(recipient_ticket)
		message_admins("[our_linked_name] has started replying to [recipient_linked_ckey]'s admin help.")

	var/request = "Private message to"
	if(recipient_fake_key)
		request = "[request] an Administrator."
	else
		request = "[request] [formatted_recipient_ckey]."

	// tgui_input_text encodes by default
	var/msg = tgui_input_text(src, "Message:", request, multiline = TRUE)

	if (!msg)
		message_admins("[our_linked_name] has cancelled their reply to [recipient_linked_ckey]'s admin help.")
		return

	cmd_admin_pm(whom, msg, html_encoded = TRUE)
	recipient_ticket?.Claim()

/// Sends an already composed reply to some existing ahelp, without prompting for input
/client/proc/cmd_ahelp_reply_instant(whom, msg, html_encoded = FALSE)
	if(IsAdminAdvancedProcCall())
		return

	if(player_details.muted & MUTE_ADMINHELP)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Reply-Instant: You are unable to use admin PM-s (muted)."))
		return

	var/ambiguous_recipient = disambiguate_client(whom)
	if(!istype(ambiguous_recipient, /client))
		if(holder)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM-Reply-Instant: Client not found."))
		return

	if (!msg)
		return
	cmd_admin_pm(whom, msg, html_encoded)

//takes input from cmd_admin_pm_context, cmd_admin_pm_panel or /client/Topic and sends them a PM.
//Fetching a message if needed.
/// whom here is a client, a ckey, or [EXTERNAL_PM_USER] if this is from tgs. msg is the default message to send
/client/proc/cmd_admin_pm(whom, msg, html_encoded = FALSE)
	if(player_details.muted & MUTE_ADMINHELP)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM: You are unable to use admin PM-s (muted)."))
		return

	if(!holder && !current_adminhelp_ticket) //no ticket? https://www.youtube.com/watch?v=iHSPf6x1Fdo
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("You can no longer reply to this ticket, please open another one by using the Adminhelp verb if need be."))
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_notice("Message: [msg]"))
		return

	// We use the ckey here rather than keeping the client to ensure resistance to client logouts mid execution
	if(istype(whom, /client))
		var/client/boi = whom
		whom = boi.ckey

	var/message_to_send = request_adminpm_message(disambiguate_client(whom), msg, html_encoded)
	if(!message_to_send)
		return

	// If we had to prompt for the message ourselves, tgui_input_text has already encoded it for us
	if(!msg)
		html_encoded = TRUE

	if(handle_spam_prevention(message_to_send, MUTE_ADMINHELP))
		// handle_spam_prevention does its own "hey buddy ya fucker up here's what happen"
		return

	message_to_send = adminpm_filter_text(disambiguate_client(whom), message_to_send, html_encoded)
	if(!message_to_send)
		return

	if(!sends_adminpm_message(disambiguate_client(whom), message_to_send, html_encoded))
		return

	notify_adminpm_message(disambiguate_client(whom), message_to_send)

/// Requests an admin pm message to send
/// ambiguous_recipient here can be either [EXTERNAL_PM_USER], indicating that this message is intended for some external chat channel
/// or a /client, which we will then store info about to ensure logout -> logins are protected as expected
/// Accepts an optional existing message, which will be used in place of asking the sender assuming all other conditions are met
/// Returns the message to send or null if no message is found
/// Sleeps
/client/proc/request_adminpm_message(ambiguous_recipient, existing_message = null, html_encoded = FALSE)
	if(IsAdminAdvancedProcCall())
		return null

	if(ambiguous_recipient == EXTERNAL_PM_USER)
		if(!externalreplyamount) //to prevent people from spamming irc/discord
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM-Message: External reply cap hit."))
			return null

		var/msg = existing_message
		if(!msg)
			// tgui_input_text encodes by default
			msg = tgui_input_text(src, "Message:", "Private message to Administrator", multiline = TRUE)

		if(!msg)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM-Message: No message input."))
			return null

		if(holder)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM-Message: Use the admin IRC/Discord channel, nerd."))
			return null
		return msg

	if(!istype(ambiguous_recipient, /client))
		if(holder)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM-Message: Client not found."))
			if(existing_message)
				to_chat(src,
					type = MESSAGE_TYPE_ADMINPM,
					html = "[span_danger("<b>Message not sent:</b>")]<br>[existing_message]")
			return null
		if(existing_message)
			current_adminhelp_ticket?.MessageNoRecipient(existing_message, sanitized = html_encoded)
			return null
		// You want to continue if there's no message instead of returning now

	var/client/recipient = ambiguous_recipient
	// Stored in case the client is deleted between this and after the message is input
	var/recipient_ckey = recipient?.ckey
	// If our recipient is an admin, this is their admins datum
	var/datum/admins/recipient_holder = recipient?.holder
	// If our recipient has a fake name, this is it
	var/recipient_fake_key = recipient_holder?.fakekey
	// Just the recipient's ckey, formatted for htmlifying stuff
	var/recipient_print_key = key_name(recipient, FALSE, FALSE)

	// The message we intend on returning
	var/msg = existing_message
	if(!msg)
		var/request = "Private message to"
		if(recipient_fake_key)
			request = "[request] an Administrator."
		else
			request = "[request] [recipient_print_key]."
		//get message text, limit it's length.and clean/escape html
		// tgui_input_text encodes by default, we need to not HTML encode again or you get &#39;s instead of 's
		msg = tgui_input_text(src, "Message:", request, multiline = TRUE)
		if(!msg)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM-Message: No message input."))
			return null

		if(player_details.muted & MUTE_ADMINHELP)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM-Message: You are unable to use admin PM-s (muted)."))
			return null

		// Client has disappeared due to logout. If they've since reconnected our caller will
		// re-resolve them from the ckey we were handed, so we can let the message through
		if(!recipient && !GLOB.directory[recipient_ckey])
			if(holder)
				to_chat(src,
					type = MESSAGE_TYPE_ADMINPM,
					html = span_danger("Error: Admin-PM-Message: Client not found."))
				to_chat(src,
					type = MESSAGE_TYPE_ADMINPM,
					html = "[span_danger("<b>Message not sent:</b>")]<br>[msg]")
			else
				current_adminhelp_ticket?.MessageNoRecipient(msg, sanitized = TRUE)
			return null

	return msg

/// Sends a pm message via the tickets system
/// ambiguous_recipient here can be either [EXTERNAL_PM_USER], indicating that this message is intended for some external chat channel
/// or a /client, in which case we send in the standard form
/// send_message is the filtered message to send
/// Returns FALSE if the send failed, TRUE otherwise
/client/proc/sends_adminpm_message(ambiguous_recipient, send_message, html_encoded = FALSE)
	if(IsAdminAdvancedProcCall())
		return FALSE

	var/raw_message = send_message

	if(holder)
		send_message = emoji_parse(send_message)

	var/keyword_parsed_msg = keywords_lookup(send_message)

	if(ambiguous_recipient == EXTERNAL_PM_USER)
		var/datum/help_ticket/new_admin_help = admin_ticket_log(
			src,
			"<font color='red'>Reply PM from-<b>[key_name(src, TRUE, TRUE)] to <i>External</i>: [keyword_parsed_msg]</font>"
		)

		// Echoes "PM to-Admins" back to the sender. Null when the ticket was closed while they were typing
		new_admin_help?.reply_to_admins_notification(raw_message)

		// The ticket's id, if we have a ticket at all
		var/ticket_id = new_admin_help?.id

		externalreplyamount--

		var/category = "Reply: [ckey]"
		if(new_admin_help)
			category = "#[ticket_id] [category]"

		send2tgs(category, raw_message)
		return TRUE

	if(!istype(ambiguous_recipient, /client))
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Send: Client not found."))
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = "[span_danger("<b>Message not sent:</b>")]<br>[send_message]")
		return FALSE

	var/client/recipient = ambiguous_recipient
	// If our recipient is an admin, this is their admins datum
	var/datum/admins/recipient_holder = recipient?.holder
	// Our own admins datum, if we have one
	var/datum/admins/our_holder = holder
	// Our current active ticket
	var/datum/help_ticket/ticket = current_adminhelp_ticket
	// Stores a bit of html with our ckey, our mob's name, and a link to reply to us with
	var/our_name_with_link = key_name(src, TRUE, TRUE)
	// Stores a bit of html with our ckey and a link to reply to us with, no mob name
	var/link_to_us = key_name(src, TRUE, FALSE)
	// Stores a bit of html with the recipient's ckey, their mob's name, and a link to reply to them with
	var/their_name_with_link = key_name(recipient, TRUE, TRUE)

	if(recipient_holder)
		if(our_holder) //both are admins
			recipient.receive_ahelp(
				our_name_with_link,
				span_linkify(keyword_parsed_msg),
				"danger",
			)

			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_notice("Admin PM to-<b>[their_name_with_link]</b>: [span_linkify("[keyword_parsed_msg]")]"))

			//omg this is dumb, just fill in both their tickets
			admin_ticket_log(src, keyword_parsed_msg, our_name_with_link, their_name_with_link, color = "teal", isSenderAdmin = TRUE, safeSenderLogged = TRUE)
			if(recipient != src) //reeee
				admin_ticket_log(recipient, keyword_parsed_msg, our_name_with_link, their_name_with_link, color = "teal", isSenderAdmin = TRUE, safeSenderLogged = TRUE)

		else //recipient is an admin but sender is not
			var/replymsg = "Reply PM from-<b>[our_name_with_link]</b>: [span_linkify("[keyword_parsed_msg]")]"
			admin_ticket_log(
				src,
				keyword_parsed_msg,
				our_name_with_link, null, "white",
				isSenderAdmin = TRUE,
				safeSenderLogged = TRUE
			)
			to_chat(recipient,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("[replymsg]"))

			ticket?.reply_to_admins_notification(send_message)

		//play the receiving admin the adminhelp sound (if they have them enabled)
		if(recipient?.prefs?.read_player_preference(/datum/preference/toggle/sound_adminhelp))
			SEND_SOUND(recipient, sound('sound/effects/adminhelp.ogg'))

		//null when an admin PMs an admin, or when the player's ticket was closed while they were typing
		if(ticket)
			SEND_SIGNAL(ticket, COMSIG_ADMIN_HELP_REPLIED)

		return TRUE

	if(!our_holder) //neither are admins
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Send: Non-admin to non-admin PM communication is forbidden."))
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = "[span_danger("<b>Message not sent:</b>")]<br>[send_message]")
		return FALSE

	//sender is an admin but recipient is not. Do BIG RED TEXT
	if(!recipient.current_adminhelp_ticket)
		var/datum/help_ticket/admin/new_ticket = new(recipient)
		new_ticket.Create(send_message, sanitized = html_encoded, is_bwoink = TRUE)

	to_chat(recipient,
		type = MESSAGE_TYPE_ADMINPM,
		html = "<font color='red' size='4'><b>-- Administrator private message --</b></font>")

	recipient.receive_ahelp(
		link_to_us,
		span_linkify("[send_message]"),
	)

	to_chat(recipient,
		type = MESSAGE_TYPE_ADMINPM,
		html = span_adminsay("<i>Click on the administrator's name to reply.</i>"))
	to_chat(src,
		type = MESSAGE_TYPE_ADMINPM,
		html = span_notice("Admin PM to-<b>[their_name_with_link]</b>: [span_linkify("[send_message]")]"))

	admin_ticket_log(recipient, keyword_parsed_msg, key_name_admin(src), null, "purple", safeSenderLogged = TRUE)

	//always play non-admin recipients the adminhelp sound
	SEND_SOUND(recipient, sound('sound/effects/adminhelp.ogg'))

	//AdminPM popup for ApocStation and anybody else who wants to use it. Set it with POPUP_ADMIN_PM in config.txt ~Carn
	if(CONFIG_GET(flag/popup_admin_pm))
		spawn()	//so we don't hold the caller proc up
			var/sender = src
			var/sendername
			if(our_holder.fakekey)
				sendername = our_holder.fakekey
			else
				sendername = key
			var/reply = tgui_input_text(recipient, send_message, "Admin PM from-[sendername]", "", multiline = TRUE)		//show message and await a reply. tgui_input_text encodes by default.
			if(recipient && reply)
				if(sender)
					recipient.cmd_admin_pm(sender, reply, html_encoded = TRUE) // sender is still about, let's reply to them.
				else
					adminhelp(reply) //sender has left, adminhelp instead
			return

	return TRUE

/// Notifies all admins about the existence of an admin pm, then logs the pm
/// ambiguous_recipient here can be either [EXTERNAL_PM_USER], indicating that this message is intended for some external chat channel
/// or a /client, in which case we send in the standard form
/// log_message is the filtered message that was sent
/client/proc/notify_adminpm_message(ambiguous_recipient, log_message)
	if(IsAdminAdvancedProcCall())
		return

	var/raw_message = log_message

	if(holder)
		log_message = emoji_parse(log_message)

	var/keyword_parsed_msg = keywords_lookup(log_message)
	// Shows our ckey and the name of any mob we might be possessing
	var/our_name = key_name(src)
	// Shows our ckey embedded inside a clickable link to reply to this message
	var/our_linked_ckey = key_name(src, TRUE, FALSE)
	// Our current active ticket
	var/datum/help_ticket/ticket = current_adminhelp_ticket

	if(ambiguous_recipient == EXTERNAL_PM_USER)
		// Guard against the possibility of a null, since it'll runtime and spit out the contents of what should be a private ticket.
		if(ticket)
			log_admin_private("PM: Ticket #[ticket.id]: [our_name]->External: [raw_message]")
		else
			log_admin_private("PM: [our_name]->External: [raw_message]")
		for(var/client/lad in GLOB.admins)
			to_chat(lad,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_notice("<B>PM: [our_linked_ckey]-&gt;External:</B> [keyword_parsed_msg]"))
		return

	if(!istype(ambiguous_recipient, /client))
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_danger("Error: Admin-PM-Notify: Client not found."))
		return

	var/client/recipient = ambiguous_recipient
	// The key of our recipient
	var/recipient_key = recipient?.key
	// Shows the recipient's ckey and the name of any mob it might be possessing
	var/recipient_name = key_name(recipient)
	// Shows the recipient's ckey embedded inside a clickable link to reply to this message
	var/recipient_linked_ckey = key_name(recipient, TRUE, FALSE)

	window_flash(recipient, ignorepref = TRUE)
	if(ticket)
		log_admin_private("PM: Ticket #[ticket.id]: [our_name]->[recipient_name]: [raw_message]")
	else
		log_admin_private("PM: [our_name]->[recipient_name]: [raw_message]")
	//we don't use message_admins here because the sender/receiver might get it too
	for(var/client/lad in GLOB.admins)
		if(lad.key == key || lad.key == recipient_key)	//check to make sure client/lad isn't the sender or recipient
			continue
		to_chat(lad,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_notice("<B>PM: [our_linked_ckey]-&gt;[recipient_linked_ckey]:</B> [keyword_parsed_msg]"))

/// Accepts a message and an ambiguous recipient (some sort of client representative, or [EXTERNAL_PM_USER])
/// Returns the filtered message if it passes all checks, or null if the send fails
/client/proc/adminpm_filter_text(ambiguous_recipient, message, html_encoded = FALSE)
	//clean the message if it's not sent by a high-rank admin
	if(ambiguous_recipient == EXTERNAL_PM_USER || !check_rights(R_SERVER|R_DEBUG, FALSE))//no sending html to the poor bots
		message = sanitize_simple(message)
		if(!html_encoded)
			message = html_encode(message)
		message = trim(message, MAX_MESSAGE_LEN)
		if(!message)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Admin-PM-Filter: Your message contained only HTML, it's been sanitized away and the message disregarded."))
			return
	return message

#define TGS_AHELP_USAGE "Usage: ticket <close|resolve|icissue|reject|reopen \[ticket #\]|list>"
/proc/TgsPm(target, msg, sender)
	var/requested_ckey = ckey(target)
	var/client/recipient = GLOB.directory[requested_ckey]

	// The ticket we want to talk about here. Either the target's active ticket, or the last one it had
	var/datum/help_ticket/ticket
	if(recipient)
		ticket = recipient.current_adminhelp_ticket
	else
		ticket = GLOB.ahelp_tickets.CKey2ActiveTicket(requested_ckey)
	// The ticket's id
	var/ticket_id = ticket?.id

	var/compliant_msg = trim(LOWER_TEXT(msg))
	var/tgs_tagged = "[sender](TGS/External)"
	var/list/splits = splittext(compliant_msg, " ")
	var/split_size = length(splits)

	if(split_size && splits[1] == "ticket")
		if(split_size < 2)
			return TGS_AHELP_USAGE
		switch(splits[2])
			if("close")
				if(ticket)
					ticket.Close(tgs_tagged)
					return "Ticket #[ticket_id] successfully closed"
			if("resolve")
				if(ticket)
					ticket.Resolve(tgs_tagged)
					return "Ticket #[ticket_id] successfully resolved"
			if("icissue")
				if(istype(ticket, /datum/help_ticket/admin))
					var/datum/help_ticket/admin/a_ticket = ticket
					a_ticket.ICIssue(tgs_tagged)
					return "Ticket #[ticket_id] successfully marked as IC issue"
			if("reject")
				if(ticket)
					ticket.Reject(tgs_tagged)
					return "Ticket #[ticket_id] successfully rejected"
			if("reopen")
				if(ticket)
					return "Error: [requested_ckey] already has ticket #[ticket_id] open"
				var/ticket_num
				// If the passed in command actually has a ticket id arg
				if(split_size >= 3)
					ticket_num = text2num(splits[3])

				if(isnull(ticket_num))
					return "Error: No/Invalid ticket id specified. [TGS_AHELP_USAGE]"

				// The ticket we're trying to reopen, if one exists
				var/datum/help_ticket/inactive_ticket = GLOB.ahelp_tickets.TicketByID(ticket_num)
				// The ckey of the player the ticket belongs to
				var/initiator_ckey = inactive_ticket?.initiator_ckey

				if(!inactive_ticket)
					return "Error: Ticket #[ticket_num] not found"
				if(initiator_ckey != requested_ckey)
					return "Error: Ticket #[ticket_num] belongs to [initiator_ckey]"

				inactive_ticket.Reopen(tgs_tagged)
				return "Ticket #[ticket_num] successfully reopened"
			if("list")
				var/list/tickets = GLOB.ahelp_tickets.TicketsByCKey(requested_ckey)
				if(!length(tickets))
					return "None"
				var/list/printable_tickets = list()
				for(var/datum/help_ticket/iterated_ticket in tickets)
					// The id of the iterated adminhelp
					var/iterated_id = iterated_ticket?.id
					var/text = ""
					if(iterated_ticket == ticket)
						text += "Active: "
					text += "#[iterated_id]"
					printable_tickets += text
				return printable_tickets.Join(", ")
			else
				return TGS_AHELP_USAGE
		return "Error: Ticket could not be found"

	// Now that we've handled command processing, we can actually send messages to the client
	if(!recipient)
		return "Error: No client"

	var/adminname
	if(CONFIG_GET(flag/show_irc_name))
		adminname = tgs_tagged
	else
		adminname = "Administrator"

	var/stealthkey = GetTgsStealthKey()

	msg = sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN))
	msg = emoji_parse(msg)

	if(!msg)
		return "Error: No message"

	// The ckey of our recipient, with a reply link, and their mob if one exists
	var/recipient_name_linked = key_name_admin(recipient)
	// The ckey of our recipient, with their mob if one exists. No link
	var/recipient_name = key_name(recipient)

	message_admins("External message from [sender] to [recipient_name_linked] : [msg]")
	log_admin_private("External PM: [sender] -> [recipient_name] : [msg]")

	to_chat(recipient,
		type = MESSAGE_TYPE_ADMINPM,
		html = "<font color='red' size='4'><b>-- Administrator private message --</b></font>")

	recipient.receive_ahelp(
		"<a href='byond://?priv_msg=[stealthkey]'>[adminname]</a>",
		msg,
	)

	to_chat(recipient,
		type = MESSAGE_TYPE_ADMINPM,
		html = span_adminsay("<i>Click on the administrator's name to reply.</i>"))

	admin_ticket_log(recipient, msg, adminname, null, "cyan", isSenderAdmin = TRUE, safeSenderLogged = TRUE)

	window_flash(recipient, ignorepref = TRUE)
	// Nullcheck because we run a winset in window flash and I do not trust byond
	if(recipient)
		//always play non-admin recipients the adminhelp sound
		SEND_SOUND(recipient, 'sound/effects/adminhelp.ogg')

		recipient.externalreplyamount = EXTERNALREPLYCOUNT
	return "Message Successful"

/// Gets TGS's stealth key, generates one if none is found
/proc/GetTgsStealthKey()
	var/static/tgs_stealth_key
	if(tgs_stealth_key)
		return tgs_stealth_key

	tgs_stealth_key = generateStealthCkey()
	GLOB.stealthminID[EXTERNAL_PM_USER] = tgs_stealth_key
	return tgs_stealth_key

/// Takes an argument which could be either a ckey, /client, or IRC marker, and returns a client if possible
/// Returns [EXTERNAL_PM_USER] if an IRC marker is detected
/// Otherwise returns null
/proc/disambiguate_client(whom)
	if(istype(whom, /client))
		return whom

	if(!istext(whom) || !(length(whom) >= 1))
		return null

	var/searching_ckey = whom
	if(IS_FAKE_KEY(whom))
		searching_ckey = findTrueKey(whom)

	if(searching_ckey == EXTERNAL_PM_USER)
		return EXTERNAL_PM_USER

	return GLOB.directory[searching_ckey]

/client/proc/receive_ahelp(reply_to, message, span_class = "adminsay")
	to_chat(
		src,
		type = MESSAGE_TYPE_ADMINPM,
		html = "<span class='[span_class]'>Admin PM from-<b>[reply_to]</b>: [message]</span>",
		allow_linkify = TRUE,
	)

	current_adminhelp_ticket?.player_replied = FALSE

	SEND_SIGNAL(src, COMSIG_ADMIN_HELP_RECEIVED, message)

#undef EXTERNALREPLYCOUNT

#undef EXTERNAL_PM_USER

#undef TGS_AHELP_USAGE
