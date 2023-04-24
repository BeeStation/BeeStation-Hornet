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

/client/proc/mrat()
	set name = "Request Mentor Assistance"
	set category = "Mentor"

	if(!CONFIG_GET(flag/enable_mrat))
		return

	if(prefs.muted & MUTE_MHELP)
		to_chat(src, "<span class='danger'>Error: You cannot send mentorhelps (Muted).</span>")
		return

	if(!istype(src.mob, /mob/living/carbon/human))
		to_chat(src, "<span class='notice'>You must be humanoid to use this!</span>")
		return

	var/mob/living/carbon/human/M = src.mob

	if(M.stat == DEAD)
		to_chat(src, "<span class='notice'>You must be alive to use this!</span>")
		return

	if(M.has_trauma_type(/datum/brain_trauma/special/imaginary_friend/mrat))
		to_chat(src, "<span class='notice'>You already have or are requesting a mentor!</span>")
		return

	var/alertresult = alert(M, "This will create an imaginary form visible only to you that a mentor can possess to guide you in person. Do you wish to continue?", null,"Yes", "No")
	if(alertresult == "No" || QDELETED(M) || !istype(M) || !M.key)
		return

	M.gain_trauma(/datum/brain_trauma/special/imaginary_friend/mrat)
