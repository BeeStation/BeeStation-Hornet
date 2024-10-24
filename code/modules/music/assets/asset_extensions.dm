/datum/asset/simple/audio
	_abstract = /datum/asset/simple/audio
	var/audio_name

/datum/asset/simple/audio/New(audio_file)
	var/divider_pos = findlasttext("[audio_file]", "/") + 1
	var/extension_pos = findlasttext("[audio_file]", ".") + 1
	var/extension = ""
	if (extension_pos > 0)
		extension = copytext("[audio_file]", extension_pos)
	else
		stack_trace("Error loading audio file asset, no extension")
	if (extension != "mp4" && extension != "mp3")
		stack_trace("Warning: Unsupported file type being loaded into audio. Only MP3 and MP4 are currently supported for streamed music.")
	var/file_name = copytext(copytext("[audio_file]", 1, extension_pos - 1), divider_pos)
	audio_name = "[file_name].[extension]"
	assets[audio_name] = file("[audio_file]")
	..()
