/// Created when a user clicks the "pAI candidate" window
/datum/pai_candidate
	/// User inputted OOC comments
	var/comments
	/// User inputted behavior description
	var/description
	/// User's ckey - not input
	var/ckey
	/// User's pAI name. If blank, ninja name.
	var/name
	/// If the user has hit "submit"
	var/ready = FALSE

/datum/pai_candidate/proc/save(mob/user)
	if(IS_GUEST_KEY(user.key))
		to_chat(usr, span_boldnotice("You cannot save pAI information as a guest."))
		return FALSE
	if(!user.client)
		return FALSE
	user.client.prefs.pai_name = name
	user.client.prefs.pai_description = description
	user.client.prefs.pai_comment = comments
	user.client.prefs.mark_undatumized_dirty_player()
	to_chat(usr, span_boldnotice("You have saved pAI information."))
	return TRUE

// loads the savefile corresponding to the mob's ckey
// returns TRUE if loaded (or file was incompatible)
// returns FALSE if savefile did not exist

/datum/pai_candidate/proc/load(mob/user)
	if (IS_GUEST_KEY(user.key))
		return FALSE

	if(!user.client)
		return FALSE
	name = user.client.prefs.pai_name
	description = user.client.prefs.pai_description
	comments = user.client.prefs.pai_comment
	return TRUE
