/**
 * private
 *
 * Handles incomming stat messages
 */
/datum/tgui_panel/proc/handle_stat_message(type, payload)
	switch(type)
		if("stat/setTab")
			client.selected_stat_tab = payload["selectedTab"]
			//Update the panel they are on
			client.mob?.UpdateMobStat(TRUE)
			client.mob?.stat_tab_changed()
			return TRUE
		if("stat/pressed")
			client.mob?.stat_pressed(payload["action_id"], payload["params"])
			client.mob?.UpdateMobStat(TRUE)
			return TRUE
	return FALSE

/**
 * public
 *
 * Sets the different available tabs.
 */
/datum/tgui_panel/proc/set_tab_info(payload)
	window.send_message("stat/setStatTabs", payload)

/**
 * public
 *
 * Sends TGUI the data of every single verb accessable to the user.
 */
/datum/tgui_panel/proc/set_verb_infomation(payload)
	window.send_message("stat/setVerbInfomation", payload)

/**
 * public
 *
 * Sets the infomation to be displayed of the current tab. (For non verb tabs)
 */
/datum/tgui_panel/proc/set_panel_infomation(payload)
	window.send_message("stat/setPanelInfomation", payload)

/**
 * public
 *
 * Sets the current tab.
 */
/datum/tgui_panel/proc/set_stat_tab(new_tab)
	window.send_message("stat/setTab", new_tab)

/**
 * public
 *
 * Displays the antagonist popup.
 */
/datum/tgui_panel/proc/give_antagonist_popup(title, text)
	if(!is_ready())
		return
	var/list/payload = list()
	payload["title"] = title
	payload["text"] = text
	window.send_message("stat/antagPopup", payload)

/**
 * public
 *
 * Clears the antagonist popup.
 */
/datum/tgui_panel/proc/clear_antagonist_popup()
	if(!is_ready())
		return
	window.send_message("stat/clearAntagPopup", list())

/**
 * public
 *
 * Displays the dead message.
 */
/datum/tgui_panel/proc/give_dead_popup()
	if(!is_ready())
		return
	window.send_message("stat/deadPopup", list())



/**
 * public
 *
 * Clears the death message
 */
/datum/tgui_panel/proc/clear_dead_popup()
	if(!is_ready())
		return
	window.send_message("stat/clearDeadPopup", list())

/**
 * public
 *
 * Displays the dead message.
 */
/datum/tgui_panel/proc/give_alert_popup(title, text)
	if(!is_ready())
		return
	var/list/payload = list()
	payload["title"] = title
	payload["text"] = text
	window.send_message("stat/alertPopup", payload)

/**
 * public
 *
 * Clears the death message
 */
/datum/tgui_panel/proc/clear_alert_popup()
	if(!is_ready())
		return
	window.send_message("stat/clearAlertPopup", list())

/**
 * public
 *
 * Displays the message asking an admin to start battle royale
 */
/datum/tgui_panel/proc/give_br_popup()
	if(!is_ready())
		return
	window.send_message("stat/alertBr")

/**
 * public
 *
 * Clears the message asking an admin to start battle royale
 */
/datum/tgui_panel/proc/clear_br_popup()
	if(!is_ready())
		return
	window.send_message("stat/clearAlertBr", list())
