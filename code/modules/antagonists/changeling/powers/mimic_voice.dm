/datum/action/changeling/mimicvoice
	name = "Mimic Voice"
	desc = "We shape our vocal glands to sound like a desired voice. Maintaining this power slows chemical production."
	button_icon_state = "mimic_voice"
	helptext = "Will turn your voice into the name that you enter."
	chemical_cost = 0
	dna_cost = 1
	req_human = 1

// Fake Voice
/datum/action/changeling/mimicvoice/sting_action(mob/user)
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(changeling.mimicing)
		changeling.mimicing = ""
		to_chat(user, "<span class='notice'>We return our vocal glands to their original position.</span>")
		return

	var/mimic_voice = sanitize_name(stripped_input(user, "Enter a name to mimic.", "Mimic Voice", null, MAX_NAME_LEN))
	if(!mimic_voice)
		return
	..()
	changeling.mimicing = mimic_voice
	to_chat(user, "<span class='notice'>We shape our glands to take the voice of <b>[mimic_voice]</b>, this will slow down regenerating chemicals while active.</span>")
	to_chat(user, "<span class='notice'>Use this power again to return to our original voice and return chemical production to normal levels.</span>")
	return TRUE
