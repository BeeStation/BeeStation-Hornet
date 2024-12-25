/client/proc/skip_lobby_song()
	var/hear = prefs.read_player_preference(/datum/preference/toggle/sound_lobby)
	if (!isnewplayer(mob) || !hear)
		return
	// Stop playing this song
	if (personal_lobby_music)
		personal_lobby_music.stop_playing_to(src)
	else
		SSmusic.login_music?.stop_playing_to(src)
	// Find a new song to play
	if (!personal_lobby_music_index)
		personal_lobby_music_index = SSmusic.current_login_song
	personal_lobby_music_index++
	if (personal_lobby_music_index > length(SSmusic.login_music_playlist))
		personal_lobby_music_index = 1
	var/datum/audio_track/played_track = SSmusic.login_music_playlist[personal_lobby_music_index]
	personal_lobby_music = played_track.play(PLAYING_FLAG_TITLE_MUSIC)
	personal_lobby_music.internal_play_to_client(src)
