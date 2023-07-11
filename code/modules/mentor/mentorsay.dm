/client/proc/get_mentor_say()
	var/msg = tgui_input_text(src, null, "msay \"text\"", encode = FALSE) // we don't encode/sanitize here because cmd_mentor_say does it anyways.
	cmd_mentor_say(msg)

/client/proc/cmd_mentor_say(msg as text)
	set category = "Mentor"
	set name = "Msay" //Gave this shit a shorter name so you only have to type out "msay" rather than "mentor say" to use it --NeoFite
	set hidden = 1
	if(!is_mentor())
		return

	msg = emoji_parse(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
	if(!msg)
		return

	log_mentor("MSAY: [key_name(src)] : [msg]")
	if(check_rights_for(src, R_ADMIN,0))
		msg = "<b><span class='mentorsay'><font color ='#8A2BE2'><span class='prefix'>MENTOR:</span> <EM>[key_name(src, 0, 0)]</EM>: <span class='message'>[msg]</span></font></b>"
	else
		msg = "<b><span class='mentorsay'><span class='prefix'>MENTOR:</span> <EM>[key_name(src, 0, 0)]</EM>: <span class='message'>[msg]</span></font></b>"
	for(var/client/client in GLOB.admins | GLOB.mentors)
		to_chat(client, msg, avoid_highlighting = client == src)

	SSblackbox.record_feedback("tally", "mentor_verb", 1, "Msay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

