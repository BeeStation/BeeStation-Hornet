/datum/team/nationmed
	name = "Medistan"
	member_name = "Medistannis"

/datum/antagonist/medistannis
	name = "Medistannis"
	show_in_antagpanel = TRUE
	antagpanel_category = "Nations"
	job_rank = ROLE_NATIONS
	show_name_in_check_antagonists = TRUE
	var/datum/team/nation/nationmed
	var/hud_type = "nation"

/datum/antagonist/medistannis/on_gain()
	owner.special_role = ROLE_NATIONS
	. = ..()

/datum/antagonist/medistannis/greet()
	to_chat(owner, "<B><font size='3'>You are apart of of the great nation called Medistan. Defend your medbay and provide help to those in need!</font></B>")