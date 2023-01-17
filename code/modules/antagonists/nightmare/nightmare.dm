/datum/antagonist/nightmare
	name = "Nightmare"
	show_in_antagpanel = TRUE
	show_to_ghosts = TRUE
	job_rank = ROLE_NIGHTMARE
	antagpanel_category = "Nightmare"
	show_name_in_check_antagonists = TRUE

/datum/antagonist/nightmare/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/nightmare/greet()
	owner.announce_objectives()

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
		new_owner.assigned_role = "Nightmare"
		new_owner.special_role = "Nightmare"
	. = ..()
