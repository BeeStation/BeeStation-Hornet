/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/client/var/datum/tgui_panel/tgui_panel

/**
 * tgui panel / chat troubleshooting verb
 */
/client/verb/fix_tgui_panel()
	set name = "Fix chat"
	set category = "OOC"
	var/action
	log_tgui(src, "Started fixing.")

	nuke_chat()

	// Failed to fix
	action = alert(src, "Did that work?", "", "Yes", "No, switch to old ui")
	if (action == "No, switch to old ui")
		winset(src, "legacy_output_selector", "left=output_legacy")
		log_tgui(src, "Failed to fix.")

/client/proc/nuke_chat()
	// Catch all solution (kick the whole thing in the pants)
	winset(src, "legacy_output_selector", "left=output_legacy")
	if(!tgui_panel || !istype(tgui_panel))
		log_tgui(src, "tgui_panel datum is missing")
		tgui_panel = new(src, "browseroutput")
	tgui_panel.Initialize(force = TRUE)
	// Force show the panel to see if there are any errors
	winset(src, "legacy_output_selector", "left=output_browser")

/client/verb/refresh_tgui()
	set name = "Refresh TGUI"
	set category = "OOC"

	for(var/window_id in tgui_windows)
		var/datum/tgui_window/window = tgui_windows[window_id]
		window.reinitialize()

/client/verb/panel_devtools()
	set name = "Enable TGUI Devtools"
	set category = "OOC"
	winset(src, "", "browser-options=devtools")
