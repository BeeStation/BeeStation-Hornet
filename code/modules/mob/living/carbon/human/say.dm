/mob/living/carbon/human/say_mod(input, list/message_mods = list())
	var/obj/item/organ/tongue/T = getorganslot(ORGAN_SLOT_TONGUE)
	if(T)
		verb_say = pick(T.say_mod)
		verb_ask = pick(T.ask_mod)
		verb_yell = pick(T.yell_mod)
		verb_exclaim = pick(T.exclaim_mod)
	if(wear_mask && istype(wear_mask, /obj/item/clothing/mask))
		var/obj/item/clothing/mask/worn_mask = wear_mask
		if(!isnull(worn_mask.chosen_tongue))
			verb_say = pick(initial(worn_mask.chosen_tongue.say_mod))
			verb_ask = pick(initial(worn_mask.chosen_tongue.ask_mod))
			verb_yell = pick(initial(worn_mask.chosen_tongue.yell_mod))
			verb_exclaim = pick(initial(worn_mask.chosen_tongue.exclaim_mod))
	if(slurring || !T)
		return "slurs"
	else
		. = ..()

/mob/living/carbon/human/GetVoice()
	var/current_name = real_name
	if(GetSpecialVoice())
		current_name = GetSpecialVoice()
	if(mind)
		var/datum/antagonist/changeling/changeling = mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling && changeling.mimicing )
			current_name = changeling.mimicing
	if(wear_mask && istype(wear_mask, /obj/item/clothing/mask))
		var/obj/item/clothing/mask/modulator = wear_mask
		current_name = modulator.get_name(usr, current_name)
	return current_name

/mob/living/carbon/human/IsVocal()
	// how do species that don't breathe talk? magic, that's what.
	if(!HAS_TRAIT_FROM(src, TRAIT_NOBREATH, SPECIES_TRAIT) && !getorganslot(ORGAN_SLOT_LUNGS))
		return FALSE
	if(dna?.species && !dna?.species.speak_no_tongue)
		if(!getorganslot(ORGAN_SLOT_TONGUE))
			return FALSE
	if(mind)
		return !mind.miming
	return TRUE

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
