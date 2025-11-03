/**
 * Given to Vampires at the start and taken away as soon as they select a clan.
 */
/datum/action/vampire/clanselect
	name = "Select Clan"
	desc = "Take the first step as a true kindred and remember your true lineage."
	button_icon_state = "clanselect"
	power_explanation = "Activate to select your unique vampire clan."
	power_flags = NONE
	check_flags = NONE
	special_flags = VAMPIRE_DEFAULT_POWER
	bloodcost = 0
	cooldown_time = 5 SECONDS

/datum/action/vampire/clanselect/can_use()
	. = ..()
	if(!.)
		return FALSE

/datum/action/vampire/clanselect/activate_power()
	. = ..()
	vampiredatum_power.assign_clan_and_bane()	// Async so the power doesn't stay active.
	deactivate_power()
