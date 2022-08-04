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
	var/client/C
	if(ismob(whom))
		var/mob/M = whom
		C = M.client
	else if(istext(whom))
		C = GLOB.directory[whom]
	else if(istype(whom, /client))
		C = whom
	if(!C)
		if(is_mentor())
			to_chat(src, "<font color='red'>Error: Mentor-PM: Client not found.</span>")
		else
			mentorhelp(msg)	//Mentor we are replying to left. Mentorhelp instead(check below)
		return

	//get message text, limit it's length.and clean/escape html
	if(!msg)
		msg = input(src,"Message:", "Private message") as text|null

		if(!msg)
			return

		if(!C)
			if(is_mentor())
				to_chat(src, "<font color='red'>Error: Mentor-PM: Client not found.</span>")
			else
				mentorhelp(msg)	//Mentor we are replying to has vanished, Mentorhelp instead (how the fuck does this work?let's hope it works,shrug)
			return

		// Neither party is a mentor, they shouldn't be PMing!
		if (!C.is_mentor() && !is_mentor())
			return

	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	if(!msg)
		return

	log_mentor("Mentor PM: [key_name(src)]->[key_name(C)]: [msg]")

	msg = emoji_parse(msg)
	C << 'sound/items/bikehorn.ogg'

	if(C.is_mentor())
		if(is_mentor())//both are mentors
			to_chat(C, "<span class='mentorfrom'>Mentor PM from-<b>[key_name_mentor(src, C)]</b>: [msg]</span>")
			to_chat(src, "<span class='mentorto'>Mentor PM to-<b>[key_name_mentor(C, C)]</b>: [msg]</span>")
			admin_ticket_log(src, msg, key_name(src, C, TRUE), key_name(C, src, TRUE), color="teal", isSenderAdmin = TRUE, safeSenderLogged = TRUE, is_admin_ticket = FALSE)
			if(C != src)
				admin_ticket_log(C, msg, key_name(src, C, TRUE), key_name(C, src, TRUE), color="teal", isSenderAdmin = TRUE, safeSenderLogged = TRUE, is_admin_ticket = FALSE)

		else		//recipient is an mentor but sender is not
			to_chat(C, "<span class='mentorfrom'>Reply PM from-<b>[key_name_mentor(src, C)]</b>: [msg]</span>")
			to_chat(src, "<span class='mentorto'>Mentor PM to-<b>[key_name_mentor(C, C)]</b>: [msg]</span>")
			admin_ticket_log(src, msg, key_name(src, C, TRUE), null, "white", isSenderAdmin = TRUE, safeSenderLogged = TRUE, is_admin_ticket = FALSE)

	else
		if(is_mentor())	//sender is an mentor but recipient is not.
			to_chat(C, "<span class='mentorfrom'>Mentor PM from-<b>[key_name_mentor(src, C)]</b>: [msg]</span>")
			to_chat(src, "<span class='mentorto'>Mentor PM to-<b>[key_name_mentor(C, C)]</b>: [msg]</span>")
			admin_ticket_log(C, msg, key_name_mentor(src), null, "purple", safeSenderLogged = TRUE, is_admin_ticket = FALSE)

	for(var/client/X in GLOB.mentors | GLOB.admins)
		if(X.key!=key && X.key!=C.key)	//check client/X is an Mentor and isn't the sender or recipient
			to_chat(X, "<B><span class='mentorto'>Mentor PM: [key_name_mentor(src, X)]-&gt;[key_name_mentor(C, X)]:</B> <span class='mentorhelp'>[msg]</span>") //inform X


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
			. += "<a href='?_src_=mentor;mentor_msg=[ckey];[MentorHrefToken(TRUE)]'>"
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
