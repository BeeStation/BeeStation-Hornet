/mob/verb/reckon_verb(msg as text)
	set category = "IC"
	set name = "Reckon"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)
		return
	if(usr.client)
		if(usr.client.prefs.muted & MUTE_RECKON)
			to_chat(usr, "<span class='danger'>You cannot reckon (muted).</span>")
			return
		if(src.client.handle_spam_prevention(msg,MUTE_RECKON))
			return
	reckon(msg)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Reckon")

/mob/proc/reckon(message, forced=FALSE)
	if(!can_reckon())
		return
	log_reckon("[src.key]/([src.name]): [message]")
	log_talk(message, LOG_SAY, tag="reckon", forced_by=forced ? "a thought-compelling" : "")
	reckon_message_to_chat(message, forced)
	reckon_message_to_mindreaders(message, forced=forced)

// hypnosis is bad for thinking to carbon creature
/mob/living/carbon/reckon(message, forced=FALSE)
	if(!can_reckon())
		return
	var/force_source = forced ? "a thought-compelling" : ""
	var/datum/brain_trauma/hypnosis/your_hypnosis
	for(var/datum/brain_trauma/hypnosis/thing in get_traumas()) // easy way to grab the thing
		your_hypnosis = thing
	var/is_hypnotic_message = FALSE
	if(your_hypnosis && prob(20)) // corrupts your original thought
		log_reckon("[src.key]/([src.name]): (original thought) [message]")
		message = your_hypnosis.hypnotic_phrase
		is_hypnotic_message = TRUE
		force_source = forced ? "FORCE-hypnosis": "weak-hypnosis"
		log_reckon("[src.key]/([src.name]): (hypnotically manipulated) [message]")
	else
		log_reckon("[src.key]/([src.name]): [message]")
	log_talk(message, LOG_SAY, tag="reckon", forced_by=force_source)

	reckon_message_to_chat(message, forced, is_hypnotic_message)
	reckon_message_to_mindreaders(message, forced=forced, hypnotic=is_hypnotic_message) // not wrapped with hypnotic span - less suspicious

/mob/proc/reckon_message_to_chat(message, forced, hypnotic=FALSE)
	if(!can_reckon(forced))
		return
	for(var/mob/dead/observer/ghost_hearer in GLOB.player_list)
		if(forced)
			break
		var/follow_link = FOLLOW_LINK(ghost_hearer, src)
		to_chat(ghost_hearer, "[follow_link] <span class='reckon'>[src.mind.name] hypnotically reckons, '[message]'</span>")
	if(hypnotic)
		message = "<span class='hypnophrase'>[message]</span>"
	to_chat(src, "<span class='reckon'>You reckon, '[message]'</span>")

/mob/proc/can_reckon(forced=FALSE)
	if(src.stat == DEAD)
		return FALSE
	if(!forced && src.stat >= UNCONSCIOUS)
		return FALSE
	return TRUE

/mob/dead/can_reckon(forced=FALSE)
	return FALSE
