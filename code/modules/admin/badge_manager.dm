#define PAGE_EDIT_BADGES 1
#define PAGE_EDIT_HOLDERS 2

/client/proc/edit_badge_holders()
	set category = "Admin"
	set name = "Badges Panel"
	set desc = "Edit chat badges of players and staff roles."
	open_badge_panel()

/client/proc/open_badge_panel(page = PAGE_EDIT_BADGES)
	if(!check_rights(R_PERMISSIONS))
		return
	if(!usr.client.bholder)
		add_badge_to(null, ckey)
		if(!usr.client.bholder)
			stack_trace("Failed to give empty badge holder to [key_name(usr)].")
			return
		log_game("[key_name(usr)] was given an empty badge holder so they can edit badge ranks.")
	usr.client.bholder.edit_badge_holders(page)

/datum/badges/proc/edit_badge_holders(page = PAGE_EDIT_BADGES)
	if(!check_rights(R_PERMISSIONS))
		return
	if(!CONFIG_GET(flag/badges))
		to_chat(usr, "<span class='warning'>Badges have been disabled on this server!</span>")
		return
	var/data = "<link rel='stylesheet' type='text/css' href='panels.css'>\
		<h2>Badge Holders</h2>\
		<a href='?_src_=holder;[HrefToken()];editbadgepage=[PAGE_EDIT_BADGES]'>Edit Badges</a> | <a href='?_src_=holder;[HrefToken()];editbadgepage=[PAGE_EDIT_HOLDERS]'>Edit Badge Holders</a>\
		<hr>\
		<b>Important:</b><br>\
		<p><b>Edit Badge Holders</b> allows you to add individual ckeys to a group of people that will have the badge in OOC chat, but do not have the role that should assign it to them automatically.</p>\
		<p><b>Mentors</b> are automatically assigned the badge role named 'mentor' and admins should have their rank assigned with a badge role.</p>\
		<p>Anyone who does not have permissions but should also have a rank (Donators, maintainers, whatever you want, etc.) can be individually assigned it here.</p>\
		<hr>\
		<p>If a badge's name is the same as the name of a rank in the permissions panel, clients with the rank in the permissions panel will automatically be assigned the badge with the same name. (For example if a badge is named admin, anyone with the admin rank will be given it automatically even if not assigned here.) Note: This system is case sensitive.</p>\
		<hr>"
	if(!SSdbcore.Connect())
		data += "<font color='red'>Failed to establish database connection!</font>"
	else
		switch(page)
			if(PAGE_EDIT_BADGES)
				data += "<a href='?_src_=holder;[HrefToken()];editbadgenewbadge=1'>Add New Badge</a>\
					<table>\
					<tr>\
						<th>Badge Name (The name of the badge)</th>\
						<th>Group (Only 1 badge from each group will display at a time)</th>\
						<th>Icon State (Defined in icons/badges.dmi)</th>\
						<th>Priority</th>\
					</tr>"
				for(var/brank_name in GLOB.badge_ranks)
					var/datum/badge_rank/R = GLOB.badge_ranks[brank_name]
					data += "<tr>\
						<td>[R.name] <a href='?_src_=holder;[HrefToken()];editbadgedeletebadge=[R.name]'>\[delete\]</a></td>\
						<td>[R.group]</td>\
						<td>[R.badge_icon]</td>\
						<td>[R.priority]</td>\
						</tr>"
				data += "</table>"
			if(PAGE_EDIT_HOLDERS)
				data += "<a href='?_src_=holder;[HrefToken()];editbadgenewholder=1'>Add badge to ckey</a>\
					<table>\
					<tr>\
						<th>Ckey</th>\
						<th>Badge</th>\
					</tr>"
				var/datum/DBQuery/query_load_badge_holders = SSdbcore.NewQuery("SELECT ckey, rank FROM [format_table_name("badge_holders")]")
				if(!query_load_badge_holders.Execute())
					to_chat(usr, "<span class='warning'>An error occured loading badge holders!</span>")
					log_sql("Error loading holders from database (source: Badge manager)")
					return
				var/list/badge_names = list()
				for(var/brank_name in GLOB.badge_ranks)
					var/datum/badge_rank/R = GLOB.badge_ranks[brank_name]
					badge_names[R.name] = R
				while(query_load_badge_holders.NextRow())
					var/bholder_ckey = ckey(query_load_badge_holders.item[1])
					var/bholder_rank = query_load_badge_holders.item[2]
					data += "<tr>\
						<td>[bholder_ckey] <a href='?_src_=holder;[HrefToken()];editbadgedeleteholder=[bholder_ckey];editbadgedeleteholder_rank=[bholder_rank]'>\[remove\]</a></td>\
						<td>[bholder_rank]</td>"
					if(!badge_names[bholder_rank])
						data += "<font color='red'>Invalid rank!</font>"
					data += "</tr>"
				data += "</table>"
	if(QDELETED(usr))
		return
	usr << browse(data, "window=editbadge;size=850x650")

/proc/create_new_badge(new_name, new_group, new_icon, priority)
	if(!check_rights(R_PERMISSIONS))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='warning'>Could not establish database connection.</span>")
		return
	var/datum/DBQuery/query_add_badge = SSdbcore.NewQuery("INSERT INTO [format_table_name("badge_ranks")] (rank, rank_group, icon, priority) VALUES (:rank, :rank_group, :icon, :priority)",
		list("rank" = new_name, "rank_group" = new_group, "icon" = new_icon, "priority" = priority)
	)
	if(!query_add_badge.warn_execute())
		qdel(query_add_badge)
		return
	message_admins("[key_name(usr)] create a new badge ([new_name])")
	log_admin("[key_name(usr)] create a new badge ([new_name])")
	qdel(query_add_badge)
	GLOB.badge_ranks[new_name] = new /datum/badge_rank(new_name, new_group, new_icon, priority)
	return

/proc/delete_badge_name(badge_name)
	if(!check_rights(R_PERMISSIONS))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='warning'>Could not establish database connection.</span>")
		return
	var/datum/DBQuery/query_delete_badge = SSdbcore.NewQuery("DELETE FROM [format_table_name("badge_ranks")] WHERE rank = :rank",
		list("rank" = badge_name)
	)
	if(!query_delete_badge.warn_execute())
		qdel(query_delete_badge)
		return
	message_admins("[key_name(usr)] deleted a badge ([badge_name])")
	log_admin("[key_name(usr)] deleted a badge ([badge_name])")
	qdel(query_delete_badge)
	GLOB.badge_ranks.Remove(badge_name)
	check_invalid_badges()
