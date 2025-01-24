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
	to_chat(owner, "<span class='boldannounce'>Due to overcrowding, you have been transferred from a Nanotrasen security facility out to this middle-of-nowhere science station. This might be your chance to escape! \
					Do anything you can to escape prison and sneak off the station when the shift ends, via an emergency pod or the main transfer shuttle. \
					Avoid killing as much as possible, especially non-security staff, but everything else is fair game!</span>")
	owner.announce_objectives()

/datum/antagonist/prisoner/proc/update_prisoner_icons_added(var/mob/living/carbon/human/prisoner)
	var/datum/atom_hud/antag/prihud = GLOB.huds[ANTAG_HUD_PRISONER]
	prihud.join_hud(prisoner)
	set_antag_hud(prisoner, "prisoner")

/datum/antagonist/prisoner/proc/update_prisoner_icons_removed(var/mob/living/carbon/human/prisoner)
	var/datum/atom_hud/antag/prihud = GLOB.huds[ANTAG_HUD_PRISONER]
	prihud.leave_hud(prisoner)
	set_antag_hud(prisoner, null)
