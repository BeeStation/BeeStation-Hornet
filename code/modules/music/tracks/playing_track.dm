/datum/playing_track
	var/static/total_count = 0
	var/uuid
	var/datum/audio_track/audio
	var/started_at
	var/playing_flags = PLAYING_FLAG_DEFAULT
	var/track_volume = 1
	var/priority = 1
	// Only if spatial audio
	var/radius = null
	var/atom/source = null

/datum/playing_track/New(datum/audio_track/audio, started_at, playing_flags)
	uuid = total_count++
	src.audio = audio
	src.started_at = started_at
	src.playing_flags = playing_flags
	return ..()

/**
 * Use the music playing wrappers on SSmusic instead of using this one.
 * You can use the other ones though.
 */
/datum/playing_track/proc/internal_play_to_client(client/target)
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

/datum/playing_track/spatial/New(atom/source, datum/audio_track/audio, started_at, playing_flags, radius)
	src.source = source
	src.radius = radius
	RegisterSignal(source, COMSIG_MOVABLE_MOVED, PROC_REF(source_moved))
	RegisterSignal(source, COMSIG_PARENT_QDELETING, PROC_REF(source_destroyed))
	return ..(audio, started_at, playing_flags)

/// We need to handle destroy, since this can be destroyed unlike global audio
/datum/playing_track/spatial/Destroy(force, ...)
	for (var/client/client in GLOB.clients)
		client.tgui_panel?.stop_playing(src)
	SSmusic.spatial_audio_tracks -= src
	return ..()

/datum/playing_track/spatial/internal_play_to_client(client/target)
	target.tgui_panel?.play_spatial_music(src)

/datum/playing_track/spatial/proc/source_moved()
	SIGNAL_HANDLER
	for (var/client/client in GLOB.clients)
		client.tgui_panel?.update_track_position(src)

/datum/playing_track/spatial/proc/source_destroyed()
	SIGNAL_HANDLER
	qdel(src)
