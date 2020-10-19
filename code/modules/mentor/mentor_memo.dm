/client/proc/mentor_memo()
	set name = "Mentor Memos"
	set category = "Server"
	if(!check_rights(0))
		return
	if(!SSdbcore.IsConnected())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/memotask = input(usr,"Choose task.","Memo") in list("Show","Write","Edit","Remove")
	if(!memotask)
		return
	mentor_memo_output(memotask)

/client/proc/show_mentor_memo()
	set name = "Show Memos"
	set category = "Mentor"
	if(!is_mentor())
		return
	if(!SSdbcore.IsConnected())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return
	mentor_memo_output("Show")

/client/proc/mentor_memo_output(task)
	if(!task)
		return
	if(!SSdbcore.IsConnected())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return
	switch(task)
		if("Write")
			var/datum/DBQuery/query_memocheck = SSdbcore.NewQuery(
				"SELECT ckey FROM [format_table_name("mentor_memo")] WHERE ckey = :ckey",
				list("ckey" = ckey)
			)
			if(!query_memocheck.Execute())
				var/err = query_memocheck.ErrorMsg()
				log_game("SQL ERROR obtaining ckey from memo table. Error : \[[err]\]\n")
				qdel(query_memocheck)
				return
			if(query_memocheck.NextRow())
				to_chat(src, "You already have set a memo.")
				qdel(query_memocheck)
				return
			var/memotext = capped_multiline_input(src,"Write your Memo","Memo")
			if(!memotext)
				qdel(query_memocheck)
				return
			var/timestamp = SQLtime()
			var/datum/DBQuery/query_memoadd = SSdbcore.NewQuery(
				"INSERT INTO [format_table_name("mentor_memo")] (ckey, memotext, timestamp) VALUES (:ckey, :memotext, :timestamp)",
				list("ckey" = ckey, "memotext" = memotext, "timestamp" = timestamp)
			)
			if(!query_memoadd.Execute())
				var/err = query_memoadd.ErrorMsg()
				log_game("SQL ERROR adding new memo. Error : \[[err]\]\n")
				qdel(query_memocheck)
				qdel(query_memoadd)
				return
			log_admin("[key_name(src)] has set a mentor memo: [memotext]")
			message_admins("[key_name_admin(src)] has set a mentor memo:<br>[memotext]")
			qdel(query_memocheck)
			qdel(query_memoadd)
		if("Edit")
			var/datum/DBQuery/query_memolist = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("mentor_memo")]")
			if(!query_memolist.Execute())
				var/err = query_memolist.ErrorMsg()
				log_game("SQL ERROR obtaining ckey from memo table. Error : \[[err]\]\n")
				qdel(query_memolist)
				return
			var/list/memolist = list()
			while(query_memolist.NextRow())
				var/lkey = query_memolist.item[1]
				memolist += "[lkey]"
			if(!memolist.len)
				to_chat(src, "No memos found in database.")
				qdel(query_memolist)
				return
			var/target_ckey = input(src, "Select whose memo to edit", "Select memo") as null|anything in memolist
			if(!target_ckey)
				qdel(query_memolist)
				return
			var/datum/DBQuery/query_memofind = SSdbcore.NewQuery(
				"SELECT memotext FROM [format_table_name("mentor_memo")] WHERE ckey = :target_ckey",
				list("target_ckey" = target_ckey)	
			)
			if(!query_memofind.Execute())
				var/err = query_memofind.ErrorMsg()
				log_game("SQL ERROR obtaining memotext from memo table. Error : \[[err]\]\n")
				qdel(query_memolist)
				qdel(query_memofind)
				return
			if(query_memofind.NextRow())
				var/old_memo = query_memofind.item[1]
				var/new_memo = capped_multiline_input(src, "Input new memo", "New Memo", "[old_memo]")
				if(!new_memo)
					qdel(query_memolist)
					qdel(query_memofind)
					return
				var/edit_text = "Edited by [ckey] on [SQLtime()] from<br>[old_memo]<br>to<br>[new_memo]<hr>"
				var/datum/DBQuery/update_query = SSdbcore.NewQuery(
					"UPDATE [format_table_name("mentor_memo")] SET memotext = :new_memo, last_editor = :ckey, edits = CONCAT(IFNULL(edits,''),:edit_text) WHERE ckey = :target_ckey",
					list("new_memo" = new_memo, "ckey" = ckey, "edit_text" = edit_text, "target_ckey" = target_ckey)
				)
				if(!update_query.Execute())
					var/err = update_query.ErrorMsg()
					log_game("SQL ERROR editing memo. Error : \[[err]\]\n")
					qdel(query_memolist)
					qdel(query_memofind)
					qdel(update_query)
					return
				if(target_ckey == ckey)
					log_admin("[key_name(src)] has edited their mentor memo from [old_memo] to [new_memo]")
					message_admins("[key_name_admin(src)] has edited their mentor memo from<br>[old_memo]<br>to<br>[new_memo]")
				else
					log_admin("[key_name(src)] has edited [target_ckey]'s mentor memo from [old_memo] to [new_memo]")
					message_admins("[key_name_admin(src)] has edited [target_ckey]'s mentor memo from<br>[old_memo]<br>to<br>[new_memo]")
				qdel(update_query)
			qdel(query_memolist)
			qdel(query_memofind)
		if("Show")
			var/datum/DBQuery/query_memoshow = SSdbcore.NewQuery("SELECT ckey, memotext, timestamp, last_editor FROM [format_table_name("mentor_memo")] ORDER BY timestamp ASC")
			if(!query_memoshow.Execute())
				var/err = query_memoshow.ErrorMsg()
				log_game("SQL ERROR obtaining ckey, memotext, timestamp, last_editor from memo table. Error : \[[err]\]\n")
				qdel(query_memoshow)
				return
			var/output = null
			while(query_memoshow.NextRow())
				var/ckey = query_memoshow.item[1]
				var/memotext = query_memoshow.item[2]
				var/timestamp = query_memoshow.item[3]
				var/last_editor = query_memoshow.item[4]
				output += "<span class='memo'>Mentor memo by <span class='prefix'>[ckey]</span> on [timestamp]"
				if(last_editor)
					output += "<br><span class='memoedit'>Last edit by [last_editor] <A href='?_src_=holder;mentormemoeditlist=[ckey];[HrefToken(TRUE)]'>(Click here to see edit log)</A></span>"
				output += "<br>[memotext]</span><br>"
			if(!output)
				to_chat(src, "No memos found in database.")
				qdel(query_memoshow)
				return
			to_chat(src, output)
			qdel(query_memoshow)
		if("Remove")
			var/datum/DBQuery/query_memodellist = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("mentor_memo")]")
			if(!query_memodellist.Execute())
				var/err = query_memodellist.ErrorMsg()
				log_game("SQL ERROR obtaining ckey from memo table. Error : \[[err]\]\n")
				qdel(query_memodellist)
				return
			var/list/memolist = list()
			while(query_memodellist.NextRow())
				var/ckey = query_memodellist.item[1]
				memolist += "[ckey]"
			if(!memolist.len)
				to_chat(src, "No memos found in database.")
				qdel(query_memodellist)
				return
			var/target_ckey = input(src, "Select whose mentor memo to delete", "Select mentor memo") as null|anything in memolist
			if(!target_ckey)
				qdel(query_memodellist)
				return
			var/datum/DBQuery/query_memodel = SSdbcore.NewQuery(
				"DELETE FROM [format_table_name("mentor_memo")] WHERE ckey = :target_ckey",
				list("target_ckey" = target_ckey)	
			)
			if(!query_memodel.Execute())
				var/err = query_memodel.ErrorMsg()
				log_game("SQL ERROR removing memo. Error : \[[err]\]\n")
				qdel(query_memodellist)
				qdel(query_memodel)
				return
			if(target_ckey == ckey)
				log_admin("[key_name(src)] has removed their mentor memo.")
				message_admins("[key_name_admin(src)] has removed their mentor memo.")
			else
				log_admin("[key_name(src)] has removed [target_ckey]'s mentor memo.")
				message_admins("[key_name_admin(src)] has removed [target_ckey]'s mentor memo.")
			qdel(query_memodellist)
			qdel(query_memodel)
