/datum/antagonist/clockcult
	name = "Servant Of Ratvar"
	roundend_category = "Clock cultists"
	antagpanel_category = "Clockcult"
	antag_moodlet = /datum/mood_event/cult
	job_rank = ROLE_SERVANT_OF_RATVAR

/datum/antagonist/clockcult/silent
	slient = TRUE
	show_in_antagpanel = FALSE

/datum/team/clockcult
	name = "Clockcult"
	var/list/objective
	var/datum/mind/eminence
