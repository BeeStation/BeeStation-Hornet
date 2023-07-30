

/*
 * Simple helper to generate a string of
 * garbled symbols up to [length] characters.
 *
 * Used in creating spooky-text for heretic ascension announcements.
 */
/proc/generate_heretic_text(length = 25)
	. = ""
	for(var/i in 1 to length)
		. += pick("!", "$", "^", "@", "&", "#", "*", "(", ")", "?")

/// The heretic antagonist itself.
/datum/antagonist/heretic
	name = "\improper Heretic"
	roundend_category = "Heretics"
	antagpanel_category = "Heretic"
	antag_moodlet = /datum/mood_event/heretics
	banning_key = ROLE_HERETIC
	required_living_playtime = 4
	/// Whether we've ascended! (Completed one of the final rituals)
	var/ascended = FALSE
	/// The path our heretic has chosen. Mostly used for flavor.
	var/heretic_path = HERETIC_PATH_START
	/// A list of how many knowledge points this heretic CURRENTLY has. Used to research.
	var/knowledge_points = 1
	/// The time between gaining influence passively. The heretic gain +1 knowledge points every this duration of time.
	var/passive_gain_timer = 20 MINUTES
	/// Assoc list of [typepath] = [knowledge instance]. A list of all knowledge this heretic's reserached.
	var/list/researched_knowledge = list()
	/// A list of TOTAL how many sacrifices completed. (Includes high value sacrifices)
	var/total_sacrifices = 0
	/// A list of TOTAL how many high value sacrifices completed.
	var/high_value_sacrifices = 0
	/// Lazy assoc list of [weakrefs to humans] to [image previews of the human]. Humans that we have as sacrifice targets.
	var/list/datum/weakref/sac_targets
	/// Whether we're drawing a rune or not
	var/drawing_rune = FALSE
	/// A static typecache of all tools we can scribe with.
	var/static/list/scribing_tools = typecacheof(list(/obj/item/pen, /obj/item/toy/crayon))
	/// A blacklist of turfs we cannot scribe on.
	var/static/list/blacklisted_rune_turfs = typecacheof(list(/turf/open/space, /turf/open/openspace, /turf/open/lava, /turf/open/chasm))
	var/datum/action/innate/hereticmenu/menu
	ui_name = "AntagInfoHeretic"

/datum/antagonist/heretic/ui_data(mob/user)
	var/list/data = list()

	var/static/list/path_to_color = list(
		HERETIC_PATH_START = "grey",
		HERETIC_PATH_SIDE = "green",
		HERETIC_PATH_RUST = "brown",
		HERETIC_PATH_FLESH = "red",
		HERETIC_PATH_ASH = "white",
		HERETIC_PATH_VOID = "blue",
	)

	data["charges"] = knowledge_points

	for(var/datum/heretic_knowledge/knowledge as anything in get_researchable_knowledge())
		var/list/knowledge_data = list()
		knowledge_data["path"] = knowledge
		knowledge_data["name"] = initial(knowledge.name)
		knowledge_data["desc"] = initial(knowledge.desc)
		knowledge_data["gainFlavor"] = initial(knowledge.gain_text)
		knowledge_data["cost"] = initial(knowledge.cost)
		knowledge_data["disabled"] = (initial(knowledge.cost) > knowledge_points)

		// Final knowledge can't be learned until all objectives are complete.
		if(ispath(knowledge, /datum/heretic_knowledge/final))
			knowledge_data["disabled"] = !can_ascend()

		knowledge_data["hereticPath"] = initial(knowledge.route)
		knowledge_data["color"] = path_to_color[initial(knowledge.route)] || "grey"

		data["learnableKnowledge"] += list(knowledge_data)

	for(var/path in researched_knowledge)
		var/list/knowledge_data = list()
		var/datum/heretic_knowledge/found_knowledge = researched_knowledge[path]
		knowledge_data["name"] = found_knowledge.name
		knowledge_data["desc"] = found_knowledge.desc
		knowledge_data["gainFlavor"] = found_knowledge.gain_text
		knowledge_data["cost"] = found_knowledge.cost
		knowledge_data["hereticPath"] = found_knowledge.route
		knowledge_data["color"] = path_to_color[found_knowledge.route] || "grey"

		data["learnedKnowledge"] += list(knowledge_data)

	return data

/datum/antagonist/heretic/ui_static_data(mob/user)
	var/list/data = list()

	data["total_sacrifices"] = total_sacrifices
	data["ascended"] = ascended
	data["objectives"] = get_objectives()

	return data

/datum/antagonist/heretic/make_info_button()
	return // we already handle this with our own button

/datum/antagonist/heretic/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("research")
			var/datum/heretic_knowledge/researched_path = text2path(params["path"])
			if(!ispath(researched_path))
				CRASH("Heretic attempted to learn non-heretic_knowledge path! (Got: [researched_path])")

			if(initial(researched_path.cost) > knowledge_points)
				return
			if(!gain_knowledge(researched_path))
				return

			knowledge_points -= initial(researched_path.cost)
			return TRUE

/datum/antagonist/heretic/ui_status(mob/user, datum/ui_state/state)
	if(user.stat == DEAD)
		return UI_CLOSE
	return ..()

/datum/antagonist/heretic/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ecult_op.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)//subject to change
	to_chat(owner, "<span class='boldannounce'>You are the Heretic!</span><br>\
	<B>The old ones gave you these tasks to fulfill:</B>")
	owner.announce_objectives()
	to_chat(owner, "<span class='cult'>The book whispers, the forbidden knowledge walks once again!<br>\
	The Forbidden Knowledge panel allows you to research abilities, read it very carefully! You cannot undo what has been done!<br>\
	You gain charges by either collecting influences or sacrificing people tracked by the living heart<br> \
	You can find a basic guide at: https://wiki.beestation13.com/view/Heretics </span>")
	owner.current.client?.tgui_panel?.give_antagonist_popup("Heretic",
		"Collect influences or sacrifice targets to expand your forbidden knowledge.")

/datum/antagonist/heretic/farewell()
	if(!silent)
		to_chat(owner.current, "<span class='userdanger'>Your mind begins to flare as the otherworldly knowledge escapes your grasp!</span>")
	return ..()

/datum/antagonist/heretic/on_gain()
	if(isipc(owner.current))//Due to IPCs having a mechanical heart it messes with the living heart, so no IPC heretics for now
		var/mob/living/carbon/C = owner.current	//only carbons have dna now, so we have to typecast
		C.set_species(/datum/species/human)
		var/replacementName = random_unique_name(C.gender)
		if(C.client.prefs.active_character.custom_names["human"])
			C.fully_replace_character_name(C.real_name, C.client.prefs.active_character.custom_names["human"])
		else
			C.fully_replace_character_name(C.real_name, replacementName)
	if(give_objectives)
		forge_objectives()

	for(var/starting_knowledge in GLOB.heretic_start_knowledge)
		gain_knowledge(starting_knowledge)

	addtimer(CALLBACK(src, PROC_REF(add_menu_action)), 1)
	GLOB.reality_smash_track.add_tracked_mind(owner)
	addtimer(CALLBACK(src, PROC_REF(passive_influence_gain)), passive_gain_timer) // Gain +1 knowledge every 20 minutes.
	return ..()

/datum/antagonist/heretic/on_removal()

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge.on_lose(owner.current)

	GLOB.reality_smash_track.remove_tracked_mind(owner)
	QDEL_LIST_ASSOC_VAL(researched_knowledge)
	QDEL_NULL(menu)
	return ..()

/datum/antagonist/heretic/apply_innate_effects(mob/living/mob_override)
	var/mob/living/our_mob = mob_override || owner.current
	handle_clown_mutation(our_mob, "Ancient knowledge described to you has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
	our_mob.faction |= FACTION_HERETIC
	RegisterSignal(our_mob, COMSIG_MOB_PRE_CAST_SPELL, PROC_REF(on_spell_cast))
	RegisterSignal(our_mob, COMSIG_MOB_ITEM_AFTERATTACK, PROC_REF(on_item_afterattack))
	RegisterSignal(our_mob, COMSIG_MOB_LOGIN, PROC_REF(fix_influence_network))
	update_heretic_icons_added()

/datum/antagonist/heretic/remove_innate_effects(mob/living/mob_override)
	var/mob/living/our_mob = mob_override || owner.current
	handle_clown_mutation(our_mob, removing = FALSE)
	our_mob.faction -= FACTION_HERETIC
	UnregisterSignal(our_mob, list(COMSIG_MOB_PRE_CAST_SPELL, COMSIG_MOB_ITEM_AFTERATTACK, COMSIG_MOB_LOGIN))
	update_heretic_icons_removed()

/datum/antagonist/heretic/proc/update_heretic_icons_added()
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_HERETIC]
	hud.join_hud(owner.current)
	set_antag_hud(owner.current, "heretic")

/datum/antagonist/heretic/proc/update_heretic_icons_removed()
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_HERETIC]
	hud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)

/datum/antagonist/heretic/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge.on_lose(old_body)
		knowledge.on_gain(new_body)

/*
 * Signal proc for [COMSIG_MOB_PRE_CAST_SPELL].
 *
 * Checks if our heretic has TRAIT_ALLOW_HERETIC_CASTING.
 * If so, allow them to cast like normal.
 * If not, cancel the cast.
 */
/datum/antagonist/heretic/proc/on_spell_cast(mob/living/source, obj/effect/proc_holder/spell/spell)
	SIGNAL_HANDLER

	// Non-Heretic spells, we don't care
	if(!spell.requires_heretic_focus)
		return

	// If we've got the trait, we don't care
	if(HAS_TRAIT(source, TRAIT_ALLOW_HERETIC_CASTING))
		return
	// All powerful, don't care
	if(ascended)
		return

	// We shouldn't be able to cast this! Cancel it.
	source.balloon_alert(source, "You need a focus")
	return COMPONENT_CANCEL_SPELL

/*
 * Signal proc for [COMSIG_MOB_ITEM_AFTERATTACK].
 *
 * If a heretic is holding a pen in their main hand,
 * and have mansus grasp active in their offhand,
 * they're able to draw a transmutation rune.
 */
/datum/antagonist/heretic/proc/on_item_afterattack(mob/living/source, atom/target, obj/item/weapon, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!is_type_in_typecache(weapon, scribing_tools))
		return
	if(!isturf(target) || !isliving(source) || !proximity_flag)
		return

	var/obj/item/offhand = source.get_inactive_held_item()
	if(QDELETED(offhand) || !istype(offhand, /obj/item/melee/touch_attack/mansus_fist))
		return

	try_draw_rune(source, target, additional_checks = CALLBACK(src, PROC_REF(check_mansus_grasp_offhand), source))
	return COMPONENT_CANCEL_ATTACK_CHAIN

/**
 * Attempt to draw a rune on [target_turf].
 *
 * Arguments
 * * user - the mob drawing the rune
 * * target_turf - the place the rune's being drawn
 * * drawing_time - how long the do_after takes to make the rune
 * * additional checks - optional callbacks to be ran while drawing the rune
 */
/datum/antagonist/heretic/proc/try_draw_rune(mob/living/user, turf/target_turf, drawing_time = 30 SECONDS, additional_checks)
	for(var/turf/nearby_turf as anything in RANGE_TURFS(1, target_turf))
		if(!isopenturf(nearby_turf) || is_type_in_typecache(nearby_turf, blacklisted_rune_turfs))
			target_turf.balloon_alert(user, "Invalid placement for rune")
			return

	if(locate(/obj/effect/heretic_rune) in range(3, target_turf))
		target_turf.balloon_alert(user, "Too close to another rune")
		return

	if(drawing_rune)
		target_turf.balloon_alert(user, "Already drawing a rune")
		return

	INVOKE_ASYNC(src, PROC_REF(draw_rune), user, target_turf, drawing_time, additional_checks)

/**
 * The actual process of drawing a rune.
 *
 * Arguments
 * * user - the mob drawing the rune
 * * target_turf - the place the rune's being drawn
 * * drawing_time - how long the do_after takes to make the rune
 * * additional checks - optional callbacks to be ran while drawing the rune
 */
/datum/antagonist/heretic/proc/draw_rune(mob/living/user, turf/target_turf, drawing_time = 30 SECONDS, additional_checks)
	drawing_rune = TRUE

	target_turf.balloon_alert(user, "You start drawing a rune")
	if(!do_after(user, drawing_time, target = target_turf, extra_checks = additional_checks))
		target_turf.balloon_alert(user, "Interrupted")
		drawing_rune = FALSE
		return

	target_turf.balloon_alert(user, "Rune created")
	new /obj/effect/heretic_rune/big(target_turf)
	drawing_rune = FALSE

/**
 * Callback to check that the user's still got their Mansus Grasp out when drawing a rune.
 *
 * Arguments
 * * user - the mob drawing the rune
 */
/datum/antagonist/heretic/proc/check_mansus_grasp_offhand(mob/living/user)
	var/obj/item/offhand = user.get_inactive_held_item()
	return !QDELETED(offhand) && istype(offhand, /obj/item/melee/touch_attack/mansus_fist)

/*
 * Signal proc for [COMSIG_MOB_LOGIN].
 *
 * Calls rework_network() on our reality smash tracker
 * whenever a login / client change happens, to ensure
 * influence client visibility is fixed.
 */
/datum/antagonist/heretic/proc/fix_influence_network(mob/source)
	SIGNAL_HANDLER

	GLOB.reality_smash_track.rework_network()

/**
 * Create our objectives for our heretic.
 */
/datum/antagonist/heretic/proc/forge_objectives()
	var/datum/objective/heretic_research/research_objective = new()
	research_objective.owner = owner
	objectives += research_objective

	var/num_heads = 0
	for(var/mob/player in SSticker.mode.current_players[CURRENT_LIVING_PLAYERS])
		if(player.mind.assigned_role in list("Captain", "Head of Personnel", "Chief Engineer", "Head of Security", "Research Director", "Chief Medical Officer"))
			num_heads++

	var/datum/objective/minor_sacrifice/sac_objective = new()
	sac_objective.owner = owner
	if(num_heads < 2) // They won't get major sacrifice, so bump up minor sacrifice a bit
		sac_objective.target_amount += 2
		sac_objective.update_explanation_text()
	objectives += sac_objective

	if(num_heads >= 2)
		var/datum/objective/major_sacrifice/other_sac_objective = new()
		other_sac_objective.owner = owner
		objectives += other_sac_objective

/**
 * Add [target] as a sacrifice target for the heretic.
 * Generates a preview image and associates it with a weakref of the mob.
 */
/datum/antagonist/heretic/proc/add_sacrifice_target(mob/living/carbon/human/target)

	var/image/target_image = image(icon = target.icon, icon_state = target.icon_state)
	target_image.overlays = target.overlays

	LAZYSET(sac_targets, WEAKREF(target), target_image)

/**
 * Increments knowledge by one.
 * Used in callbacks for passive gain over time.
 */
/datum/antagonist/heretic/proc/passive_influence_gain()
	knowledge_points++
	if(owner.current.stat <= SOFT_CRIT)
		to_chat(owner.current, "<span class='hear'>You hear a whisper...</span> <span class = 'hypnophrase'>[pick(strings(HERETIC_INFLUENCE_FILE, "drain_message"))]</span>")
	addtimer(CALLBACK(src, PROC_REF(passive_influence_gain)), passive_gain_timer)

/datum/antagonist/heretic/proc/add_menu_action()
	menu = new /datum/action/innate/hereticmenu(src)
	menu.Grant(owner.current)

/datum/antagonist/heretic/roundend_report()
	var/list/parts = list()

	var/succeeded = TRUE

	parts += printplayer(owner)
	parts += "<b>Sacrifices Made:</b> [total_sacrifices]"

	if(length(objectives))
		var/count = 1
		for(var/datum/objective/objective as anything in objectives)
			if(objective.check_completion())
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='greentext'>Success!</span>"
			else
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
				succeeded = FALSE
			count++

	if(ascended)
		parts += "<span class='greentext'><span class='big'>THE HERETIC ASCENDED!</span></span>"

	else
		if(succeeded)
			parts += "<span class='greentext'>The heretic was successful, but did not ascend!</span>"
		else
			parts += "<span class='redtext'>The heretic has failed.</span>"

	parts += "<b>Knowledge Researched:</b> "

	var/list/string_of_knowledge = list()

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		string_of_knowledge += knowledge.name

	parts += english_list(string_of_knowledge)

	return parts.Join("<br>")

/datum/antagonist/heretic/get_admin_commands()
	. = ..()

	switch(has_living_heart())
		if(HERETIC_NO_LIVING_HEART)
			.["Give Living Heart"] = CALLBACK(src, PROC_REF(give_living_heart))
		if(HERETIC_HAS_LIVING_HEART)
			.["Add Heart Target (Marked Mob)"] = CALLBACK(src, PROC_REF(add_marked_as_target))
			.["Remove Heart Target"] = CALLBACK(src, PROC_REF(remove_target))

	.["Adjust Knowledge Points"] = CALLBACK(src, PROC_REF(admin_change_points))

/*
 * Admin proc for giving a heretic a Living Heart easily.
 */
/datum/antagonist/heretic/proc/give_living_heart(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, "<span class='warning'>You shouldn't be using this!</span>")
		return

	var/datum/heretic_knowledge/living_heart/heart_knowledge = get_knowledge(/datum/heretic_knowledge/living_heart)
	if(!heart_knowledge)
		to_chat(admin, "<span class='warning'>The heretic doesn't have a living heart knowledge for some reason. What?</span>")
		return

	heart_knowledge.on_research(owner.current)

/*
 * Admin proc for adding a marked mob to a heretic's sac list.
 */
/datum/antagonist/heretic/proc/add_marked_as_target(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, "<span class='warning'>You shouldn't be using this!</span>")
		return

	var/mob/living/carbon/human/new_target = admin.client?.holder.marked_datum
	if(!istype(new_target))
		to_chat(admin, "<span class='warning'>You need to mark a human to do this!</span>")
		return

	if(alert(admin, "Let them know their targets have been updated?", "Whispers of the Mansus", "Yes", "No") == "Yes")
		to_chat(owner.current, "<span class='danger'>The Mansus has modified your targets. Go find them!</span>")
		to_chat(owner.current, "<span class='danger'>[new_target.real_name], the [new_target.mind?.assigned_role || "human"].</span>")

	add_sacrifice_target(new_target)

/*
 * Admin proc for removing a mob from a heretic's sac list.
 */
/datum/antagonist/heretic/proc/remove_target(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, "<span class='warning'>You shouldn't be using this!</span>")
		return

	var/list/removable = list()
	for(var/datum/weakref/ref as anything in sac_targets)
		var/mob/living/carbon/human/old_target = ref.resolve()
		if(!QDELETED(old_target))
			removable[old_target.name] = old_target

	var/name_of_removed = input(admin, "Choose a human to remove", "Who to Spare") as null|anything in removable
	if(QDELETED(src) || !admin.client?.holder || isnull(name_of_removed))
		return
	var/mob/living/carbon/human/chosen_target = removable[name_of_removed]
	if(QDELETED(chosen_target) || !ishuman(chosen_target))
		return
	if(!(WEAKREF(chosen_target) in sac_targets))
		return

	LAZYREMOVE(sac_targets, WEAKREF(chosen_target))

	if(alert(admin, "Let them know their targets have been updated?", "Whispers of the Mansus", "Yes", "No") == "Yes")
		to_chat(owner.current, "<span class='danger'>The Mansus has modified your targets.</span>")

/*
 * Admin proc for easily adding / removing knowledge points.
 */
/datum/antagonist/heretic/proc/admin_change_points(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, "<span class='warning'>You shouldn't be using this!</span>")
		return

	var/change_num = input(admin, "Add or remove knowledge points", "Points") as null|num
	if(!change_num || QDELETED(src))
		return
	knowledge_points += change_num
	message_admins("[admin] modified [src]'s knowledge points by [change_num].")

/datum/antagonist/heretic/antag_panel_data()
	var/list/string_of_knowledge = list()

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		if(istype(knowledge, /datum/heretic_knowledge/final))
			string_of_knowledge += "<span class='bold'>[knowledge.name]</span>"
		else
			string_of_knowledge += knowledge.name

	return "<br><b>Research Done:</b><br>[english_list(string_of_knowledge, and_text = ", and ")]<br>"

/datum/antagonist/heretic/antag_panel_objectives()
	. = ..()

	. += "<br>"
	. += "<i><b>Current Targets:</b></i><br>"
	if(LAZYLEN(sac_targets))
		for(var/datum/weakref/ref as anything in sac_targets)
			var/mob/living/carbon/human/actual_target = ref.resolve()
			if(QDELETED(actual_target))
				continue
			. += " - <b>[actual_target.real_name]</b>, the [actual_target.mind?.assigned_role || "Unknown"].<br>"
	else
		. += "<i>None!</i><br>"
	. += "<br>"

/*
 * Learns the passed [typepath] of knowledge, creating a knowledge datum
 * and adding it to our researched knowledge list.
 *
 * Returns TRUE if the knowledge was added successfully. FALSE otherwise.
 */
/datum/antagonist/heretic/proc/gain_knowledge(datum/heretic_knowledge/knowledge_type)
	if(!ispath(knowledge_type))
		stack_trace("[type] gain_knowledge was given an invalid path! (Got: [knowledge_type])")
		return FALSE
	if(get_knowledge(knowledge_type))
		return FALSE
	var/datum/heretic_knowledge/initialized_knowledge = new knowledge_type()
	researched_knowledge[knowledge_type] = initialized_knowledge
	initialized_knowledge.on_research(owner.current)
	return TRUE

/*
 * Get a list of all knowledge TYPEPATHS that we can currently research.
 */
/datum/antagonist/heretic/proc/get_researchable_knowledge()
	var/list/researchable_knowledge = list()
	var/list/banned_knowledge = list()
	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		researchable_knowledge |= knowledge.next_knowledge
		banned_knowledge |= knowledge.banned_knowledge
		banned_knowledge |= knowledge.type
	researchable_knowledge -= banned_knowledge
	return researchable_knowledge

/*
 * Check if the wanted type-path is in the list of research knowledge.
 */
/datum/antagonist/heretic/proc/get_knowledge(wanted)
	return researched_knowledge[wanted]

/*
 * Get a list of all rituals this heretic can invoke on a rune.
 * Iterates over all of our knowledge and, if we can invoke it, adds it to our list.
 *
 * Returns an associated list of [knowledge name] to [knowledge datum] sorted by knowledge priority.
 */
/datum/antagonist/heretic/proc/get_rituals()
	var/list/rituals = list()

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		if(!knowledge.can_be_invoked(src))
			continue
		rituals[knowledge.name] = knowledge

	return sortTim(rituals, /proc/cmp_heretic_knowledge, associative = TRUE)

/*
 * Checks to see if our heretic can ccurrently ascend.
 *
 * Returns FALSE if not all of our objectives are complete, or TRUE otherwise.
 */
/datum/antagonist/heretic/proc/can_ascend()
	for(var/datum/objective/must_be_done as anything in objectives)
		if(!must_be_done.check_completion())
			return FALSE
	return TRUE

/*
 * Helper to determine if a Heretic
 * - Has a Living Heart
 * - Has a an organ in the correct slot that isn't a living heart
 * - Is missing the organ they need in the slot to make a living heart
 *
 * Returns HERETIC_NO_HEART_ORGAN if they have no heart (organ) at all,
 * Returns HERETIC_NO_LIVING_HEART if they have a heart (organ) but it's not a living one,
 * and returns HERETIC_HAS_LIVING_HEART if they have a living heart
 */
/datum/antagonist/heretic/proc/has_living_heart()
	var/obj/item/organ/our_living_heart = owner.current?.getorganslot(ORGAN_SLOT_HEART)
	if(!our_living_heart)
		return HERETIC_NO_HEART_ORGAN

	if(!HAS_TRAIT(our_living_heart, TRAIT_LIVING_HEART))
		return HERETIC_NO_LIVING_HEART

	return HERETIC_HAS_LIVING_HEART

/// Heretic's minor sacrifice objective. "Minor sacrifices" includes anyone.
/datum/objective/minor_sacrifice
	name = "minor sacrifice"

/datum/objective/minor_sacrifice/New(text)
	. = ..()
	target_amount = rand(2, 3)
	update_explanation_text()

/datum/objective/minor_sacrifice/update_explanation_text()
	. = ..()
	explanation_text = "Sacrifice at least [target_amount] crewmembers."

/datum/objective/minor_sacrifice/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE
	return heretic_datum.total_sacrifices >= target_amount

/// Heretic's major sacrifice objective. "Major sacrifices" are heads of staff.
/datum/objective/major_sacrifice
	name = "major sacrifice"
	target_amount = 1
	explanation_text = "Sacrifice 1 head of staff."

/datum/objective/major_sacrifice/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE
	return heretic_datum.high_value_sacrifices >= target_amount

/// Heretic's research objective. "Research" is heretic knowledge nodes (You start with some).
/datum/objective/heretic_research
	name = "research"
	/// The length of a main path. Calculated once in New().
	var/static/main_path_length = 0

/datum/objective/heretic_research/New(text)
	. = ..()

	if(!main_path_length)
		// Let's find the length of a main path. We'll use rust because it's the coolest.
		// (All the main paths are (should be) the same length, so it doesn't matter.)
		var/rust_paths_found = 0
		for(var/datum/heretic_knowledge/knowledge as anything in subtypesof(/datum/heretic_knowledge))
			if(initial(knowledge.route) == HERETIC_PATH_RUST)
				rust_paths_found++

		main_path_length = rust_paths_found

	// Factor in the length of the main path first.
	target_amount = main_path_length
	// Add in the base research we spawn with, otherwise it'd be too easy.
	target_amount += length(GLOB.heretic_start_knowledge)
	// And add in some buffer, to require some sidepathing.
	target_amount += rand(2, 4)
	update_explanation_text()

/datum/objective/heretic_research/update_explanation_text()
	. = ..()
	explanation_text = "Research at least [target_amount] knowledge from the Mansus. You start with [length(GLOB.heretic_start_knowledge)] researched."

/datum/objective/heretic_research/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE
	return length(heretic_datum.researched_knowledge) >= target_amount

/datum/objective/heretic_summon
	name = "summon monsters"
	target_amount = 2
	explanation_text = "Summon 2 monsters from the Mansus into this realm."

/datum/objective/heretic_summon/check_completion()

	var/num_we_have = 0
	for(var/datum/antagonist/heretic_monster/monster in GLOB.antagonists)
		if(!monster.master)
			continue
		if(ishuman(monster.owner.current))
			continue
		if(monster.master != owner)
			continue

		num_we_have++

	return completed || (num_we_have >= target_amount)

/datum/outfit/heretic
	name = "Heretic (Preview only)"

	suit = /obj/item/clothing/suit/hooded/cultrobes/eldritch
	r_hand = /obj/item/melee/touch_attack/mansus_fist

/datum/outfit/heretic/post_equip(mob/living/carbon/human/equipper, visualsOnly)
	var/obj/item/clothing/suit/hooded/hooded = locate() in equipper
	hooded.MakeHood() // This is usually created on Initialize, but we run before atoms
	hooded.ToggleHood()

/datum/action/innate/hereticmenu
	name = "Forbidden Knowledge"
	desc = "Utilize your connection to the beyond to unlock new eldritch abilities"
	icon_icon = 'icons/obj/heretic.dmi'
	button_icon_state = "book_open"
	background_icon_state = "bg_ecult"
	var/datum/antagonist/heretic/ownerantag

/datum/action/innate/hereticmenu/New(datum/H)
	. = ..()
	button.name = name
	ownerantag = H

/datum/action/innate/hereticmenu/Activate()
	ownerantag.ui_interact(owner)
