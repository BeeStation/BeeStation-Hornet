/datum/antagonist/fugitive
	name = "Fugitive"
	roundend_category = "Fugitive"
	banning_key = ROLE_FUGITIVE
	show_in_antagpanel = TRUE
	antagpanel_category = "Fugitives"
	show_to_ghosts = TRUE
	prevent_roundtype_conversion = FALSE
	required_living_playtime = 1
	var/datum/team/fugitive/fugitive_team
	var/is_captured = FALSE
	var/living_on_capture = TRUE
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
	to_chat(owner, span_bigbold("You are the Fugitive!"))
	to_chat(owner, backstory.greet_message)
	to_chat(owner, span_boldannounce("You should not be killing anyone you please, but you can do anything to avoid being captured."))
	to_chat(owner, span_bold("Someone was hot on my tail when I managed to get to this space station! I probably have about 10 minutes before they show up..."))
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
		fugitive_team.backstory = backstory
		fugitive_team.forge_team_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	fugitive_team = new_team

/datum/antagonist/fugitive/get_team()
	return fugitive_team

/datum/objective/escape_capture
	name = "Escape Capture"
	explanation_text = "Ensure that no fugitives are captured by fugitive hunters."

/datum/objective/escape_capture/check_completion()
	if(!team || explanation_text == "Free Objective" || ..())
		return TRUE
	for(var/datum/mind/T in team.members)
		var/datum/antagonist/fugitive/A = T.has_antag_datum(/datum/antagonist/fugitive)
		if(istype(A) && A.is_captured)
			return FALSE
	return TRUE

/datum/team/fugitive
	name = "Fugitives"
	member_name = "fugitive"
	var/datum/fugitive_type/backstory

/datum/team/fugitive/get_team_name() // simple to know fugitive story
	return backstory.multiple_name

/datum/team/fugitive/roundend_report() //shows the number of fugitives, but not if they won in case there is no security
	var/list/fugitives = list()
	for(var/datum/mind/T in members)
		var/datum/antagonist/fugitive/A = T.has_antag_datum(/datum/antagonist/fugitive)
		fugitives += A
	if(!fugitives.len)
		return

	var/list/result = list()
	result += "<div class='panel redborder'>"
	result += span_header("[name]:")
	result += "<b>[fugitives.len]</b> fugitive\s took refuge on [station_name()]!<br />"
	var/list/parts = list()
	parts += "<ul class='playerlist'>"
	for(var/datum/antagonist/fugitive/antag in fugitives)
		if(!antag.owner)
			continue
		parts += "<li>[printplayer(antag.owner)]\
		<br />  - and they [antag.is_captured ? span_redtext("were captured by the hunters, [antag.living_on_capture ? "alive" : "dead"]") : span_greentext("escaped the hunters")]</li>"
	parts += "</ul>"
	result += parts.Join()
	result += "</div>"
	return result.Join("<br />")

/datum/team/fugitive/proc/forge_team_objectives()
	var/datum/objective/escape_capture/survive = new()
	survive.team = src
	objectives += survive

/datum/antagonist/fugitive/proc/update_fugitive_icons_added(mob/living/carbon/human/fugitive)
	var/datum/atom_hud/antag/fughud = GLOB.huds[ANTAG_HUD_FUGITIVE]
	fughud.join_hud(fugitive)
	set_antag_hud(fugitive, "fugitive")

/datum/antagonist/fugitive/proc/update_fugitive_icons_removed(mob/living/carbon/human/fugitive)
	var/datum/atom_hud/antag/fughud = GLOB.huds[ANTAG_HUD_FUGITIVE]
	fughud.leave_hud(fugitive)
	set_antag_hud(fugitive, null)
