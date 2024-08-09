//world/proc/shelleo
#define SHELLEO_ERRORLEVEL 1
#define SHELLEO_STDOUT 2
#define SHELLEO_STDERR 3

/client/proc/play_sound(S as sound)
	set category = "Fun"
	set name = "Play Global Sound"
	if(!check_rights(R_SOUND))
		return

	var/freq = 1
	var/vol = input(usr, "What volume would you like the sound to play at?",, 100) as null|num
	if(!vol)
		return
	vol = clamp(vol, 1, 100)

	var/sound/admin_sound = new()
	admin_sound.file = S
	admin_sound.priority = 250
	admin_sound.channel = CHANNEL_ADMIN
	admin_sound.frequency = freq
	admin_sound.wait = 1
	admin_sound.repeat = 0
	admin_sound.status = SOUND_STREAM
	admin_sound.volume = vol

	var/res = alert(usr, "Show the title of this song to the players?",, "Yes","No", "Cancel")
	switch(res)
		if("Yes")
			to_chat(world, "<span class='boldannounce'>An admin played: [S]</span>")
		if("Cancel")
			return

	log_admin("[key_name(src)] played sound [S]")
	message_admins("[key_name_admin(src)] played sound [S]")

	for(var/mob/M in GLOB.player_list)
		if(M.client.prefs.read_player_preference(/datum/preference/toggle/sound_midi))
			admin_sound.volume = vol * M.client.admin_music_volume
			SEND_SOUND(M, admin_sound)
			admin_sound.volume = vol

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Global Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/play_local_sound(S as sound)
	set category = "Fun"
	set name = "Play Local Sound"
	if(!check_rights(R_SOUND))
		return

	log_admin("[key_name(src)] played a local sound [S]")
	message_admins("[key_name_admin(src)] played a local sound [S]")
	playsound(get_turf(src.mob), S, 50, 0, 0)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Local Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/add_jukebox_music()
	set category = "Fun"
	set name = "Add Jukebox Music"
	if(!check_rights(R_SOUND))
		return
	var/datum/audio_track/track = new()
	track.track_flags = TRACK_FLAG_JUKEBOX
	var/web_sound_input = capped_input(usr, "Enter content URL (supported sites only)", "Add Internet Sound via youtube-dl")
	if (!web_sound_input)
		return
	track.url = web_sound_input
	to_chat(src, "<span class='boldwarning'Loading...</span>")
	track.load()
	if (track._failed)
		to_chat(src, "<span class='boldwarning'>Song-loading failed, see the world log for more details.</span>")
		return
	// If this is already loaded, then skip
	if (SSmusic.audio_tracks_by_url[track._web_sound_url])
		to_chat(src, "<span class='boldwarning'Song loaded successfully!</span>")
		return
	SSmusic.audio_tracks += track
	SSmusic.audio_tracks_by_url[track._web_sound_url] = track
	to_chat(src, "<span class='boldwarning'Song loaded successfully!</span>")

/client/proc/queue_lobby_song()
	set category = "Fun"
	set name = "Queue Lobby Song"
	if(!check_rights(R_SOUND))
		return
	var/datum/audio_track/track = new()
	track.track_flags = TRACK_FLAG_TITLE
	var/web_sound_input = capped_input(usr, "Enter content URL (supported sites only)", "Add Internet Sound via youtube-dl")
	if (!web_sound_input)
		return
	track.url = web_sound_input
	to_chat(src, "<span class='boldwarning'Loading...</span>")
	track.load()
	if (track._failed)
		to_chat(src, "<span class='boldwarning'>Song-loading failed, see the world log for more details.</span>")
		return
	// If this is already loaded, then skip
	if (SSmusic.audio_tracks_by_url[track._web_sound_url])
		track = SSmusic.audio_tracks_by_url[track._web_sound_url]
	else
		SSmusic.audio_tracks += track
		SSmusic.audio_tracks_by_url[track._web_sound_url] = track
	SSmusic.login_music_playlist.Insert(SSmusic.current_login_song + 1, track)

/client/proc/play_lobby_song()
	set category = "Fun"
	set name = "Play Lobby Song"
	if(!check_rights(R_SOUND))
		return
	var/datum/audio_track/track = new()
	track.track_flags = TRACK_FLAG_TITLE
	var/web_sound_input = capped_input(usr, "Enter content URL (supported sites only)", "Add Internet Sound via youtube-dl")
	if (!web_sound_input)
		return
	track.url = web_sound_input
	to_chat(src, "<span class='boldwarning'Loading...</span>")
	track.load()
	if (track._failed)
		to_chat(src, "<span class='boldwarning'>Song-loading failed, see the world log for more details.</span>")
		return
	// If this is already loaded, then skip
	if (SSmusic.audio_tracks_by_url[track._web_sound_url])
		track = SSmusic.audio_tracks_by_url[track._web_sound_url]
	else
		SSmusic.audio_tracks += track
		SSmusic.audio_tracks_by_url[track._web_sound_url] = track
	SSmusic.login_music_playlist.Insert(SSmusic.current_login_song + 1, track)
	SSmusic.play_next_lobby_song()

/client/proc/play_web_sound()
	set category = "Fun"
	set name = "Play Internet Sound"
	if(!check_rights(R_SOUND))
		return

	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		to_chat(src, "<span class='boldwarning'>Youtube-dl was not configured, action unavailable</span>") //Check config.txt for the INVOKE_YOUTUBEDL value
		return

	var/web_sound_input = capped_input(usr, "Enter content URL (supported sites only, leave blank to stop playing)", "Play Internet Sound via youtube-dl")
	if(web_sound_input)
		var/datum/audio_track/track = new()
		if (!web_sound_input)
			return
		track.url = web_sound_input
		to_chat(src, "<span class='boldwarning'Loading...</span>")
		track.load()
		if (track._failed)
			to_chat(src, "<span class='boldwarning'>Song-loading failed, see the world log for more details.</span>")
			return
		// If this is already loaded, then skip
		if (SSmusic.audio_tracks_by_url[track._web_sound_url])
			track = SSmusic.audio_tracks_by_url[track._web_sound_url]
		else
			SSmusic.audio_tracks += track
			SSmusic.audio_tracks_by_url[track._web_sound_url] = track
		for (var/datum/playing_track/old_track in SSmusic.global_audio_tracks)
			if (!(old_track.playing_flags & PLAYING_FLAG_ADMIN))
				continue
			SSmusic.stop_global_music(old_track)
		var/datum/playing_track/played = track.play(PLAYING_FLAG_ADMIN)
		played.priority = 100
		SSmusic.play_global_music(played)
	else
		for (var/datum/playing_track/track in SSmusic.global_audio_tracks)
			if (!(track.playing_flags & PLAYING_FLAG_ADMIN))
				continue
			SSmusic.stop_global_music(track)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Internet Sound")

/client/proc/set_round_end_sound(S as sound)
	set category = "Fun"
	set name = "Set Round End Sound"
	if(!check_rights(R_SOUND))
		return

	SSticker.SetRoundEndSound(S)

	log_admin("[key_name(src)] set the round end sound to [S]")
	message_admins("[key_name_admin(src)] set the round end sound to [S]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Set Round End Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/play_soundtrack()
	set category = "Fun"
	set name = "Play Soundtrack Music"
	set desc = "Choose a song to play from the available soundtrack."

	var/station_only = alert(usr, "Play only on station?", "Station Setting", "Station Only", "All", "Cancel")
	if(station_only == "Cancel" || station_only == null)
		return
	var/soundtracks = subtypesof(/datum/soundtrack_song)
	for(var/datum/soundtrack_song/song as() in soundtracks)
		if(initial(song.file) != null)
			continue
		soundtracks -= song
	var/song_choice = input(usr, "Choose a song", "Song Choice", null) as null|anything in soundtracks
	if(!ispath(song_choice, /datum/soundtrack_song))
		return
	play_soundtrack_music(song_choice, only_station = (station_only == "Station Only" ? SOUNDTRACK_PLAY_ONLYSTATION : SOUNDTRACK_PLAY_ALL))

/client/proc/stop_sounds()
	set category = "Debug"
	set name = "Stop All Playing Sounds"
	if(!src.holder)
		return

	log_admin("[key_name(src)] stopped all currently playing sounds.")
	message_admins("[key_name_admin(src)] stopped all currently playing sounds.")
	for(var/mob/M in GLOB.player_list)
		if(M.client)
			SEND_SOUND(M, sound(null))
			var/client/C = M.client
			C?.tgui_panel?.stop_music()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Stop All Playing Sounds") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

#undef SHELLEO_ERRORLEVEL
#undef SHELLEO_STDOUT
#undef SHELLEO_STDERR
