///Tracking reasons
/datum/antagonist/heretic_monster
	name = "\improper Eldritch Horror"
	roundend_category = "Heretics"
	antagpanel_category = "Heretic Beast"
	antag_moodlet = /datum/mood_event/heretics
	job_rank = ROLE_HERETIC
	show_in_antagpanel = FALSE
	var/antag_hud_type = ANTAG_HUD_HERETIC
	var/antag_hud_name = "heretic_beast"
	/// Our master (a heretic)'s mind.
	var/datum/mind/master
	show_to_ghosts = TRUE

/datum/antagonist/heretic_monster/on_gain()
	. = ..()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ecult_op.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)//subject to change

/datum/antagonist/heretic_monster/on_removal()
	if(!silent)
		if(master?.current)
			to_chat(master.current, "<span class='warning'>The essence of [owner], your servant, fades from your mind.</span>")
		if(owner.current)
			to_chat(owner.current, "<span class='deconversion_message'>Your mind begins to fill with haze - your master is no longer[master ? " [master]":""], you are free!</span>")
			owner.current.visible_message("[owner.current] looks like [owner.current.p_theyve()] been freed from the chains of the Mansus!", ignored_mobs = owner.current)

	master = null
	return ..()

/*
 * Set our [master] var to a new mind.
 */
/datum/antagonist/heretic_monster/proc/set_owner(datum/mind/master)
	src.master = master

	var/datum/objective/master_obj = new()
	master_obj.owner = owner
	master_obj.explanation_text = "Assist your master."
	master_obj.completed = TRUE

	objectives += master_obj
	owner.announce_objectives()
	to_chat(owner, "<span class='boldnotice'>You are a horrible creation brought to this plane through the Gates of the Mansus.</span>")
	to_chat(owner, "<span class='notice'>Your master is [master.name]. Assist them to all ends.</span>")

/datum/antagonist/heretic_monster/apply_innate_effects(mob/living/mob_override)
	. = ..()
	add_antag_hud(antag_hud_type, antag_hud_name, owner.current)

/datum/antagonist/heretic_monster/remove_innate_effects(mob/living/mob_override)
	. = ..()
	remove_antag_hud(antag_hud_type, owner.current)

/datum/antagonist/heretic_monster/get_antag_name() // good to recognise who's responsible with these monsters
	if(!master)
		return "Unchained Eldritch Horror"
	return "Eldritch Horror of [master.name]"
