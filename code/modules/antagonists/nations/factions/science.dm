/datum/team/nationsci
	name = "Sciencetopia"
	member_name = "Sciencetopians"

/datum/antagonist/sciencetopia
	name = "Sciencetopians"
	show_in_antagpanel = TRUE
	antagpanel_category = "Nations"
	job_rank = ROLE_NATIONS
	show_name_in_check_antagonists = TRUE
	var/datum/team/nation/nationsci
	var/hud_type = "nation"

/datum/antagonist/sciencetopia/on_gain()
	owner.special_role = ROLE_NATIONS
	. = ..()

/datum/antagonist/sciencetopia/greet()
	to_chat(owner, "<B><font size='3'>You are apart of Sciencetopia - Defend it with your technological prowess, and defend your brothers in arms!</font></B>")