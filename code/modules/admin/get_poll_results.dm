/client/proc/get_poll_results()
	set name = "Get Poll Results"
	set category = "Special Verbs"
	if(!check_rights(R_POLL))
		return
	if(!SSdbcore.Connect())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/datum/DBQuery/query_poll_get = SSdbcore.NewQuery("SELECT id, question FROM [format_table_name("poll_question")]")
	if(!query_poll_get.warn_execute())
		qdel(query_poll_get)
		return
	var/output = "<div align='center'><B>Player polls</B><hr><table>"
	var/i = 0
	var/rs = REF(mob)
	while(query_poll_get.NextRow())
		var/pollid = query_poll_get.item[1]
		var/pollquestion = query_poll_get.item[2]
		output += "<tr bgcolor='#[ (i % 2 == 1) ? "e2e2e2" : "e2e2e2" ]'><td><a href='?_src_=holder;[HrefToken()];getpollresult=[pollid];page=0'><b>[pollquestion]</b></a></td></tr>"
		i++
	qdel(query_poll_get)
	output += "</table>"
	if(!QDELETED(src))
		src << browse(output,"window=playerpolllist;size=500x300")
