/datum/antagonist/prisoner
	name = "Prisoner"
	roundend_category = "Prisoner"
	banning_key = ROLE_PRISONER
	show_in_antagpanel = TRUE
	antagpanel_category = "Prisoners"
	show_to_ghosts = TRUE
	prevent_roundtype_conversion = FALSE
	count_against_dynamic_roll_chance = FALSE

/datum/antagonist/prisoner/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_prisoner_icons_added(M)

/datum/antagonist/prisoner/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_prisoner_icons_removed(M)

/datum/antagonist/prisoner/on_gain()
	forge_objectives()
	return ..()

/datum/antagonist/prisoner/proc/forge_objectives()
	var/datum/objective/escape/escape = new
	escape.owner = owner
	objectives += escape

/datum/antagonist/prisoner/greet()
	to_chat(owner, "<span class='big bold'>You are the Prisoner!</span>")
	to_chat(owner, "<span class='boldannounce'>You should not be killing anyone you please, but you can do anything to escape Prison.</span>")
	owner.announce_objectives()

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


/datum/antagonist/prisoner/proc/update_prisoner_icons_added(var/mob/living/carbon/human/prisoner)
	var/datum/atom_hud/antag/prihud = GLOB.huds[ANTAG_HUD_PRISONER]
	prihud.join_hud(prisoner)
	set_antag_hud(prisoner, "prisoner")

/datum/antagonist/prisoner/proc/update_prisoner_icons_removed(var/mob/living/carbon/human/prisoner)
	var/datum/atom_hud/antag/prihud = GLOB.huds[ANTAG_HUD_PRISONER]
	prihud.leave_hud(prisoner)
	set_antag_hud(prisoner, null)
