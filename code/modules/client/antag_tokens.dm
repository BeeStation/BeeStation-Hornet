/// Cached antag token count, pulled just before prefs initialization.
/client/var/antag_token_count_cached = null

/// Never-blocking method to retrieve cached antag token count. This CAN be null and runtimes if it is.
/// Use get_antag_token_count_db() for a more accurate measure. Never use this in modifying calculations.
/// The cached antag token count is initialized during client/Login()
/client/proc/get_antag_token_count_unreliable()
	SHOULD_NOT_SLEEP(TRUE)
	if(antag_token_count_cached == null)
		CRASH("Antag token amount fetched before value initialized")
	return antag_token_count_cached

/// Gets the user's antag token count from the DB. Blocking.
/client/proc/get_antag_token_count_db()
	var/datum/DBQuery/query_get_antag_tokens = SSdbcore.NewQuery(
		"SELECT antag_tokens FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	var/token_count = 0
	if(query_get_antag_tokens.warn_execute() && query_get_antag_tokens.NextRow())
		token_count = query_get_antag_tokens.item[1]

	qdel(query_get_antag_tokens)
	var/count = text2num(token_count)
	antag_token_count_cached = count
	return count

/// Sets antag token count in the local cache, then invokes a database update.
/// token_count: Amount to increment the antag token count by
/client/proc/set_antag_token_count(token_count)
	SHOULD_NOT_SLEEP(TRUE)
	if(antag_token_count_cached == null)
		to_chat(usr, "<span class='warning'>Error adjusting antag tokens!</span>")
		CRASH("Antag token amount adjusted before value initialized")
	antag_token_count_cached = token_count
	INVOKE_ASYNC(src, PROC_REF(db_set_antag_token_count), token_count)

/// Increases antag token count in the local cache, then invokes a database update.
/// token_count: Amount to increment the antag token count by
/client/proc/inc_antag_token_count(token_count)
	SHOULD_NOT_SLEEP(TRUE)
	if(antag_token_count_cached == null)
		to_chat(usr, "<span class='warning'>Error adjusting antag tokens!</span>")
		CRASH("Antag token amount adjusted before value initialized")
	antag_token_count_cached += token_count
	INVOKE_ASYNC(src, PROC_REF(db_inc_antag_token_count), token_count)

/client/proc/db_inc_antag_token_count(token_count)
	var/datum/DBQuery/query_inc_antag_tokens = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET antag_tokens = antag_tokens + :token_count WHERE ckey = :ckey",
		list("token_count" = token_count, "ckey" = ckey)
	)
	if(!query_inc_antag_tokens.warn_execute())
		qdel(query_inc_antag_tokens)
		return
	qdel(query_inc_antag_tokens)

/client/proc/db_set_antag_token_count(token_count)
	var/datum/DBQuery/query_set_antag_tokens = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET antag_tokens = :token_count WHERE ckey = :ckey",
		list("token_count" = token_count, "ckey" = ckey)
	)
	if(!query_set_antag_tokens.warn_execute())
		qdel(query_set_antag_tokens)
		return
	qdel(query_set_antag_tokens)
