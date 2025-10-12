/**
 *	# Tremere Powers
 *
 *	This file is for Tremere power procs and Vampire procs that deals exclusively with Tremere.
 *	Tremere has quite a bit of unique things to it, so I thought it's own subtype would be nice
 */

/datum/action/vampire/targeted/tremere
	name = "Tremere Gift"
	desc = "A Tremere exclusive gift."
	background_icon_state = "tremere_power_off"
	button_icon_state = "power_auspex"

	background_icon_state_on = "tremere_power_on"
	background_icon_state_off = "tremere_power_off"

	// Tremere powers don't level up, we have them hardcoded.
	level_current = 0
	// Re-defining these as we want total control over them
	power_flags = BP_AM_TOGGLE | BP_AM_STATIC_COOLDOWN
	purchase_flags = TREMERE_CAN_BUY
	// Targeted stuff
	power_activates_immediately = FALSE

	///The upgraded version of this Power. 'null' means it's the max level.
	var/upgraded_power = null
