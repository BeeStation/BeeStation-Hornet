/// Returns all actions mentors have done this round
/datum/admins/proc/MentorLogSecret()
	var/dat = "<B>Mentor Log<HR></B>"
	for(var/l in GLOB.mentorlog)
		dat += "<li>[l]</li>"

	if(!GLOB.mentorlog.len)
		dat += "No mentors have done anything this round!"
	usr << browse(HTML_SKELETON(dat), "window=mentor_log")

/// Logs a mentor action to the investigate panel and game.log
/proc/log_mentor(text)
	GLOB.mentorlog.Add(text)
	WRITE_LOG(GLOB.world_game_log, "MENTOR: [text]")
