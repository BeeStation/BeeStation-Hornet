/datum/antagonist/nightmare
	name = "\improper Nightmare"
	antagpanel_category = ANTAG_GROUP_ABOMINATIONS
	show_in_antagpanel = TRUE
	show_to_ghosts = TRUE
	banning_key = ROLE_NIGHTMARE
	ui_name = "AntagInfoNightmare"
	show_name_in_check_antagonists = TRUE
	required_living_playtime = 0
	antag_hud_name = "nightmare"

/datum/antagonist/nightmare/greet()
	. = ..()
	owner.announce_objectives()
	to_chat(owner, span_boldannounce("Your primary goal is keeping the station dark, do not kill people in such a way that is likely to completely remove them from the round."))

/datum/antagonist/nightmare/on_gain()
	forge_objectives()
	. = ..()

/datum/objective/nightmare_fluff

/datum/objective/nightmare_fluff/New()
	. = ..()
	explanation_text = pick(
		"Consume the last glimmer of light from the space station.",
		"Bring judgment upon the daywalkers.",
		"Extinguish the flame of this hellscape.",
		"Reveal the true nature of the shadows.",
		"From the shadows, all shall perish.",
		"Conjure nightfall by blade or by flame.",
		"Bring the darkness to the light.",
	)

/datum/objective/nightmare_fluff/check_completion()
	return owner.current && owner.current.stat != DEAD

/datum/antagonist/nightmare/forge_objectives()
	var/datum/objective/nightmare_fluff/objective = new
	objective.owner = owner
	objectives += objective

/datum/antagonist/nightmare/admin_add(datum/mind/new_owner, mob/admin)
	var/mob/living/carbon/C = new_owner.current
	if(alert(admin, "Transform the player into a nightmare?","Species Change","Yes","No") == "Yes")
		C.set_species(/datum/species/shadow/nightmare)
		new_owner.set_assigned_role(SSjob.get_job_type(/datum/job/nightmare))
		new_owner.special_role = ROLE_NIGHTMARE
	return ..()
