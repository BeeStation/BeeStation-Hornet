/// Cached metabalance, pulled just before prefs initialization.
/client/var/metabalance_cached = null

/client/proc/process_endround_metacoin()
	if(!mob)
		return
	var/mob/M = mob
	if(M.mind && !isnewplayer(M))
		if(M.stat != DEAD && !isbrain(M))
			if(EMERGENCY_ESCAPED_OR_ENDGAMED)
				if(!M.onCentCom() && !M.onSyndieBase())
					var/reward_type = ((isAI(M)|| iscyborg(M) ? METACOIN_ESCAPE_REWARD : METACOIN_SURVIVE_REWARD))
					inc_metabalance(reward_type, reason="Survived the shift.")
				else
					inc_metabalance(METACOIN_ESCAPE_REWARD, reason="Survived the shift and escaped!")
			else
				inc_metabalance(METACOIN_ESCAPE_REWARD, reason="Survived the shift.")
		else
			inc_metabalance(METACOIN_NOTSURVIVE_REWARD, reason="You tried.")

/client/proc/process_greentext()
	src.give_award(/datum/award/achievement/misc/greentext, src.mob)

/client/proc/process_ten_minute_living()
	inc_metabalance(METACOIN_TENMINUTELIVING_REWARD, FALSE)

/// Never-blocking method to retrieve cached metabalance. This CAN be null and runtimes if it is.
/// Use get_metabalance_db() for a more accurate measure. Never use this in modifying calculations.
/// The cached metabalance is initialized during client/Login()
/client/proc/get_metabalance_unreliable()
	SHOULD_NOT_SLEEP(TRUE)
	if(metabalance_cached == null)
		CRASH("Metacoin amount fetched before value initialized")
	return metabalance_cached

/client/proc/get_metabalance_async()
	return metabalance_cached || get_metabalance_db()

/// Gets the user's metabalance from the DB. Blocking.
/client/proc/get_metabalance_db()
	var/datum/db_query/query_get_metacoins = SSdbcore.NewQuery(
		"SELECT metacoins FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	var/mc_count = 0
	if(query_get_metacoins.warn_execute() && query_get_metacoins.NextRow())
		mc_count = query_get_metacoins.item[1]

	qdel(query_get_metacoins)
	var/count = text2num(mc_count)
	metabalance_cached = count
	return count

/// Sets metabalance in the local cache, then invokes a database update.
/// mc_count: Amount to increment the metabalance by
/// ann: If we should announce this modification to the user.
/client/proc/set_metacoin_count(mc_count, ann=TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	if(metabalance_cached == null)
		CRASH("Metacoin amount adjusted before value initialized")
	metabalance_cached = mc_count
	if(ann)
		to_chat(src, span_rosebold("Your new metacoin balance is [mc_count]!"))
	INVOKE_ASYNC(src, PROC_REF(db_set_metabalance), mc_count)

/// Increases metabalance in the local cache, then invokes a database update.
/// mc_count: Amount to increment the metabalance by
/// ann: If we should announce this modification to the user.
/// reason: The reason the metabalance was modified, echoed to the user.
/client/proc/inc_metabalance(mc_count, ann=TRUE, reason=null)
	SHOULD_NOT_SLEEP(TRUE)
	if(mc_count >= 0 && !CONFIG_GET(flag/grant_metacurrency))
		return FALSE
	if(metabalance_cached == null)
		CRASH("Metacoin amount adjusted before value initialized")
	metabalance_cached += mc_count
	if(ann)
		if(reason)
			to_chat(src, span_rosebold("[abs(mc_count)] [CONFIG_GET(string/metacurrency_name)]\s have been [mc_count >= 0 ? "deposited to" : "withdrawn from"] your account! Reason: [reason]"))
		else
			to_chat(src, span_rosebold("[abs(mc_count)] [CONFIG_GET(string/metacurrency_name)]\s have been [mc_count >= 0 ? "deposited to" : "withdrawn from"] your account!"))
	INVOKE_ASYNC(src, PROC_REF(db_inc_metabalance), mc_count)
	return TRUE

/client/proc/db_inc_metabalance(mc_count)
	var/datum/db_query/query_set_metacoins = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET metacoins = metacoins + :mc_count WHERE ckey = :ckey",
		list("mc_count" = mc_count, "ckey" = ckey)
	)
	query_set_metacoins.warn_execute()
	qdel(query_set_metacoins)

/client/proc/db_set_metabalance(mc_count)
	var/datum/db_query/query_set_metacoins = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET metacoins = :mc_count WHERE ckey = :ckey",
		list("mc_count" = mc_count, "ckey" = ckey)
	)
	query_set_metacoins.warn_execute()
	qdel(query_set_metacoins)
