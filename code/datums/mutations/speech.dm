//These are all minor mutations that affect your speech somehow.
//Individual ones aren't commented since their functions should be evident at a glance

/datum/mutation/nervousness
	name = "Nervousness"
	desc = "A hereditary mutation characterized by its signature speech disorder."
	quality = MINOR_NEGATIVE

/datum/mutation/nervousness/on_life(delta_time, times_fired)
	if(DT_PROB(5, delta_time))
		owner.set_stutter_if_lower(20 SECONDS)

/datum/mutation/wacky
	name = "Wacky"
	desc = "A mutation that causes the user to talk in an odd manner."
	quality = MINOR_NEGATIVE

/datum/mutation/wacky/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/wacky/on_losing(mob/living/carbon/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/wacky/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	speech_args[SPEECH_SPANS] |= SPAN_SANS

/datum/mutation/mute
	name = "Mute"
	desc = "Inherited mutation that completely inhibits the vocal section of the brain."
	quality = NEGATIVE
	traits = TRAIT_MUTE

/datum/mutation/smile
	name = "Smile"
	desc = "Hereditary mutation reminiscent of Bipolar Disorder. Characterized by a near constant state of mania and an apathy towards negative stimuli."
	quality = MINOR_NEGATIVE

/datum/mutation/smile/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/smile/on_losing(mob/living/carbon/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/smile/proc/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = " [message] "
		//Time for a friendly game of SS13
		message = replacetext(message," stupid "," smart ")
		message = replacetext(message," unrobust "," robust ")
		message = replacetext(message," dumb "," smart ")
		message = replacetext(message," awful "," great ")
		message = replacetext(message," gay ",pick(" nice "," ok "," alright "))
		message = replacetext(message," horrible "," fun ")
		message = replacetext(message," terrible "," terribly fun ")
		message = replacetext(message," terrifying "," wonderful ")
		message = replacetext(message," gross "," cool ")
		message = replacetext(message," disgusting "," amazing ")
		message = replacetext(message," loser "," winner ")
		message = replacetext(message," useless "," useful ")
		message = replacetext(message," oh god "," cheese and crackers ")
		message = replacetext(message," jesus "," gee wiz ")
		message = replacetext(message," weak "," strong ")
		message = replacetext(message," kill "," hug ")
		message = replacetext(message," murder "," tease ")
		message = replacetext(message," ugly "," beautiful ")
		message = replacetext(message," douchbag "," nice guy ")
		message = replacetext(message," douchebag "," nice guy ")
		message = replacetext(message," whore "," lady ")
		message = replacetext(message," nerd "," smart guy ")
		message = replacetext(message," moron "," fun person ")
		message = replacetext(message," IT'S LOOSE "," EVERYTHING IS FINE ")
		message = replacetext(message," sex "," hug fight ")
		message = replacetext(message," idiot "," genius ")
		message = replacetext(message," fat "," thin ")
		message = replacetext(message," beer "," water with ice ")
		message = replacetext(message," drink "," water ")
		message = replacetext(message," feminist "," empowered woman ")
		message = replacetext(message," i hate you "," you're mean ")
		message = replacetext(message," jew "," jewish ")
		message = replacetext(message," shit "," shiz ")
		message = replacetext(message," crap "," poo ")
		message = replacetext(message," slut "," tease ")
		message = replacetext(message," ass "," butt ")
		message = replacetext(message," damn "," dang ")
		message = replacetext(message," fuck ","  ")
		message = replacetext(message," penis "," privates ")
		message = replacetext(message," cunt "," privates ")
		message = replacetext(message," dick "," jerk ")
		message = replacetext(message," vagina "," privates ")
		speech_args[SPEECH_MESSAGE] = trim(message)


/datum/mutation/unintelligible
	name = "Unintelligible"
	desc = "Hereditary mutation that partially inhibits the vocal center of the brain, resulting in a severe speech disorder."
	quality = NEGATIVE
	traits = TRAIT_UNINTELLIGIBLE_SPEECH

/datum/mutation/swedish
	name = "Swedish"
	desc = "A horrible mutation originating from the distant past. Thought to be eradicated after the incident in 2037."
	quality = MINOR_NEGATIVE

/datum/mutation/swedish/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/swedish/on_losing(mob/living/carbon/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/swedish/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	handle_accented_speech(speech_args, SWEDISH_TALK_FILE)

/datum/mutation/chav
	name = "Chav"
	desc = "A mutation that causes the user to construct sentences in a more rudimentary manner."
	quality = MINOR_NEGATIVE

/datum/mutation/chav/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/chav/on_losing(mob/living/carbon/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/chav/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	handle_accented_speech(speech_args, ROADMAN_TALK_FILE)


/datum/mutation/elvis
	name = "Elvis"
	desc = "A terrifying mutation named after its 'patient-zero'."
	quality = MINOR_NEGATIVE
	locked = TRUE

/datum/mutation/elvis/on_life(delta_time, times_fired)
	switch(pick(1,2))
		if(1)
			if(DT_PROB(7.5, delta_time))
				var/list/dancetypes = list("swinging", "fancy", "stylish", "20'th century", "jivin'", "rock and roller", "cool", "salacious", "bashing", "smashing")
				var/dancemoves = pick(dancetypes)
				owner.visible_message("<b>[owner]</b> busts out some [dancemoves] moves!")
		if(2)
			if(DT_PROB(7.5, delta_time))
				owner.visible_message("<b>[owner]</b> [pick("jiggles their hips", "rotates their hips", "gyrates their hips", "taps their foot", "dances to an imaginary song", "jiggles their legs", "snaps their fingers")]!")

/datum/mutation/elvis/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/elvis/on_losing(mob/living/carbon/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/elvis/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = " [message] "
		message = replacetext(message," i'm not "," I ain't ")
		message = replacetext(message," girl ",pick(" honey "," baby "," baby doll "))
		message = replacetext(message," man ",pick(" son "," buddy "," brother"," pal "," friendo "))
		message = replacetext(message," out of "," outta ")
		message = replacetext(message," thank you "," thank you, thank you very much ")
		message = replacetext(message," thanks "," thank you, thank you very much ")
		message = replacetext(message," what are you "," whatcha ")
		message = replacetext(message," yes ",pick(" sure", "yea "))
		message = replacetext(message," muh valids "," my kicks ")
		speech_args[SPEECH_MESSAGE] = trim(message)


/datum/mutation/stoner
	name = "Stoner"
	desc = "A common mutation that severely decreases intelligence."
	quality = NEGATIVE
	locked = TRUE

/datum/mutation/stoner/on_acquiring(mob/living/carbon/owner)
	..()
	owner.grant_language(/datum/language/beachbum, source = LANGUAGE_STONER)
	owner.add_blocked_language(subtypesof(/datum/language) - /datum/language/beachbum, LANGUAGE_STONER)

/datum/mutation/stoner/on_losing(mob/living/carbon/owner)
	..()
	owner.remove_language(/datum/language/beachbum, source = LANGUAGE_STONER)
	owner.remove_blocked_language(subtypesof(/datum/language) - /datum/language/beachbum, LANGUAGE_STONER)

/datum/mutation/medieval
	name = "Medieval"
	desc = "A horrific genetic condition suffered in ancient times."
	quality = MINOR_NEGATIVE

/datum/mutation/medieval/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/medieval/on_losing(mob/living/carbon/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/medieval/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	handle_accented_speech(speech_args, MEDIEVAL_SPEECH_FILE)
