/client/proc/process_endround_metacoin()
	if(!mob)	return
	var/mob/M = mob
	if(M.mind && !isnewplayer(M))
		if(M.stat != DEAD && !isbrain(M))
			if(EMERGENCY_ESCAPED_OR_ENDGAMED)
				if(!M.onCentCom() && !M.onSyndieBase())
					inc_metabalance(METACOIN_SURVIVE_REWARD, reason="Survived the shift.")
				else
					inc_metabalance(METACOIN_ESCAPE_REWARD, reason="Survived the shift and escaped!")
			else
				inc_metabalance(METACOIN_ESCAPE_REWARD, reason="Survived the shift.")
		else
			inc_metabalance(METACOIN_NOTSURVIVE_REWARD, reason="You tried.")

/client/proc/process_greentext()
	inc_metabalance(METACOIN_GREENTEXT_REWARD, reason="Greentext!")
	SSmedals.UnlockMedal(MEDAL_COMPLETE_ALL_OBJECTIVES,src)

/client/proc/process_ten_minute_living()
	inc_metabalance(METACOIN_TENMINUTELIVING_REWARD, FALSE)

/client/proc/get_metabalance()
	var/datum/DBQuery/query_get_metacoins = SSdbcore.NewQuery(
		"SELECT metacoins FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	var/mc_count = 0
	if(query_get_metacoins.warn_execute())
		if(query_get_metacoins.NextRow())
			mc_count = query_get_metacoins.item[1]

	qdel(query_get_metacoins)
	return text2num(mc_count)

/client/proc/set_metacoin_count(mc_count, ann=TRUE)
	var/datum/DBQuery/query_set_metacoins = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET metacoins = :mc_count WHERE ckey = :ckey",
		list("mc_count" = mc_count, "ckey" = ckey)	
	)
	query_set_metacoins.warn_execute()
	qdel(query_set_metacoins)
	if(ann)
		to_chat(src, "<span class='rose bold'>Your new metacoin balance is [mc_count]!</span>")

/client/proc/inc_metabalance(mc_count, ann=TRUE, reason=null)
	if(mc_count >= 0 && !CONFIG_GET(flag/grant_metacurrency))
		return
	var/datum/DBQuery/query_inc_metacoins = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET metacoins = metacoins + :mc_count WHERE ckey = :ckey",
		list("mc_count" = mc_count, "ckey" = ckey)	
	)
	query_inc_metacoins.warn_execute()
	qdel(query_inc_metacoins)
	if(ann)
		if(reason)
			to_chat(src, "<span class='rose bold'>[abs(mc_count)] [CONFIG_GET(string/metacurrency_name)]\s have been [mc_count >= 0 ? "deposited to" : "withdrawn from"] your account! Reason: [reason]</span>")
		else
			to_chat(src, "<span class='rose bold'>[abs(mc_count)] [CONFIG_GET(string/metacurrency_name)]\s have been [mc_count >= 0 ? "deposited to" : "withdrawn from"] your account!</span>")
