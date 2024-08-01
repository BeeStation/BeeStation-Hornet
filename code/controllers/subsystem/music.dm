SUBSYSTEM_DEF(music)
	name = "Music Manager"
	// Not-critical, worse case scenario is that we send someone a song which
	// is already finished and they just don't play it
	flags = SS_BACKGROUND
	wait = 20 SECONDS
	init_order = INIT_ORDER_MUSIC
	var/index = 1
	// Music we are playing in the lobby
	var/datum/playing_track/login_music
	// Are we currently loading tracks?
	var/datum/task/loading_tracks = null
	// List of all audio tracks
	var/list/audio_tracks
	// List of all audio tracks by URL
	var/list/audio_tracks_by_url
	// List of audio tracks currently being played globally
	var/list/global_audio_tracks = list()

/datum/controller/subsystem/music/Initialize()
	// Load all music information asynchronously (it performs shell calls which sleep)
	var/datum/task/music_loader = load_tracks_async()
	if (!login_music)
		music_loader.continue_with(CALLBACK(src, PROC_REF(select_title_music)))

/datum/controller/subsystem/music/proc/load_tracks_async()
	DECLARE_ASYNC
	// If we are loading tracks, return the task for that thing's loading instead
	if (loading_tracks)
		return loading_tracks
	loading_tracks = .
	if (audio_tracks)
		ASYNC_RETURN(audio_tracks)
	audio_tracks = list()
	audio_tracks_by_url = list()
	for (var/track_type in subtypesof(/datum/audio_track))
		// Load the default track types
		var/datum/audio_track/track = new track_type()
		track.load()
		audio_tracks += track
		audio_tracks_by_url[track._web_sound_url] = track
	ASYNC_RETURN(audio_tracks)

/datum/controller/subsystem/music/proc/select_title_music(list/audio_tracks)
	// Something else has set the lobby music already
	if (login_music)
		return
	// Try to load map specific music first
	var/list/valid_tracks = list()
	if (LAZYLEN(SSmapping.config.title_music))
		for (var/datum/audio_track/track in audio_tracks)
			if (track.title in SSmapping.config.title_music)
				valid_tracks += track
		if (length(valid_tracks))
			var/datum/audio_track/picked = pick(valid_tracks)
			login_music = picked.play()
			SSmusic.play_global_music(login_music)
			return
	for (var/datum/audio_track/track in audio_tracks)
		if (!(track.play_flags & TRACK_FLAG_TITLE))
			continue
		valid_tracks += track
	if (length(valid_tracks))
		var/datum/audio_track/picked = pick(valid_tracks)
		login_music = picked.play()
		SSmusic.play_global_music(login_music)
	else
		var/datum/audio_track/picked = pick(audio_tracks)
		login_music = picked.play()
		SSmusic.play_global_music(login_music)

/datum/controller/subsystem/music/fire(resumed)
	// Run through our playing audio tracks and cull anyones that we think might be finished
	if (!resumed)
		index = 1
	while (index <= length(global_audio_tracks))
		// Check this song
		var/datum/playing_track/playing = global_audio_tracks[index]
		if (playing.audio.duration != 0 && world.time > playing.started_at + playing.audio.duration)
			global_audio_tracks.Cut(index, index+1)
		else
			index++
		// Someone else wants our time now, give it up
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/music/proc/play_global_music(datum/playing_track/playing)
	playing.play_to_clients()
	global_audio_tracks += playing

/datum/controller/subsystem/music/proc/feed_music(client/target)
	for (var/datum/playing_track/playing in global_audio_tracks)
		playing.play_to_client(target)
