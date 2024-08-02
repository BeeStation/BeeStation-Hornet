#define LAST_LOBBY_MUSIC_TXT "data/last_round_lobby_music.txt"

//#define GENERATE_JSON

SUBSYSTEM_DEF(music)
	name = "Music Manager"
	// Not-critical, worse case scenario is that we send someone a song which
	// is already finished and they just don't play it
	flags = SS_BACKGROUND
	wait = 10 SECONDS
	init_order = INIT_ORDER_MUSIC
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	var/index = 1
	var/last_song_name
	// Music we are playing in the lobby
	var/datum/playing_track/login_music
	// Playlist of login music
	var/list/login_music_playlist
	// Current global login song
	var/current_login_song = 1
	// Are we currently loading tracks?
	var/datum/task/loading_tracks = null
	// List of all audio tracks
	var/list/audio_tracks
	// List of all audio tracks by URL
	var/list/audio_tracks_by_url
	// List of audio tracks currently being played globally
	var/list/global_audio_tracks = list()
	// List of spatial audio tracks. Sending them to the client is relatively cheap, so we
	// actually just send them to everyone whether they are playing or not
	var/list/spatial_audio_tracks = list()

/datum/controller/subsystem/music/Initialize()
	// Load up the last song we played
	last_song_name = trim(rustg_file_read(LAST_LOBBY_MUSIC_TXT))
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
	// Check if we are using a config override
	if (rustg_file_exists("config/music.json"))
		try
			load_json_tracks()
			ASYNC_RETURN(audio_tracks)
		catch(var/exception/e)
			log_config("Music.json failed to load.")
			log_config("[e.file]:[e.line] - [e.name]\n[e.desc]")
			message_admins("Failed to load music.json config, please contact a server operator.")
#ifdef GENERATE_JSON
	var/list/track_list = list()
#endif
	for (var/track_type in subtypesof(/datum/audio_track))
		// Load the default track types
		var/datum/audio_track/track = new track_type()
		track.load()
		if (track._failed)
			log_runtime("Failed to load track [track.audio_file]/[track.url]")
			continue
		audio_tracks += track
		audio_tracks_by_url[track._web_sound_url] = track
#ifdef GENERATE_JSON
		var/list/output_track = list()
		if (track.title)
			output_track["title"] = track.title
		if (track.artist)
			output_track["artist"] = track.artist
		if (track.album)
			output_track["album"] = track.album
		if (track.license)
			output_track["license"] = track.license
		if (track.license)
			var/list/license_info = list(
				"title" = track.license.title,
				"legal_text" = track.license.legal_text,
				"url" = track.license.url,
				"attribution_required" = track.license.attribution_required,
			)
			output_track["license_alt"] = license_info
		if (track.duration)
			output_track["duration"] = track.duration
		if (track.upload_date)
			output_track["upload_date"] = track.upload_date
		if (track.audio_file)
			output_track["audio_file"] = track.audio_file
		if (track.url)
			output_track["url"] = track.url
		if (track.track_flags & TRACK_FLAG_JUKEBOX)
			output_track["jukebox"] = TRUE
		if (track.track_flags & TRACK_FLAG_ROUNDEND)
			output_track["roundend"] = TRUE
		if (track.track_flags & TRACK_FLAG_TITLE)
			output_track["lobbymusic"] = TRUE
		track_list += list(output_track)
	message_admins(json_encode(track_list))
#endif
	log_world("Successfully loaded [length(audio_tracks)] songs from datums")
	ASYNC_RETURN(audio_tracks)

/datum/controller/subsystem/music/proc/load_json_tracks()
	var/full_file = rustg_file_read("config/music.json")
	var/list/decoded_file = json_decode(full_file)
	for (var/list/thing in decoded_file)
		var/datum/audio_track/track = new()
		track.title = thing["title"]
		track.artist = thing["artist"]
		track.album = thing["album"]
		track.duration = thing["duration"]
		track.upload_date = thing["upload_date"]
		track.audio_file = thing["audio_file"]
		track.url = thing["url"]
		track.track_flags = 0
		if (thing["jukebox"])
			track.track_flags |= TRACK_FLAG_JUKEBOX
		if (thing["roundend"])
			track.track_flags |= TRACK_FLAG_ROUNDEND
		if (thing["lobbymusic"])
			track.track_flags |= TRACK_FLAG_TITLE
		if (islist(thing["license"]))
			var/list/license_information = thing["license"]
			var/datum/license/license = new()
			license.title = license_information["title"]
			license.legal_text = license_information["legal_text"]
			license.url = license_information["url"]
			license.attribution_required = license_information["attribution_required"]
			track.license = license
		else if (thing["license"])
			var/path = text2path(thing["license"])
			if (!ispath(path, /datum/license))
				log_runtime("Invalid license specified in music.json, path is set to [thing["license"]] which isn't a /datum/license")
				continue
			track.license = new path()
		track.load()
		if (track._failed)
			log_runtime("Failed to load track [track.audio_file]/[track.url]")
			continue
		audio_tracks += track
		audio_tracks_by_url[track._web_sound_url] = track
	log_world("Successfully loaded [length(audio_tracks)] songs from music.json")

/datum/controller/subsystem/music/proc/select_title_music(list/audio_tracks)
	// Something else has set the lobby music already
	if (login_music)
		return
	var/list/shuffled_tracks = shuffle(audio_tracks)
	login_music_playlist = list()
	// Try to load map specific music first
	if (LAZYLEN(SSmapping.config.title_music))
		for (var/datum/audio_track/track in shuffled_tracks)
			if (track.title in SSmapping.config.title_music)
				login_music_playlist += track
		if (length(login_music_playlist))
			var/datum/audio_track/picked = login_music_playlist[1]
			login_music = picked.play(PLAYING_FLAG_TITLE_MUSIC)
			SSmusic.play_global_music(login_music)
			last_song_name = picked.title
			rustg_file_write(picked.title, LAST_LOBBY_MUSIC_TXT)
			return
	// Search for lobby music that we didn't just play
	var/last_song
	for (var/datum/audio_track/track in shuffled_tracks)
		if (!(track.track_flags & TRACK_FLAG_TITLE))
			continue
		if (track.title == last_song_name)
			last_song = track
			continue
		login_music_playlist += track
	// ONE MORE SONG. ONE MORE SONG.
	if (last_song)
		login_music_playlist += last_song
	if (!length(login_music_playlist))
		login_music_playlist = shuffled_tracks
		if (!length(login_music_playlist))
			CRASH("No music has been loaded, meaning a title-track cannot be played.")
	var/datum/audio_track/picked = login_music_playlist[1]
	login_music = picked.play(PLAYING_FLAG_TITLE_MUSIC)
	SSmusic.play_global_music(login_music)
	last_song_name = picked.title
	rustg_file_write(picked.title, LAST_LOBBY_MUSIC_TXT)

/datum/controller/subsystem/music/proc/play_next_lobby_song()
	login_music?.stop_playing_to_clients()
	current_login_song ++
	if (current_login_song > length(login_music_playlist))
		current_login_song = 1
	var/datum/audio_track/picked = login_music_playlist[current_login_song]
	login_music = picked.play(PLAYING_FLAG_TITLE_MUSIC)
	SSmusic.play_global_music(login_music)
	last_song_name = picked.title
	rustg_file_write(picked.title, LAST_LOBBY_MUSIC_TXT)

/datum/controller/subsystem/music/fire(resumed)
	// Run through our playing audio tracks and cull anyones that we think might be finished
	if (!resumed)
		index = 1
	// Check if we need to change the title song
	if (login_music && login_music.audio.duration && world.time > login_music.started_at + login_music.audio.duration)
		play_next_lobby_song()
	// Run through global audio tracks
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
	for (var/client/client in GLOB.clients)
		// If this is a title music, don't play it to anyone who has skipped title music
		if ((playing.playing_flags & PLAYING_FLAG_TITLE_MUSIC) && (client.personal_lobby_music || !isnewplayer(client.mob)))
			continue
		playing.internal_play_to_client(client)
	global_audio_tracks += playing

/datum/controller/subsystem/music/proc/play_spatial_music(datum/playing_track/spatial/playing)
	for (var/client/client in GLOB.clients)
		// If this is a title music, don't play it to anyone who has skipped title music
		if ((playing.playing_flags & PLAYING_FLAG_TITLE_MUSIC) && (client.personal_lobby_music || !isnewplayer(client.mob)))
			continue
		playing.internal_play_to_client(client)
	spatial_audio_tracks += playing

/datum/controller/subsystem/music/proc/feed_music_async(client/target)
	DECLARE_ASYNC
	// Global audio
	for (var/datum/playing_track/playing in global_audio_tracks)
		if ((playing.playing_flags & PLAYING_FLAG_TITLE_MUSIC) && (target.personal_lobby_music || !isnewplayer(target.mob)))
			continue
		playing.internal_play_to_client(target)
	// Spatial audio
	for (var/datum/playing_track/playing in spatial_audio_tracks)
		if ((playing.playing_flags & PLAYING_FLAG_TITLE_MUSIC) && (target.personal_lobby_music || !isnewplayer(target.mob)))
			continue
		playing.internal_play_to_client(target)
	// Personal lobby music
	if (target.personal_lobby_music)
		target.personal_lobby_music.internal_play_to_client(target)
	ASYNC_FINISH
