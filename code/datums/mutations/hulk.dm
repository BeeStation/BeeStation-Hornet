//Hulk turns your skin green, and allows you to punch through walls.
/datum/mutation/hulk
	name = "Hulk"
	desc = "A poorly understood genome that causes the holder's muscles to expand, inhibit speech and gives the person a bad skin condition."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	species_allowed = list(SPECIES_HUMAN) //no skeleton/lizard hulk
	mobtypes_allowed = list(/mob/living/carbon/human)
	health_req = 25
	instability = 40
	locked = TRUE
	traits = list(
		TRAIT_STUNIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_CONFUSEIMMUNE,
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_NOSTAMCRIT,
		TRAIT_NOLIMBDISABLE
	)

/datum/mutation/hulk/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "hulk", /datum/mood_event/hulk)
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	owner.update_body_parts()

/datum/mutation/hulk/on_attack_hand(atom/target, proximity)
	if(proximity) //no telekinetic hulk attack
		return target.attack_hulk(owner)

/datum/mutation/hulk/on_life()
	if(owner.health < 0)
		on_losing(owner)
		to_chat(owner, "<span class='danger'>You suddenly feel very weak.</span>")

/datum/mutation/hulk/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "hulk")
	owner.update_body_parts()
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/hulk/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = "[replacetext(message, ".", "!")]!!"
	speech_args[SPEECH_MESSAGE] = message
	return COMPONENT_UPPERCASE_SPEECH
