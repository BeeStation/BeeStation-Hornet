///Tracking reasons
/datum/antagonist/heretic_monster
	name = "Eldritch Horror"
	roundend_category = "Heretics"
	antagpanel_category = "Heretic Beast"
	antag_moodlet = /datum/mood_event/heretics
	job_rank = ROLE_HERETIC
	var/datum/antagonist/heretic/master

/datum/antagonist/heretic_monster/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has heresized [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has heresized [key_name(new_owner)].")

/datum/antagonist/heretic_monster/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ecult_op.ogg', 100, FALSE, pressure_affected = FALSE)//subject to change
	to_chat(owner, "<span class='boldannounce'>You became an Eldritch Horror!</span>")

/datum/antagonist/heretic_monster/on_removal()
	if(owner)
		to_chat(owner, "<span class='boldannounce'>Your master is no longer [master.owner.current.real_name]</span>")
		owner = null
	return ..()

/datum/antagonist/heretic_monster/proc/set_owner(datum/antagonist/heretic/_master)
	master = _master
	var/datum/objective/master_obj = new
	master_obj.owner = src
	master_obj.explanation_text = "Assist your master in any way you can!"
	objectives += master_obj
	owner.announce_objectives()
	to_chat(owner, "<span class='boldannounce'>Your master is [master.owner.current.real_name]</span>")
	return

/datum/antagonist/heretic_monster/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/datum/atom_hud/antag/traitor_hud = GLOB.huds[ANTAG_HUD_HERETIC]
	traitor_hud.join_hud(owner.current)
	if(!owner.antag_hud_icon_state)
		set_antag_hud(owner.current, "heretic")

/datum/antagonist/heretic_monster/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/datum/atom_hud/antag/traitor_hud = GLOB.huds[ANTAG_HUD_HERETIC]
	traitor_hud.leave_hud(owner.current)
	if(owner.antag_hud_icon_state == "heretic")
		set_antag_hud(owner.current, null)
