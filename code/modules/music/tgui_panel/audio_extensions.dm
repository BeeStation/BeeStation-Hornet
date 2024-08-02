/**
 * Modularised extensions file for modules/tgui_panel/audio.dm
 */

/datum/tgui_panel/var/needs_spatial_audio = FALSE

/datum/tgui_panel/proc/play_global_music(datum/playing_track/track)
	if(!is_ready())
		return FALSE
	if(!track.audio._audio_asset && !findtext(track.audio._web_sound_url, GLOB.is_http_protocol))
		return FALSE
	if (track.audio._failed)
		return FALSE
	// Transport assets
	if (track.audio._audio_asset)
		track.audio._audio_asset.send(client)
	var/list/payload = list()
	var/list/extra_data = track.audio.get_additional_information()
	if(length(extra_data) > 0)
		for(var/key in extra_data)
			payload[key] = extra_data[key]
	if (payload["start"])
		payload["start"] = payload["start"] + (world.time - track.started_at) * 0.1
	else
		payload["start"] = (world.time - track.started_at) * 0.1
	if (istype(track.audio.license))
		payload["license_title"] = track.audio.license.title
		payload["license_url"] = track.audio.license.legal_text
	payload["uuid"] = track.uuid
	payload["url"] = track.audio._web_sound_url
	payload["priority"] = track.priority
	payload["flags"] = track.playing_flags
	payload["volume"] = track.track_volume
	window.send_message("audio/playMusic", payload)
	return TRUE

/**
 * Play music with a given 3D position in the world
 */
/datum/tgui_panel/proc/play_spatial_music(datum/playing_track/spatial/track)
	if(!is_ready())
		return FALSE
	if(!track.audio._audio_asset && !findtext(track.audio._web_sound_url, GLOB.is_http_protocol))
		return FALSE
	if (track.audio._failed)
		return FALSE
	// Transport assets
	if (track.audio._audio_asset)
		track.audio._audio_asset.send(client)
	var/list/payload = list()
	var/list/extra_data = track.audio.get_additional_information()
	if(length(extra_data) > 0)
		for(var/key in extra_data)
			payload[key] = extra_data[key]
	if (payload["start"])
		payload["start"] = payload["start"] + (world.time - track.started_at) * 100
	else
		payload["start"] = (world.time - track.started_at) * 100
	if (istype(track.audio.license))
		payload["license_title"] = track.audio.license.title
		payload["license_url"] = track.audio.license.legal_text
	payload["uuid"] = track.uuid
	payload["url"] = track.audio._web_sound_url
	payload["priority"] = track.priority
	var/turf/location = get_turf(track.source)
	if (!location)
		payload["x"] = 0
		payload["y"] = 0
		payload["z"] = 0
	else
		payload["x"] = location.x
		payload["y"] = location.y
		payload["z"] = location.z
	payload["range"] = track.radius
	payload["flags"] = track.playing_flags
	payload["volume"] = track.track_volume
	window.send_message("audio/playWorldMusic", payload)
	needs_spatial_audio = TRUE
	// Become a music listener
	client.mob.AddComponent(/datum/component/music_listener, src)
	return TRUE

/datum/tgui_panel/proc/update_track_position(datum/playing_track/spatial/track)
	if(!is_ready())
		return FALSE
	var/list/payload = list()
	payload["uuid"] = track.uuid
	var/turf/location = get_turf(track.source)
	if (!location)
		payload["x"] = 0
		payload["y"] = 0
		payload["z"] = 0
	else
		payload["x"] = location.x
		payload["y"] = location.y
		payload["z"] = location.z
	window.send_message("audio/updateMusicPosition", payload)

/datum/tgui_panel/proc/stop_playing(datum/playing_track/track)
	if(!is_ready())
		return
	var/list/payload = list()
	payload["uuid"] = track.uuid
	window.send_message("audio/stopPlaying", payload)

/datum/tgui_panel/proc/update_volume(datum/playing_track/track)
	if(!is_ready())
		return
	var/list/payload = list()
	payload["uuid"] = track.uuid
	payload["volume"] = track.track_volume
	window.send_message("audio/updateVolume", payload)

/**
 * Updates the position of our listener.
 */
/datum/tgui_panel/proc/update_listener_position(x, y, z)
	if(!is_ready())
		return
	var/list/payload = list()
	payload["x"] = x
	payload["y"] = y
	payload["z"] = z
	window.send_message("audio/updateListener", payload)
