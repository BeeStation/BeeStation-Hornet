/// Global cache of audio datum instances, keyed by type path.
/// Use get_audio_datum() to access.
var/global/list/datum/audio/_audio_cache

/// Returns a cached /datum/audio instance for the given type path, creating it if needed.
/proc/get_audio_datum(audio_path)
	if (!ispath(audio_path, /datum/audio))
		return null
	if (!_audio_cache)
		_audio_cache = list()
	if (_audio_cache[audio_path])
		return _audio_cache[audio_path]
	var/datum/audio/instance = new audio_path
	_audio_cache[audio_path] = instance
	return instance

/datum/audio
	/// Path to file source
	var/source

	/// The real (ie, artist's) audio title
	var/title

	/// The display title to use in game, if different
	var/display

	/// The normal volume to play the audio at, if set
	var/volume

	/// The artist's name
	var/author

	/// The collection (eg album) the audio belongs to
	var/collection

	/// The license under which the audio was made available
	var/datum/license/license

	/// A link to the audio's source, if available
	var/url


/datum/audio/New()
	. = ..()
	if (ispath(license))
		license = new license


/datum/audio/proc/get_info(with_meta = TRUE)
	. = span_good("[title][!author?"":" by [author]"][!collection?"":" ([collection])"]")
	if (with_meta)
		. = "[.][!url?"":"\[<a href='[url]'>link</a>\]"]\[<a href='[license.url]'>license</a>\]"


/datum/audio/proc/get_sound(channel)
	var/sound/sound = sound(source, FALSE, FALSE, channel, volume || 100)
	return sound


/datum/audio/track/get_sound(channel = CHANNEL_LOBBYMUSIC)
	var/sound/sound = ..()
	sound.repeat = TRUE
	return sound
