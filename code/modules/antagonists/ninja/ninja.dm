#define NINJA_OBJECTIVE_RESEARCH 1
#define NINJA_OBJECTIVE_STEAL 2
#define NINJA_OBJECTIVE_KILL 3
#define NINJA_OBJECTIVE_CAPTURE 4
#define NINJA_OBJECTIVE_PROTECT 5
#define NINJA_OBJECTIVE_DEBRAIN 6

/datum/antagonist/ninja
	name = "Ninja"
	antagpanel_category = "Ninja"
	job_rank = ROLE_NINJA
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	antag_moodlet = /datum/mood_event/focused
	var/give_equipment = TRUE

/datum/antagonist/ninja/New()
	. = ..()

/datum/antagonist/ninja/greet()
	SEND_SOUND(owner.current, sound('sound/effects/ninja_greeting.ogg'))
	to_chat(owner.current, "I am an elite mercenary assassin of the mighty Spider Clan. A <font color='red'><b>SPACE NINJA</b></font>!<br>\
							Surprise is my weapon. Shadows are my armor. Without them, I am nothing.<br>\
							My suit can be initialized can be initialized with button on the top left of your screen.<br>\
							Every ability you use consumes a power, if your suit runs out of power it will shut down!")
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Ninja",
		"Infiltrate the station and complete your assigned objectives.")

/datum/antagonist/ninja/on_gain()
	. = ..()
	forge_objectives()
	add_memories()
	if(give_equipment)
		equip_space_ninja(owner.current)

/datum/antagonist/ninja/proc/add_objective(datum/objective/O, target)
	O.owner = owner
	if(target)
		O.target = target
	objectives += O
	O.update_explanation_text()
	log_objective(owner, O.explanation_text)

/datum/antagonist/obsessed/proc/remove_objective(datum/objective/O)
	objectives -= O
	qdel(O)

/datum/antagonist/ninja/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_ninja_icons_added(M)

/datum/antagonist/ninja/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_ninja_icons_removed(M)

/datum/antagonist/ninja/proc/equip_space_ninja(mob/living/carbon/human/H = owner.current)
	for(var/obj/item/I in H)
		if(!H.dropItemToGround(I))
			qdel(I)
			H.regenerate_icons()
	H.equipOutfit(/datum/outfit/ninja)

/datum/antagonist/ninja/proc/add_memories()
	antag_memory += "I am an elite mercenary assassin of the mighty Spider Clan. A <font color='red'><B>SPACE NINJA</B></font>!<br>\
					Surprise is my weapon. Shadows are my armor. Without them, I am nothing. !<br>\
					My suit can be initialized can be initialized with button on the top left of your screen.<br>\
					Every ability you use consumes a power, if your suit runs out of power it will shut down!"

/datum/antagonist/ninja/proc/forge_objectives()
	if(!give_objectives)
		return

	//This means we can have 5 objectives at most and 3 at least, since survive/hijack is always given
	var/objective_amount = rand(2,4)
	var/list/possible_targets = list()
	var/can_elimination_hijack = TRUE

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || H.mind.antag_datums?.len || H.mind == owner || !is_station_level(H.z))
			continue
		possible_targets += H

	var/list/possible_objectives = list(NINJA_OBJECTIVE_RESEARCH, NINJA_OBJECTIVE_STEAL,
										NINJA_OBJECTIVE_KILL, NINJA_OBJECTIVE_CAPTURE,
										NINJA_OBJECTIVE_PROTECT, NINJA_OBJECTIVE_DEBRAIN)

	if(!length(possible_targets))
		possible_objectives -= list(NINJA_OBJECTIVE_KILL, NINJA_OBJECTIVE_CAPTURE,
									NINJA_OBJECTIVE_PROTECT, NINJA_OBJECTIVE_DEBRAIN)

	if(objective_amount > objectives.len)
		objective_amount = objectives.len

	for(var/i in 1 to objective_amount)
		switch(pick_n_take(possible_objectives))
			if(NINJA_OBJECTIVE_RESEARCH)
				//Similar to normal download but only checks if you tech in your suit
				var/datum/objective/download/ninja/O = new /datum/objective/download/ninja()
				add_objective(O)

			if(NINJA_OBJECTIVE_STEAL)
				var/datum/objective/steal/special/O = new /datum/objective/steal/special()
				add_objective(O)

			if(NINJA_OBJECTIVE_KILL)
				var/datum/objective/assassinate/O = new /datum/objective/assassinate()
				var/mob/living/carbon/human/H = pick_n_take(possible_targets)
				add_objective(O, H)
				if(prob(25))	//25% chance to keep kill objective in the pool
					possible_objectives += NINJA_OBJECTIVE_KILL

			if(NINJA_OBJECTIVE_PROTECT)
				var/datum/objective/protect/O = new /datum/objective/protect()
				var/mob/living/carbon/human/H = pick_n_take(possible_targets)
				add_objective(O, H)
				can_elimination_hijack = FALSE

			if(NINJA_OBJECTIVE_CAPTURE)
				var/datum/objective/capture/O = new /datum/objective/capture()
				var/mob/living/carbon/human/H = pick_n_take(possible_targets)
				add_objective(O, H)
				if(prob(15))	//15% chance to keep capture objective in the pool
					possible_objectives += NINJA_OBJECTIVE_CAPTURE

			if(NINJA_OBJECTIVE_DEBRAIN)
				var/datum/objective/debrain/O = new /datum/objective/debrain()
				var/mob/living/carbon/human/H = pick_n_take(possible_targets)
				add_objective(O, H)
				if(prob(15))	//15% chance to keep debrain objective in the pool
					possible_objectives += NINJA_OBJECTIVE_CAPTURE

	//10% chance to have hijack objective if you don't have protect and at least 30 players joined this round
	if(can_elimination_hijack && GLOB.joined_player_list >= 30 && prob(10))
		var/datum/objective/O = new /datum/objective/hijack()
		add_objective(O)
	else
		var/datum/objective/O = new /datum/objective/survive()
		add_objective(O)

/datum/antagonist/ninja/admin_add(datum/mind/new_owner, mob/admin)
	if(alert("Give ninja objectives?", "Ninja", "Yes", "No") == "No")
		give_objectives = FALSE
	new_owner.assigned_role = ROLE_NINJA
	new_owner.special_role = ROLE_NINJA
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has made a ninja [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has made a ninja [key_name(new_owner)].")

/datum/antagonist/ninja/proc/update_ninja_icons_added(mob/living/carbon/human/ninja)
	var/datum/atom_hud/antag/ninjahud = GLOB.huds[ANTAG_HUD_NINJA]
	ninjahud.join_hud(ninja)
	set_antag_hud(ninja, "ninja")

/datum/antagonist/ninja/proc/update_ninja_icons_removed(mob/living/carbon/human/ninja)
	var/datum/atom_hud/antag/ninjahud = GLOB.huds[ANTAG_HUD_NINJA]
	ninjahud.leave_hud(ninja)
	set_antag_hud(ninja, null)

#undef NINJA_OBJECTIVE_RESEARCH
#undef NINJA_OBJECTIVE_STEAL
#undef NINJA_OBJECTIVE_KILL
#undef NINJA_OBJECTIVE_CAPTURE
#undef NINJA_OBJECTIVE_PROTECT
#undef NINJA_OBJECTIVE_DEBRAIN
