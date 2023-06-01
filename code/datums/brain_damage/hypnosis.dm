/datum/brain_trauma/hypnosis
	name = "Hypnosis"
	desc = "Patient's unconscious is completely enthralled by a word or sentence, focusing their thoughts and actions on it."
	scan_desc = "looping thought pattern"
	gain_text = ""
	lose_text = ""
	resilience = TRAUMA_RESILIENCE_SURGERY
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM
	var/hypnotic_phrase = ""
	var/regex/target_phrase

/datum/brain_trauma/hypnosis/New(phrase)
	if(!phrase)
		qdel(src)
	hypnotic_phrase = phrase
	try
		target_phrase = new("(\\b[hypnotic_phrase]\\b)","ig")
	catch(var/exception/e)
		stack_trace("[e] on [e.file]:[e.line]")
		qdel(src)
	..()

/datum/brain_trauma/hypnosis/on_gain()
	hypnotize(owner, hypnotic_phrase)
	..()

/datum/brain_trauma/hypnosis/on_lose()
	message_admins("[ADMIN_LOOKUPFLW(owner)] is no longer hypnotized with the phrase '[hypnotic_phrase]'.")
	log_game("[key_name(owner)] is no longer hypnotized with the phrase '[hypnotic_phrase]'.")
	owner.log_message("is no longer hypnotized with the phrase '[hypnotic_phrase]'.", LOG_ATTACK, color="red")
	to_chat(owner, "<span class='userdanger'>You suddenly snap out of your hypnosis. The phrase '[hypnotic_phrase]' no longer feels important to you.</span>")
	owner.clear_alert("hypnosis")
	var/datum/mind/M = owner.mind
	var/datum/antagonist/hypnotized/B = M.has_antag_datum(/datum/antagonist/hypnotized)
	if(!B)
		return
	for(var/O in hypnotic_phrase)
		var/datum/objective/hypnotized/objective = new(O)
		B.objectives -= objective
	M.remove_antag_datum(/datum/antagonist/hypnotized)

/datum/brain_trauma/hypnosis/on_life()
	..()
	if(prob(2))
		switch(rand(1,2))
			if(1)
				to_chat(owner, "<i>...[lowertext(hypnotic_phrase)]...</i>")
			if(2)
				new /datum/hallucination/chat(owner, TRUE, FALSE, "<span class='hypnophrase'>[hypnotic_phrase]</span>")

/datum/brain_trauma/hypnosis/handle_hearing(datum/source, list/hearing_args)
	hearing_args[HEARING_RAW_MESSAGE] = target_phrase.Replace(hearing_args[HEARING_RAW_MESSAGE], "<span class='hypnophrase'>$1</span>")

/// A "hardened" variant of the hypnosis trauma, used by hypnoflashes so that nanites can't cure it.
/datum/brain_trauma/hypnosis/hardened
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM | TRAUMA_SPECIAL_CURE_PROOF
