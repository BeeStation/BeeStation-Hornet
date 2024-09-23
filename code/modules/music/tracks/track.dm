//#define DEBUG_NO_ADMINS

#define SHELLEO_ERRORLEVEL 1
#define SHELLEO_STDOUT 2
#define SHELLEO_STDERR 3

// Do not unprotect, admins must upload audio through a helper verb instead
// of directly for safety.
/datum/audio_track/vv_edit_var(var_name, var_value)
	return FALSE

/datum/audio_track/CanProcCall(procname)
	return FALSE

/datum/audio_track
	var/title
	var/artist
	var/album
	var/datum/license/license
	// The duration of this song IN DECISECONDS. There is no easy way to get the duration of a song, and we are relying on the clients
	// to tell us the duration. To prevent exploitation (since it is shared), we rely on a vote. This value may be 0
	// if clients have not yet voted on the duration of the song, or if they could not come to an agreement.
	// PLEASE enter a duration in the config, you will save me a lot of trouble and prevent exploitation of the voting system
	var/duration = 0
	var/safe_duration = FALSE
	var/upload_date = null
	// By default, allow this to play everywhere
	var/track_flags = TRACK_FLAG_ALL
	var/_failed = FALSE
	/// File of the audio source, if it should be handled over the CDN
	/// Takes precedence over the URL, which will instead be used to get a link to where
	/// users can stream the song for themselves.
	var/audio_file
	/// The asset to use
	var/datum/asset/simple/audio/_audio_asset
	/// URL of the audio source, if the sound should be fetched from the internet
	var/url
	/// URL of the actual file to use
	var/_web_sound_url
	// Dynamic duration voting
	var/list/voted_ckeys = list()

/datum/audio_track/New()
	// Licenses do nothing special, so we won't bother singletoning them.
	if (ispath(license))
		license = new license()
	. = ..()

// Not a huge fan of this proc, but it does the job.
/datum/audio_track/proc/load()
	// What do we do with audio files?
	if (audio_file)
		// Prepare asset cache
		_audio_asset = new(audio_file)
		_web_sound_url = SSassets.transport.get_asset_url(_audio_asset.audio_name, _audio_asset.assets[_audio_asset.audio_name])
		if (duration)
			safe_duration = TRUE
		else
			message_admins("Audio file [title] was loaded without a duration provided. Please contact your server owner.")
			log_world("Audio file [title] was loaded without a duration provided. This will use a fallback client-driven voting system which may be exploited. Please update this.")
		return
	// Start by doing a safe setup
	_web_sound_url = url
	// Attempt to load youtube DLL
	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		message_admins("Failed to load audio; youtube-dl is not configured.")
		log_world("Youtube-dl was not configured, action unavailable") //Check config.txt for the INVOKE_YOUTUBEDL value
		_failed = TRUE
		return
	url = trim(url)
	if(findtext(url, ":") && !findtext(url, GLOB.is_http_protocol))
		message_admins("Failed to load audio; audio URL was rejected.")
		log_world("Attempting to load an audio-track with a non-HTTPS URL which has been rejected.")
		_failed = TRUE
		return
	var/shell_scrubbed_input = shell_url_scrub(url)
	var/list/output = world.shelleo("[ytdl] --geo-bypass --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height<=360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --dump-single-json --no-playlist -- \"[shell_scrubbed_input]\"")
	var/errorlevel = output[SHELLEO_ERRORLEVEL]
	var/stdout = output[SHELLEO_STDOUT]
	var/stderr = output[SHELLEO_STDERR]
	if (errorlevel)
		message_admins("Failed to load audio; failed to retrieve URL.")
		log_world("Failed to retrieve URL: [stderr]")
		_failed = TRUE
		return
	var/list/data
	try
		data = json_decode(stdout)
	catch(var/exception/e)
		message_admins("Failed to load audio; failed to parse URL.")
		log_world("Parsing URL failed: [e]: [stdout]")
		_failed = TRUE
		return
	if (!data["url"])
		_failed = TRUE
		return
	_web_sound_url = data["url"]
	title = title || data["title"]
	artist = data["artist"]
	album = data["album"]
	duration = data["duration"] * 1 SECONDS
	if (duration)
		safe_duration = TRUE
	else
		message_admins("Audio file [title] was loaded without a duration provided. Please contact your server owner.")
		log_world("Audio file [title] was loaded without a duration provided. This will use a fallback client-driven voting system which may be exploited. Please update this.")
	upload_date = data["upload_date"]
	log_world("Successfully loaded internet song: [title] by [artist].")

/datum/audio_track/proc/get_additional_information()
	return list(
		"title" = title,
		"start" = 0,
		"end" = duration * 0.1,
		"duration" = DisplayTimeText(duration * 10),
		"link" = url,
		"artist" = artist,
		"album" = album,
		"upload_date" = upload_date,
	)

/datum/audio_track/proc/play(track_flags = PLAYING_FLAG_DEFAULT)
	RETURN_TYPE(/datum/playing_track)
	return new /datum/playing_track(src, world.time, track_flags)

/datum/audio_track/proc/play_spatial(atom/source, radius, track_flags = PLAYING_FLAG_DEFAULT)
	RETURN_TYPE(/datum/playing_track/spatial)
	return new /datum/playing_track/spatial(source, src, world.time, track_flags, radius)

/**
 * There is no easy way to get the length of the audio, so when a client starts playing
 * a sound, they will tell us how long the sound is.
 */
/datum/audio_track/proc/vote_duration(client/votee, duration_vote)
	if (!isnum(duration_vote))
		return
	if (duration_vote <= 0)
		return
	// We don't need your vote if we know the duration
	if (safe_duration)
		return
	var/has_voted = voted_ckeys.Find(votee.ckey)
	voted_ckeys[votee.ckey] = duration_vote
	if (!has_voted)
		// Re-evaluate our vote
#ifndef DEBUG_NO_ADMINS
		// Step 1: An admin's word is final since we can probably trust them
		for (var/voted_ckey in voted_ckeys)
			if (is_admin(voted_ckey))
				duration = voted_ckeys[voted_ckey] * 10
				safe_duration = TRUE
				return
#endif
		// Step 2: If there is an agreed modal value, then use that
		var/list/values = list()
		for (var/voted_ckey in voted_ckeys)
			var/vote_value = CEILING(voted_ckeys[voted_ckey], 5)
			if (values["[vote_value]"])
				values["[vote_value]"] ++
			else
				values["[vote_value]"] = 1
		var/ambiguous_maximum = FALSE
		var/agreed_maximum = 0
		var/votes = 0
		for (var/vote in values)
			var/vote_count = values[vote]
			if (vote_count < votes)
				continue
			if (vote_count == votes)
				ambiguous_maximum = TRUE
				continue
			ambiguous_maximum = FALSE
			votes = vote_count
			agreed_maximum = vote
		if (!ambiguous_maximum)
			duration = text2num(agreed_maximum) * 10
			return
		// Step 3: If we cannot agree, then just tell everything that we have no idea
		duration = 0

/*

// Example of a youtube track.
// These may fail as youtube doesn't like you getting the mp4s from their videos
// however you can always try soundcloud or another service that YT-DLP supports,
// or you can use a file that you, yourself, are hosting.
// This is how you do all of that though:
// Note: Using your own files will require filling out the meta-data, youtube
// will give some meta-data when we load it.

/datum/audio_track/countdown
	url = "https://www.youtube.com/watch?v=G2gVAPKlgqA"

*/

/datum/audio_track/countdown
	url = "https://www.youtube.com/watch?v=G2gVAPKlgqA"
	track_flags = TRACK_FLAG_JUKEBOX

#undef SHELLEO_ERRORLEVEL
#undef SHELLEO_STDOUT
#undef SHELLEO_STDERR
