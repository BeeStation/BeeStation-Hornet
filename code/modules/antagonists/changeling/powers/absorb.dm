/datum/action/changeling/absorbDNA
	name = "Absorb DNA"
	desc = "Absorb the DNA of our victim. Requires us to strangle them."
	button_icon_state = "absorb_dna"
	chemical_cost = 0
	dna_cost = 0
	req_human = TRUE
	///if we're currently absorbing, used for sanity
	var/is_absorbing = FALSE

/datum/action/changeling/absorbDNA/can_sting(mob/living/carbon/user)
	if(!..())
		return

	if(is_absorbing)
		owner.balloon_alert(owner, "already absorbing!")
		return

	if(!owner.pulling || !iscarbon(owner.pulling))
		owner.balloon_alert(owner, "needs grab!")
		return
	if(owner.grab_state <= GRAB_NECK)
		owner.balloon_alert(owner, "needs tighter grip!")
		return

	var/mob/living/carbon/target = owner.pulling
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(owner)
	return changeling.can_absorb_dna(target)

/datum/action/changeling/absorbDNA/sting_action(mob/owner)
	SHOULD_CALL_PARENT(FALSE)

	var/datum/antagonist/changeling/changeling = IS_CHANGELING(owner)
	var/mob/living/carbon/human/target = owner.pulling
	is_absorbing = TRUE

	if(!attempt_absorb(target))
		return

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("Absorb DNA", "4"))
	owner.visible_message(span_danger("[owner] sucks the fluids from [target]!"), span_notice("We have absorbed [target]."))
	to_chat(target, span_userdanger("You are absorbed by the changeling!"))

	if(!changeling.has_profile_with_dna(target.dna))
		changeling.add_new_profile(target)

	if(owner.nutrition < NUTRITION_LEVEL_WELL_FED)
		owner.set_nutrition(min((owner.nutrition + target.nutrition), NUTRITION_LEVEL_WELL_FED))

	// Absorb a lizard, speak Draconic.
	owner.copy_languages(target, LANGUAGE_ABSORB)

	if(target.mind && owner.mind)//if the victim and owner have minds
		absorb_memories(target)

	is_absorbing = FALSE

	changeling.adjust_chemicals(10)
	changeling.can_respec = TRUE

	if(target.stat != DEAD)
		target.investigate_log("has died from being changeling absorbed.", INVESTIGATE_DEATHS)
	target.death(FALSE)
	target.Drain()
	return TRUE

/datum/action/changeling/absorbDNA/proc/absorb_memories(mob/living/carbon/human/target)
	var/datum/mind/suckedbrain = target.mind
	owner.mind.memory += "<BR><b>We've absorbed [target]'s memories into our own...</b><BR>[suckedbrain.memory]<BR>"
	for(var/A in suckedbrain.antag_datums)
		var/datum/antagonist/antag_types = A
		var/list/all_objectives = antag_types.objectives.Copy()
		if(antag_types.antag_memory)
			owner.mind.memory += "[antag_types.antag_memory]<BR>"
		if(LAZYLEN(all_objectives))
			owner.mind.memory += "<B>Objectives:</B>"
			var/obj_count = 1
			for(var/O in all_objectives)
				var/datum/objective/objective = O
				owner.mind.memory += "<br><B>Objective #[obj_count++]</B>: [objective.explanation_text]"
				var/list/datum/mind/other_owners = objective.get_owners() - suckedbrain
				if(other_owners.len)
					owner.mind.memory += "<ul>"
					for(var/mind in other_owners)
						var/datum/mind/M = mind
						owner.mind.memory += "<li>Conspirator: [M.name]</li>"
					owner.mind.memory += "</ul>"
	owner.mind.memory += "<b>That's all [target] had.</b><BR>"
	owner.memory() //I can read your mind, kekeke. Output all their notes.

	//Some of target's recent speech, so the changeling can attempt to imitate them better.
	//Recent as opposed to all because rounds tend to have a LOT of text.

	var/list/recent_speech = list()
	var/list/say_log = list()
	var/log_source = target.logging
	for(var/log_type in log_source)
		var/nlog_type = text2num(log_type)
		if(nlog_type & LOG_SAY)
			var/list/reversed = log_source[log_type]
			if(islist(reversed))
				say_log = reverse_range(reversed.Copy())
				break

	if(LAZYLEN(say_log) > LING_ABSORB_RECENT_SPEECH)
		recent_speech = say_log.Copy(say_log.len-LING_ABSORB_RECENT_SPEECH+1,0) //0 so len-LING_ARS+1 to end of list
	else
		for(var/spoken_memory in say_log)
			if(recent_speech.len >= LING_ABSORB_RECENT_SPEECH)
				break
			recent_speech[spoken_memory] = say_log[spoken_memory]

	var/datum/antagonist/changeling/changeling = IS_CHANGELING(owner)
	if(recent_speech.len && changeling)
		changeling.antag_memory += "<B>Some of [target]'s speech patterns, we should study these to better impersonate [target.p_them()]!</B><br>"
		to_chat(owner, span_boldnotice("Some of [target]'s speech patterns, we should study these to better impersonate [target.p_them()]!"))
		for(var/spoken_memory in recent_speech)
			changeling.antag_memory += "\"[recent_speech[spoken_memory]]\"<br>"
			to_chat(owner, span_notice("\"[recent_speech[spoken_memory]]\""))
		changeling.antag_memory += "<B>We have no more knowledge of [target]'s speech patterns.</B><br>"
		to_chat(owner, span_boldnotice("We have no more knowledge of [target]'s speech patterns."))


	var/datum/antagonist/changeling/target_ling = IS_CHANGELING(target)
	if(target_ling)//If the target was a changeling, suck out their extra juice and objective points!
		to_chat(owner, span_boldnotice("[target] was one of us. We have absorbed their power."))

		// Gain half of their genetic points.
		var/genetic_points_to_add = round(target_ling.total_genetic_points / 2)
		changeling.genetic_points += genetic_points_to_add
		changeling.total_genetic_points += genetic_points_to_add

		// And half of their chemical charges.
		var/chems_to_add = round(target_ling.total_chem_storage / 2)
		changeling.adjust_chemicals(chems_to_add)
		changeling.total_chem_storage += chems_to_add

		// And of course however many they've absorbed, we've absorbed
		changeling.absorbed_count += target_ling.absorbed_count

		// Lastly, make them not a ling anymore. (But leave their objectives for round-end purposes).
		var/list/copied_objectives = target_ling.objectives.Copy()
		target.mind.remove_antag_datum(/datum/antagonist/changeling)
		var/datum/antagonist/fallen_changeling/fallen = target.mind.add_antag_datum(/datum/antagonist/fallen_changeling)
		fallen.objectives = copied_objectives

/datum/action/changeling/absorbDNA/proc/attempt_absorb(mob/living/carbon/human/target)
	for(var/absorbing_iteration in 1 to 3)
		switch(absorbing_iteration)
			if(1)
				to_chat(owner, span_notice("This creature is compatible. We must hold still..."))
			if(2)
				owner.visible_message(span_warning("[owner] extends a proboscis!"), span_notice("We extend a proboscis."))
			if(3)
				owner.visible_message(span_danger("[owner] stabs [target] with the proboscis!"), span_notice("We stab [target] with the proboscis."))
				to_chat(target, span_userdanger("You feel a sharp stabbing pain!"))
				target.take_overall_damage(40)

		SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("Absorb DNA", "[absorbing_iteration]"))
		if(!do_after(owner, 15 SECONDS, target, hidden = TRUE))
			owner.balloon_alert(owner, "interrupted!")
			is_absorbing = FALSE
			return FALSE
	return TRUE
