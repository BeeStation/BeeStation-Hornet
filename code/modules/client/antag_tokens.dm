/// Cached antag token count, pulled just before prefs initialization.
/client/var/antag_token_count_cached = null

/// Never-blocking method to retrieve cached antag token count. This CAN be null and runtimes if it is.
/// Use get_antag_token_count_db() for a more accurate measure. Never use this in modifying calculations.
/// The cached antag token count is initialized during client/Login()
/client/proc/get_antag_token_count_unreliable()
	SHOULD_NOT_SLEEP(TRUE)
	if(isnull(antag_token_count_cached))
		CRASH("Antag token amount fetched before value initialized")
	return antag_token_count_cached

/// Gets the user's antag token count from the DB. Blocking.
/proc/get_antag_token_count_db(target_ckey)
	var/datum/db_query/query_get_antag_tokens = SSdbcore.NewQuery(
		"SELECT antag_tokens FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = target_ckey)
	)
	var/token_count = 0
	if(query_get_antag_tokens.warn_execute() && query_get_antag_tokens.NextRow())
		token_count = text2num(query_get_antag_tokens.item[1])

	qdel(query_get_antag_tokens)

	var/client/target_client = GLOB.directory[target_ckey]
	target_client?.antag_token_count_cached = token_count
	return token_count

/**
 * Sets antag token count in the local cache, then invokes a database update.
 *
 * Arguments:
 * * token_count - What to set the antag token count to
 */
/client/proc/set_antag_token_count(token_count)
	SHOULD_NOT_SLEEP(TRUE)
	if(IsAdminAdvancedProcCall())
		return

	if(isnull(antag_token_count_cached))
		to_chat(usr, span_warning("Error adjusting antag tokens!"))
		CRASH("Antag token amount adjusted before value initialized")
	antag_token_count_cached = token_count

	INVOKE_ASYNC(src, GLOBAL_PROC_REF(db_set_antag_token_count), ckey, token_count)

/proc/db_set_antag_token_count(target_ckey, token_count)
	if(IsAdminAdvancedProcCall())
		return

	var/datum/db_query/query_set_antag_tokens = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET antag_tokens = :token_count WHERE ckey = :ckey",
		list("token_count" = token_count, "ckey" = target_ckey)
	)
	query_set_antag_tokens.Execute()
	qdel(query_set_antag_tokens)

/**
 * Increases antag token count in the local cache, then invokes a database update.
 *
 * Arguments:
 * * token_count - Amount to increment the antag token count by
 */
/client/proc/inc_antag_token_count(token_count)
	SHOULD_NOT_SLEEP(TRUE)
	if(IsAdminAdvancedProcCall())
		return

	if(isnull(antag_token_count_cached))
		to_chat(usr, span_warning("Error adjusting antag tokens!"))
		CRASH("Antag token amount adjusted before value initialized")
	antag_token_count_cached += token_count

	INVOKE_ASYNC(src, GLOBAL_PROC_REF(db_inc_antag_token_count), ckey, token_count)

/proc/db_inc_antag_token_count(target_ckey, token_count)
	if(IsAdminAdvancedProcCall())
		return

	var/datum/db_query/query_inc_antag_tokens = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET antag_tokens = antag_tokens + :token_count WHERE ckey = :ckey",
		list("token_count" = token_count, "ckey" = target_ckey)
	)
	query_inc_antag_tokens.Execute()
	qdel(query_inc_antag_tokens)

