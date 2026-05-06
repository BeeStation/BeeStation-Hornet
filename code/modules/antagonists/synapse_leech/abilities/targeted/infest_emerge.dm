/datum/action/leech/targeted/infest_emerge
	name = "Infest or Emerge"
	desc = "Infest a suitable host, or emerge from your current host."
	power_explanation = "Click on an adjacent carbon to attempt to infest their skull and become their parasite. Activating again while burrowed will let you emerge."
	button_icon_state = "burrow"

	target_range = 1
	cooldown_time = 5 SECONDS
	saturation_cost = 10
	prefire_message = "Select a host to infest..."
	// This ability doubles as the "emerge" button while we are nested, so it must
	// be usable regardless of state.
	burrow_usage_flags = LEECH_ABILITY_USABLE_ALWAYS

	/// How long each of the three stages takes.
	var/burrow_stage_time = 5 SECONDS
	/// How long the emerge sequence takes.
	var/emerge_time = 10 SECONDS

/// Override for if we're already burrowed
/datum/action/leech/targeted/infest_emerge/set_click_ability(mob/on_who)
	var/mob/living/basic/synapse_leech/leech = get_leech()
	if(leech?.nested || leech?.host)
		try_emerge(leech)
		// Don't do targeting, the action is now just a button press
		return FALSE
	return ..()

/datum/action/leech/targeted/infest_emerge/is_valid_target(atom/target)
	if(!iscarbon(target))
		return FALSE
	var/mob/living/basic/synapse_leech/leech = get_leech()
	if(target == leech)
		return FALSE
	var/mob/living/carbon/victim = target
	// Helmets / hardsuits / anything covering the head blocks the burrow.
	if(victim.get_item_by_slot(ITEM_SLOT_HEAD))
		leech.balloon_alert(leech, "head is covered!")
		return FALSE
	return TRUE

/datum/action/leech/targeted/infest_emerge/on_target(mob/living/basic/synapse_leech/leech, atom/target)
	var/mob/living/carbon/victim = target
	if(leech.nested || leech.host)
		leech.balloon_alert(leech, "already burrowed!")
		return FALSE

	return do_burrow(leech, victim)

/// Runs the 3-stage burrow sequence. Returns TRUE on success, FALSE on interruption.
/datum/action/leech/targeted/infest_emerge/proc/do_burrow(mob/living/basic/synapse_leech/leech, mob/living/carbon/victim)
	// Stage 1: skin piercing
	leech.visible_message(
		span_warning("[leech] latches onto [victim]'s scalp and begins chewing through the skin!"),
		span_notice("You sink your mandibles into [victim]'s scalp..."),
		span_warning("You hear a wet, tearing sound."),
	)
	to_chat(victim, span_userdanger("Something is gnawing at your scalp!"))

	playsound(victim, 'sound/effects/meatslap.ogg', 60, TRUE)

	if(!do_after(leech, burrow_stage_time, victim))
		leech.balloon_alert(leech, "interrupted!")
		return FALSE

	victim.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
	victim.add_bleeding(BLEED_SURFACE)

	if(!burrow_target_still_valid(leech, victim))
		return FALSE

	// Stage 2: Skull Cracking
	leech.visible_message(
		span_warning("[leech] cracks through [victim]'s skull with a sickening crunch!"),
		span_notice("You crack apart [victim]'s skull, exposing the soft tissue beneath..."),
		span_warning("You hear a horrible cracking noise."),
	)
	to_chat(victim, span_userdanger("Something is breaking through your skull!"))

	playsound(victim, 'sound/surgery/hemostat1.ogg', 70, TRUE)

	if(!do_after(leech, burrow_stage_time, victim))
		leech.balloon_alert(leech, "interrupted!")
		return FALSE

	victim.apply_damage(20, BRUTE, BODY_ZONE_HEAD)
	victim.add_bleeding(BLEED_CRITICAL)
	victim.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)

	if(!burrow_target_still_valid(leech, victim))
		return FALSE

	// Stage 3: hop on in
	leech.visible_message(
		span_warning("[leech] writhes and crawls deep into [victim]'s skull!"),
		span_notice("You writhe deeper into [victim]'s skull, settling into their nervous system..."),
		span_warning("You hear something wet and squirming."),
	)
	to_chat(victim, span_userdanger("Something is crawling inside your head!"))

	playsound(victim, 'sound/surgery/organ2.ogg', 80, TRUE)

	victim.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
	victim.adjustOrganLoss(ORGAN_SLOT_BRAIN, 30)

	if(!do_after(leech, burrow_stage_time, victim))
		leech.balloon_alert(leech, "interrupted!")
		return FALSE

	if(!burrow_target_still_valid(leech, victim))
		return FALSE

	// We're in.
	playsound(victim, 'sound/ambience/antag/ling_aler.ogg', 60, TRUE)
	victim.visible_message(
		span_userdanger("[leech] disappears inside [victim]'s skull!"),
		span_userdanger("You feel something settle into your brain. You are not alone in your own head."),
	)
	finish_burrow(leech, victim)
	return TRUE

/// validity check between stages
/datum/action/leech/targeted/infest_emerge/proc/burrow_target_still_valid(mob/living/basic/synapse_leech/leech, mob/living/carbon/victim)
	if(QDELETED(victim) || QDELETED(leech))
		return FALSE
	if(!leech.Adjacent(victim))
		leech.balloon_alert(leech, "out of reach!")
		return FALSE
	if(victim.get_item_by_slot(ITEM_SLOT_HEAD))
		leech.balloon_alert(leech, "head is covered!")
		return FALSE
	return TRUE

/// Actually places the leech inside the host
/datum/action/leech/targeted/infest_emerge/proc/finish_burrow(mob/living/basic/synapse_leech/leech, mob/living/carbon/victim)
	// Put in
	leech.host = victim
	leech.nested = TRUE
	leech.forceMove(victim)

	// Imagine some kinda secretion to clot the wound.
	victim.suppress_bloodloss(5)
	leech.RegisterSignal(victim, COMSIG_QDELETING, TYPE_PROC_REF(/mob/living/basic/synapse_leech, on_host_qdel))
	leech.RegisterSignal(victim, COMSIG_LIVING_DEATH, TYPE_PROC_REF(/mob/living/basic/synapse_leech, on_host_death))
	button_icon_state = "emerge"
	leech.refresh_leech_actions()

/// Confirms the user wants to emerge, then runs the emerge sequence.
/datum/action/leech/targeted/infest_emerge/proc/try_emerge(mob/living/basic/synapse_leech/leech)
	var/mob/living/carbon/host = leech.host
	if(!host || QDELETED(host))
		// clean up on aisle four
		leech.clear_host_state()
		return
	if(tgui_alert(leech, "Emerge from [host]? This will be loud and obvious.", "Emerge", list("Yes", "No")) != "Yes")
		return
	// Re-check after the prompt as things may have changed during the dialog.
	if(!leech.nested || leech.host != host || QDELETED(host))
		return
	do_emerge(leech, host)

/// Runs the emerge sequence.
/datum/action/leech/targeted/infest_emerge/proc/do_emerge(mob/living/basic/synapse_leech/leech, mob/living/carbon/host)
	host.visible_message(
		span_userdanger("[host]'s skull cracks and squirms as something inside tries to get out!"),
		span_userdanger("Something is forcing its way out of your skull!"),
	)
	playsound(host, 'sound/surgery/organ2.ogg', 80, TRUE)
	if(!do_after(leech, emerge_time, host))
		leech.balloon_alert(leech, "interrupted!")
		return FALSE

	var/turf/exit_turf = get_turf(host)
	if(!exit_turf)
		leech.balloon_alert(leech, "no way out!")
		return FALSE

	playsound(host, 'sound/ambience/antag/ling_aler.ogg', 60, TRUE)
	host.visible_message(
		span_userdanger("[leech] bursts out of [host]'s skull in a spray of gore!"),
		span_userdanger("[leech] tears its way out of your head!"),
	)
	host.apply_damage(40, BRUTE, BODY_ZONE_HEAD)
	host.adjustOrganLoss(ORGAN_SLOT_BRAIN, 100)
	host.add_bleeding(BLEED_CRITICAL)

	leech.forceMove(exit_turf)
	leech.clear_host_state()

	button_icon_state = "burrow"

	pay_cost()
	start_cooldown()
	return TRUE
