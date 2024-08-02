/datum/playing_track
	var/static/total_count = 0
	var/uuid
	var/datum/audio_track/audio
	var/started_at
	var/playing_flags = PLAYING_FLAG_DEFAULT
	var/track_volume = 1

/datum/playing_track/New(datum/audio_track/audio, started_at, playing_flags)
	uuid = total_count++
	src.audio = audio
	src.started_at = started_at
	src.playing_flags = playing_flags
	return ..()

/datum/playing_track/proc/play_to_clients()
	// Stop playing to everyone, since it's not that expensive of a message
	for (var/client/C in GLOB.clients)
		C.tgui_panel?.play_global_music(src)

/datum/playing_track/proc/play_to_client(client/target)
	target.tgui_panel?.play_global_music(src)

/datum/playing_track/proc/stop_playing_to_clients()
	// Stop playing to everyone, since it's not that expensive of a message
	for (var/client/C in GLOB.clients)
		C.tgui_panel?.stop_playing(src)

/datum/playing_track/proc/stop_playing_to(client/target)
	target.tgui_panel?.stop_playing(src)

/datum/playing_track/proc/update_volume()
	for (var/client/C in GLOB.clients)
		C.tgui_panel?.update_volume(src)
