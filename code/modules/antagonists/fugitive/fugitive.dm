/datum/antagonist/fugitive
	name = "Fugitive"
	roundend_category = "Fugitive"
	job_rank = ROLE_FUGITIVE
	show_in_antagpanel = TRUE
	antagpanel_category = "Fugitives"
	show_to_ghosts = TRUE
	prevent_roundtype_conversion = FALSE
	count_against_dynamic_roll_chance = FALSE
	var/datum/team/fugitive/fugitive_team
	var/is_captured = FALSE
	var/datum/fugitive_type/backstory

/datum/antagonist/fugitive/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_fugitive_icons_added(M)

/datum/antagonist/fugitive/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_fugitive_icons_removed(M)

/datum/antagonist/fugitive/on_gain()
	for(var/datum/objective/O in fugitive_team.objectives)
		objectives += O
		log_objective(owner, O.explanation_text)
	return ..()

/datum/antagonist/fugitive/greet()
	to_chat(owner, "<span class='big bold'>You are the Fugitive!</span>")
	to_chat(owner, backstory.greet_message)
	to_chat(owner, "<span class='boldannounce'>You should not be killing anyone you please, but you can do anything to avoid being captured.</span>")
	to_chat(owner, "<span class='bold'>Someone was hot on my tail when I managed to get to this space station! I probably have about 10 minutes before they show up...</span>")
	owner.announce_objectives()

/datum/antagonist/fugitive/create_team(datum/team/fugitive/new_team)
	if(!new_team)
		for(var/datum/antagonist/fugitive/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.fugitive_team)
				fugitive_team = H.fugitive_team
				return
		fugitive_team = new /datum/team/fugitive
		fugitive_team.forge_team_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	fugitive_team = new_team

/datum/antagonist/fugitive/get_team()
	return fugitive_team

/datum/team/fugitive/roundend_report() //shows the number of fugitives, but not if they won in case there is no security
	var/list/fugitives = list()
	for(var/datum/antagonist/fugitive/fugitive_antag in GLOB.antagonists)
		if(!fugitive_antag.owner)
			continue
		fugitives += fugitive_antag
	if(!fugitives.len)
		return

	var/list/result = list()

	result += "<div class='panel redborder'><B>[fugitives.len]</B> [fugitives.len == 1 ? "fugitive" : "fugitives"] took refuge on [station_name()]!"

	for(var/datum/antagonist/fugitive/antag in fugitives)
		if(antag.owner)
			result += "<b>[printplayer(antag.owner)]</b>"

	return result.Join("<br>")

/datum/team/fugitive/proc/forge_team_objectives()
	var/datum/objective/survive = new /datum/objective
	survive.team = src
	survive.explanation_text = "Avoid capture from the fugitive hunters."
	objectives += survive

/datum/antagonist/fugitive/proc/update_fugitive_icons_added(var/mob/living/carbon/human/fugitive)
	var/datum/atom_hud/antag/fughud = GLOB.huds[ANTAG_HUD_FUGITIVE]
	fughud.join_hud(fugitive)
	set_antag_hud(fugitive, "fugitive")

/datum/antagonist/fugitive/proc/update_fugitive_icons_removed(var/mob/living/carbon/human/fugitive)
	var/datum/atom_hud/antag/fughud = GLOB.huds[ANTAG_HUD_FUGITIVE]
	fughud.leave_hud(fugitive)
	set_antag_hud(fugitive, null)
