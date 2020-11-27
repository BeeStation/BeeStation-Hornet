///Tracking reasons
/datum/antagonist/heretic_monster
	name = "Eldritch Horror"
	roundend_category = "Heretics"
	antagpanel_category = "Heretic Beast"
	antag_moodlet = /datum/mood_event/heretics
	job_rank = ROLE_HERETIC
	var/antag_hud_type = ANTAG_HUD_HERETIC
	var/antag_hud_name = "heretic_beast"
	var/datum/antagonist/heretic/master

/datum/antagonist/heretic_monster/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has heresized [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has heresized [key_name(new_owner)].")

/datum/antagonist/heretic_monster/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ecult_op.ogg', 100, FALSE, pressure_affected = FALSE)//subject to change
	to_chat(owner, "<span class='boldannounce'>You became an Eldritch Horror, servant of [master]!</span>")

/datum/antagonist/heretic_monster/on_removal()
	if(master)
		to_chat(owner, "<span class='boldannounce'>Your no longer bound to your master, [master.owner.current.real_name]</span>")
		master = null
	return ..()

/datum/antagonist/heretic_monster/proc/set_owner(datum/antagonist/_master)
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
	add_antag_hud(antag_hud_type, antag_hud_name, owner.current)

/datum/antagonist/heretic_monster/remove_innate_effects(mob/living/mob_override)
	. = ..()
	remove_antag_hud(antag_hud_type, owner.current)

/datum/antagonist/heretic_monster/disciple
	name = "Believer"
	var/tier = 1
	var/obj/effect/proc_holder/spell/targeted/touch/mansus_grasp/lesser/touch_spell

/datum/antagonist/heretic_monster/disciple/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ecult_op.ogg', 100, FALSE, pressure_affected = FALSE)
	to_chat(owner, "<span class='boldannounce'>You have become a [name] of [master]. Obey their orders and help them accomplish their goals, and they may reward you with great power!</span>")

/datum/antagonist/heretic_monster/disciple/proc/can_read_lore()
	return tier>=1

/datum/antagonist/heretic_monster/disciple/proc/can_use_magic()
	return tier>=3

/datum/antagonist/heretic_monster/disciple/proc/get_promote_cost()
	return tier+1

/datum/antagonist/heretic_monster/disciple/proc/promote()
	tier = tier+1
	switch (tier)
		if (1)
			to_chat(owner, "<span class='boldannounce'>Huh...</span>")//this should never happen
		if (2)
			name = "Adept"	//can understand eldritch knowledge
			to_chat(owner, "<span class='boldannounce'>You have been promoted to [name]. You can now understand eldritch lore.</span>")
		if (3)
			name = "Disciple"	//has magic
			to_chat(owner, "<span class='boldannounce'>You have been promoted to [name]. You can now use eldritch magic.</span>")
			touch_spell = new
			owner.AddSpell(touch_spell)
		else
			name = "Exalted"
			to_chat(owner, "<span class='boldannounce'>You have been promoted to [name]. They can't stop you!</span>")
			ADD_TRAIT(owner,TRAIT_NOBREATH,MAGIC_TRAIT)
			ADD_TRAIT(owner,TRAIT_RESISTCOLD,MAGIC_TRAIT)
			ADD_TRAIT(owner,TRAIT_RESISTLOWPRESSURE,MAGIC_TRAIT)

/datum/antagonist/heretic_monster/disciple/on_removal()
	owner.RemoveSpell(touch_spell)
	REMOVE_TRAIT(owner,TRAIT_NOBREATH,MAGIC_TRAIT)
	REMOVE_TRAIT(owner,TRAIT_RESISTCOLD,MAGIC_TRAIT)
	REMOVE_TRAIT(owner,TRAIT_RESISTLOWPRESSURE,MAGIC_TRAIT)
	return ..()
