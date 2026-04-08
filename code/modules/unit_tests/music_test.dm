/datum/unit_test/audio_track_validate

/datum/unit_test/audio_track_validate/Run()
	for (var/track_type in subtypesof(/datum/audio/track))
		var/datum/audio/track/track = get_audio_datum(track_type)
		if (!track)
			continue
		if (!isfile(track.source))
			TEST_FAIL("Invalid Audio Track [track.type]: Invalid Source")
		if (!istext(track.title))
			TEST_FAIL("Invalid Audio Track [track.type]: Invalid Title")
		if (!istype(track.license, /datum/license))
			TEST_FAIL("Invalid Audio Track [track.type]: Invalid License")
		else if (track.license.attribution_mandatory)
			if (!istext(track.author))
				TEST_FAIL("Invalid Audio Track [track.type]: Invalid Author")
			if (!istext(track.url))
				TEST_FAIL("Invalid Audio Track [track.type]: Invalid URL")

/datum/unit_test/jukebox_validate

/datum/unit_test/jukebox_validate/Run()
	for (var/datum/audio_jukebox/jukebox)
		for (var/entry in jukebox.tracks)
			var/datum/audio_jukebox_track/track = entry
			if (!track.title || !isfile(track.source))
				TEST_FAIL("Invalid Jukebox Track In [jukebox.type]: [track .type]")
