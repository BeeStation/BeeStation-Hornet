GLOBAL_VAR(audio_tracks)

/proc/load_tracks()
	GLOB.audio_tracks = list()
	for (var/track_type in subtypesof(/datum/audio_track))
		// Load the default track types
		var/datum/audio_track/track = new track_type()
		track.load()
		GLOB.audio_tracks += track
