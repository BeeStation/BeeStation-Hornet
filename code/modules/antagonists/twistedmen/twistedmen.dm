/datum/team/twistedmen
	name = "Twisted Men"
	show_roundend_report = FALSE

/datum/antagonist/twistedmen
	name = "Twisted Men"
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	prevent_roundtype_conversion = FALSE
	antagpanel_category = "Twisted Men"
	delay_roundend = FALSE
	count_against_dynamic_roll_chance = FALSE
	antag_moodlet = /datum/mood_event/twisted_good
	var/datum/team/twistedmen/twisted_team

/datum/antagonist/twistedmen/create_team(datum/team/team)
	if(team)
		twisted_team = team
		objectives |= twisted_team.objectives
	else
		twisted_team = new

/datum/antagonist/twistedmen/get_team()
	return twisted_team

