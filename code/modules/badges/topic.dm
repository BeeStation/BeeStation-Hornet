/datum/badges/Topic(href, href_list)
	if(..())
		return

	if(!check_rights(R_PERMISSIONS))
		message_admins("[usr.key] has attempted to override the badges panel.")
		log_admin("[usr.key] has attempted to override the badges panel.")
		return

	message_admins("Href recieved [href]")
	if(href_list["editbadgepage"])
		usr.client.open_badge_panel(href_list["editbadgepage"])

	else if(href_list["editbadgenewbadge"])
		var/new_badge_name = stripped_input(usr, "What do you want the rank to be called?", "Rank name", max_length=16)
		if(!new_badge_name)
			return
		if(get_rank_from_name(new_badge_name))
			to_chat(usr, "<span class='warning'>There is already a badge named [new_badge_name]!</span>")
			return
		var/new_badge_group = stripped_input(usr, "What group do you want to put the rank in? (Only 1 rank per group will display at a time).", "Rank group", max_length=16)
		if(!new_badge_group)
			return
		var/list/valid_states = icon_states('icons/badges.dmi')
		if(!LAZYLEN(valid_states))
			to_chat(usr, "<span class='warning'>No valid icon states found in file 'icons/badges.dmi'</span>")
			return
		var/new_badge_icon = input(usr, "Badge Icon") as anything in valid_states
		if(!new_badge_icon || !(new_badge_icon in valid_states))
			return
		create_new_badge(new_badge_name, new_badge_group, new_badge_icon)
