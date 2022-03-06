/*
		name
		key
		description
		role
		comments
		ready = 0
*/

/datum/paiCandidate/proc/prefs_save(mob/user)
	if(IS_GUEST_KEY(user.key))
		return FALSE

	var/datum/preferences/prefs = user?.client?.prefs
	if(!prefs)
		return FALSE

	prefs.pai_name = name
	prefs.pai_description = description
	prefs.pai_role = role
	prefs.pai_comments = comments

	return prefs.save_preferences()

/datum/paiCandidate/proc/prefs_load(mob/user, silent = TRUE)
	if (IS_GUEST_KEY(user.key))
		return FALSE

	var/datum/preferences/prefs = user?.client?.prefs
	if(!prefs)
		return FALSE

	name = prefs.pai_name
	description = prefs.pai_description
	role = prefs.pai_role
	comments = prefs.pai_comments

	return TRUE
