/client/proc/get_beecoin_count() //We had to go back
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
		to_chat(src, "<span class='rose bold'>Your new beecoin balance is [bc_count]!</span>")

/client/proc/inc_beecoin_count(bc_count, ann=TRUE)
	var/datum/DBQuery/query_inc_beecoins = SSdbcore.NewQuery("UPDATE [format_table_name("player")] SET beecoins = beecoins + '[bc_count]' WHERE ckey = '[ckey]'")
	query_inc_beecoins.warn_execute()
	qdel(query_inc_beecoins)
	if(ann)
		to_chat(src, "<span class='rose bold'>[bc_count] beecoins have been deposited to your account!</span>")



/client/verb/beecoin_shop()
	set category = "OOC"
	set name = "Beecoin Shop"
	set desc="The shop for buying things with beecoins!"

	var/beecoins = src.get_beecoin_count()
	var/body = "<body>"
	body += "<div style='font-size: 20px;'><b>Beecoin Balance</b>: [beecoins]</div><br><br>"
 	body += "<h1 align='center' style='font-size: 35px;'>Coming Soon!</h1><br>"

	body += "<br></body>"

	var/datum/browser/popup = new(usr, "beecoinshop-[REF(src)]", "<div style='font-size: 20px;' align='center'>Welcome to the BeeCoin Shop!</div>", 700, 500)
	popup.set_content(body)
	popup.open(0)
