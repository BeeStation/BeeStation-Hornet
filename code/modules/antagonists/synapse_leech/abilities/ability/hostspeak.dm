/datum/action/leech/hostspeak
	name = "Hostspeak"
	desc = "Speak through your host, forcing them to vocalize your thoughts."
	power_explanation = "Enter a message and your host will say it out loud."
	button_icon_state = "hostspeak"

	cooldown_time = 5 SECONDS
	substrate_cost = 5

	burrow_usage_flags = LEECH_ABILITY_USABLE_BURROWED


/datum/action/leech/hostspeak/can_use()
	var/mob/living/basic/synapse_leech/leech = get_leech()
	var/mob/living/carbon/host = get_host()

	if(!leech || !host)
		return FALSE

	if(host.is_mouth_covered() || !isturf(host.loc))
		owner.balloon_alert(owner, "host's mouth is blocked.")
		return FALSE

	if(HAS_TRAIT(host, TRAIT_MUTE))
		owner.balloon_alert(owner, "host cannot speak!")
		return FALSE

	if(!leech.nested)
		return FALSE

	return TRUE

/datum/action/leech/hostspeak/activate_leech_power()
	var/mob/living/carbon/host = get_host()

	var/message = get_message()

	if(!message)
		return FALSE

	to_chat(host, span_warning("You feel compelled to speak..."))
	host.say(message)

	return TRUE

/datum/action/leech/hostspeak/proc/get_message()
	. = TRUE
	var/message = tgui_input_text(owner, "What would you like your host to say?", "Input a command", encode = FALSE, timeout = 2 MINUTES)
	if(QDELETED(src))
		return FALSE
	if(CHAT_FILTER_CHECK(message))
		to_chat(owner, span_warning("The message '[span_boldname("[message]")]' is forbidden!"))
		return FALSE
	if(length_char(message) > 100)
		to_chat(owner, span_warning("Message too long!"))
		return FALSE
	return(message)
