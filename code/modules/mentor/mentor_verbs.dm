GLOBAL_LIST_INIT(mentor_verbs, list(
	/client/proc/cmd_mentor_say,
	/client/proc/openMentorTicketManager
	))
GLOBAL_PROTECT(mentor_verbs)

/client/proc/add_mentor_verbs()
	if(mentor_datum)
		add_verb(GLOB.mentor_verbs)
		reset_badges()

/client/proc/remove_mentor_verbs()
	remove_verb(GLOB.mentor_verbs)
	reset_badges()
