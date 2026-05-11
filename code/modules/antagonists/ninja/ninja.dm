/datum/antagonist/ninja
	name = "\improper Space Ninja"
	antagpanel_category = "Ninja"
	banning_key = ROLE_NINJA
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	antag_moodlet = /datum/mood_event/focused
	required_living_playtime = 0
	//preview_outfit = /datum/outfit/ninja_preview
	var/helping_station = FALSE
	var/give_equipment = TRUE

/datum/antagonist/ninja/New()
	if(helping_station)
		can_elimination_hijack = ELIMINATION_PREVENT
	. = ..()

/datum/antagonist/ninja/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_ninja_icons_added(M)

/datum/antagonist/ninja/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_ninja_icons_removed(M)

/**
 *
 * Proc that equips the space ninja outfit on a given individual.  By default this is the owner of the antagonist datum.
 * Arguments:
 * * ninja - The human to receive the gear
 * * Returns a proc call on the given human which will equip them with all the gear.
 */
/datum/antagonist/ninja/proc/equip_space_ninja(mob/living/carbon/human/ninja = owner.current)
	return ninja.equipOutfit(/datum/outfit/ninja)

/datum/antagonist/ninja/proc/addMemories()
	antag_memory += "I am an elite mercenary assassin of the mighty Spider Clan. A <font color='red'><B>SPACE NINJA</B></font>!<br>"
	antag_memory += "Surprise is my weapon. Shadows are my armor. Without them, I am nothing. (initialize your suit by clicking the initialize UI button, to use abilities like stealth)!<br>"

/datum/antagonist/ninja/forge_objectives()
	// Explosive plant objective - always given
	var/datum/objective/plant_explosive/bomb_objective = new()
	for(var/sanity in 1 to 100) // 100 checks at most.
		var/area/selected_area = pick(GLOB.areas)
		if(!is_station_level(selected_area.z) || !(selected_area.area_flags & VALID_TERRITORY))
			continue

		bomb_objective.detonation_location = selected_area
		bomb_objective.explanation_text = "Detonate your starter bomb in [bomb_objective.detonation_location]. Note that the bomb will not work anywhere else!"
		add_objective(bomb_objective)
		break

	var/list/possible_objectives = list(1,1,1,2,2,2,3,4,4)
	// Research(1) and steal(2) weighted higher, kill(3) lower, capture(4) same

	while(length(objectives) < 3)
		switch(pick_n_take(possible_objectives))
			if(1) //research
				var/datum/objective/download/download_objective = new()
				download_objective.gen_amount_goal()
				add_objective(download_objective)

			if(2) //steal
				var/datum/objective/steal/special/steal_objective = new()
				steal_objective.find_target()
				add_objective(steal_objective)

			if(3) //kill
				var/list/datum/mind/potential_targets = list()
				for(var/datum/mind/potential_target as anything in get_crewmember_minds())
					if(!ishuman(potential_target.current))
						continue
					if(!potential_target.special_role && !(potential_target.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND)))
						continue
					potential_targets += potential_target

				if(!length(potential_targets))
					continue

				var/datum/objective/assassinate/assassinate_objective = new()
				var/datum/mind/person_to_kill = pick(potential_targets)
				assassinate_objective.set_target(person_to_kill)
				assassinate_objective.explanation_text = "Slay [person_to_kill.current.real_name], the [person_to_kill.assigned_role]."
				add_objective(assassinate_objective)
			if(4) //capture
				var/datum/objective/capture/capture_objective = new()
				capture_objective.gen_amount_goal()
				add_objective(capture_objective)

	add_objective(new /datum/objective/survive())

/proc/remove_ninja(mob/living/L)
	if(!L || !L.mind)
		return FALSE
	var/datum/antagonist/datum = L.mind.has_antag_datum(/datum/antagonist/ninja)
	datum.on_removal()
	return TRUE

/proc/is_ninja(mob/living/M)
	return M?.mind?.has_antag_datum(/datum/antagonist/ninja)


/datum/antagonist/ninja/greet()
	SEND_SOUND(owner.current, sound('sound/effects/ninja_greeting.ogg'))
	to_chat(owner.current, "I am an elite mercenary assassin of the mighty Spider Clan. A <font color='red'><B>SPACE NINJA</B></font>!")
	to_chat(owner.current, "Surprise is my weapon. Shadows are my armor. Without them, I am nothing. (initialize your suit by right clicking on it, to use abilities like stealth)!")
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Ninja",
		"Infiltrate the station and complete your assigned objectives.")

/datum/antagonist/ninja/on_gain()
	if(give_objectives)
		forge_objectives()
	addMemories()
	if(give_equipment)
		equip_space_ninja(owner.current)
	. = ..()

/datum/antagonist/ninja/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.set_assigned_role(ROLE_NINJA)
	new_owner.special_role = ROLE_NINJA
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has ninja'd [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has ninja'd [key_name(new_owner)].")

/datum/antagonist/ninja/proc/update_ninja_icons_added(mob/living/carbon/human/ninja)
	var/datum/atom_hud/antag/ninjahud = GLOB.huds[ANTAG_HUD_NINJA]
	ninjahud.join_hud(ninja)
	set_antag_hud(ninja, "ninja")

/datum/antagonist/ninja/proc/update_ninja_icons_removed(mob/living/carbon/human/ninja)
	var/datum/atom_hud/antag/ninjahud = GLOB.huds[ANTAG_HUD_NINJA]
	ninjahud.leave_hud(ninja)
	set_antag_hud(ninja, null)

/datum/objective/plant_explosive
	name = "plant explosive"
	var/area/detonation_location
