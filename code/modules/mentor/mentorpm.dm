/// Sends a mentor PM to the relevant ticket log and client
/// - whom: a CKEY, a Stealth Key, or a client
/// - msg: the message to send
/client/proc/cmd_mentor_pm(whom, msg, html_encoded = FALSE)
	if(player_details.muted & MUTE_MHELP)
		to_chat(src, span_danger("Error: Mentor-PM: You are unable to use mentor PM-s (muted)."), type = MESSAGE_TYPE_MENTORPM)
		return

	if(!GLOB.mentor_datums[ckey] && !current_mentorhelp_ticket)	//no ticket? https://www.youtube.com/watch?v=iHSPf6x1Fdo
		to_chat(src, span_danger("You can no longer reply to this ticket, please open another one by using the Mentorhelp verb if need be."), type = MESSAGE_TYPE_MENTORPM)
		to_chat(src, span_notice("Message: [msg]"), type = MESSAGE_TYPE_MENTORPM)
		return

	var/client/recipient
	if(istext(whom))
		if(whom[1] == "@")
			whom = findStealthKey(whom)
		recipient = GLOB.directory[whom]
	else if(istype(whom, /client))
		recipient = whom

	if(!recipient)
		if(GLOB.mentor_datums[ckey])
			to_chat(src, span_danger("Error: Mentor-PM: Client not found."), type = MESSAGE_TYPE_MENTORPM)
			if(msg)
				to_chat(src, msg)
			return
		else if(msg) // you want to continue if there's no message instead of returning now
			current_mentorhelp_ticket.MessageNoRecipient(msg)
			return

	//get message text, limit it's length.and clean/escape html
	if(!msg)
		msg = tgui_input_text(src, "Message:", "Private message to [(!recipient || recipient.holder?.fakekey) ? "a Mentor" : key_name_mentor(recipient, FALSE)].", multiline = TRUE)
		if(!msg)
			return
		// we need to not HTML encode again or you get &#39;s instead of 's
		html_encoded = TRUE

		if(player_details.muted & MUTE_MHELP)
			to_chat(src, span_danger("Error: Mentor-PM: You are unable to use mentor PM-s (muted)."), type = MESSAGE_TYPE_MENTORPM)
			return

		if(!recipient)
			if(holder)
				to_chat(src, span_danger("Error: Mentor-PM: Client not found."), type = MESSAGE_TYPE_MENTORPM)
			else
				current_mentorhelp_ticket.MessageNoRecipient(msg, sanitized = TRUE)
			return

	if (src.handle_spam_prevention(msg,MUTE_MHELP))
		return

	//clean the message if it's not sent by a high-rank admin
	if(!check_rights(R_SERVER|R_DEBUG,0))//no sending html to the poor bots
		msg = sanitize_simple(msg)
		if(!html_encoded)
			msg = html_encode(msg)
		msg = trim(msg, MAX_MESSAGE_LEN)
		if(!msg)
			return

	var/rawmsg = msg

	if(GLOB.mentor_datums[ckey])
		msg = emoji_parse(msg)
	SEND_SOUND(recipient, sound('sound/items/bikehorn.ogg'))

	if(recipient.is_mentor())
		if(is_mentor())//both are mentors
			to_chat(recipient, span_mentorfrom("Mentor PM from-<b>[key_name_mentor(src, recipient)]</b>: [msg]"), type = MESSAGE_TYPE_MENTORPM)
			to_chat(src, span_mentorto("Mentor PM to-<b>[key_name_mentor(recipient, recipient)]</b>: [msg]"), type = MESSAGE_TYPE_MENTORPM)
			admin_ticket_log(src, msg, key_name_mentor(src, recipient), key_name_mentor(recipient, src), color="teal", isSenderAdmin = TRUE, safeSenderLogged = TRUE, is_admin_ticket = FALSE)
			if(recipient != src)
				admin_ticket_log(recipient, msg, key_name_mentor(src, recipient), key_name_mentor(recipient, src), color="teal", isSenderAdmin = TRUE, safeSenderLogged = TRUE, is_admin_ticket = FALSE)

		else		//recipient is an mentor but sender is not
			to_chat(recipient, span_mentorfrom("Reply PM from-<b>[key_name_mentor(src, recipient)]</b>: [msg]"), type = MESSAGE_TYPE_MENTORPM)
			to_chat(src, span_mentorto("Mentor PM to-<b>Mentors</b>: [msg]"), type = MESSAGE_TYPE_MENTORPM)
			admin_ticket_log(src, msg, key_name_mentor(src, recipient, TRUE), null, "white", isSenderAdmin = TRUE, safeSenderLogged = TRUE, is_admin_ticket = FALSE)

	else
		if(is_mentor())	//sender is an mentor but recipient is not.
			to_chat(recipient, span_mentorfrom("Mentor PM from-<b>[key_name_mentor(src, recipient)]</b>: [msg]"), type = MESSAGE_TYPE_MENTORPM)
			to_chat(src, span_mentorto("Mentor PM to-<b>[key_name_mentor(recipient, recipient)]</b>: [msg]"), type = MESSAGE_TYPE_MENTORPM)
			admin_ticket_log(recipient, msg, key_name_mentor(src), null, "purple", safeSenderLogged = TRUE, is_admin_ticket = FALSE)

	log_mentor("Mentor PM: [key_name(src)]->[key_name(recipient)]: [rawmsg]")
	for(var/client/X in GLOB.mentors | GLOB.admins)
		if(X.key!=key && X.key!=recipient.key)	//check client/X is an Mentor and isn't the sender or recipient
			to_chat(X, "<B>[span_mentorto("Mentor PM: [key_name_mentor(src, !!X)]-&gt;[key_name_mentor(recipient, !!X)]:</B> [span_mentorhelp(msg)]")]", type = MESSAGE_TYPE_MENTORPM) //inform X

/// Basically the same thing as key_name_admin but with the mentorPM key instead
/proc/key_name_mentor(whom, include_link = null)
	return key_name(whom, include_link = include_link, include_name = FALSE, href="_src_=mentor;mentor_msg", include_external_name = TRUE)

/// Used when Reply is clicked for a ticket in chat - informs other mentors when you start typing.
/client/proc/cmd_mhelp_reply(whom)
	if(player_details.muted & MUTE_MHELP)
		to_chat(src, span_danger("Error: Mentor-PM: You are unable to use mentor PM-s (muted)."), type = MESSAGE_TYPE_MENTORPM)
		return
	var/client/C
	if(istext(whom))
		if(whom[1] == "@")
			whom = findStealthKey(whom)
		C = GLOB.directory[whom]
	else if(istype(whom, /client))
		C = whom
	if(!C)
		if(holder)
			to_chat(src, span_danger("Error: Mentor-PM: Client not found."), type = MESSAGE_TYPE_MENTORPM)
		return

	var/datum/help_ticket/AH = C.current_mentorhelp_ticket

	if(AH)
		message_mentors("[key_name_mentor(src, TRUE)] has started replying to [key_name_mentor(C, FALSE)]'s mentor help.", target = src)
	var/msg = tgui_input_text(src,"Message:", "Private message to [C.holder?.fakekey ? "a Mentor" : key_name_mentor(C, FALSE)].", multiline = TRUE)
	if (!msg)
		message_mentors("[key_name_mentor(src, TRUE)] has cancelled their reply to [key_name_mentor(C, FALSE)]'s mentor help.", target = src)
		return
	cmd_mentor_pm(whom, msg, html_encoded = TRUE)
	AH.Claim()

/// Use when PMing from a ticket
/client/proc/cmd_mhelp_reply_instant(whom, msg)
	if(player_details.muted & MUTE_MHELP)
		to_chat(src, span_danger("Error: Mentor-PM: You are unable to use mentor PM-s (muted)."), type = MESSAGE_TYPE_MENTORPM)
		return
	var/client/C
	if(istext(whom))
		if(whom[1] == "@")
			whom = findStealthKey(whom)
		C = GLOB.directory[whom]
	else if(istype(whom, /client))
		C = whom
	if(!C)
		if(holder)
			to_chat(src, span_danger("Error: Mentor-PM: Client not found."), type = MESSAGE_TYPE_MENTORPM)
		return

	if (!msg)
		return
	cmd_mentor_pm(whom, msg)

/// Send a message to all mentors (MENTOR LOG:)
/proc/message_mentors(msg, client/target)
	msg = span_mentor("[span_prefix("MENTOR LOG:")] [span_messagelinkify("[msg]")]")
	for(var/client/client in GLOB.mentors | GLOB.admins)
		to_chat(client, msg, type = MESSAGE_TYPE_MENTORLOG, avoid_highlighting = client == target)
