/datum/antagonist/prisoner
	name = "Prisoner"
	roundend_category = "Prisoner"
	banning_key = ROLE_PRISONER
	show_in_antagpanel = TRUE
	antagpanel_category = "Prisoners"
	show_to_ghosts = TRUE
	prevent_roundtype_conversion = FALSE
	count_against_dynamic_roll_chance = FALSE
	var/datum/team/prisoner/prisoner_team
	var/is_captured = FALSE
	var/living_on_capture = TRUE

/datum/antagonist/prisoner/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_prisoner_icons_added(M)

/datum/antagonist/prisoner/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_prisoner_icons_removed(M)

/datum/antagonist/prisoner/on_gain()
	for(var/datum/objective/O in prisoner_team.objectives)
		objectives += O
		log_objective(owner, O.explanation_text)
	return ..()

/datum/antagonist/prisoner/greet()
	to_chat(owner, "<span class='big bold'>You are the Prisoner!</span>")
	to_chat(owner, "<span class='boldannounce'>You should not be killing anyone you please, but you can do anything to escape Prison.</span>")
	owner.announce_objectives()

/datum/antagonist/prisoner/create_team(datum/team/prisoner/new_team)
	if(!new_team)
		for(var/datum/antagonist/prisoner/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.prisoner_team)
				prisoner_team = H.prisoner_team
				return
		prisoner_team = new /datum/team/prisoner
		prisoner_team.forge_team_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	prisoner_team = new_team

/datum/antagonist/prisoner/get_team()
	return prisoner_team

/datum/objective/escape_capture
	name = "Escape Capture"
	explanation_text = "Ensure that no prisoners are imprisoned by the end of the shift."

/datum/objective/escape_capture/check_completion()
	if(!team || explanation_text == "Free Objective" || ..())
		return TRUE
	for(var/datum/mind/T in team.members)
		var/datum/antagonist/prisoner/A = T.has_antag_datum(/datum/antagonist/prisoner)
		if(istype(A) && A.is_captured)
			return FALSE
	return TRUE

/datum/team/prisoner
	name = "Prisoners"
	member_name = "prisoner"

/datum/team/prisoner/roundend_report() //shows the number of fugitives, but not if they won in case there is no security
	var/list/prisoners = list()
	for(var/datum/mind/T in members)
		var/datum/antagonist/prisoner/A = T.has_antag_datum(/datum/antagonist/prisoner)
		prisoners += A
	if(!prisoners.len)
		return

	var/list/result = list()
	result += "<div class='panel redborder'>"
	result += "<span class='header'>[name]:</span>"
	result += "<b>[prisoners.len]</b> prisoners\s were sent to [station_name()]!<br />"
	var/list/parts = list()
	parts += "<ul class='playerlist'>"
	for(var/datum/antagonist/prisoner/antag in prisoners)
		if(!antag.owner)
			continue
		parts += "<li>[printplayer(antag.owner)]\
		<br />  - and they [antag.is_captured ? "<span class='redtext'>didn't manage to escape from Prison</span>" : "<span class='greentext'>escaped the prison</span>"]</li>"
	parts += "</ul>"
	result += parts.Join()
	result += "</div>"
	return result.Join("<br />")

/datum/team/prisoner/proc/forge_team_objectives()
	var/datum/objective/escape_capture/survive = new()
	survive.team = src
	objectives += survive

/datum/antagonist/prisoner/proc/update_prisoner_icons_added(var/mob/living/carbon/human/prisoner)
	var/datum/atom_hud/antag/prihud = GLOB.huds[ANTAG_HUD_PRISONER]
	prihud.join_hud(prisoner)
	set_antag_hud(prisoner, "prisoner")

/datum/antagonist/prisoner/proc/update_prisoner_icons_removed(var/mob/living/carbon/human/prisoner)
	var/datum/atom_hud/antag/prihud = GLOB.huds[ANTAG_HUD_PRISONER]
	prihud.leave_hud(prisoner)
	set_antag_hud(prisoner, null)
