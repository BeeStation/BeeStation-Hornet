/datum/team/nationsec
	name = "Securitystan"
	member_name = "Security"

/datum/antagonist/securitystan
	name = "Security"
	show_in_antagpanel = TRUE
	antagpanel_category = "Nations"
	job_rank = ROLE_NATIONS
	show_name_in_check_antagonists = TRUE
	var/datum/team/nation/nationsec
	var/hud_type = "nation"

/datum/antagonist/securitystan/on_gain()
	owner.special_role = ROLE_NATIONS
	. = ..()

/datum/antagonist/securitystan/greet()
	to_chat(owner, "<B><font size='3'>You are apart of of the great nation called Securitystan. Control the other nations, and stop all illegal trade. Glory to Securitystan!</font></B>")