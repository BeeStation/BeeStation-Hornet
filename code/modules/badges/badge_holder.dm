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

/proc/add_badge_to(datum/badge_rank/R, ckey)
	if(IsAdminAdvancedProcCall())
		message_admins("[key_name_admin(usr)] has tried to add a badge to [ckey] through the use of proc calls.")
		log_admin("[key_name(usr)] has tried to add a badge to [ckey] through the use of proc calls.")
		return
	if(!GLOB.badge_datums.Find(ckey))
		GLOB.badge_datums[ckey] = new /datum/badges(ckey)
	if(R)
		GLOB.badge_datums[ckey].badges += R
	if(GLOB.directory[ckey])
		var/client/C = GLOB.directory[ckey]
		if(!C.bholder)
			C.bholder = GLOB.badge_datums[ckey]
			GLOB.badgers |= C
