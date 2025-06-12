#define NO_ADMINS_ONLINE_MESSAGE "Adminhelps are also sent through TGS to services like IRC and Discord. If no admins are available in game, sending an adminhelp might still be noticed and responded to."

/client/verb/staffwho()
	set category = "Admin"
	set name = "Staffwho"
	staff_who("Staffwho")

/client/verb/mentorwho()  // redundant with staffwho, but people wont check the admin tab for if there are mentors on
	set category = "Mentor"
	set name = "Mentorwho"
	staff_who("Mentorwho")

/client/proc/staff_who(via)
	var/list/lines = list()

	var/header
	var/payload_string = generate_adminwho_string()
	var/header2
	var/payload_string2 = generate_mentor_string()

	if(payload_string == NO_ADMINS_ONLINE_MESSAGE)
		header = "No Admins Currently Online"
	else
		header = "Current Admins:"

	if(!payload_string2)
		header2 = "No Mentors Currently Online"
	else
		header2 = "Current Mentors:"

	lines += span_bold(header)
	lines += payload_string
	lines += span_bold(header2)
	lines += payload_string2

	if(world.time - src.staff_check_rate > 1 MINUTES)
		message_admins("[ADMIN_LOOKUPFLW(src.mob)] has checked online staff[via ? " (via [via])" : ""].")
		log_admin("[key_name(src)] has checked online staff[via ? " (via [via])" : ""].")
		src.staff_check_rate = world.time
	var/finalized_string = examine_block(jointext(lines, "\n"))
	to_chat(src, finalized_string)

/// Proc that generates the applicable string to dispatch to the client for adminwho.
/client/proc/generate_adminwho_string()
	var/list/list_of_admins = get_list_of_admins()
	if(isnull(list_of_admins))
		return NO_ADMINS_ONLINE_MESSAGE

	var/list/message_strings = list()
	if(isnull(holder))
		message_strings += get_general_adminwho_information(list_of_admins)
		message_strings += NO_ADMINS_ONLINE_MESSAGE
	else
		message_strings += get_sensitive_adminwho_information(list_of_admins)

	return jointext(message_strings, "\n")

/// Proc that generates the applicable string to dispatch to the client for adminwho.
/client/proc/generate_mentor_string()
	var/list/list_of_mentors = get_list_of_mentors()

	var/list/message_strings = list()
	message_strings += get_mentor_information(list_of_mentors)

	return jointext(message_strings, "\n")

/// Proc that returns a list of cliented admins. Remember that this list can contain nulls!
/// Also, will return null if we don't have any admins.
/proc/get_list_of_admins()
	var/returnable_list = list()

	for(var/client/admin in GLOB.admins)
		returnable_list += admin

	if(length(returnable_list) == 0)
		return null

	return returnable_list

/// Proc that returns a list of cliented mentors. Remember that this list can contain nulls!
/// Also, will return null if we don't have any mentors.
/proc/get_list_of_mentors()
	var/returnable_list = list()

	for(var/client/mentor in GLOB.mentors)
		returnable_list += mentor

	if(length(returnable_list) == 0)
		return null

	return returnable_list

/*
/// Proc that will return the applicable display name, linkified or not, based on the input client reference.
/proc/get_linked_admin_name(client/admin)
	var/feedback_link = admin.holder.feedback_link()
	return isnull(feedback_link) ? admin : "<a href=[feedback_link]>[admin]</a>"
*/

/// Proc that gathers adminwho information for a general player, which will only give information if an admin isn't AFK, and handles potential fakekeying.
/// Will return a list of strings.
/proc/get_general_adminwho_information(list/checkable_admins)
	var/returnable_list = list()

	for(var/client/admin in checkable_admins)
		if(admin.is_afk() || !isnull(admin.holder.fakekey))
			continue //Don't show afk or fakekeyed admins to adminwho

		var/rank = "\improper [admin.holder.rank]"
		returnable_list += "• [admin] is \a [rank]"

	return returnable_list

/// Proc that gathers adminwho information for admins, which will contain information on if the admin is AFK, readied to join, etc. Only arg is a list of clients to use.
/// Will return a list of strings.
/proc/get_sensitive_adminwho_information(list/checkable_admins)
	var/returnable_list = list()

	for(var/client/admin in checkable_admins)
		var/list/admin_strings = list()

		var/rank = "\improper [admin.holder.rank]"
		admin_strings += "• [admin] is \a [rank]"

		if(admin.holder.fakekey)
			admin_strings += "<i>(as [admin.holder.fakekey])</i>"

		if(isobserver(admin.mob))
			admin_strings += "- Observing"
		else if(isnewplayer(admin.mob))
			if(SSticker.current_state <= GAME_STATE_PREGAME)
				var/mob/dead/new_player/lobbied_admin = admin.mob
				if(lobbied_admin.ready == PLAYER_READY_TO_PLAY)
					admin_strings += "- Lobby (Readied)"
				else
					admin_strings += "- Lobby (Not Readied)"
			else
				admin_strings += "- Lobby"
		else
			admin_strings += "- Playing"

		if(admin.is_afk())
			admin_strings += "(AFK)"

		returnable_list += jointext(admin_strings, " ")

	return returnable_list

/proc/get_mentor_information(list/checkable_mentors)
	var/returnable_list = list()

	for(var/client/mentor in checkable_mentors)
		var/list/mentor_strings = list()

		var/rank = "\improper [mentor.holder.rank]"
		mentor_strings += "• [mentor] is \a [rank]"

		if(isobserver(mentor.mob))
			mentor_strings += "- Observing"
		else if(isnewplayer(mentor.mob))
			if(SSticker.current_state <= GAME_STATE_PREGAME)
				var/mob/dead/new_player/lobbied_mentor = mentor.mob
				if(lobbied_mentor.ready == PLAYER_READY_TO_PLAY)
					mentor_strings += "- Lobby (Readied)"
				else
					mentor_strings += "- Lobby (Not Readied)"
			else
				mentor_strings += "- Lobby"
		else
			mentor_strings += "- Playing"

		if(mentor.is_afk())
			mentor_strings += "(AFK)"

		returnable_list += jointext(mentor_strings, " ")

	return returnable_list

#undef NO_ADMINS_ONLINE_MESSAGE
