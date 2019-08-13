/datum/team/nationserv
	name = "Servicetopia"
	member_name = "Servicetopians"

/datum/antagonist/servicetopia
	name = "Servicetopians"
	show_in_antagpanel = TRUE
	antagpanel_category = "Nations"
	job_rank = ROLE_NATIONS
	show_name_in_check_antagonists = TRUE
	var/datum/team/nation/nationserv
	var/hud_type = "nation"

/datum/antagonist/servicetopia/on_gain()
	owner.special_role = ROLE_NATIONS
	. = ..()

/datum/antagonist/servicetopia/greet()
	to_chat(owner, "<B><font size='3'>You are apart of Servicetopia! Glory to the workers! Defend your brothers.</font></B>")