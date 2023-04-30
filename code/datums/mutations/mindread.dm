/datum/mutation/mindread
	name = "Mindread"
	desc = "A mutation that allows the user to read nearby people's thoughts and prays."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	instability = 20
	locked = TRUE

/datum/mutation/mindread/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_MINDREAD, GENETIC_MUTATION)

/datum/mutation/mindread/on_losing(mob/living/carbon/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_MINDREAD, GENETIC_MUTATION)

/mob/proc/reckon_message_to_mindreaders(message, subject="someone", verbtype="reckons,", comma="\'", datum/language/language=null, forced=FALSE, hypnotic=FALSE)
	if(!can_reckon(forced))
		return
	var/mindreaders = list()
	for(var/mob/living/mindreader in get_hearers_in_view(7, src, SEE_INVISIBLE_MAXIMUM))
		if(!HAS_TRAIT(mindreader, TRAIT_MINDREAD) || !mindreader.mind || mindreader == src)
			continue
		if(language && !mindreader.has_language(language))
			to_chat(mindreader, "<span class='reckon'>You notice [subject] [verbtype] but you can't understand it.</span>")
			continue
		mindreaders += mindreader
		if(!length(message))
			to_chat(mindreader, "<span class='reckon'>You notice [subject] [verbtype]</span>") // someone dreams...
			continue

		// the message must be hyonotic, and the source should reckon it not by their will(forced flag)
		if(hypnotic && forced && !HAS_TRAIT(mindreader, TRAIT_MINDSHIELD) && prob(75))
			message = "<span class='hypnophrase'>[message]</span>"
			to_chat(mindreader, "<span class='reckon'>You notice [subject] [verbtype] [comma][message][comma]</span>")
			if(mindreader.mind.has_antag_datum(/datum/antagonist/hypnotized)) // skip if you're already hypnotised
				continue
			mindreader.log_message("has vulnerably mindread a hypnotic message '[message]'.", LOG_ATTACK, color="red")
			log_game("[key_name(mindreader)] has vulnerably mindread a hypnotic message '[message]'.")
			hypnotize(mindreader, message) // reading a hypnotic thought is a bad idea even if you didn't intend
		else
			to_chat(mindreader, "<span class='reckon'>You notice [subject] [verbtype] [comma][message][comma]</span>")
	if(length(mindreaders) && message)
		log_reckon("their message '[message]' has been mindread by [english_list(mindreaders)].")
