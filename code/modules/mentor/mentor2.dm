//Globals

//Tracking
GLOBAL_LIST_EMPTY(mentors) //all mentor clients. This is probably kinda dirty but it's saving me time ripping out old garbage.
GLOBAL_PROTECT(mentors)
//Logging
GLOBAL_LIST_EMPTY(mentorlog)
GLOBAL_PROTECT(mentorlog)


//CONFIG
/datum/config_entry/flag/mentors_mobname_only

//MSAY

/client/proc/cmd_mentor_say(msg as text)
	set category = "Mentor"
	set name = "Msay" //Gave this shit a shorter name so you only have to time out "msay" rather than "mentor say" to use it --NeoFite
	set hidden = TRUE

	if(!check_rights(R_MENTOR, TRUE))
		return

	msg = emoji_parse(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
	if(!msg)
		return

	log_mentor("MSAY: [key_name(src)] : [msg]")
	msg = keywords_lookup(msg)
	if(check_rights_for(src, R_ADMIN,0))
		msg = "<b><font color ='#8A2BE2'><span class='prefix'>MENTOR:</span> <EM>[key_name(src, 0, 0)]</EM>: <span class='message'>[msg]</span></font></b>"
	else
		msg = "<b><font color ='#E236D8'><span class='prefix'>MENTOR:</span> <EM>[key_name(src, 0, 0)]</EM>: <span class='message'>[msg]</span></font></b>"
	to_chat(GLOB.mentors, msg)

	SSblackbox.record_feedback("tally", "mentor_verb", 1, "Msay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/get_mentor_say()
	var/msg = input(src, null, "msay \"text\"") as text
	cmd_mentor_say(msg)

//Logging

/proc/log_mentor(text)
	GLOB.mentorlog.Add(text)
	WRITE_LOG(GLOB.world_game_log, "MENTOR: [text]")

/datum/admins/proc/MentorLogSecret()
	var/dat = "<B>Mentor Log<HR></B>"
	for(var/l in GLOB.mentorlog)
		dat += "<li>[l]</li>"

	if(!GLOB.mentorlog.len)
		dat += "No mentors have done anything this round!"
	usr << browse(dat, "window=mentor_log")
