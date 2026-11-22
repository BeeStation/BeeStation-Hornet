/datum/saymode
	/// The symbol key used to enable this say mode.
	var/key
	/// The corresponding say mode string.
	var/mode
	/// Whether this say mode works with custom say emotes.
	var/allows_custom_say_emotes = FALSE

/// Checks whether this saymode can be used by the given user. May send feedback.
/datum/saymode/proc/can_be_used_by(mob/living/user)
	return TRUE

/**
 * Handles actually modifying or forwarding our message.
 * Returns `SAYMODE_[X]` flags.
 *
 * user - The living speaking using this say mode.
 * message - The message to be said.
 * spans - A list of spans to attach to the message.
 * language - The language the message was said in.
 * message_mods - A list of message modifiers, i.e. whispering/singing.
 */
/datum/saymode/proc/handle_message(
	mob/living/user,
	message,
	list/spans = list(),
	datum/language/language,
	list/message_mods = list()
)
	return NONE

/datum/saymode/xeno
	key = MODE_KEY_ALIEN
	mode = MODE_ALIEN

/datum/saymode/xeno/can_be_used_by(mob/living/user)
	if(!user.hivecheck() && !(FACTION_CARP in user.faction))
		return FALSE
	return TRUE

/datum/saymode/xeno/handle_message/handle_message(
	mob/living/user,
	message,
	list/spans = list(),
	datum/language/language,
	list/message_mods = list()
)
	if(user.hivecheck())
		user.alien_talk(message, spans, message_mods)
	else
		user.carp_talk(message, spans, message_mods)
	return SAYMODE_MESSAGE_HANDLED

/datum/saymode/vocalcords
	key = MODE_KEY_VOCALCORDS
	mode = MODE_VOCALCORDS

/datum/saymode/vocalcords
	key = MODE_KEY_VOCALCORDS
	mode = MODE_VOCALCORDS

/datum/saymode/vocalcords/can_be_used_by(mob/living/user)
	if(!iscarbon(user))
		return FALSE
	return TRUE

/datum/saymode/vocalcords/handle_message/handle_message(
	mob/living/user,
	message,
	list/spans = list(),
	datum/language/language,
	list/message_mods = list()
)
	var/mob/living/carbon/carbon_user = user
	var/obj/item/organ/vocal_cords/our_vocal_cords = carbon_user.get_organ_slot(ORGAN_SLOT_VOICE)
	if(our_vocal_cords?.can_speak_with())
		our_vocal_cords.handle_speech(message) //message
		our_vocal_cords.speak_with(message) //action
	return SAYMODE_MESSAGE_HANDLED


/datum/saymode/binary //everything that uses .b (silicons, drones)
	key = MODE_KEY_BINARY
	mode = MODE_BINARY
	allows_custom_say_emotes = TRUE

/datum/saymode/binary/can_be_used_by(mob/living/user)
	if(!isswarmer(user) && !isdrone(user) && !user.binarycheck())
		return FALSE
	return TRUE

/datum/saymode/binary/handle_message/handle_message(
	mob/living/user,
	message,
	list/spans = list(),
	datum/language/language,
	list/message_mods = list()
)
	if(isswarmer(user))
		var/mob/living/simple_animal/hostile/swarmer/S = user
		S.swarmer_chat(message)
	else if(isdrone(user))
		var/mob/living/simple_animal/drone/D = user
		D.drone_chat(message)
	else if(user.binarycheck())
		user.robot_talk(message)
	return SAYMODE_MESSAGE_HANDLED


/datum/saymode/holopad
	key = MODE_KEY_HOLOPAD
	mode = MODE_HOLOPAD

/datum/saymode/holopad/can_be_used_by(mob/living/user)
	if(!isAI(user))
		return FALSE
	return TRUE

/datum/saymode/holopad/handle_message/handle_message(
	mob/living/user,
	message,
	list/spans = list(),
	datum/language/language,
	list/message_mods = list()
)
	var/mob/living/silicon/ai/ai_user = user
	ai_user.holopad_talk(message, spans, language, message_mods)
	return SAYMODE_MESSAGE_HANDLED

/datum/saymode/holoparasite
	key = MODE_KEY_HOLOPARASITE
	mode = MODE_HOLOPARASITE

/datum/saymode/holoparasite/handle_message(mob/living/user, message, datum/language/_language)
	. = FALSE
	if(!istype(user) || !user.mind || !length(message) || (!isholopara(user) && !user.has_holoparasites()))
		return TRUE
	user.holoparasite_telepathy(message, sanitize = FALSE) // sanitize = FALSE is used because say() sanitizes the message before passing it to any saymodes, even early saymodes.
