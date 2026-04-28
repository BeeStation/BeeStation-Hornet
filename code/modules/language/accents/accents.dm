#define REGEX_FULLWORD 1
#define REGEX_STARTWORD 2
#define REGEX_ENDWORD 3
#define REGEX_ANY 4

/proc/handle_accented_speech(list/speech_args, file_path)
	var/message = speech_args[SPEECH_MESSAGE]
	if(!message || message[1] == "*")
		return

	message = " [message]"

	load_strings_file(file_path, STRING_DIRECTORY)
	var/list/speech_data = GLOB.string_cache[file_path]

	if(speech_data["words"])
		message = treat_message_accent(message, speech_data["words"], REGEX_FULLWORD)
	if(speech_data["start"])
		message = treat_message_accent(message, speech_data["start"], REGEX_STARTWORD)
	if(speech_data["end"])
		message = treat_message_accent(message, speech_data["end"], REGEX_ENDWORD)
	if(speech_data["syllables"])
		message = treat_message_accent(message, speech_data["syllables"], REGEX_ANY)
	if(speech_data["appends"] && prob(1))	// If chance too high it becomes memey. Like this is hopefully more immersive. Appends are just meant to add some flavour.
		var/regex/punct_regex = regex(@"[.!?]$", "")
		message = replacetextEx(message, punct_regex, "")  // Remove final punctuation

		message = "[trim(message)], [pick(speech_data["appends"])]"	// Reconsidering if appends should be removed from real accents and kept in meme ones

	speech_args[SPEECH_MESSAGE] = trim(message)

/proc/treat_message_accent(message, list/accent_list, chosen_regex)
	if(!message || !accent_list || message[1] == "*")
		return message

	message = "[message]"
	for(var/key in accent_list)
		var/value = accent_list[key]
		if(islist(value))
			value = pick(value)

		switch(chosen_regex)
			if(REGEX_FULLWORD)
				message = replacetextEx(message, regex("\\b[uppertext(key)]\\b|\\A[uppertext(key)]\\b|\\b[uppertext(key)]\\Z|\\A[uppertext(key)]\\Z", "(\\w+)/g"), uppertext(value))
				message = replacetextEx(message, regex("\\b[capitalize(key)]\\b|\\A[capitalize(key)]\\b|\\b[capitalize(key)]\\Z|\\A[capitalize(key)]\\Z", "(\\w+)/g"), capitalize(value))
				message = replacetextEx(message, regex("\\b[key]\\b|\\A[key]\\b|\\b[key]\\Z|\\A[key]\\Z", "(\\w+)/g"), value)
			if(REGEX_STARTWORD)
				message = replacetextEx(message, regex("\\b[uppertext(key)]|\\A[uppertext(key)]", "(\\w+)/g"), uppertext(value))
				message = replacetextEx(message, regex("\\b[capitalize(key)]|\\A[capitalize(key)]", "(\\w+)/g"), capitalize(value))
				message = replacetextEx(message, regex("\\b[key]|\\A[key]", "(\\w+)/g"), value)
			if(REGEX_ENDWORD)
				message = replacetextEx(message, regex("[uppertext(key)]\\b|[uppertext(key)]\\Z", "(\\w+)/g"), uppertext(value))
				message = replacetextEx(message, regex("[key]\\b|[key]\\Z", "(\\w+)/g"), value)
			if(REGEX_ANY)
				message = replacetextEx(message, uppertext(key), uppertext(value))
				message = replacetextEx(message, key, value)

	return message

#undef REGEX_FULLWORD
#undef REGEX_STARTWORD
#undef REGEX_ENDWORD
#undef REGEX_ANY
