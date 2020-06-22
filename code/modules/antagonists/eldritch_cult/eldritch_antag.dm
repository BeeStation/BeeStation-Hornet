/datum/antagonist/heretic
	name = "Heretic"
	roundend_category = "Heretics"
	antagpanel_category = "Heretic"
	antag_moodlet = /datum/mood_event/heretics
	job_rank = ROLE_HERETIC
	var/give_equipment = TRUE
	var/list/researched_knowledge = list()
	var/total_sacrifices = 0

/datum/antagonist/heretic/admin_add(datum/mind/new_owner, mob/admin)
	give_equipment = FALSE
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has heresized [key_name_admin(new_owner)].")
	log_admin("[key_name_admin(admin)] has heresized [key_name(new_owner)].")

/datum/antagonist/heretic/greet()

	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ecult_op.ogg', 100, FALSE, pressure_affected = FALSE)
	to_chat(owner, "<span class='boldannounce'>You are the Heretic!</span><br>\
	<B>The old ones gave you these tasks to fulfill:</B>")
	owner.announce_objectives()
	to_chat(owner,"<span class='cult'>The book whispers, the forbidden knowledge walks once again!<br>\
	Your book allows you to research abilities, read it very carefully! you cannot undo what has been done!<br>\
	You gain charges by either collecitng influences or sacrifcing people tracked by the living heart<br> \
	You can find a basic guide at : https://wiki.beestation13.com/wiki/Heresy_101 </span>")

/datum/antagonist/heretic/on_gain()
	var/mob/living/current = owner.current
	if(ishuman(current))
		forge_primary_objectives()
		gain_knowledge(/datum/eldritch_knowledge/spell/basic)
		gain_knowledge(/datum/eldritch_knowledge/living_heart)
		current.log_message("has been converted to the cult of the forgotten ones!", LOG_ATTACK, color="#960000")
		GLOB.reality_smash_track.AddMind(owner)
		START_PROCESSING(SSprocessing,src)
		if(give_equipment)
			equip_cultist()
		return ..()

/datum/antagonist/heretic/on_removal()

	for(var/X in researched_knowledge)
		var/datum/eldritch_knowledge/EK = researched_knowledge[X]
		EK.on_lose(owner.current)

	if(!silent)
		owner.current.visible_message("<span class='deconversion_message'>[owner.current] looks like [owner.current.p_theyve()] just reverted to [owner.current.p_their()] old faith!</span>", null, null, null, owner.current)
		to_chat(owner.current, "<span class='userdanger'>Your mind begins to flare as the otherwordly knowledge escapes your grasp!</span>")
		owner.current.log_message("has renounced the cult of the old ones!", LOG_ATTACK, color="#960000")
		GLOB.reality_smash_track.RemoveMind(owner)
		STOP_PROCESSING(SSprocessing,src)

		return ..()

/datum/antagonist/heretic/proc/equip_cultist()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	. += ecult_give_item(/obj/item/forbidden_book, H)
	. += ecult_give_item(/obj/item/living_heart, H)

/datum/antagonist/heretic/proc/ecult_give_item(obj/item/item_path, mob/living/carbon/human/H)
	var/list/slots = list(
		"backpack" = ITEM_SLOT_BACKPACK,
		"left pocket" = ITEM_SLOT_POCKET,
	)

	var/T = new item_path(H)
	var/item_name = initial(item_path.name)
	var/where = H.equip_in_one_of_slots(T, slots)
	if(!where)
		to_chat(owner.current, "<span class='userdanger'>Unfortunately, you weren't able to get a [item_name]. This is very bad and you should adminhelp immediately (press F1)</span>")
		return FALSE
	else
		to_chat(H, "<span class='danger'>You have a [item_name] in your [where].</span>")
		if(where == "backpack")
			SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_SHOW, H)
			return TRUE

/datum/antagonist/heretic/process()

	for(var/X in researched_knowledge)
		var/datum/eldritch_knowledge/EK = researched_knowledge[X]
		EK.on_life(owner.current)

/datum/antagonist/heretic/proc/forge_primary_objectives()
	for(var/i in 1 to 2)
		var/datum/mind/M
		var/pck = pick("assasinate","protect","stalk")
		switch(pck)
			if("stalk")
				var/datum/objective/spendtime/S = new
				S.owner = owner
				S.target = M
				objectives += S
				log_objective(owner, S.explanation_text)
			if("assasinate")
				var/datum/objective/assassinate/O = new /datum/objective/assassinate()
				O.owner = owner
				O.target = M
				O.explanation_text = "Slay \the [M.current.real_name], the [M.assigned_role]."
				objectives += O
				log_objective(owner, O.explanation_text)
			if("protect")
				var/datum/objective/protect/A = new /datum/objective/protect()
				A.owner = owner
				A.target = M
				objectives += A
				A.explanation_text = "Protect \the [M.current.real_name], the [M.assigned_role], from harm."
				log_objective(owner, A.explanation_text)
/datum/antagonist/heretic/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	var/datum/atom_hud/antag/traitor_hud = GLOB.huds[ANTAG_HUD_HERETIC]
	if(mob_override)
		current = mob_override
	current.faction -= "heretics"
	traitor_hud.join_hud(owner.current)
	if(!owner.antag_hud_icon_state)
		set_antag_hud(owner.current, "heretic")

/datum/antagonist/heretic/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/datum/atom_hud/antag/traitor_hud = GLOB.huds[ANTAG_HUD_HERETIC]
	traitor_hud.leave_hud(owner.current)
	if(owner.antag_hud_icon_state == "heretic")
		set_antag_hud(owner.current, null)

/datum/antagonist/heretic/get_admin_commands()
	. = ..()
	.["Equip"] = CALLBACK(src,.proc/equip_cultist)

/datum/antagonist/heretic/roundend_report()
	var/list/parts = list()

	var/cultiewin = TRUE

	parts += printplayer(owner)
	parts += "<b>Sacrifices Made:</b> [total_sacrifices]"

	if(length(objectives))
		var/count = 1
		for(var/o in objectives)
			var/datum/objective/objective = o
			if(objective.check_completion())
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='greentext'>Success!</b></span>"
			else
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
				cultiewin = FALSE
			count++
	if(cultiewin)
		parts += "<span class='greentext'>The heretic was successful!</span>"
	else
		parts += "<span class='redtext'>The heretic has failed.</span>"

	parts += "<b>Knowledge Researched:</b>"

	var/list/knowledge_message = list()
	var/list/knowledge = get_all_knowledge()
	for(var/X in knowledge)
		var/datum/eldritch_knowledge/EK = knowledge[X]
		knowledge_message += "[EK.name]"
	parts += knowledge_message.Join(", ")

	return parts.Join("<br>")
////////////////
// Knowledge //
////////////////

/datum/antagonist/heretic/proc/gain_knowledge(datum/eldritch_knowledge/EK)
	if(get_knowledge(EK))
		return FALSE
	var/datum/eldritch_knowledge/initialized_knowledge = new EK
	researched_knowledge[initialized_knowledge.type] = initialized_knowledge
	initialized_knowledge.on_gain(owner.current)
	return TRUE

/datum/antagonist/heretic/proc/get_researchable_knowledge()
	var/list/researchable_knowledge = list()
	var/list/banned_knowledge = list()
	for(var/X in researched_knowledge)
		var/datum/eldritch_knowledge/EK = researched_knowledge[X]
		researchable_knowledge |= EK.next_knowledge
		banned_knowledge |= EK.banned_knowledge
		banned_knowledge |= EK.type
	researchable_knowledge -= banned_knowledge
	return researchable_knowledge

/datum/antagonist/heretic/proc/get_knowledge(wanted)
	return researched_knowledge[wanted]

/datum/antagonist/heretic/proc/get_all_knowledge()
	return researched_knowledge

////////////////
// Objectives //
////////////////

/datum/objective/stalk
	name = "spendtime"
	var/timer = 5 MINUTES

/datum/objective/stalk/process()
	if(owner?.current.stat != DEAD && target?.current.stat != DEAD && (target in view(5,owner.current)))
		timer -= 1 SECONDS
	///we don't want to process after the counter reaches 0, otherwise it is wasted processing
	if(timer <= 0)
		STOP_PROCESSING(SSprocessing,src)

/datum/objective/stalk/Destroy(force, ...)
	STOP_PROCESSING(SSprocessing,src)
	return ..()

/datum/objective/stalk/update_explanation_text()
	//we want to start processing after we set the timer
	timer += rand(-3 MINUTES, 3 MINUTES)
	START_PROCESSING(SSprocessing,src)
	if(target?.current)
		explanation_text = "Stalk [target.name] for at least [DisplayTimeText(timer)] while they're alive."
	else
		explanation_text = "Free Objective"

/datum/objective/stalk/check_completion()
	return timer <= 0 || explanation_text == "Free Objective"

/datum/objective/sacrifice_ecult
	name = "sacrifice"

/datum/objective/sacrifice_ecult/update_explanation_text()
	. = ..()
	target_amount = rand(2,6)
	explanation_text = "Sacrifice at least [target_amount] people."

/datum/objective/sacrifice_ecult/check_completion()
	if(!owner)
		return FALSE
	var/datum/antagonist/heretic/cultie = owner.has_antag_datum(/datum/antagonist/heretic)
	if(!cultie)
		return FALSE
	return cultie.total_sacrifices >= target_amount
