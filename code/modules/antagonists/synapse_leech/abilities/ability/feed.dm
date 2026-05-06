/datum/action/leech/feed
	name = "Feed"
	desc = "Feast on the neuronal matter of your host."
	power_explanation = "Use to gain satiety."
	button_icon_state = "feed"

	cooldown_time = 20 SECONDS

	burrow_usage_flags = LEECH_ABILITY_USABLE_BURROWED


/datum/action/leech/feed/can_use()
	var/mob/living/basic/synapse_leech/leech = get_leech()
	var/mob/living/carbon/host = get_host()

	if(!leech || !host)
		return FALSE

	if(!leech.nested)
		return FALSE

	return TRUE

/datum/action/leech/feed/activate_leech_power()
	var/mob/living/basic/synapse_leech/leech = get_leech()
	var/mob/living/carbon/host = get_host()

	to_chat(leech, span_warning("You begin to feed on your host's brain..."))
	to_chat(host, span_userdanger("You suddenly get a huge headache..."))

	// Is this the right way to play sounds only to the leech and host?
	leech.playsound_local(leech, 'sound/synapse_leech/feed.ogg', 80, TRUE)
	host.playsound_local(host, 'sound/synapse_leech/feed.ogg', 80, TRUE)

	if(!do_after(leech, 3 SECONDS, host))
		leech.balloon_alert(leech, "interrupted!")
		return FALSE

	host.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
	leech.adjust_saturation(30)

	to_chat(leech, span_warning("You feel a surge of energy."))
	to_chat(host, span_userdanger("You feel your thoughts slipping away..."))

	return TRUE
