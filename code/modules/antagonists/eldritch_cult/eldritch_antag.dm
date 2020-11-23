/datum/antagonist/heretic
	name = "Heretic"
	roundend_category = "Heretics"
	antagpanel_category = "Heretic"
	antag_moodlet = /datum/mood_event/heretics
	job_rank = ROLE_HERETIC
	var/antag_hud_type = ANTAG_HUD_HERETIC
	var/antag_hud_name = "heretic"
	var/give_equipment = TRUE
	var/list/researched_knowledge = list()
	var/list/pantheon = list(FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,)
	var/total_sacrifices = 0
	var/dread = 0
	var/favor_earned = 0
	var/favor_spent = 0
	var/list/followers = list()
	var/ascended = FALSE
	can_hijack = HIJACK_HIJACKER

/datum/antagonist/heretic/admin_add(datum/mind/new_owner,mob/admin)
	give_equipment = FALSE
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has heresized [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has heresized [key_name(new_owner)].")

/datum/antagonist/heretic/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ecult_op.ogg', 100, FALSE, pressure_affected = FALSE)//subject to change
	to_chat(owner, "<span class='boldannounce'>You are the Heretic!</span><br>\
	<B>The old ones gave you these tasks to fulfill:</B>")
	owner.announce_objectives()
	to_chat(owner, "<span class='cult'>As a heretic, you can gain the favor of the old gods through various acts to enhance your arcane powers1<br>\
	You can start by seeking out strange figurines to gain the favor of the lesser gods.<br>\
	When you are ready, carve a Rune of Transmutation and transmute a Codex Cycatrix from a bible, a pair of eyes and a pen, to unlock your true powers.<br> \
	You can find a basic guide at : https://wiki.beestation13.com/view/Heretics </span>")

/datum/antagonist/heretic/on_gain()
	var/mob/living/current = owner.current
	if(ishuman(current))
		forge_primary_objectives()
		gain_knowledge(/datum/eldritch_knowledge/codex_cicatrix)
		gain_knowledge(/datum/eldritch_knowledge/living_heart)
		gain_knowledge(/datum/eldritch_knowledge/spell/basic)
		gain_knowledge(/datum/eldritch_knowledge/eldritch_avatar)
	current.log_message("has become a heretic", LOG_ATTACK, color="#960000")
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
		to_chat(owner.current, "<span class='userdanger'>Your mind begins to flare as the otherwordly knowledge escapes your grasp!</span>")
		owner.current.log_message("has become a non-heretic", LOG_ATTACK, color="#960000")
	GLOB.reality_smash_track.RemoveMind(owner)
	STOP_PROCESSING(SSprocessing,src)

	return ..()


/datum/antagonist/heretic/proc/equip_cultist()
	var/mob/living/carbon/H = owner.current
	if(!istype(H))
		return
	. += ecult_give_item(/obj/item/storage/book/bible, H)
	. += ecult_give_item(/obj/item/reagent_containers/food/snacks/grown/poppy, H)
	. += ecult_give_item(/obj/item/artifact, H)

/datum/antagonist/heretic/proc/ecult_give_item(obj/item/item_path, mob/living/carbon/human/H)
	var/list/slots = list(
		"backpack" = SLOT_IN_BACKPACK,
		"left pocket" = SLOT_L_STORE,
		"right pocket" = SLOT_R_STORE
	)

	var/T = new item_path(H)
	var/item_name = initial(item_path.name)
	var/where = H.equip_in_one_of_slots(T, slots)
	if(!where)
		to_chat(H, "<span class='userdanger'>Unfortunately, you weren't able to get a [item_name]. This is very bad and you should adminhelp immediately (press F1).</span>")
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
	if (prob(5))
		if (prob(66))
			var/datum/objective/ascend/AE = new()
			AE.owner = owner
			AE.update_explanation_text()
			objectives += AE
			log_objective(owner, AE.explanation_text)
		else
			var/datum/objective/hijack/hijack_objective = new
			hijack_objective.owner = owner
			hijack_objective.update_explanation_text()
			objectives += hijack_objective
			log_objective(owner, hijack_objective.explanation_text)
	else 
		var/list/assasination = list()
		var/list/protection = list()
		for(var/i in 1 to 2)
			switch (rand(0,100))
				if (0 to 4)
					var/datum/objective/protect/P = new()
					P.owner = owner
					var/list/owners = P.get_owners()
					P.find_target(owners,assasination)
					protection += P.target
					objectives += P
					log_objective(owner, P.explanation_text)
				if (5 to 35)
					var/datum/objective/stalk/S = new()
					S.owner = owner
					S.find_target()
					objectives += S
					log_objective(owner, S.explanation_text)
				else
					var/datum/objective/assassinate/A = new()
					A.owner = owner
					var/list/owners = A.get_owners()
					A.find_target(owners,protection)
					assasination += A.target
					objectives += A
					log_objective(owner, A.explanation_text)
		if (prob(20))
			var/datum/objective/minicult/CE = new()
			CE.owner = owner
			CE.update_explanation_text()
			objectives += CE
			log_objective(owner, CE.explanation_text)
		else 
			var/datum/objective/sacrifice_ecult/SE = new()
			SE.owner = owner
			SE.update_explanation_text()
			objectives += SE
			log_objective(owner, SE.explanation_text)

/datum/antagonist/heretic/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	add_antag_hud(antag_hud_type, antag_hud_name, current)
	handle_clown_mutation(current, mob_override ? null : "Knowledge described in the book allowed you to overcome your clownish nature, allowing you to use complex items effectively.")
	current.faction |= "heretics"

/datum/antagonist/heretic/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	remove_antag_hud(antag_hud_type, current)
	handle_clown_mutation(current, removing = FALSE)
	current.faction -= "heretics"

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
			if(isnull(o) || !o)
				stack_trace("Heretic objective was NULL'ed")
				continue
			var/datum/objective/objective = o
			if(objective.check_completion())
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='greentext'>Success!</b></span>"
			else
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
				cultiewin = FALSE
			count++

	if(ascended)
		//Ascension isnt technically finishing the objectives, buut it is to be considered a great win.
		var/client/C = GLOB.directory[ckey(owner.key)]
		if(C)
			C.process_greentext()
		parts += "<span class='greentext big'>HERETIC HAS ASCENDED!</span>"
	else
		if(cultiewin)
			parts += "<span class='greentext'>The heretic was successful!</span>"
		else
			parts += "<span class='redtext'>The heretic has failed.</span>"

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

/////////////
// Economy //
/////////////

/datum/antagonist/heretic/proc/gain_favor(points,dread = FALSE)
	favor_earned+=points
	if (dread)
		dread++
	return TRUE

/datum/antagonist/heretic/proc/spend_favor(points)
	if (get_favor_left()<points)
		return FALSE
	favor_spent-=points
	return TRUE

/datum/antagonist/heretic/proc/get_favor_left()
	return favor_earned-favor_spent

////////////////
// Objectives //
////////////////

/datum/objective/stalk
	name = "spendtime"
	var/timer = 5 MINUTES

/datum/objective/stalk/process()
	if(owner?.current?.stat != DEAD && target?.current?.stat != DEAD && (target in view(5,owner.current)))
		timer -= 1 SECONDS
	///we don't want to process after the counter reaches 0, otherwise it is wasted processing
	if(timer <= 0)
		completed = TRUE
		STOP_PROCESSING(SSprocessing,src)

/datum/objective/stalk/Destroy(force, ...)
	stack_trace("Stalk objective is being removed! This shouldn't normally happen!")
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

/datum/objective/ascend
	name = "ascend"

/datum/objective/ascend/update_explanation_text()
	. = ..()
	explanation_text = "Applease the Gods and ascend."

/datum/objective/ascend/check_completion()
	if(!owner)
		return FALSE
	var/datum/antagonist/heretic/cultie = owner.has_antag_datum(/datum/antagonist/heretic)
	if(!cultie)
		return FALSE
	return cultie.ascended

/datum/objective/minicult
	name = "mini cult"

/datum/objective/minicult/update_explanation_text()
	. = ..()
	target_amount = rand(2,5)
	explanation_text = "Raise and maintain a cult of [target_amount] people."

/datum/objective/minicult/check_completion()
	if(!owner)
		return FALSE
	var/datum/antagonist/heretic/cultie = owner.has_antag_datum(/datum/antagonist/heretic)
	if(!cultie)
		return FALSE
	return cultie.get_cur_followers()>=target_amount

//////////////
// Minicult //
//////////////

/datum/antagonist/heretic/proc/get_max_followers()
	var/total = 0
	var/list/knowledge = get_all_knowledge()
	for(var/X in knowledge)
		var/datum/eldritch_knowledge/EK = knowledge[X]
		total += EK.followers_increment
	return total

/datum/antagonist/heretic/proc/get_cur_followers()
	return LAZYLEN(followers)

/datum/antagonist/heretic/proc/enslave(mob/living/carbon/human/victim)
	if(get_cur_followers() >= get_max_followers())
		return 1
	if(!victim.mind || !victim.client )
		return 2
	if (IS_HERETIC(victim) || IS_HERETIC_MONSTER(victim))
		return 3
	log_game("[key_name_admin(victim)] has become a follower of [key_name_admin(src)]")
	victim.faction |= "heretics"
	var/datum/antagonist/heretic_monster/heretic_monster = victim.mind.add_antag_datum(/datum/antagonist/heretic_monster/disciple)
	heretic_monster.set_owner(src)
	return 0

//////////////
// Pantheon //
//////////////

/datum/antagonist/heretic/proc/gain_deity(intid)
	if(has_deity(intid))
		return FALSE
	pantheon[intid] = TRUE
	return TRUE

/datum/antagonist/heretic/proc/has_deity(intid)
	return pantheon[intid]
