#define NO_ADMINS_ONLINE_MESSAGE "Adminhelps are also sent through TGS to services like IRC and Discord. If no admins are available in game, sending an adminhelp might still be noticed and responded to."

AUTH_CLIENT_VERB(staffwho)
	set category = "Admin"
	set name = "Staffwho"
	staff_who("Staffwho")

AUTH_CLIENT_VERB(mentorwho)  // redundant with staffwho, but people wont check the admin tab for if there are mentors on
	set category = "Mentor"
	set name = "Mentorwho"
	staff_who("Mentorwho")

/client/proc/staff_who(via)
	var/list/lines = list()
	//Assoc list
	var/list/staff_info = list(
		"admin" = list(
			"header" = "Current Admins:",
			"empty_header" = "No Admins Currently Online",
			"data" = generate_staff_list("admin")
		),
		"maintainer" = list(
			"header" = "Current Maintainers:",
			"data" = generate_staff_list("maintainer")
		),
		"mentor" = list(
			"header" = "Current Mentors:",
			"data" = generate_staff_list("mentor")
		)
	)

	var/admin_data = staff_info["admin"]["data"]
	lines += span_bold(admin_data ? staff_info["admin"]["header"] : staff_info["admin"]["empty_header"])
	lines += admin_data || NO_ADMINS_ONLINE_MESSAGE

	// Add disclaimer if other staff exists
	if(!admin_data && (staff_info["maintainer"]["data"] || staff_info["mentor"]["data"]))
		lines += "<b>Non-admin staff are unable to handle adminhelp tickets.</b>"

	for(var/staff_type in list("maintainer", "mentor"))
		var/list/staff_data = staff_info[staff_type]
		if(!isnull(staff_data["data"]))
			lines += span_bold(staff_data["header"])
			lines += staff_data["data"]

	if(world.time - src.staff_check_rate > 1 MINUTES)
		message_admins("[ADMIN_LOOKUPFLW(src.mob)] has checked online staff[via ? " (via [via])" : ""].")
		log_admin("[key_name(src)] has checked online staff[via ? " (via [via])" : ""].")
		src.staff_check_rate = world.time

	to_chat(src, examine_block(jointext(lines, "\n")))

/client/proc/generate_staff_list(staff_type)
	var/list/staff_list
	switch(staff_type)
		if("admin")
			staff_list = get_staff_list(GLOB.admins, R_ADMIN, TRUE)
		if("maintainer")
			staff_list = get_staff_list(GLOB.admins, R_ADMIN, FALSE)
		if("mentor")
			staff_list = get_staff_list(GLOB.mentors)

	return length(staff_list) ? format_staff_list(staff_list, holder != null) : null

/proc/get_staff_list(list/global_list, rights = null, has_rights = null)
	var/list/staff = list()
	for(var/client/C in global_list)
		if(!isnull(rights) && !isnull(has_rights))
			if(has_rights != check_rights_for(C, rights))
				continue
		staff += C
	return length(staff) ? staff : null

/proc/format_staff_list(list/staff_list, show_sensitive = FALSE)
	var/list/formatted = list()
	for(var/client/C in staff_list)
		if(!show_sensitive && (C.is_afk() || (!isnull(C.holder) && !isnull(C.holder.fakekey))))
			continue

		var/list/info = list()
		//We check for admins first, since you can have a mentor datum and a holder datum at the same time
		if(C?.holder)
			var/rank = C.holder.rank
			var/display_rank = LOWER_TEXT(rank)
			if(display_rank == "!localhost!")
				display_rank = "localhost"
			// Convert spaces to underscores
			var/css_class = replacetext(display_rank, " ", "_")
			info += "• [C.display_name_chat()] is a <span class='[css_class]'>[rank]</span>"
		//You are just a mint green, no admin about you
		else if(C?.mentor_datum)
			info += "• [C.display_name_chat()] is a <span class='mentor'>Mentor</span>"
		else
			message_admins("Client [C] has no admin holder or mentor datum, yet is being passed as staff in staffwho. What the FUCK.")
			continue

		if(show_sensitive)
			if(C?.holder.fakekey)
				info += "<i>(as [C.holder.fakekey])</i>"

			if(isobserver(C.mob))
				info += "- Observing"
			else if(isnewplayer(C.mob))
				info += get_lobby_status(C)
			else
				info += "- Playing"

			if(C.is_afk())
				info += "(AFK)"

		formatted += jointext(info, " ")
	return jointext(formatted, "\n")

/proc/get_lobby_status(client/C)
	if(SSticker.current_state <= GAME_STATE_PREGAME)
		var/mob/dead/new_player/authenticated/player = C.mob
		return "- Lobby [(player.ready == PLAYER_READY_TO_PLAY) ? "(Readied)" : "(Not Readied)"]"
	return "- Lobby"

#undef NO_ADMINS_ONLINE_MESSAGE
