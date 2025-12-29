// This is to replace the previous datum/disease/alien_embryo for slightly improved handling and maintainability
// It functions almost identically (see code/datums/diseases/alien_embryo.dm)
/obj/item/organ/body_egg/alien_embryo
	name = "alien embryo"
	icon = 'icons/mob/alien.dmi'
	icon_state = "larva0_dead"
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/toxin/acid = 10)
	var/stage = 0
	COOLDOWN_DECLARE(next_stage_time)
	var/bursting = FALSE

/obj/item/organ/body_egg/alien_embryo/on_find(mob/living/finder)
	. = ..()
	if(stage < 4)
		to_chat(finder, "It's small and weak, barely the size of a foetus.")
	else
		to_chat(finder, "It's grown quite large, and writhes slightly as you look at it.")
		if(prob(10))
			AttemptGrow(0)

/obj/item/organ/body_egg/alien_embryo/on_life(delta_time, times_fired)
	. = ..()
	if(!owner)
		return
	switch(stage)
		if(3, 4)
			if(DT_PROB(1, delta_time))
				owner.emote("sneeze")
			if(DT_PROB(1, delta_time))
				owner.emote("cough")
			if(DT_PROB(1, delta_time))
				to_chat(owner, span_danger("Your throat feels sore."))
			if(DT_PROB(1, delta_time))
				to_chat(owner, span_danger("Mucous runs down the back of your throat."))
		if(5)
			if(DT_PROB(1, delta_time))
				owner.emote("sneeze")
			if(DT_PROB(1, delta_time))
				owner.emote("cough")
			if(DT_PROB(2, delta_time))
				to_chat(owner, span_danger("Your muscles ache."))
				if(prob(20))
					owner.take_bodypart_damage(1)
			if(DT_PROB(2, delta_time))
				to_chat(owner, span_danger("Your stomach hurts."))
				if(prob(20))
					owner.adjustToxLoss(1)
		if(6)
			to_chat(owner, span_danger("You feel something tearing its way out of your stomach."))
			owner.adjustToxLoss(5 * delta_time) // Why is this [TOX]?

/obj/item/organ/body_egg/alien_embryo/on_death()
	. = ..()
	if(!owner) // If we're out of the body, kill us and stop processing
		apply_organ_damage(maxHealth)
		STOP_PROCESSING(SSobj, src)

/obj/item/organ/body_egg/alien_embryo/egg_process()
	if(!next_stage_time)
		COOLDOWN_START(src, next_stage_time, 30 SECONDS)
		return
	if(COOLDOWN_FINISHED(src, next_stage_time) && stage < 5)
		var/additional_grow_time = 0 SECONDS
		for(var/mob/living/carbon/alien/humanoid/A in GLOB.alive_mob_list) // Add more growing time based on how many aliens are alive
			if(!A.key || A.stat == DEAD) // Don't count dead/SSD aliens
				continue
			additional_grow_time += 2 SECONDS
		additional_grow_time = min(additional_grow_time, 1 MINUTES)
		COOLDOWN_START(src, next_stage_time, rand(30 SECONDS, 45 SECONDS) + additional_grow_time) // Somewhere from 2.5-3.5 minutes to fully grow
		stage++
		INVOKE_ASYNC(src, PROC_REF(RefreshInfectionImage))

	if(stage == 5 && prob(50))
		for(var/datum/surgery/S in owner.surgeries)
			if(S.location == BODY_ZONE_CHEST && istype(S.get_surgery_step(), /datum/surgery_step/manipulate_organs))
				AttemptGrow(FALSE)
				return
		AttemptGrow()

/obj/item/organ/body_egg/alien_embryo/proc/AttemptGrow(kill_on_success = TRUE)
	if(!owner || bursting)
		return

	bursting = TRUE

	var/datum/poll_config/config = new()
	config.question = "Do you want to play as an alien larva that will burst out of [owner]?"
	config.check_jobban = ROLE_ALIEN
	config.poll_time = 10 SECONDS
	config.ignore_category = POLL_IGNORE_ALIEN_LARVA
	config.jump_target = owner
	config.role_name_text = "alien larva"
	config.alert_pic = /mob/living/carbon/alien/larva
	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(config)

	if(QDELETED(src) || QDELETED(owner))
		return

	if(!candidate || !owner)
		bursting = FALSE
		stage = 4
		return

	var/mutable_appearance/overlay = mutable_appearance('icons/mob/alien.dmi', "burst_lie")
	owner.add_overlay(overlay)

	var/atom/xeno_loc = get_turf(owner)
	var/mob/living/carbon/alien/larva/new_xeno = new(xeno_loc)
	new_xeno.key = candidate.key
	SEND_SOUND(new_xeno, sound('sound/voice/hiss5.ogg',0,0,0,100))	//To get the player's attention
	ADD_TRAIT(new_xeno, TRAIT_IMMOBILIZED, type) //so we don't move during the bursting animation
	ADD_TRAIT(new_xeno, TRAIT_HANDS_BLOCKED, type)
	new_xeno.notransform = 1
	new_xeno.invisibility = INVISIBILITY_MAXIMUM

	sleep(6)

	if(QDELETED(src) || QDELETED(owner))
		qdel(new_xeno)
		CRASH("AttemptGrow failed due to the early qdeletion of source or owner.")

	if(new_xeno)
		REMOVE_TRAIT(new_xeno, TRAIT_IMMOBILIZED, type)
		REMOVE_TRAIT(new_xeno, TRAIT_HANDS_BLOCKED, type)
		new_xeno.notransform = 0
		new_xeno.invisibility = 0

	var/mob/living/carbon/host = owner
	if(kill_on_success)
		new_xeno.visible_message(span_danger("[new_xeno] bursts out of [owner] in a shower of gore!"), span_userdanger("You exit [owner], your previous host."), span_italics("You hear organic matter ripping and tearing!"))
		owner.investigate_log("has been killed by an alien larva chestburst.", INVESTIGATE_DEATHS)
		var/obj/item/bodypart/BP = owner.get_bodypart(BODY_ZONE_CHEST)
		if(BP)
			BP.receive_damage(brute = 200) // Kill them dead
			BP.dismember()
		else
			owner.apply_damage(200)
	else
		new_xeno.visible_message(span_danger("[new_xeno] wriggles out of [owner]!"), span_userdanger("You exit [owner], your previous host."))
		owner.adjustBruteLoss(40)
	host.cut_overlay(overlay)
	qdel(src)


/*----------------------------------------
Proc: AddInfectionImages(C)
Des: Adds the infection image to all aliens for this embryo
----------------------------------------*/
/obj/item/organ/body_egg/alien_embryo/AddInfectionImages()
	for(var/mob/living/carbon/alien/alien in GLOB.player_list)
		if(alien.client)
			var/I = image('icons/mob/alien.dmi', loc = owner, icon_state = "infected[stage]")
			alien.client.images += I

/*----------------------------------------
Proc: RemoveInfectionImage(C)
Des: Removes all images from the mob infected by this embryo
----------------------------------------*/
/obj/item/organ/body_egg/alien_embryo/RemoveInfectionImages()
	for(var/mob/living/carbon/alien/alien in GLOB.player_list)
		if(alien.client)
			for(var/image/I in alien.client.images)
				var/searchfor = "infected"
				if(I.loc == owner && findtext(I.icon_state, searchfor, 1, length(searchfor) + 1))
					alien.client.images -= I
					qdel(I)
