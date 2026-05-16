/datum/antagonist/nightmare
	name = "\improper Nightmare"
	antagpanel_category = ANTAG_GROUP_ABOMINATIONS
	show_in_antagpanel = TRUE
	show_to_ghosts = TRUE
	banning_key = ROLE_NIGHTMARE
	ui_name = "AntagInfoNightmare"
	show_name_in_check_antagonists = TRUE
	required_living_playtime = 0

/datum/antagonist/nightmare/greet()
	. = ..()
	owner.announce_objectives()
	to_chat(owner, span_boldannounce("Your primary goal is keeping the station dark, do not kill people in such a way that is likely to completely remove them from the round."))

/datum/antagonist/nightmare/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/nightmare/apply_innate_effects(mob/living/mob_override)
	. = ..()
	//Give nightmare appearance on hud (If they are not an antag already)
	var/datum/atom_hud/antag/nightmarehud = GLOB.huds[ANTAG_HUD_NIGHTMARE]
	nightmarehud.join_hud(owner.current)
	if(!owner.antag_hud_icon_state)
		set_antag_hud(owner.current, "nightmare")

/datum/antagonist/nightmare/remove_innate_effects(mob/living/mob_override)
	. = ..()
	//Clear the hud if they haven't become something else and had the hud overwritten
	var/datum/atom_hud/antag/nightmarehud = GLOB.huds[ANTAG_HUD_NIGHTMARE]
	nightmarehud.leave_hud(owner.current)
	if(owner.antag_hud_icon_state == "nightmare")
		set_antag_hud(owner.current, null)

/datum/objective/nightmare_fluff

/datum/objective/nightmare_fluff/New()
	var/list/explanation_texts = list(
		"Consume the last glimmer of light from the space station.",
		"Bring judgment upon the daywalkers.",
		"Extinguish the flame of this hellscape.",
		"Reveal the true nature of the shadows.",
		"From the shadows, all shall perish.",
		"Conjure nightfall by blade or by flame.",
		"Bring the darkness to the light."
	)
	explanation_text = pick(explanation_texts)
	..()

/datum/objective/nightmare_fluff/check_completion()
	return owner.current.stat != DEAD

/datum/antagonist/nightmare/forge_objectives()
	var/datum/objective/nightmare_fluff/objective = new
	objective.owner = owner
	objectives += objective

/datum/antagonist/nightmare/admin_add(datum/mind/new_owner,mob/admin)
	var/mob/living/carbon/C = new_owner.current
	if(alert(admin,"Transform the player into a nightmare?","Species Change","Yes","No") == "Yes")
		C.set_species(/datum/species/shadow/nightmare)
		new_owner.set_assigned_role(ROLE_NIGHTMARE)
		new_owner.special_role = ROLE_NIGHTMARE
	return ..()
