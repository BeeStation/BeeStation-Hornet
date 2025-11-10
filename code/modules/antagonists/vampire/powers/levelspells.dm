/**
 * Given to Vampires at the start and taken away as soon as they select a clan.
 */
/datum/action/vampire/clanselect
	name = "Select Clan"
	desc = "Take the first step as a true kindred and remember your true lineage."
	button_icon_state = "clanselect"
	power_explanation = "Activate to select your unique vampire clan."
	power_flags = BP_AM_SINGLEUSE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	special_flags = VAMPIRE_DEFAULT_POWER
	bloodcost = 0
	cooldown_time = 5 SECONDS

/datum/action/vampire/clanselect/activate_power()
	. = ..()
	vampiredatum_power.assign_clan_and_bane()
	deactivate_power()

/**
 * Given to Vampires every levelup. Opens the radial.
 */
/datum/action/vampire/levelup
	name = "Level Up"
	desc = "Take another step as a full kindred, and remember your true lineage."
	button_icon_state = "power_levelup"
	power_explanation = "Activate to level one of your disciplines."
	power_flags = BP_AM_SINGLEUSE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	bloodcost = 0
	cooldown_time = 5 SECONDS

/datum/action/vampire/levelup/activate_power()
	. = ..()
	vampiredatum_power.my_clan.spend_rank()
	deactivate_power()
