/datum/action/leech/revive
	name = "Revive"
	desc = "Restore your host's vital functions."
	power_explanation = "Use to revive a downed host. If their injuries are too severe, you will spend time mending them first before completing the revival."
	button_icon_state = "revive"

	cooldown_time = 120 SECONDS
	substrate_cost = 100

	burrow_usage_flags = LEECH_ABILITY_USABLE_BURROWED

/datum/action/leech/revive/can_use()
	var/mob/living/basic/synapse_leech/leech = get_leech()
	var/mob/living/carbon/host = get_host()

	if(!leech || !host)
		return FALSE

	if(!leech.nested)
		return FALSE

	if(host.stat != DEAD)
		leech.balloon_alert(leech, "host is alive!")
		return FALSE

	if(!host.get_organ_by_type(/obj/item/organ/heart))
		leech.balloon_alert(leech, "host has no heart!")
		return FALSE

	if(!host.get_organ_by_type(/obj/item/organ/brain))
		leech.balloon_alert(leech, "host has no brain!")
		return FALSE

	return TRUE

/datum/action/leech/revive/activate_leech_power()
	var/mob/living/basic/synapse_leech/leech = get_leech()
	var/mob/living/carbon/host = get_host()

	// If injuries are too severe for a direct revive, mend them first.
	if(host.getBruteLoss() >= MAX_REVIVE_BRUTE_DAMAGE || host.getFireLoss() >= MAX_REVIVE_FIRE_DAMAGE)
		// Calls do_mending_loop which returns TRUE on success and FALSE if interrupted
		// the ! negates that, so this branch runs when mending failed/interrupted and we should abort the revive by returning FALSE.
		if(!do_mending_loop(leech, host))
			return FALSE

	// Either mending worked a good while ago, and we now revive, or we were in a revivable state to begin with

	return do_revive(leech, host)

/// Heals the host's brute and burn damage in stages until they drop below revival thresholds.
/// Returns TRUE on success, FALSE if interrupted.
/datum/action/leech/revive/proc/do_mending_loop(mob/living/basic/synapse_leech/leech, mob/living/carbon/host)
	to_chat(leech, span_warning("Your host's injuries are too severe to revive directly. You begin mending their wounds..."))
	to_chat(host, span_userdanger("You feel something working through your body, knitting your wounds back together..."))

	while(host.getBruteLoss() >= MAX_REVIVE_BRUTE_DAMAGE || host.getFireLoss() >= MAX_REVIVE_FIRE_DAMAGE)
		// Check each time
		if(QDELETED(host) || QDELETED(leech) || !leech.nested || leech.host != host)
			leech.balloon_alert(leech, "interrupted!")
			return FALSE

		if(host.stat != DEAD)
			leech.balloon_alert(leech, "interrupted!")
			return FALSE

		// NONE movement flags: not interrupted by moving (we are inside the host).
		if(!do_after(leech, 2 SECONDS, host, NONE))
			leech.balloon_alert(leech, "interrupted!")
			return FALSE

		// Check again
		if(QDELETED(host) || QDELETED(leech) || !leech.nested || leech.host != host)
			leech.balloon_alert(leech, "interrupted!")
			return FALSE

		if(host.stat != DEAD)
			leech.balloon_alert(leech, "interrupted!")
			return FALSE

		playsound(host, 'sound/effects/singlebeat.ogg', 5)
		host.adjustBruteLoss(-10, updating_health = FALSE)
		host.adjustFireLoss(-10, updating_health = FALSE)
		host.updatehealth()

		to_chat(leech, span_notice("You mend some of your host's injuries..."))
		to_chat(host, span_userdanger("The wounds across your body begin to close..."))

	return TRUE

/// Performs the final revive
/// Returns TRUE on success, FALSE if interrupted.
/datum/action/leech/revive/proc/do_revive(mob/living/basic/synapse_leech/leech, mob/living/carbon/host)
	to_chat(leech, span_warning("You begin stimulating your host's nervous system..."))
	to_chat(host, span_userdanger("Something deep inside your skull begins to pulse with terrible energy..."))

	if(!do_after(leech, 5 SECONDS, host, NONE))
		leech.balloon_alert(leech, "interrupted!")
		return FALSE

	// Final checks
	if(QDELETED(host) || QDELETED(leech) || !leech.nested || leech.host != host)
		leech.balloon_alert(leech, "interrupted!")
		return FALSE

	if(host.stat != DEAD || !host.can_be_revived())
		leech.balloon_alert(leech, "interrupted!")
		return FALSE

	// If health drifted exactly to the death boundary, nudge up so revive() succeeds.
	if(host.health <= HEALTH_THRESHOLD_DEAD)
		host.adjustOxyLoss(host.health - (HEALTH_THRESHOLD_DEAD + 1), updating_health = TRUE)

	host.set_heartattack(FALSE)
	host.revive()
	host.emote("gasp")
	host.set_jitter_if_lower(20 SECONDS)

	to_chat(leech, span_warning("Your host's vital functions are restored. They live, but you feel them shudder with pain."))
	to_chat(host, span_userdanger("You gasp for air as your body surges back to life!"))

	return TRUE
