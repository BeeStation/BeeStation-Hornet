/datum/antagonist/nightmare
	name = "Nightmare"
	show_in_antagpanel = TRUE
	show_to_ghosts = TRUE
	banning_key = ROLE_NIGHTMARE
	antagpanel_category = "Nightmare"
	ui_name = "AntagInfoNightmare"
	show_name_in_check_antagonists = TRUE
	required_living_playtime = 0
	antag_hud_name = "nightmare"

/datum/antagonist/nightmare/on_gain()
	forge_objectives()
	return  ..()

/datum/antagonist/nightmare/greet()
	owner.announce_objectives()
	to_chat(owner, span_boldannounce("Your primary goal is keeping the station dark, do not kill people in such a way that is likely to completely remove them from the round."))

/datum/antagonist/nightmare/proc/forge_objectives()
	var/datum/objective/smash_lights/nolight = new
	nolight.owner = owner
	objectives += nolight

/datum/objective/smash_lights
	explanation_text = "Ensure the station is shrouded in darkness, Snuff out all lights aboard the station, \
						Defend yourself against any being that dares disturb your darkness with light."
	completed = TRUE

/datum/antagonist/nightmare/admin_add(datum/mind/new_owner,mob/admin)
	var/mob/living/carbon/C = new_owner.current
	if(alert(admin,"Transform the player into a nightmare?","Species Change","Yes","No") == "Yes")
		C.set_species(/datum/species/shadow/nightmare)
		new_owner.assigned_role = ROLE_NIGHTMARE
		new_owner.special_role = ROLE_NIGHTMARE
	return ..()
