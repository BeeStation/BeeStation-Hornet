#define SHELLEO_ERRORLEVEL 1
#define SHELLEO_STDOUT 2
#define SHELLEO_STDERR 3

// Do not unprotect, admins must upload audio through a helper verb instead
// of directly for safety.
GENERAL_PROTECT_DATUM(/datum/audio_track)

/datum/audio_track
	var/title
	var/artist
	var/album
	var/datum/license/license
	var/duration = 0
	var/upload_date = null
	var/failed = FALSE
	/// File of the audio source, if it should be handled over the CDN
	/// Takes precedence over the URL, which will instead be used to get a link to where
	/// users can stream the song for themselves.
	var/audio_file
	/// The asset to use
	var/datum/asset/simple/audio/audio_asset
	/// URL of the audio source, if the sound should be fetched from the internet
	var/url
	/// URL of the actual file to use
	var/web_sound_url

/datum/audio_track/New()
	// Licenses do nothing special, so we won't bother singletoning them.
	if (ispath(license))
		license = new license()
	return ..()

// Not a huge fan of this proc, but it does the job.
/datum/audio_track/proc/load()
	// What do we do with audio files?
	if (audio_file)
		audio_asset = new(audio_file)
		web_sound_url = SSassets.transport.get_asset_url(audio_asset.audio_name, audio_asset.assets[audio_asset.audio_name])
		return
	// Start by doing a safe setup
	web_sound_url = url
	// Attempt to load youtube DLL
	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		log_world("Youtube-dl was not configured, action unavailable") //Check config.txt for the INVOKE_YOUTUBEDL value
		failed = TRUE
		return
	url = trim(url)
	if(findtext(url, ":") && !findtext(url, GLOB.is_http_protocol))
		log_world("Attempting to load an audio-track with a non-HTTPS URL which has been rejected.")
		failed = TRUE
		return
	var/shell_scrubbed_input = shell_url_scrub(url)
	var/list/output = world.shelleo("[ytdl] --geo-bypass --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height<=360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --dump-single-json --no-playlist -- \"[shell_scrubbed_input]\"")
	var/errorlevel = output[SHELLEO_ERRORLEVEL]
	var/stdout = output[SHELLEO_STDOUT]
	var/stderr = output[SHELLEO_STDERR]
	if (errorlevel)
		log_world("Failed to retrieve URL: [stderr]")
		failed = TRUE
		return
	var/list/data
	try
		data = json_decode(stdout)
	catch(var/exception/e)
		log_world("Parsing URL failed: [e]: [stdout]")
		failed = TRUE
		return
	if (!data["url"])
		failed = TRUE
		return
	web_sound_url = data["url"]
	title = title || data["title"]
	artist = data["artist"]
	album = data["album"]
	duration = text2num(data["end_time"]) - text2num(data["start_time"])
	upload_date = data["upload_date"]
	log_world("Successfully loaded internet song: [title] by [artist].")

/datum/audio_track/proc/get_additional_information()
	return list(
		"title" = title,
		"start" = 0,
		"end" = duration,
		"duration" = DisplayTimeText(duration * 10),
		"link" = url,
		"artist" = artist,
		"album" = album,
		"upload_date" = upload_date,
	)

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

#undef SHELLEO_ERRORLEVEL
#undef SHELLEO_STDOUT
#undef SHELLEO_STDERR
