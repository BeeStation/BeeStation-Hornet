/datum/team/nationengi
	name = "Engitopia"
	member_name = "Engitopians"

/datum/antagonist/engitopia
	name = "Engitopians"
	show_in_antagpanel = TRUE
	antagpanel_category = "Nations"
	job_rank = ROLE_NATIONS
	show_name_in_check_antagonists = TRUE
	var/datum/team/nation/nationengi
	var/hud_type = "nation"

/datum/antagonist/engitopia/on_gain()
	owner.special_role = ROLE_NATIONS
	. = ..()

/datum/antagonist/engitopia/greet()
	to_chat(owner, "<B><font size='3'>You are apart of engitopia - Defend it with all of your might, and protect your brothers in arms!</font></B>")