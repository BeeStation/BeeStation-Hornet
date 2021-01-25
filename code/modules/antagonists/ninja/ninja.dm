/datum/antagonist/ninja
	name = "Ninja"
	antagpanel_category = "Ninja"
	job_rank = ROLE_NINJA
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	antag_moodlet = /datum/mood_event/focused
	var/give_equipment = TRUE



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
	antag_memory += "Surprise is my weapon. Shadows are my armor. Without them, I am nothing. (//choose a path from the beacon to gain your gadgets and equipment)!<br>"
	antag_memory += "My cloak recharges in darkness, and quickly fades in the light. I must knock out the lights to remain unseen.<br>"

/datum/antagonist/ninja/proc/addObjectives(quantity = 3)
	if(!give_objectives)
		return
	var/list/possible_targets = list()
	for(var/datum/mind/M in SSticker.minds)
		if(M.current && M.current.stat != DEAD)
			if(ishuman(M.current))
				possible_targets+= M
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
				var/datum/objective/steal/O = new /datum/objective/steal()
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
				O.target = M
				O.explanation_text = "Slay \the [M.current.real_name], the [M.assigned_role]."
				objectives += O
				log_objective(owner, O.explanation_text)
				
			if(4)	//debrain
				if(!possible_targets.len)	continue
				var/selected = rand(1,possible_targets.len)
				var/datum/mind/M = possible_targets[selected]
				possible_targets.Cut(selected,selected+1)
				var/datum/objective/debrain/O = new /datum/objective/debrain()
				O.owner = owner
				O.target = M
				O.explanation_text = "Steal the brain of [M.current.real_name]."
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

/datum/antagonist/ninja/proc/movetospawn()
	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/carpspawn/L in GLOB.landmarks_list)
		if(isturf(L.loc))
			spawn_locs += L.loc
	if(!spawn_locs.len)
		return
	var/spawn_loc = pick(spawn_locs)
	if(!spawn_loc)
		return MAP_ERROR
	owner.current.forceMove(spawn_loc)

/datum/antagonist/ninja/greet()
	SEND_SOUND(owner.current, sound('sound/effects/ninja_greeting.ogg'))
	to_chat(owner.current, "I am an elite mercenary assassin of the mighty Spider Clan. A <font color='red'><B>SPACE NINJA</B></font>!")
	to_chat(owner.current, "Surprise is my weapon. Shadows are my armor. Without them, I am nothing. (//choose a path from the beacon to gain your gadgets and equipment)!")
	to_chat(owner.current, "My cloak recharges in darkness, and quickly fades in the light. I must knock out the lights to remain unseen.")
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Ninja",
		"Infiltrate the station and complete your assigned objectives.")
	movetospawn()
	return

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
	message_admins("[key_name_admin(admin)] has ninja'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has ninja'ed [key_name(new_owner)].")

/datum/antagonist/ninja/proc/update_ninja_icons_added(var/mob/living/carbon/human/ninja)
	var/datum/atom_hud/antag/ninjahud = GLOB.huds[ANTAG_HUD_NINJA]
	ninjahud.join_hud(ninja)
	set_antag_hud(ninja, "ninja")

/datum/antagonist/ninja/proc/update_ninja_icons_removed(var/mob/living/carbon/human/ninja)
	var/datum/atom_hud/antag/ninjahud = GLOB.huds[ANTAG_HUD_NINJA]
	ninjahud.leave_hud(ninja)
	set_antag_hud(ninja, null)
