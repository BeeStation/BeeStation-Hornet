//This file was ported from hippie, used to be indented with spaces, and is the single worst corner of this codebase next to voice radio. For the love of god please rewrite this.
//8/3/2022: I partially rewrote it but I haven't nuked everything, enjoy

//shows a list of clients we could send PMs to, then forwards our choice to cmd_Mentor_pm
/client/proc/cmd_mentor_pm_panel()
	set category = "Mentor"
	set name = "Mentor PM"
	if(!is_mentor())
		to_chat(src, "<font color='red'>Error: Mentor-PM-Panel: Only Mentors and Admins may use this command.</span>")
		return
	var/list/client/targets[0]
	for(var/client/T)
		targets["[T]"] = T

	var/list/sorted = sortList(targets)
	var/target = input(src,"To whom shall we send a message?","Mentor PM",null) in sorted|null
	cmd_mentor_pm(targets[target],null)
	SSblackbox.record_feedback("tally", "Mentor_verb", 1, "APM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


//takes input from cmd_mentor_pm_context, cmd_Mentor_pm_panel or /client/Topic and sends them a PM.
//Fetching a message if needed. src is the sender and C is the target client
/client/proc/cmd_mentor_pm(whom, msg)
	if(prefs.muted & MUTE_MHELP)
		to_chat(src, "<span class='danger'>Error: Mentor-PM: You are unable to use mentor PM-s (muted).</span>", type = MESSAGE_TYPE_MENTORPM)
		return

	if(!GLOB.mentor_datums[ckey] && !current_mentorhelp_ticket)	//no ticket? https://www.youtube.com/watch?v=iHSPf6x1Fdo
		to_chat(src, "<span class='danger'>You can no longer reply to this ticket, please open another one by using the Mentorhelp verb if need be.</span>", type = MESSAGE_TYPE_MENTORPM)
		to_chat(src, "<span class='notice'>Message: [msg]</span>", type = MESSAGE_TYPE_MENTORPM)
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
			to_chat(src, "<span class='danger'>Error: Mentor-PM: Client not found.</span>", type = MESSAGE_TYPE_MENTORPM)
			if(msg)
				to_chat(src, msg)
			return
		else if(msg) // you want to continue if there's no message instead of returning now
			current_mentorhelp_ticket.MessageNoRecipient(msg)
			return

	//get message text, limit it's length.and clean/escape html
	if(!msg)
		msg = stripped_multiline_input(src,"Message:", "Private message to [recipient.holder?.fakekey ? "a Mentor" : key_name(recipient, FALSE, FALSE)].")
		msg = trim(msg)
		if(!msg)
			return

		if(prefs.muted & MUTE_MHELP)
			to_chat(src, "<span class='danger'>Error: Mentor-PM: You are unable to use mentor PM-s (muted).</span>", type = MESSAGE_TYPE_MENTORPM)
			return

		if(!recipient)
			if(holder)
				to_chat(src, "<span class='danger'>Error: Mentor-PM: Client not found.</span>", type = MESSAGE_TYPE_MENTORPM)
			else
				current_mentorhelp_ticket.MessageNoRecipient(msg)
			return

	if (src.handle_spam_prevention(msg,MUTE_MHELP))
		return

	//clean the message if it's not sent by a high-rank admin
	if(!check_rights(R_SERVER|R_DEBUG,0))//no sending html to the poor bots
		msg = trim(sanitize(msg), MAX_MESSAGE_LEN)
		if(!msg)
			return

	var/rawmsg = msg

	if(GLOB.mentor_datums[ckey])
		msg = emoji_parse(msg)
	recipient << 'sound/items/bikehorn.ogg'

	if(recipient.is_mentor())
		if(is_mentor())//both are mentors
			to_chat(recipient, "<span class='mentorfrom'>Mentor PM from-<b>[key_name_mentor(src, recipient)]</b>: [msg]</span>")
			to_chat(src, "<span class='mentorto'>Mentor PM to-<b>[key_name_mentor(recipient, recipient)]</b>: [msg]</span>")
			admin_ticket_log(src, msg, key_name(src, recipient, TRUE), key_name(recipient, src, TRUE), color="teal", isSenderAdmin = TRUE, safeSenderLogged = TRUE, is_admin_ticket = FALSE)
			if(recipient != src)
				admin_ticket_log(recipient, msg, key_name(src, recipient, TRUE), key_name(recipient, src, TRUE), color="teal", isSenderAdmin = TRUE, safeSenderLogged = TRUE, is_admin_ticket = FALSE)

		else		//recipient is an mentor but sender is not
			to_chat(recipient, "<span class='mentorfrom'>Reply PM from-<b>[key_name_mentor(src, recipient)]</b>: [msg]</span>")
			to_chat(src, "<span class='mentorto'>Mentor PM to-<b>Mentors</b>: [msg]</span>")
			admin_ticket_log(src, msg, key_name(src, recipient, TRUE), null, "white", isSenderAdmin = TRUE, safeSenderLogged = TRUE, is_admin_ticket = FALSE)

	else
		if(is_mentor())	//sender is an mentor but recipient is not.
			to_chat(recipient, "<span class='mentorfrom'>Mentor PM from-<b>[key_name_mentor(src, recipient)]</b>: [msg]</span>")
			to_chat(src, "<span class='mentorto'>Mentor PM to-<b>[key_name_mentor(recipient, recipient)]</b>: [msg]</span>")
			admin_ticket_log(recipient, msg, key_name(src), null, "purple", safeSenderLogged = TRUE, is_admin_ticket = FALSE)

	log_mentor("Mentor PM: [key_name(src)]->[key_name(recipient)]: [rawmsg]")
	for(var/client/X in GLOB.mentors | GLOB.admins)
		if(X.key!=key && X.key!=recipient.key)	//check client/X is an Mentor and isn't the sender or recipient
			to_chat(X, "<B><span class='mentorto'>Mentor PM: [key_name_mentor(src, X)]-&gt;[key_name_mentor(recipient, X)]:</B> <span class='mentorhelp'>[msg]</span>") //inform X


/proc/key_name_mentor(var/whom, var/include_link = null)
	var/mob/M
	var/client/C
	var/key
	var/ckey

	if(!whom)
		return "*null*"
	if(istype(whom, /client))
		C = whom
		M = C.mob
		key = C.key
		ckey = C.ckey
	else if(ismob(whom))
		M = whom
		C = M.client
		key = M.key
		ckey = M.ckey
	else if(istext(whom))
		key = whom
		ckey = ckey(whom)
		C = GLOB.directory[ckey]
		if(C)
			M = C.mob
	else
		return "*invalid*"

	. = ""

	if(!ckey)
		include_link = FALSE

	if(key)
		if(include_link)
			. += "<a href='?_src_=mentor;mentor_msg=[ckey];'>"
		if(C && C.holder && C.holder.fakekey)
			. += "Administrator"
		else
			. += key
		if(!C)
			. += "\[DC\]"
		if(include_link)
			. += "</a>"
	else
		. += "*no key*"
	return .

/client/proc/cmd_mhelp_reply(whom)
	if(prefs.muted & MUTE_MHELP)
		to_chat(src, "<span class='danger'>Error: Mentor-PM: You are unable to use mentor PM-s (muted).</span>", type = MESSAGE_TYPE_ADMINPM)
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
			to_chat(src, "<span class='danger'>Error: Mentor-PM: Client not found.</span>", type = MESSAGE_TYPE_ADMINPM)
		return

	var/datum/help_ticket/AH = C.current_mentorhelp_ticket

	if(AH)
		message_mentors("[key_name(src, TRUE)] has started replying to [key_name(C, FALSE, FALSE)]'s mentor help.")
	var/msg = stripped_multiline_input(src,"Message:", "Private message to [C.holder?.fakekey ? "a Mentor" : key_name(C, FALSE, FALSE)].")
	if (!msg)
		message_mentors("[key_name(src, TRUE)] has cancelled their reply to [key_name(C, FALSE, FALSE)]'s mentor help.")
		return
	cmd_mentor_pm(whom, msg)
	AH.Claim()

/client/proc/cmd_mhelp_reply_instant(whom, msg)
	if(prefs.muted & MUTE_MHELP)
		to_chat(src, "<span class='danger'>Error: Mentor-PM: You are unable to use mentor PM-s (muted).</span>", type = MESSAGE_TYPE_ADMINPM)
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
			to_chat(src, "<span class='danger'>Error: Mentor-PM: Client not found.</span>", type = MESSAGE_TYPE_ADMINPM)
		return

	if (!msg)
		return
	cmd_mentor_pm(whom, msg)

/proc/message_mentors(msg)
	msg = "<span class=\"mentor\"><span class=\"prefix\">MENTOR LOG:</span> <span class=\"message linkify\">[msg]</span></span>"
	to_chat(GLOB.mentors | GLOB.admins, msg)
