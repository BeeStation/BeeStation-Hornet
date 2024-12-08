/// Preset for an action that has a cooldown.
/datum/action/cooldown
	transparent_when_unavailable = FALSE


/datum/action/cooldown/create_button()
	var/atom/movable/screen/movable/action_button/button = ..()
	button.maptext = ""
	button.maptext_x = 8
	button.maptext_y = 0
	button.maptext_width = 24
	button.maptext_height = 12
	return button

/datum/action/cooldown/Remove(mob/living/remove_from)
	if(requires_target && remove_from.click_intercept == src)
		unset_click_ability(remove_from, refund_cooldown = FALSE)
	return ..()

/datum/action/cooldown/update_button(atom/movable/screen/movable/action_button/button, status_only = FALSE, force = FALSE)
	. = ..()
	if(!button)
		return
	var/time_left = max(next_use_time - world.time, 0)
	if(show_cooldown)
		button.maptext = MAPTEXT("<b>[CEILING(time_left/10, 1)]s</b>")
	if(!owner || time_left == 0)
		button.maptext = ""
	if(is_available() && (button.our_hud.mymob.click_intercept == src))
		button.color = COLOR_GREEN

/// Formats the action to be returned to the stat panel.
/datum/action/cooldown/proc/set_statpanel_format()
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
