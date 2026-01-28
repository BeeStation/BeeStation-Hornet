/mob/living/carbon/human/say(
	message,
	bubble_type,
	list/spans = list(),
	sanitize = TRUE,
	datum/language/language,
	ignore_spam = FALSE,
	forced,
	filterproof = FALSE,
	message_range = 7,
	datum/saymode/saymode,
	list/message_mods = list(),
)
	if(!HAS_TRAIT(src, TRAIT_SPEAKS_CLEARLY))
		var/static/regex/tongueless_lower = new("\[gdntke]+", "g")
		var/static/regex/tongueless_upper = new("\[GDNTKE]+", "g")
		if(message[1] != "*")
			message = tongueless_lower.Replace(message, pick("aa","oo","'"))
			message = tongueless_upper.Replace(message, pick("AA","OO","'"))
	return ..()

/mob/living/carbon/human/get_default_say_verb()
	var/obj/item/organ/tongue/tongue = get_organ_slot(ORGAN_SLOT_TONGUE)
	if(isnull(tongue))
		return "gurgles"
	return tongue.temp_say_mod || tongue.say_mod || ..()

/mob/living/carbon/human/get_default_ask_verb()
	var/obj/item/organ/tongue/tongue = get_organ_slot(ORGAN_SLOT_TONGUE)
	if(isnull(tongue))
		return "gurgles inquisitively"
	return tongue.ask_mod || ..()

/mob/living/carbon/human/get_default_yell_verb()
	var/obj/item/organ/tongue/tongue = get_organ_slot(ORGAN_SLOT_TONGUE)
	if(isnull(tongue))
		return "gurgles loudly"
	return tongue.yell_mod || ..()

/mob/living/carbon/human/get_default_exclaim_verb()
	var/obj/item/organ/tongue/tongue = get_organ_slot(ORGAN_SLOT_TONGUE)
	if(isnull(tongue))
		return "gurgles excitedly"
	return tongue.exclaim_mod || ..()

/mob/living/carbon/human/GetVoice()
	if(HAS_TRAIT(src, TRAIT_UNKNOWN))
		return ("Unknown")

	var/current_name = real_name
	if(GetSpecialVoice())
		current_name = GetSpecialVoice()

	if(mind)
		var/datum/antagonist/changeling/changeling = mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling && changeling.mimicing )
			current_name = changeling.mimicing
	if(wear_mask && istype(wear_mask, /obj/item/clothing/mask))
		var/obj/item/clothing/mask/modulator = wear_mask
		current_name = modulator.get_name(src, current_name)
	return current_name

/mob/living/carbon/human/proc/SetSpecialVoice(new_voice)
	if(new_voice)
		special_voice = new_voice
	return

/mob/living/carbon/human/proc/UnsetSpecialVoice()
	special_voice = ""
	return

/mob/living/carbon/human/proc/GetSpecialVoice()
	return special_voice

/mob/living/carbon/human/binarycheck()
	if(stat >= SOFT_CRIT || !ears)
		return FALSE
	var/obj/item/radio/headset/dongle = ears
	if(!istype(dongle))
		return FALSE
	return dongle.translate_binary

/mob/living/carbon/human/radio(message, list/message_mods = list(), list/spans, language)
	. = ..()
	if(. != FALSE)
		return .

	if(message_mods[MODE_HEADSET])
		if(ears)
			ears.talk_into(src, message, , spans, language, message_mods)
		return ITALICS | REDUCE_RANGE
	else if(message_mods[RADIO_EXTENSION] == MODE_DEPARTMENT || (GLOB.radiochannels[message_mods[RADIO_EXTENSION]]))
		if(ears)
			ears.talk_into(src, message, message_mods[RADIO_EXTENSION], spans, language, message_mods)
			return ITALICS | REDUCE_RANGE

	return FALSE

/mob/living/carbon/human/get_alt_name()
	if(name != GetVoice())
		return " (as [get_id_name("Unknown")])"
