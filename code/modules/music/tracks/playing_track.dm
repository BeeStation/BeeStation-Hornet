/datum/playing_track
	var/static/total_count = 0
	var/uuid
	var/datum/audio_track/audio
	var/started_at

/datum/playing_track/New(datum/audio_track/audio, started_at)
	uuid = total_count++
	src.audio = audio
	src.started_at = started_at
	return ..()

/datum/playing_track/proc/play_to_clients()
	// Stop playing to everyone, since it's not that expensive of a message
	for (var/client/C in GLOB.clients)
		C.tgui_panel?.play_global_music(src)

/datum/playing_track/proc/stop_playing_to_clients()
	// Stop playing to everyone, since it's not that expensive of a message
	for (var/client/C in GLOB.clients)
		C.tgui_panel?.stop_playing(src)
