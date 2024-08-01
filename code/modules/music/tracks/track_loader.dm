GLOBAL_VAR(audio_tracks)
GLOBAL_VAR(audio_tracks_by_url)

/proc/load_tracks_async()
	DECLARE_ASYNC
	if (GLOB.audio_tracks)
		ASYNC_RETURN(GLOB.audio_tracks)
	GLOB.audio_tracks = list()
	GLOB.audio_tracks_by_url = list()
	for (var/track_type in subtypesof(/datum/audio_track))
		// Load the default track types
		var/datum/audio_track/track = new track_type()
		track.load()
		GLOB.audio_tracks += track
		GLOB.audio_tracks_by_url[track._web_sound_url] = track
	ASYNC_RETURN(GLOB.audio_tracks)
