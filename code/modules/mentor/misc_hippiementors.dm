/// All clients with mentor datums (excluding admins) - use is_mentor() instead of checking this
GLOBAL_LIST_EMPTY(mentors)
GLOBAL_PROTECT(mentors)

/client/New()
	. = ..()
	mentor_datum_set()

/client/proc/is_mentor() // admins are mentors too.
	return mentor_datum || check_rights_for(src, R_ADMIN, 0)

/client/proc/mentor_datum_set(admin)
	mentor_datum = GLOB.mentor_datums[ckey]
	if(!mentor_datum && check_rights_for(src, R_ADMIN,0)) // admin with no mentor datum?let's fix that
		new /datum/mentors(ckey)
	if(mentor_datum)
		if(!check_rights_for(src, R_ADMIN,0) && !admin)
			GLOB.mentors |= src // don't add admins to this list too.
		mentor_datum.owner = src
		add_mentor_verbs()

/proc/log_mentor(text)
	GLOB.mentorlog.Add(text)
	WRITE_LOG(GLOB.world_game_log, "MENTOR: [text]")
