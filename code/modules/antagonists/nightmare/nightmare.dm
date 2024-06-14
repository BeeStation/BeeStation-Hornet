/datum/antagonist/nightmare
	name = "Nightmare"
	show_in_antagpanel = TRUE
	show_to_ghosts = TRUE
	banning_key = ROLE_NIGHTMARE
	antagpanel_category = "Nightmare"
	ui_name = "AntagInfoNightmare"
	show_name_in_check_antagonists = TRUE

/datum/antagonist/nightmare/on_gain()
	forge_objectives()
	return  ..()

/datum/antagonist/nightmare/greet()
	owner.announce_objectives()
	to_chat(owner, "<span class='boldannounce'>Your primary goal is keeping the station dark, do not go out of your way to randomly kill people. \
	You may attack them to snuff out their light or retaliate after they start attacking.</span>")

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
