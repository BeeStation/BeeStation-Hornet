/client/New()
	. = ..()
	if(!prefs.rules_agree)  // if this is their first time joining since the new movement
		warning("By playing here, you agree to follow the rules stated by the rules button.")
		prefs.rules_agree = TRUE
		prefs.save_preferences()

/client/proc/get_antag_token_count()
	var/datum/DBQuery/query_get_antag_tokens = SSdbcore.NewQuery("SELECT antag_tokens FROM [format_table_name("player")] WHERE ckey = '[ckey]'")
	var/token_count = 0
	if(!query_get_antag_tokens.warn_execute())
		qdel(query_get_antag_tokens)
		return text2num(token_count)
	if(!query_get_antag_tokens.NextRow())
		qdel(query_get_antag_tokens)
		return text2num(token_count)
	else
		token_count = query_get_antag_tokens.item[1]
	qdel(query_get_antag_tokens)
	return text2num(token_count)

/client/proc/set_antag_token_count(token_count)
	var/datum/DBQuery/query_set_antag_tokens = SSdbcore.NewQuery("UPDATE [format_table_name("player")] SET antag_tokens = '[token_count]' WHERE ckey = '[ckey]'")
	if(!query_set_antag_tokens.warn_execute())
		qdel(query_set_antag_tokens)
		return
	qdel(query_set_antag_tokens)
