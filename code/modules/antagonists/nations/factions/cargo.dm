/datum/team/nationcargo
	name = "Cargonia"
	member_name = "Cargonians"

/datum/antagonist/cargonia
	name = "cargonia"
	show_in_antagpanel = TRUE
	antagpanel_category = "Nations"
	job_rank = ROLE_NATIONS
	show_name_in_check_antagonists = TRUE
	var/datum/team/nation/nationcargo
	var/hud_type = "nation"

/datum/antagonist/cargonia/on_gain()
	owner.special_role = ROLE_NATIONS
	. = ..()

/datum/antagonist/cargonia/greet()
	to_chat(owner, "<B><font size='3'>You are apart of Cargonia! Supply illegal drugs, guns etc to other nations and make the QM Proud!</font></B>")