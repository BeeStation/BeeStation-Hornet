AUTH_CLIENT_VERB(staffwho)
	set category = "Admin"
	set name = "Staffwho"
	staff_who("Staffwho")

AUTH_CLIENT_VERB(mentorwho)  // redundant with staffwho, but people wont check the admin tab for if there are mentors on
	set category = "Mentor"
	set name = "Mentorwho"
	staff_who("Mentorwho")

/client/proc/staff_who(via)
	var/msg

	// when you are admin
	if(holder)
		msg = "<b>Current Admins:</b>\n"
		for(var/client/C in GLOB.admins)
			var/rank = "\improper [C.holder.rank]"
			msg += "\t[C.display_name_chat()] is \a [rank]"

			if(C.holder.fakekey)
				msg += " <i>(as [C.holder.fakekey])</i>"

			if(isobserver(C.mob))
				msg += " - Observing"
			else if(isnewplayer(C.mob))
				msg += " - Lobby"
			else
				msg += " - Playing"

			if(C.is_afk())
				msg += " (AFK)"
			msg += "\n"
		msg += "<b>Current Mentors:</b>\n"
		for(var/client/C in GLOB.mentors)
			msg += "\t[C.display_name_chat()] is a Mentor"

			if(isobserver(C.mob))
				msg += " - Observing"
			else if(isnewplayer(C.mob))
				msg += " - Lobby"
			else
				msg += " - Playing"

			if(C.is_afk())
				msg += " (AFK)"
			msg += "\n"

	// for standard players
	else
		var/list/admin_list = list()
		var/list/non_admin_list = list()
		for(var/client/C in GLOB.admins)
			if(C.is_afk())
				continue //Don't show afk admins to adminwho
			if(!C.holder.fakekey)
				if(check_rights_for(C, R_ADMIN)) // ahelp needs R_ADMIN. If they have R_ADMIN, they'll be listed in admin list.
					var/rank = "\improper [C.holder.rank]"
					admin_list += "\t[C.display_name_chat()] is \a [rank]\n"
				else // admins without R_ADMIN perm should be sorted in different area, so that people won't believe coders will handle ahelp
					var/rank = "\improper [C.holder.rank]"
					non_admin_list += "\t[C.display_name_chat()] is \a [rank]\n"

		msg = "<b>Current Admins:</b>\n"
		for(var/each in admin_list)
			msg += each
		if(length(non_admin_list)) // notifying the absence of non-admins has no point
			msg += "<b>Current Maintainers:</b>\n"
			msg += "\t[span_info("Non-admin staff are unable to handle adminhelp tickets.")]\n"
			for(var/each in non_admin_list)
				msg += each
		msg += "<b>Current Mentors:</b>\n"
		for(var/client/C in GLOB.mentors)
			if(C.is_afk())
				continue //Don't show afk admins to adminwho
			msg += "\t[C.display_name_chat()] is a Mentor\n"

		msg += span_info("Adminhelps are also sent through TGS to services like IRC and Discord. If no admins are available in game adminhelp anyways and an admin will see it and respond.")
		if(world.time - src.staff_check_rate > 1 MINUTES)
			message_admins("[ADMIN_LOOKUPFLW(src.mob)] has checked online staff[via ? " (via [via])" : ""].")
			log_admin("[key_name(src)] has checked online staff[via ? " (via [via])" : ""].")
			src.staff_check_rate = world.time
	to_chat(src, msg)
