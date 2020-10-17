
/**
 * public
 *
 * Sends stat panel info for things that are set constantly throughout the round.
 *
 * Round ID
 */
/datum/tgui_panel/proc/initial_stat_info(payload)
	if(!is_ready())
		return
	window.send_message("stat/setInfo", payload)

/**
 * public
 *
 * Sends stat panel info for things that are set constantly throughout the round.
 *
 * Note: List twice to prevent sending as an object rather than a list.
 * list(list(
 *		"statPanelName" = list
 * 		(
 *			"" = ""
 * 		)
 * ))
 *
 * Round Time
 * Mob status
 * Antagonist or not
 * etc.
 */
/datum/tgui_panel/proc/update_stat_info(payload)
	if(!is_ready())
		return
	window.send_message("stat/updateInfo", payload)

/**
 * public
 *
 * Updates the stat panel with the names of the verbs
 * accessable to the client.
 *
 * Should be called when the client recieves new verbs (adminning / deadminning)
 */
/datum/tgui_panel/proc/update_verbs()
