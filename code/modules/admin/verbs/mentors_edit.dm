/******************************************
It's like permissions panel, but for mentors,
also probably less secure, but honestly dude
its mentors, not actual dangerous perms
******************************************/
/client/proc/edit_mentors()
	set category = "Admin"
	set name = "Mentor Panel"
	set desc = "Edit mentors"

	if(!check_rights(R_PERMISSIONS))
		return
	if(!SSdbcore.IsConnected())
		to_chat(src, span_danger("Failed to establish database connection."))
		return

	var/html = "<h1>Mentor Panel</h1>\n"
	html += "<A HREF='BYOND://?mentor_edit=add'>Add a Mentor</A>\n"
	html += "<table style='width: 100%' border=1>\n"
	html += "<tr><th>Mentor Ckey</th><th>Remove</th></tr>\n"

	var/datum/db_query/query_mentor_list = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("mentor")]")
	if(!query_mentor_list.warn_execute())
		to_chat(src, span_danger("Unable to pull the mentor list from the database."))
		qdel(query_mentor_list)
	query_mentor_list.Execute()
	while(query_mentor_list.NextRow())
		html += "<tr><td>[query_mentor_list.item[1]]</td><td><A HREF='BYOND://?mentor_edit=remove;mentor_ckey=[query_mentor_list.item[1]]'>X</A></td></tr>\n"

	html += "</table>"

	usr << browse(HTML_SKELETON(html),"window=editmentors;size=1000x650")
	qdel(query_mentor_list)

/client/Topic(href, href_list)
	..()
	if(href_list["mentor_edit"])
		if(!check_rights(R_PERMISSIONS))
			message_admins("[key_name_admin(usr)] attempted to edit mentor permissions without sufficient rights.")
			log_admin("[key_name(usr)] attempted to edit mentor permissions without sufficient rights.")
			return
		if(IsAdminAdvancedProcCall())
			to_chat(usr, span_adminprefix("Mentor Edit blocked: Advanced ProcCall detected."))
			return

		if(href_list["mentor_edit"] == "add")
			var/newguy = input("Enter the key of the mentor you wish to add.", "")
			if(!length(newguy))
				to_chat(usr, span_admin("Failed to add empty mentor. Please specify a ckey."))
				return
			var/datum/db_query/query_add_mentor = SSdbcore.NewQuery(
				"INSERT INTO [format_table_name("mentor")] (ckey) VALUES (:newguy)",
				list("newguy" = newguy)
			)
			if(!query_add_mentor.warn_execute())
				qdel(query_add_mentor)
				return
			message_admins("[key_name(usr)] made [newguy] a mentor.")
			log_admin("[key_name(usr)] made [newguy] a mentor.")
			qdel(query_add_mentor)
			load_mentors()
			return

		if(href_list["mentor_edit"] == "remove")
			var/removed_mentor = href_list["mentor_ckey"]
			var/datum/db_query/query_remove_mentor = SSdbcore.NewQuery(
				"DELETE FROM [format_table_name("mentor")] WHERE ckey = :removed_mentor",
				list("removed_mentor" = removed_mentor)
			)
			if(!query_remove_mentor.warn_execute())
				qdel(query_remove_mentor)
				return
			message_admins("[key_name(usr)] de-mentored [href_list["mentor_ckey"]]")
			log_admin("[key_name(usr)] de-mentored [href_list["mentor_ckey"]]")
			qdel(query_remove_mentor)
			load_mentors()
