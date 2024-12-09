/// Formats the action to be returned to the stat panel.
/datum/action/proc/set_statpanel_format()
	// TODO: Doesn't work
	if(!panel)
		return null

	var/time_remaining = max(next_use_time - world.time, 0)
	var/time_remaining_in_seconds = round(time_remaining / 10, 0.1)
	var/cooldown_time_in_seconds =  round(cooldown_time / 10, 0.1)

	var/list/stat_panel_data = list()

	// Pass on what panel we should be displayed in.
	stat_panel_data[PANEL_DISPLAY_PANEL] = panel
	// Also pass on the name of the spell, with some spacing
	stat_panel_data[PANEL_DISPLAY_NAME] = " - [name]"

	// No cooldown time at all, just show the ability
	if(cooldown_time_in_seconds <= 0)
		stat_panel_data[PANEL_DISPLAY_STATUS] = ""

	// It's a toggle-active ability, show if it's active
	else if(requires_target && owner.click_intercept == src)
		stat_panel_data[PANEL_DISPLAY_STATUS] = "ACTIVE"

	// It's on cooldown, show the cooldown
	else if(time_remaining_in_seconds > 0)
		stat_panel_data[PANEL_DISPLAY_STATUS] = "CD - [time_remaining_in_seconds]s / [cooldown_time_in_seconds]s"

	// It's not on cooldown, show that it is ready
	else
		stat_panel_data[PANEL_DISPLAY_STATUS] = "READY"

	return stat_panel_data
