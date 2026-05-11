#define SPEECHMOD_REPLACE_WORD 1
#define SPEECHMOD_REPLACE_START 2
#define SPEECHMOD_REPLACE_END 3
#define SPEECHMOD_REPLACE_ANY 4

/// Used to apply certain speech patterns
/// Can be used on organs, wearables, mutations and mobs
/datum/component/speechmod
	/// Assoc list for strings/regexes and their replacements. Should be lowercase, as case will be automatically changed
	var/list/replacements = list()
	/// Assoc list for full-word replacements with word-boundary regex and case preservation
	var/list/word_replacements = list()
	/// Assoc list for word-start replacements with case preservation
	var/list/start_replacements = list()
	/// Assoc list for word-end replacements with case preservation
	var/list/end_replacements = list()
	/// Assoc list for substring replacements with case preservation
	var/list/syllable_replacements = list()
	/// List of phrases randomly appended at low probability
	var/list/appends = list()
	/// Chance for an append to trigger
	var/append_chance = 1
	/// String added to the end of the message
	var/end_string = ""
	/// Chance for the end string to be applied
	var/end_string_chance = 100
	/// Current target for modification
	var/mob/targeted
	/// Slot tags in which this item works when equipped
	var/slots
	/// If set to true, turns all text to uppercase
	var/uppercase = FALSE
	/// Any additional checks that we should do before applying the speech modification
	var/datum/callback/should_modify_speech = null

/datum/component/speechmod/Initialize(replacements = list(), end_string = "", end_string_chance = 100, slots, uppercase = FALSE, should_modify_speech, word_replacements = list(), start_replacements = list(), end_replacements = list(), syllable_replacements = list(), appends = list(), append_chance = 1, file_path = null)
	if (!ismob(parent) && !isitem(parent) && !istype(parent, /datum/mutation) && !istype(parent, /datum/status_effect))
		return COMPONENT_INCOMPATIBLE

	src.replacements = replacements
	src.end_string = end_string
	src.end_string_chance = end_string_chance
	src.slots = slots
	src.uppercase = uppercase
	src.should_modify_speech = should_modify_speech
	src.append_chance = append_chance

	if(file_path)
		if(!(file_path in GLOB.string_cache))
			GLOB.string_cache[file_path] = json_load(file_path)
		var/list/speech_data = GLOB.string_cache[file_path]
		src.word_replacements = islist(speech_data["words"]) ? speech_data["words"] : list()
		src.start_replacements = islist(speech_data["start"]) ? speech_data["start"] : list()
		src.end_replacements = islist(speech_data["end"]) ? speech_data["end"] : list()
		src.syllable_replacements = islist(speech_data["syllables"]) ? speech_data["syllables"] : list()
		src.appends = islist(speech_data["appends"]) ? speech_data["appends"] : list()
	else
		src.word_replacements = word_replacements
		src.start_replacements = start_replacements
		src.end_replacements = end_replacements
		src.syllable_replacements = syllable_replacements
		src.appends = appends

	if (istype(parent, /datum/mutation))
		RegisterSignal(parent, COMSIG_MUTATION_GAINED, PROC_REF(on_mutation_gained))
		RegisterSignal(parent, COMSIG_MUTATION_LOST, PROC_REF(on_mutation_lost))
		return

	var/atom/owner = parent

	if (istype(parent, /datum/status_effect))
		var/datum/status_effect/effect = parent
		targeted = effect.owner
		RegisterSignal(targeted, COMSIG_MOB_SAY, PROC_REF(handle_speech))
		return

	if (ismob(parent))
		targeted = parent
		RegisterSignal(targeted, COMSIG_MOB_SAY, PROC_REF(handle_speech))
		return

	if (ismob(owner.loc))
		targeted = owner.loc
		RegisterSignal(targeted, COMSIG_MOB_SAY, PROC_REF(handle_speech))

	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_unequipped))
	RegisterSignal(parent, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_implanted))
	RegisterSignal(parent, COMSIG_ORGAN_REMOVED, PROC_REF(on_removed))

/datum/component/speechmod/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] == "*")
		return
	if(SEND_SIGNAL(source, COMSIG_TRY_MODIFY_SPEECH) & PREVENT_MODIFY_SPEECH)
		return
	if(!isnull(should_modify_speech) && !should_modify_speech.Invoke(source, speech_args))
		return

	if(length(word_replacements) || length(start_replacements) || length(end_replacements) || length(syllable_replacements))
		message = " [message]"  // leading space lets word-boundary regex match at string start
		if(length(word_replacements))
			message = apply_accent_mode(message, word_replacements, SPEECHMOD_REPLACE_WORD)
		if(length(start_replacements))
			message = apply_accent_mode(message, start_replacements, SPEECHMOD_REPLACE_START)
		if(length(end_replacements))
			message = apply_accent_mode(message, end_replacements, SPEECHMOD_REPLACE_END)
		if(length(syllable_replacements))
			message = apply_accent_mode(message, syllable_replacements, SPEECHMOD_REPLACE_ANY)
		if(length(appends) && prob(append_chance))
			var/regex/punct_regex = regex(@"[.!?]$", "")
			message = replacetextEx(message, punct_regex, "")
			message = "[trim(message)], [pick(appends)]"
		message = trim(message)

	for (var/to_replace in replacements)
		var/replacement = replacements[to_replace]
		if (islist(replacement))
			replacement = pick(replacement)
		message = replacetextEx(message, to_replace, replacement)

	message = trim(message)
	if (prob(end_string_chance))
		message += islist(end_string) ? pick(end_string) : end_string
	speech_args[SPEECH_MESSAGE] = trim(message)

	if (uppercase)
		return COMPONENT_UPPERCASE_SPEECH

/// Applies one pass of accent replacements with word-boundary awareness and case preservation
/datum/component/speechmod/proc/apply_accent_mode(message, list/accent_list, mode)
	for(var/key in accent_list)
		var/value = accent_list[key]
		if(islist(value))
			value = pick(value)
		switch(mode)
			if(SPEECHMOD_REPLACE_WORD)
				message = replacetextEx(message, regex("\\b[uppertext(key)]\\b|\\A[uppertext(key)]\\b|\\b[uppertext(key)]\\Z|\\A[uppertext(key)]\\Z", "(\\w+)/g"), uppertext(value))
				message = replacetextEx(message, regex("\\b[capitalize(key)]\\b|\\A[capitalize(key)]\\b|\\b[capitalize(key)]\\Z|\\A[capitalize(key)]\\Z", "(\\w+)/g"), capitalize(value))
				message = replacetextEx(message, regex("\\b[key]\\b|\\A[key]\\b|\\b[key]\\Z|\\A[key]\\Z", "(\\w+)/g"), value)
			if(SPEECHMOD_REPLACE_START)
				message = replacetextEx(message, regex("\\b[uppertext(key)]|\\A[uppertext(key)]", "(\\w+)/g"), uppertext(value))
				message = replacetextEx(message, regex("\\b[capitalize(key)]|\\A[capitalize(key)]", "(\\w+)/g"), capitalize(value))
				message = replacetextEx(message, regex("\\b[key]|\\A[key]", "(\\w+)/g"), value)
			if(SPEECHMOD_REPLACE_END)
				message = replacetextEx(message, regex("[uppertext(key)]\\b|[uppertext(key)]\\Z", "(\\w+)/g"), uppertext(value))
				message = replacetextEx(message, regex("[key]\\b|[key]\\Z", "(\\w+)/g"), value)
			if(SPEECHMOD_REPLACE_ANY)
				message = replacetextEx(message, uppertext(key), uppertext(value))
				message = replacetextEx(message, key, value)
	return message

/datum/component/speechmod/proc/on_equipped(datum/source, mob/living/user, slot)
	SIGNAL_HANDLER

	if (!isnull(slots) && !(slot & slots))
		if (!isnull(targeted))
			UnregisterSignal(targeted, COMSIG_MOB_SAY)
			targeted = null
		return

	if (targeted == user)
		return

	targeted = user
	RegisterSignal(targeted, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/component/speechmod/proc/on_unequipped(datum/source, mob/living/user)
	SIGNAL_HANDLER

	if (isnull(targeted))
		return
	UnregisterSignal(targeted, COMSIG_MOB_SAY)
	targeted = null

/datum/component/speechmod/proc/on_implanted(datum/source, mob/living/carbon/receiver)
	SIGNAL_HANDLER

	if (targeted == receiver)
		return

	targeted = receiver
	RegisterSignal(targeted, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/component/speechmod/proc/on_removed(datum/source, mob/living/carbon/former_owner)
	SIGNAL_HANDLER

	if (isnull(targeted))
		return
	UnregisterSignal(targeted, COMSIG_MOB_SAY)
	targeted = null

/datum/component/speechmod/proc/on_mutation_gained(datum/source, mob/living/carbon/human/owner)
	SIGNAL_HANDLER

	if (targeted == owner)
		return

	targeted = owner
	RegisterSignal(targeted, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/component/speechmod/proc/on_mutation_lost(datum/source, mob/living/carbon/human/owner)
	SIGNAL_HANDLER

	if (isnull(targeted))
		return
	UnregisterSignal(targeted, COMSIG_MOB_SAY)
	targeted = null

/datum/component/speechmod/Destroy()
	should_modify_speech = null
	return ..()

#undef SPEECHMOD_REPLACE_WORD
#undef SPEECHMOD_REPLACE_START
#undef SPEECHMOD_REPLACE_END
#undef SPEECHMOD_REPLACE_ANY
