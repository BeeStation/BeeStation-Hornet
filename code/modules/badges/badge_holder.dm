GLOBAL_LIST_EMPTY(badge_datums)
GLOBAL_PROTECT(badge_datums)

/datum/badges
	var/target
	var/name
	var/list/datum/badge_rank/badges

/datum/badges/New(ckey)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate badge perms!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		if (!target) //only del if this is a true creation (and not just a New() proc call), other wise trialmins/coders could abuse this to deadmin other admins
			QDEL_IN(src, 0)
			CRASH("Admin proc call creation of admin datum")
		return
	if(!ckey)
		QDEL_IN(src, 0)
		CRASH("Badge datum created without a ckey")
	badges = list()
	target = ckey
	name = "[ckey]'s badge datum"

/datum/badges/Destroy()
	QDEL_LIST(badges)
	. = ..()


/datum/badges/proc/update()
	for(var/datum/badge_rank/badge as anything in badges)
		if(!(badge.name in GLOB.badge_ranks))
			badges.Remove(badge)	//Badge no longer exists

/datum/badges/proc/reload_from_db()
	var/datum/DBQuery/query_reload_badge_holder = SSdbcore.NewQuery("SELECT rank FROM [format_table_name("badge_holders")] WHERE ckey = :ckey",
		list("ckey" = target))
	if(!query_reload_badge_holder.Execute())
		to_chat(usr, "<span class='warning'>An error occured loading badge holders!</span>")
		log_sql("Error loading holders from database (source: Badge manager)")
		return
	//Hard reset our badges
	badges.Cut()
	//Find badges
	while(query_reload_badge_holder.NextRow())
		var/badge_rank = query_reload_badge_holder.item[1]
		var/skip
		if(!GLOB.badge_ranks[badge_rank])
			message_admins("[target] loaded with an invalid badge rank [badge_rank]")
			skip = 1
		if(!skip)
			add_badge_to(GLOB.badge_ranks[badge_rank], target)
	qdel(query_reload_badge_holder)
	//Re-apply mentor badges
	if(GLOB.badge_ranks["mentor"])
		if(GLOB.directory[target] in GLOB.mentors + GLOB.admins + GLOB.deadmins)
			add_badge_to(GLOB.badge_ranks["mentor"], target)

/proc/add_badge_to(datum/badge_rank/R, ckey)
	if(IsAdminAdvancedProcCall())
		message_admins("[key_name_admin(usr)] has tried to add a badge to [ckey] through the use of proc calls.")
		log_admin("[key_name(usr)] has tried to add a badge to [ckey] through the use of proc calls.")
		return
	if(!GLOB.badge_datums.Find(ckey))
		GLOB.badge_datums[ckey] = new /datum/badges(ckey)
	if(R)
		var/datum/badges/badge_holder = GLOB.badge_datums[ckey]
		for(var/datum/badge_rank/B in badge_holder.badges)
			if(B.group == R.group)
				if(B.priority > R.priority)
					//Don't add ourselves if there is a higher priority badge
					return
				else
					//Remove lower priority badges to ourself.
					var/datum/badges/badge = GLOB.badge_datums[ckey]
					badge.badges.Remove(B)
		badge_holder.badges += R
	if(GLOB.directory[ckey])
		var/client/C = GLOB.directory[ckey]
		if(!C.bholder)
			C.bholder = GLOB.badge_datums[ckey]
			GLOB.badgers |= C
