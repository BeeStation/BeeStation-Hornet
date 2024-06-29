/datum/antagonist/ninja
	name = "Ninja"
	antagpanel_category = "Ninja"
	banning_key = ROLE_NINJA
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	antag_moodlet = /datum/mood_event/focused
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

/datum/antagonist/ninja/proc/equip_space_ninja(mob/living/carbon/human/H = owner.current)
	return H.equipOutfit(/datum/outfit/ninja)

/datum/antagonist/ninja/proc/addMemories()
	antag_memory += "I am an elite mercenary assassin of the mighty Spider Clan. A <font color='red'><B>SPACE NINJA</B></font>!<br>"
	antag_memory += "Surprise is my weapon. Shadows are my armor. Without them, I am nothing. (initialize your suit by clicking the initialize UI button, to use abilities like stealth)!<br>"

/datum/antagonist/ninja/proc/addObjectives(quantity = 3)
	if(!give_objectives)
		return
	var/list/possible_targets = list()
	for(var/datum/mind/M in SSticker.minds)
		if(M.current && M.current.stat != DEAD)
			if(ishuman(M.current))
				if(M.special_role)
					possible_targets[M] = 0						//bad-guy
				else if(M.assigned_role in GLOB.command_positions)
					possible_targets[M] = 1						//good-guy

	var/list/possible_objectives = list(1,2,3,4)

	while(objectives.len < quantity)
		switch(pick_n_take(possible_objectives))
			if(1)	//research
				var/datum/objective/download/O = new /datum/objective/download()
				O.owner = owner
				O.gen_amount_goal()
				objectives += O
				log_objective(owner, O.explanation_text)

			if(2)	//steal
				var/datum/objective/steal/special/O = new /datum/objective/steal/special()
				O.owner = owner
				objectives += O
				log_objective(owner, O.explanation_text)

			if(3)	//kill
				if(!possible_targets.len)	continue
				var/index = rand(1,possible_targets.len)
				var/datum/mind/M = possible_targets[index]
				possible_targets.Cut(index,index+1)
				var/datum/objective/assassinate/O = new /datum/objective/assassinate()
				O.owner = owner
				O.set_target(M)
				O.explanation_text = "Slay \the [M.current.real_name], the [M.assigned_role]."
				objectives += O
				log_objective(owner, O.explanation_text)
			if(4)	//capture
				var/datum/objective/capture/O = new /datum/objective/capture()
				O.owner = owner
				O.gen_amount_goal()
				objectives += O
				log_objective(owner, O.explanation_text)
			else
				break
	var/datum/objective/O = new /datum/objective/survive()
	O.owner = owner
	objectives += O
	log_objective(owner, O.explanation_text)

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
		addObjectives()
	addMemories()
	if(give_equipment)
		equip_space_ninja(owner.current)
	. = ..()

/datum/antagonist/ninja/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.assigned_role = ROLE_NINJA
	new_owner.special_role = ROLE_NINJA
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has ninja'd [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has ninja'd [key_name(new_owner)].")

/datum/antagonist/ninja/proc/update_ninja_icons_added(var/mob/living/carbon/human/ninja)
	var/datum/atom_hud/antag/ninjahud = GLOB.huds[ANTAG_HUD_NINJA]
	ninjahud.join_hud(ninja)
	set_antag_hud(ninja, "ninja")

/datum/antagonist/ninja/proc/update_ninja_icons_removed(var/mob/living/carbon/human/ninja)
	var/datum/atom_hud/antag/ninjahud = GLOB.huds[ANTAG_HUD_NINJA]
	ninjahud.leave_hud(ninja)
	set_antag_hud(ninja, null)
