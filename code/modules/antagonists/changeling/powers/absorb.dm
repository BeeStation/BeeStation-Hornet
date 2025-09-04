/datum/action/changeling/absorbDNA
	name = "Absorb DNA"
	desc = "Absorb the DNA of our victim. Requires us to strangle them."
	button_icon_state = "absorb_dna"
	chemical_cost = 0
	dna_cost = 0
	req_human = TRUE
	///if we're currently absorbing, used for sanity
	var/is_absorbing = FALSE

/datum/action/changeling/absorbDNA/ling_can_cast(mob/living/carbon/user)
	if(!..())
		return

	if(is_absorbing)
		owner.balloon_alert(owner, "already absorbing!")
		return

	if(!owner.pulling || !iscarbon(owner.pulling))
		owner.balloon_alert(owner, "needs grab!")
		return

	var/mob/living/carbon/target = owner.pulling
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(owner)
	return changeling.can_absorb_dna(target)

/datum/action/changeling/absorbDNA/sting_action(mob/living/carbon/owner)
	SHOULD_CALL_PARENT(FALSE)

	var/datum/antagonist/changeling/changeling = IS_CHANGELING(owner)
	var/mob/living/carbon/human/target = owner.pulling
	is_absorbing = TRUE

	if(!attempt_absorb(target))
		return

	if(!changeling.has_profile_with_dna(target.dna))
		changeling.add_new_profile(target)

	if(owner.nutrition < NUTRITION_LEVEL_WELL_FED)
		owner.set_nutrition(min((owner.nutrition + target.nutrition), NUTRITION_LEVEL_WELL_FED))

	// Absorb a lizard, speak Draconic.
	owner.copy_languages(target, LANGUAGE_ABSORB)

	if(target.mind && owner.mind)//if the victim and owner have minds
		absorb_ling_power(target)

	is_absorbing = FALSE

	if(target.stat != DEAD)
		target.investigate_log("has died from being changeling absorbed.", INVESTIGATE_DEATHS)

	switch(changeling.total_chem_storage)
		if(35 to 45)
			target.soft_drain()
		if(46 to 70)	// Third drain on a normal person will cause this.
			target.changeling_drain()
		if(71 to INFINITY)
			target.master_drain()

	// Changeling gains chems, 50 more than cap.
	changeling.adjust_chemicals(100, changeling.total_chem_storage + 50)
	owner.blood_volume += 300	// We drain blood because its cool and useful!
	if(target.mind)
		changeling.genetic_points += 1
		changeling.total_chem_storage += 10
		to_chat(owner, span_notice("We have drained [target] and gained 1 genetic point <span class='cfc_cyan'>Total</span>: <span class='cfc_green'>[changeling.genetic_points]</span>."))
	else
		changeling.genetic_points += 0.5
		changeling.total_chem_storage += 5
		to_chat(owner, span_notice("We have drained [target] and gained half a genetic point. Absent-minded targets are less... nutricious... <span class='cfc_cyan'>Total</span>: <span class='cfc_green'>[changeling.genetic_points]</span>."))

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("Absorb DNA", "4"))
	owner.balloon_alert_to_viewers("<font color='#ff0040'>SLURP!</font>")
	owner.visible_message(span_danger("[target] was drained!"))
	to_chat(target, span_userdanger("You are drained by the changeling!"))

	playsound(owner, 'sound/items/drink.ogg', 35, TRUE)
	playsound(owner, 'sound/surgery/organ2.ogg', 50)
	return TRUE

/datum/action/changeling/absorbDNA/proc/absorb_ling_power(mob/living/carbon/human/target)
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
				playsound(owner, 'sound/creatures/rattle.ogg', 10)
			if(2)
				owner.visible_message(span_warning("[owner] extends a proboscis!"), span_notice("We extend a proboscis."))
				playsound(owner, 'sound/creatures/venus_trap_death.ogg', 20)
			if(3)
				owner.visible_message(span_danger("[owner] stabs [target] with the proboscis!"), span_notice("We stab [target] with the proboscis."))
				to_chat(target, span_userdanger("You feel a sharp stabbing pain!"))
				playsound(owner, 'sound/creatures/venus_trap_hit.ogg', 30)
				target.take_overall_damage(40)

		SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("Absorb DNA", "[absorbing_iteration]"))
		if(!do_after(owner, 2 SECONDS, target))
			owner.balloon_alert(owner, "interrupted!")
			is_absorbing = FALSE
			return FALSE
	return TRUE
