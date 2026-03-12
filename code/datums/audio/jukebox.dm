/datum/audio_jukebox
	var/atom/owner
	var/sound/active_sound
	var/list/mob/listeners
	var/sound_channel
	var/list/tracks
	var/index = 1
	var/volume = 20
	var/volume_max = 50
	var/volume_step = 10
	var/frequency = 1
	var/range = 7
	var/falloff = 1
	var/playing = FALSE

/datum/audio_jukebox/New(atom/_owner)
	. = ..()
	if (QDELETED(_owner) || !isatom(_owner))
		qdel(src)
		return
	owner = _owner
	tracks = list()
	listeners = list()
	for (var/path in GLOB.audio_jukebox_tracks)
		var/datum/audio/track/track = get_audio_datum(path)
		AddTrack(track.display || track.title, track.source, track.author)


/datum/audio_jukebox/Destroy()
	Stop()
	QDEL_LIST(tracks)
	tracks = null
	owner = null
	return ..()


/datum/audio_jukebox/proc/AddTrack(title = "Track [length(tracks) + 1]", source, author)
	tracks += new /datum/audio_jukebox_track (title, source, author)


/datum/audio_jukebox/proc/ClearTracks()
	QDEL_LIST(tracks)
	tracks = list()


/datum/audio_jukebox/proc/Next()
	if (++index > length(tracks))
		index = 1
	if (playing)
		Stop()
		Play()


/datum/audio_jukebox/proc/Last()
	if (--index < 1)
		index = length(tracks)
	if (playing)
		Stop()
		Play()


/datum/audio_jukebox/proc/Track(_index)
	_index = text2num(_index)
	if (isnull(_index) || !ISINTEGER(_index))
		return
	index = clamp(_index, 1, length(tracks))
	if (playing)
		Stop()
		Play()


/datum/audio_jukebox/proc/Stop()
	playing = FALSE
	STOP_PROCESSING(SSprocessing, src)
	if (sound_channel)
		for (var/mob/M as anything in listeners)
			if (!QDELETED(M))
				M.stop_sound_channel(sound_channel)
		SSsounds.free_sound_channel(sound_channel)
		sound_channel = null
	listeners.Cut()
	active_sound = null
	if (!QDELETED(owner))
		owner.update_appearance(UPDATE_ICON_STATE)


/datum/audio_jukebox/proc/Play()
	if (playing)
		return
	var/datum/audio_jukebox_track/track = tracks[index]
	if (!track.source)
		return
	sound_channel = SSsounds.reserve_sound_channel(src)
	if (!sound_channel)
		return
	playing = TRUE
	active_sound = sound(track.source)
	active_sound.repeat = TRUE
	active_sound.channel = sound_channel
	active_sound.volume = volume
	active_sound.frequency = frequency
	active_sound.falloff = falloff
	active_sound.environment = SOUND_ENVIRONMENT_NONE
	active_sound.y = 1
	var/turf/source_turf = get_turf(owner)
	for (var/mob/M in hearers(range, owner))
		if (M.client)
			listeners += M
			send_sound_to_listener(M, source_turf)
	START_PROCESSING(SSprocessing, src)
	owner.update_appearance(UPDATE_ICON_STATE)


/datum/audio_jukebox/process()
	if (!playing || QDELETED(owner))
		Stop()
		return PROCESS_KILL
	var/turf/source_turf = get_turf(owner)
	// Remove listeners who left range or were deleted
	for (var/mob/M as anything in listeners)
		if (QDELETED(M) || !M.client || get_dist(M, owner) > range)
			listeners -= M
			if (!QDELETED(M))
				M.stop_sound_channel(sound_channel)
		else
			// Update spatial position for existing listeners
			send_sound_to_listener(M, source_turf, update = TRUE)
	// Add new listeners who entered range
	for (var/mob/M in hearers(range, owner))
		if (M.client && !(M in listeners))
			listeners += M
			send_sound_to_listener(M, source_turf)


/datum/audio_jukebox/proc/Volume(_volume)
	_volume = text2num(_volume)
	if (!isnum(_volume))
		return
	if (_volume >= 0)
		volume = min(_volume, volume_max)
	else if (_volume == -1)
		volume = max(volume - volume_step, 0)
	else if (_volume == -2)
		volume = min(volume + volume_step, volume_max)
	if (active_sound)
		active_sound.volume = volume
		var/turf/source_turf = get_turf(owner)
		for (var/mob/M as anything in listeners)
			if (!QDELETED(M) && M.client)
				send_sound_to_listener(M, source_turf, update = TRUE)


/// Sends the active sound to a listener with proper 3D spatial positioning.
/datum/audio_jukebox/proc/send_sound_to_listener(mob/listener, turf/source_turf, update = FALSE)
	var/turf/listener_turf = get_turf(listener)
	if (source_turf && listener_turf && source_turf.z == listener_turf.z)
		active_sound.x = source_turf.x - listener_turf.x
		active_sound.z = source_turf.y - listener_turf.y
	else
		active_sound.x = 0
		active_sound.z = 0
	if (update)
		active_sound.status = SOUND_UPDATE
	SEND_SOUND(listener, active_sound)
	if (update)
		active_sound.status = NONE

/// Returns UI data for use with any UI framework.
/datum/audio_jukebox/proc/get_ui_data()
	var/list/data_tracks = list()
	for (var/i = 1 to length(tracks))
		var/datum/audio_jukebox_track/track = tracks[i]
		data_tracks += list(list("track" = track.title, "author" = track.author, "index" = i))
	var/datum/audio_jukebox_track/current = tracks[index]
	return list(
		"track" = current.title,
		"author" = current.author,
		"playing" = playing,
		"volume" = volume,
		"tracks" = data_tracks
	)



/// Returns the title of the currently selected track.
/datum/audio_jukebox/proc/get_current_track_name()
	var/datum/audio_jukebox_track/track = tracks[index]
	return track?.title


/**
 * Subtype which only plays music to a single specified mob.
 *
 * Does not use range-based polling. You must pass the target mob to Play().
 */
/datum/audio_jukebox/single_mob

/datum/audio_jukebox/single_mob/Play(mob/target)
	if (playing || !target)
		return
	var/datum/audio_jukebox_track/track = tracks[index]
	if (!track.source)
		return
	sound_channel = SSsounds.reserve_sound_channel(src)
	if (!sound_channel)
		return
	playing = TRUE
	active_sound = sound(track.source)
	active_sound.repeat = TRUE
	active_sound.channel = sound_channel
	active_sound.volume = volume
	active_sound.frequency = frequency
	active_sound.environment = SOUND_ENVIRONMENT_NONE
	if (target.client)
		listeners += target
		SEND_SOUND(target, active_sound)
	owner.update_appearance(UPDATE_ICON_STATE)

/datum/audio_jukebox/single_mob/process()
	return PROCESS_KILL


/datum/audio_jukebox_track
	var/title
	var/source
	var/author


/datum/audio_jukebox_track/New(_title, _source, _author)
	title = _title
	source = _source
	author = _author



GLOBAL_LIST_INIT(audio_jukebox_tracks, list(
	/datum/audio/track/absconditus,
	/datum/audio/track/ambispace,
	/datum/audio/track/asfarasitgets,
	/datum/audio/track/clouds_of_fire,
	/datum/audio/track/comet_haley,
	/datum/audio/track/df_theme,
	/datum/audio/track/digit_one,
	/datum/audio/track/dilbert,
	/datum/audio/track/eighties,
	/datum/audio/track/elevator,
	/datum/audio/track/elibao,
	/datum/audio/track/endless_space,
	/datum/audio/track/floating,
	/datum/audio/track/hull_rupture,
	/datum/audio/track/human,
	/datum/audio/track/inorbit,
	/datum/audio/track/lasers,
	/datum/audio/track/level3_mod,
	/datum/audio/track/lysendraa,
	/datum/audio/track/marhaba,
	/datum/audio/track/martiancowboy,
	/datum/audio/track/misanthropic_corridors,
	/datum/audio/track/monument,
	/datum/audio/track/nebula,
	/datum/audio/track/on_the_rocks,
	/datum/audio/track/one_loop,
	/datum/audio/track/pwmur,
	/datum/audio/track/rimward_cruise,
	/datum/audio/track/space_oddity,
	/datum/audio/track/thunderdome,
	/datum/audio/track/torch,
	/datum/audio/track/torn,
	/datum/audio/track/treacherous_voyage,
	/datum/audio/track/voidsent,
	/datum/audio/track/wake,
	/datum/audio/track/wildencounters
))
