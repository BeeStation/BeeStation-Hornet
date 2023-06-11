/// Returns if the given client is an admin, REGARDLESS of if they're deadminned or not.
/proc/is_admin(client)
	var/ckey = ""
	if(istext(client))
		ckey = client
	else if(istype(client))
		ckey = client.ckey
	else
		return FALSE
	return !isnull(GLOB.admin_datums[ckey]) || !isnull(GLOB.deadmins[ckey])
