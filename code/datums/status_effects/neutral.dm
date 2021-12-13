//entirely neutral or internal status effects go here

/datum/status_effect/sigil_mark //allows the affected target to always trigger sigils while mindless
	id = "sigil_mark"
	duration = -1
	alert_type = null
	var/stat_allowed = DEAD //if owner's stat is below this, will remove itself

/datum/status_effect/sigil_mark/tick()
	if(owner.stat < stat_allowed)
		qdel(src)

/datum/status_effect/crusher_damage //tracks the damage dealt to this mob by kinetic crushers
	id = "crusher_damage"
	duration = -1
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/total_damage = 0

/datum/status_effect/syphon_mark
	id = "syphon_mark"
	duration = 50
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	on_remove_on_mob_delete = TRUE
	var/obj/item/borg/upgrade/modkit/bounty/reward_target

/datum/status_effect/syphon_mark/on_creation(mob/living/new_owner, obj/item/borg/upgrade/modkit/bounty/new_reward_target)
	. = ..()
	if(.)
		reward_target = new_reward_target

/datum/status_effect/syphon_mark/on_apply()
	if(owner.stat == DEAD)
		return FALSE
	return ..()

/datum/status_effect/syphon_mark/proc/get_kill()
	if(!QDELETED(reward_target))
		reward_target.get_kill(owner)

/datum/status_effect/syphon_mark/tick()
	if(owner.stat == DEAD)
		get_kill()
		qdel(src)

/datum/status_effect/syphon_mark/on_remove()
	get_kill()
	. = ..()

/atom/movable/screen/alert/status_effect/in_love
	name = "In Love"
	desc = "You feel so wonderfully in love!"
	icon_state = "in_love"

/datum/status_effect/in_love
	id = "in_love"
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/in_love
	var/mob/living/date

/datum/status_effect/in_love/on_creation(mob/living/new_owner, mob/living/love_interest)
	. = ..()
	if(.)
		date = love_interest
	linked_alert.desc = "You're in love with [date.real_name]! How lovely."

/datum/status_effect/in_love/tick()
	if(date)
		new /obj/effect/temp_visual/love_heart/invisible(get_turf(date.loc), owner)
		if(get_dist(get_turf(owner), get_turf(date)) < 7)
			owner.heal_overall_damage(1, 1, BODYPART_ORGANIC)
			date.heal_overall_damage(1, 1, BODYPART_ORGANIC)

/datum/status_effect/throat_soothed
	id = "throat_soothed"
	duration = 60 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/throat_soothed/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_SOOTHED_THROAT, "[STATUS_EFFECT_TRAIT]_[id]")

/datum/status_effect/throat_soothed/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_SOOTHED_THROAT, "[STATUS_EFFECT_TRAIT]_[id]")

/datum/status_effect/bounty
	id = "bounty"
	status_type = STATUS_EFFECT_UNIQUE
	var/mob/living/rewarded

/datum/status_effect/bounty/on_creation(mob/living/new_owner, mob/living/caster)
	. = ..()
	if(.)
		rewarded = caster

/datum/status_effect/bounty/on_apply()
	to_chat(owner, "<span class='boldnotice'>You hear something behind you talking...</span> <span class='notice'>You have been marked for death by [rewarded]. If you die, they will be rewarded.</span>")
	playsound(owner, 'sound/weapons/shotgunpump.ogg', 75, 0)
	return ..()

/datum/status_effect/bounty/tick()
	if(owner.stat == DEAD)
		rewards()
		qdel(src)

/datum/status_effect/bounty/proc/rewards()
	if(rewarded && rewarded.mind && rewarded.stat != DEAD)
		to_chat(owner, "<span class='boldnotice'>You hear something behind you talking...</span> <span class='notice'>Bounty claimed.</span>")
		playsound(owner, 'sound/weapons/shotgunshot.ogg', 75, 0)
		to_chat(rewarded, "<span class='greentext'>You feel a surge of mana flow into you!</span>")
		for(var/obj/effect/proc_holder/spell/spell in rewarded.mind.spell_list)
			spell.charge_counter = spell.charge_max
			spell.recharging = FALSE
			spell.update_icon()
		rewarded.adjustBruteLoss(-25)
		rewarded.adjustFireLoss(-25)
		rewarded.adjustToxLoss(-25, FALSE, TRUE)
		rewarded.adjustOxyLoss(-25)
		rewarded.adjustCloneLoss(-25)

/datum/status_effect/bugged //Lets another mob hear everything you can
	id = "bugged"
	duration = -1
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	var/mob/living/listening_in

/datum/status_effect/bugged/on_apply(mob/living/new_owner, mob/living/tracker)
	. = ..()
	if (.)
		RegisterSignal(new_owner, COMSIG_MOVABLE_HEAR, .proc/handle_hearing)

/datum/status_effect/bugged/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOVABLE_HEAR)

/datum/status_effect/bugged/proc/handle_hearing(datum/source, list/hearing_args)
	SIGNAL_HANDLER
	listening_in.show_message(hearing_args[HEARING_MESSAGE])


/datum/status_effect/bugged/on_creation(mob/living/new_owner, mob/living/tracker)
	. = ..()
	if(.)
		listening_in = tracker

	owner.emote("surrender")

/*
 * A status effect used for preventing caltrop message spam
 *
 * While a mob has this status effect, they won't recieve any messages about
 * stepping on caltrops. But they will be stunned and damaged regardless.
 *
 * The status effect itself has no effect, other than to disappear after
 * a second.
 */
/datum/status_effect/caltropped
	id = "caltropped"
	duration = 1 SECONDS
	tick_interval = INFINITY
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

#define EIGENSTASIUM_MAX_BUFFER -250
#define EIGENSTASIUM_STABILISATION_RATE 5
#define EIGENSTASIUM_PHASE_1_END 50
#define EIGENSTASIUM_PHASE_2_END 80
#define EIGENSTASIUM_PHASE_3_START 100
#define EIGENSTASIUM_PHASE_3_END 150

/datum/status_effect/eigenstasium
	id = "eigenstasium"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	///So we know what cycle we're in during the status
	var/current_cycle = EIGENSTASIUM_MAX_BUFFER //Consider it your stability
	///The addiction looper for addiction stage 3
	var/phase_3_cycle = -0 //start off delayed
	///Your clone from another reality
	var/mob/living/carbon/alt_clone = null
	///If we display the stabilised message or not
	var/stable_message = FALSE

/datum/status_effect/eigenstasium/Destroy()
	if(alt_clone)
		UnregisterSignal(alt_clone, COMSIG_PARENT_QDELETING)
		QDEL_NULL(alt_clone)
	return ..()

/datum/status_effect/eigenstasium/tick()
	. = ..()
	//This stuff runs every cycle
	if(prob(5))
		do_sparks(5, FALSE, owner)

	//If we have a reagent that blocks the effects
	var/block_effects = FALSE
	if(owner.has_reagent(/datum/reagent/bluespace))
		current_cycle = max(EIGENSTASIUM_MAX_BUFFER, (current_cycle - (EIGENSTASIUM_STABILISATION_RATE * 1.5))) //cap to -250
		block_effects = TRUE
	if(owner.has_reagent(/datum/reagent/stabilizing_agent))
		current_cycle = max(EIGENSTASIUM_MAX_BUFFER, (current_cycle - EIGENSTASIUM_STABILISATION_RATE))
		block_effects = TRUE
	var/datum/reagent/eigen = owner.has_reagent(/datum/reagent/eigenstate)
	if(eigen)
		if(eigen.overdosed)
			block_effects = FALSE
		else
			current_cycle = max(EIGENSTASIUM_MAX_BUFFER, (current_cycle - (EIGENSTASIUM_STABILISATION_RATE * 2)))
			block_effects = TRUE

	if(!QDELETED(alt_clone)) //catch any stragglers
		do_sparks(5, FALSE, alt_clone)
		owner.visible_message("[owner] is snapped across to a different alternative reality!")
		QDEL_NULL(alt_clone)

	if(block_effects)
		if(!stable_message)
			owner.visible_message("You feel stable...for now.")
			stable_message = TRUE
		return
	stable_message = FALSE

	//These run on specific cycles
	switch(current_cycle)
		if(0)
			to_chat(owner, "<span class='userdanger'>You feel like you're being pulled across to somewhere else. You feel empty inside.</span>")

		//phase 1
		if(1 to EIGENSTASIUM_PHASE_1_END)
			owner.Jitter(2)
			owner.adjust_nutrition(-4)

		//phase 2
		if(EIGENSTASIUM_PHASE_1_END to EIGENSTASIUM_PHASE_2_END)
			if(current_cycle == 51)
				to_chat(owner, "<span class='userdanger'>You start to convlse violently as you feel your consciousness merges across realities, your possessions flying wildy off your body!</span>")
				owner.Jitter(200)
				owner.Knockdown(10)
			var/items = owner.get_contents()
			if(!LAZYLEN(items))
				return ..()
			var/obj/item/item = pick(items)
			owner.dropItemToGround(item, TRUE)
			do_sparks(5,FALSE,item)
			do_teleport(item, get_turf(item), 3, no_effects=TRUE);
			do_sparks(5,FALSE,item)

		//phase 3 - little break to get your items
		if(EIGENSTASIUM_PHASE_3_START to EIGENSTASIUM_PHASE_3_END)
			//Clone function - spawns a clone then deletes it - simulates multiple copies of the player teleporting in
			switch(phase_3_cycle) //Loops 0 -> 1 -> 2 -> 1 -> 2 -> 1 ...ect.
				if(0)
					owner.Jitter(100)
					to_chat(owner, "<span class='userdanger'>Your eigenstate starts to rip apart, drawing in alternative reality versions of yourself!</span>")
				if(1)
					var/typepath = owner.type
					alt_clone = new typepath(owner.loc)
					alt_clone.appearance = owner.appearance
					alt_clone.real_name = owner.real_name
					RegisterSignal(alt_clone, COMSIG_PARENT_QDELETING, .proc/remove_clone_from_var)
					owner.visible_message("[owner] splits into seemingly two versions of themselves!")
					do_teleport(alt_clone, get_turf(alt_clone), 2, no_effects=TRUE) //teleports clone so it's hard to find the real one!
					do_sparks(5,FALSE,alt_clone)
					alt_clone.emote("spin")
					owner.emote("spin")
					var/static/list/say_phrases = list(
						"Bugger me, whats all this then?",
						"Sacre bleu! Ou suis-je?!",
						"I knew powering the station using a singularity engine would lead to something like this...",
						"Wow, I can't believe in your universe Cencomm got rid of cloning.",
						"WHAT IS HAPPENING?!",
						"YOU'VE CREATED A TIME PARADOX!",
						"You trying to steal my job?",
						"So that's what I'd look like if I was ugly...",
						"So, two alternate universe twins walk into a bar...",
						"YOU'VE DOOMED THE TIMELINE!",
						"Ruffle a cat once in a while!",
						"I'm starting to get why no one wants to hang out with me.",
						"Why haven't you gotten around to starting that band?!",
						"No!! I was just about to greentext!",
						"Kept you waiting huh?",
						"Oh god I think I'm ODing I'm seeing a fake version of me.",
						"Hey, I remember that phase, glad I grew out of it.",
						"Keep going lets see if more of us show up.",
						"I bet we can finally take the clown now.",
						"LING DISGUISED AS ME!",
						"El psy congroo.",
						"At long last! My evil twin!",
						"Keep going lets see if more of us show up.",
						"No! Dark spirits, do not torment me with these visions of my future self! It's horrible!",
						"Good. Now that the council is assembled the meeting can begin.",
						"Listen! I only have so much time before I'm ripped away. The secret behind the gas giants are...",
						"Das ist nicht deutschland. Das ist nicht akzeptabel!!!",
						"I've come from the future to warn you about eigenstasium! Oh no! I'm too late!",
						"You fool! You took too much eigenstasium! You've doomed us all!",
						"Don't trust any bagels you see until next month!",
						"What...what's with these teleports? It's like one of my Japanese animes...!",
						"Ik stond op het punt om mehki op tafel te zetten, en nu, waar ben ik?",
						"Wake the fuck up spaceman we have a gas giant to burn",
						"This is one hell of a beepsky smash.",
						"Now neither of us will be virgins!")
					alt_clone.say(pick(say_phrases))
				if(2)
					phase_3_cycle = 0 //counter
			phase_3_cycle++
			do_teleport(owner, get_turf(owner), 2, no_effects=TRUE) //Teleports player randomly
			do_sparks(5, FALSE, owner)

		//phase 4
		if(EIGENSTASIUM_PHASE_3_END to INFINITY)
			//clean up and remove status
			SSblackbox.record_feedback("tally", "chemical_reaction", 1, "Eigenstasium wild rides ridden")
			do_sparks(5, FALSE, owner)
			do_teleport(owner, get_turf(owner), 2, no_effects=TRUE) //teleports clone so it's hard to find the real one!
			do_sparks(5, FALSE, owner)
			owner.Sleeping(100)
			owner.Jitter(50)
			to_chat(owner, "<span class='userdanger'>You feel your eigenstate settle, as \"you\" become an alternative version of yourself!</span>")
			owner.emote("me",1,"flashes into reality suddenly, gasping as they gaze around in a bewildered and highly confused fashion!",TRUE)
			log_game("FERMICHEM: [owner] ckey: [owner.key] has become an alternative universe version of themselves.")
			//new you new stuff
			SSquirks.randomise_quirks(owner)
			owner.reagents.remove_all(1000)
			var/datum/component/mood/mood = owner.GetComponent(/datum/component/mood)
			mood.remove_temp_moods() //New you, new moods.
			var/mob/living/carbon/human/human_mob = owner
			SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "Eigentrip", /datum/mood_event/eigentrip)
			if(QDELETED(human_mob))
				return
			if(prob(1))//low chance of the alternative reality returning to monkey
				var/obj/item/organ/tail/monkey/monkey_tail = new ()
				monkey_tail.Insert(human_mob, drop_if_replaced = FALSE)
			var/datum/species/human_species = human_mob.dna?.species
			if(human_species)
				human_species.randomize_main_appearance_element(human_mob)
				human_species.randomize_active_underwear(human_mob)

			owner.remove_status_effect(STATUS_EFFECT_EIGEN)

	//Finally increment cycle
	current_cycle++

/datum/status_effect/eigenstasium/proc/remove_clone_from_var()
	UnregisterSignal(alt_clone, COMSIG_PARENT_QDELETING)

/datum/status_effect/eigenstasium/on_remove()
	if(!QDELETED(alt_clone))//catch any stragilers
		do_sparks(5, FALSE, alt_clone)
		owner.visible_message("One of the [owner]s suddenly phases out of reality in front of you!")
		QDEL_NULL(alt_clone)
	return ..()

#undef EIGENSTASIUM_MAX_BUFFER
#undef EIGENSTASIUM_STABILISATION_RATE
#undef EIGENSTASIUM_PHASE_1_END
#undef EIGENSTASIUM_PHASE_2_END
#undef EIGENSTASIUM_PHASE_3_START
#undef EIGENSTASIUM_PHASE_3_END
