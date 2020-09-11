
GLOBAL_LIST_EMPTY(badge_ranks)
GLOBAL_PROTECT(badge_ranks)

/datum/badge_rank
	var/name = "NoBadgeRank"
	var/group = "NoGroup"
	var/badge_icon = "badge_null"
	var/priority = 0

/datum/badge_rank/New(init_name, init_group, init_icon, badge_priority)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevator their badge level!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name_admin(usr)][msg]")
		if(name == "NoBadgeRank")
			QDEL_IN(src, 0)
			CRASH("Admin proc call creation of badge datum")
		return
	name = init_name
	group = init_group
	badge_icon = init_icon
	priority = badge_priority
	if(!name)
		qdel(src)
		CRASH("Badge rank created without name.")
	if(!group)
		qdel(src)
		CRASH("Badge rank created without group.")
	if(!badge_icon)
		qdel(src)
		CRASH("Badge rank created without badge_icon.")

/datum/badge_rank/Destroy()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate their badge status!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return QDEL_HINT_LETMELIVE
	. = ..()

/datum/badge_rank/vv_edit_var(var_name, var_value)
	return FALSE

/proc/sync_badges_with_db()
	set waitfor = FALSE

	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='admin prefix'>Badge DB sync blocked: Advanced ProcCall detected.</span>")
		return

	var/list/sql_badges = list()
	for(var/brank_name in GLOB.badge_ranks)
		var/datum/badge_rank/R = GLOB.badge_ranks[brank_name]
		sql_badges += list(list("rank" = R.name, "group" = R.group, "icon" = R.badge_icon))
	SSdbcore.MassInsert(format_table_name("badge_ranks"), sql_badges, duplicate_key = TRUE)

/proc/load_badge_ranks(no_update)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='admin prefix'>Badge Reload blocked: Advanced ProcCall detected.</span>")
		return
	GLOB.badge_ranks.Cut()
	// Load from database
	if(CONFIG_GET(flag/badges))
		var/datum/DBQuery/query_load_badge_ranks = SSdbcore.NewQuery("SELECT rank, rank_group, icon, priority FROM [format_table_name("badge_ranks")]")
		if(!query_load_badge_ranks.Execute())
			message_admins("Error loading badge ranks from database.")
			log_sql("Error loading badge ranks from database.")
			qdel(query_load_badge_ranks)
			return
		while(query_load_badge_ranks.NextRow())
			var/skip = FALSE
			var/rank_name = query_load_badge_ranks.item[1]
			for(var/brank_name in GLOB.badge_ranks)
				var/datum/badge_rank/R = GLOB.badge_ranks[brank_name]
				if(R.name == rank_name)
					skip = TRUE
					break
			if(!skip)
				var/rank_group = query_load_badge_ranks.item[2]
				var/rank_icon = query_load_badge_ranks.item[3]
				var/priority = query_load_badge_ranks.item[4]
				var/datum/badge_rank/R = new(rank_name, rank_group, rank_icon, priority)
				if(!R)
					continue
				GLOB.badge_ranks[R.name] = R
		qdel(query_load_badge_ranks)

/proc/load_badges()
	if(!CONFIG_GET(flag/badges))
		return
	if(!SSdbcore.Connect())
		message_admins("Failed to connect to database while getting badges.")
		log_sql("Failed to connect to database while getting badges.")
		return
	GLOB.badge_datums.Cut()
	GLOB.badge_ranks.Cut()
	for(var/client/C in GLOB.badgers)
		QDEL_NULL(C.bholder)
	GLOB.badgers.Cut()
	load_badge_ranks()
	var/list/badge_names = GLOB.badge_ranks
	var/datum/DBQuery/query_load_badgers = SSdbcore.NewQuery("SELECT ckey, rank FROM [format_table_name("badge_holders")] ORDER BY `rank`")
	if(!query_load_badgers.Execute())
		message_admins("Error loading badge holders from database.")
		log_sql("Error loading badge holders from database.")
		return
	while(query_load_badgers.NextRow())
		var/badge_holder_ckey = ckey(query_load_badgers.item[1])
		var/badge_rank = query_load_badgers.item[2]
		var/skip
		if(!badge_names[badge_rank])
			message_admins("[badge_holder_ckey] loaded with an invalid badge rank [badge_rank]")
			skip = 1
		if(!skip)
			add_badge_to(badge_names[badge_rank], badge_holder_ckey)
	qdel(query_load_badgers)
	//Re-apply mentor badges
	if(badge_names["mentor"])
		var/list/mentor_clients = GLOB.mentors + GLOB.admins + GLOB.deadmins
		for(var/client/C in mentor_clients)
			add_badge_to(badge_names["mentor"], C.ckey)
	//Add permission rank badges
	for(var/client/C in (GLOB.admins + GLOB.deadmins))
		if(badge_names.Find(C.holder.rank.name))
			add_badge_to(badge_names[C.holder.rank.name], C.ckey)

/proc/get_rank_from_name(rank_name)
	return GLOB.badge_ranks[rank_name]

//Removes invalid badges from bholders.
/proc/check_invalid_badges()
	for(var/datum/badges/B as anything in GLOB.badge_datums)
		B.update()
