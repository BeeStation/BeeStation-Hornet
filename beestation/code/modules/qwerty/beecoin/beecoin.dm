/client/proc/get_beecoin_count()
	var/datum/DBQuery/query_get_beecoins = SSdbcore.NewQuery("SELECT beecoins FROM [format_table_name("player")] WHERE ckey = '[ckey]'")
	var/bc_count = 0
	if(query_get_beecoins.warn_execute())
		if(query_get_beecoins.NextRow())
			bc_count = query_get_beecoins.item[1]

	qdel(query_get_beecoins)
	return text2num(bc_count)

/client/proc/set_beecoin_count(bc_count, ann=TRUE)
	var/datum/DBQuery/query_set_beecoins = SSdbcore.NewQuery("UPDATE [format_table_name("player")] SET beecoins = '[bc_count]' WHERE ckey = '[ckey]'")
	query_set_beecoins.warn_execute()
	qdel(query_set_beecoins)
	if(ann)
		to_chat(src, "Your new beecoin balance is [bc_count]!")

/client/proc/inc_beecoin_count(bc_count, ann=TRUE)
	var/datum/DBQuery/query_inc_beecoins = SSdbcore.NewQuery("UPDATE [format_table_name("player")] SET beecoins = beecoins + '[bc_count]' WHERE ckey = '[ckey]'")
	query_inc_beecoins.warn_execute()
	qdel(query_inc_beecoins)
	if(ann)
		to_chat(src, "[bc_count] beecoins have been deposited to your account!")
