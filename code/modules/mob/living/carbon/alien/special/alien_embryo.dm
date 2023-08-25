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

/obj/item/organ/body_egg/alien_embryo/on_life()
	. = ..()
	switch(stage)
		if(2, 3)
			if(prob(2))
				owner.emote("sneeze")
			if(prob(2))
				owner.emote("cough")
			if(prob(2))
				to_chat(owner, "<span class='danger'>Your throat feels sore.</span>")
			if(prob(2))
				to_chat(owner, "<span class='danger'>Mucous runs down the back of your throat.</span>")
		if(4)
			if(prob(2))
				owner.emote("sneeze")
			if(prob(2))
				owner.emote("cough")
			if(prob(4))
				to_chat(owner, "<span class='danger'>Your muscles ache.</span>")
				if(prob(20))
					owner.take_bodypart_damage(1)
			if(prob(4))
				to_chat(owner, "<span class='danger'>Your stomach hurts.</span>")
				if(prob(20))
					owner.adjustToxLoss(1)
		if(5)
			to_chat(owner, "<span class='danger'>You feel something tearing its way out of your stomach.</span>")
			owner.adjustToxLoss(10)

/obj/item/organ/body_egg/alien_embryo/on_death()
	. = ..()
	if(!owner) // If we're out of the body, kill us and stop processing
		applyOrganDamage(maxHealth)
		STOP_PROCESSING(SSobj, src)

/obj/item/organ/body_egg/alien_embryo/egg_process()
	var/mob/living/L = owner
	if(IS_IN_STASIS(L))
		return
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

	var/list/candidates = pollGhostCandidates("Do you want to play as an alien larva that will burst out of [owner]?", ROLE_ALIEN, /datum/role_preference/midround_ghost/xenomorph, 10 SECONDS, POLL_IGNORE_ALIEN_LARVA) // separate poll from xeno event spawns

	if(QDELETED(src) || QDELETED(owner))
		return

	if(!candidates.len || !owner)
		bursting = FALSE
		stage = 4
		return

	var/mob/dead/observer/ghost = pick(candidates)

	var/mutable_appearance/overlay = mutable_appearance('icons/mob/alien.dmi', "burst_lie")
	owner.add_overlay(overlay)

	var/atom/xeno_loc = get_turf(owner)
	var/mob/living/carbon/alien/larva/new_xeno = new(xeno_loc)
	new_xeno.key = ghost.key
	SEND_SOUND(new_xeno, sound('sound/voice/hiss5.ogg',0,0,0,100))	//To get the player's attention
	new_xeno.mobility_flags = NONE //so we don't move during the bursting animation
	new_xeno.notransform = 1
	new_xeno.invisibility = INVISIBILITY_MAXIMUM

	sleep(6)

	if(QDELETED(src) || QDELETED(owner))
		return

	if(new_xeno)
		new_xeno.mobility_flags = MOBILITY_FLAGS_DEFAULT
		new_xeno.notransform = 0
		new_xeno.invisibility = 0

	var/mob/living/carbon/host = owner
	if(kill_on_success)
		new_xeno.visible_message("<span class='danger'>[new_xeno] bursts out of [owner] in a shower of gore!</span>", "<span class='userdanger'>You exit [owner], your previous host.</span>", "<span class='italics'>You hear organic matter ripping and tearing!</span>")
		var/obj/item/bodypart/BP = owner.get_bodypart(BODY_ZONE_CHEST)
		if(BP)
			BP.receive_damage(brute = 200) // Kill them dead
			BP.dismember()
		else
			owner.apply_damage(200)
	else
		new_xeno.visible_message("<span class='danger'>[new_xeno] wriggles out of [owner]!</span>", "<span class='userdanger'>You exit [owner], your previous host.</span>")
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
