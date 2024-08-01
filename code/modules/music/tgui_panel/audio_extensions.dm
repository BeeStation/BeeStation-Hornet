/**
 * Modularised extensions file for modules/tgui_panel/audio.dm
 */

/**
 * Play music with a given 3D position in the world
 */
/datum/tgui_panel/proc/play_world_music(datum/audio_track/track, atom/source, radius, priority = 0)
	if(!is_ready())
		return FALSE
	if(!track.audio_asset && !findtext(track.web_sound_url, GLOB.is_http_protocol))
		return FALSE
	if (track.failed)
		return FALSE
	// Transport assets
	if (track.audio_asset)
		track.audio_asset.send(client)
	var/list/payload = list()
	var/list/extra_data = track.get_additional_information()
	if(length(extra_data) > 0)
		for(var/key in extra_data)
			payload[key] = extra_data[key]
	if (istype(track.license))
		payload["license_title"] = track.license.title
		payload["license_url"] = track.license.legal_text
	payload["url"] = track.web_sound_url
	payload["priority"] = priority
	var/turf/location = get_turf(source)
	if (!location)
		CRASH("Attempting to play world music from a null location which is not allowed.")
	payload["x"] = location.x
	payload["y"] = location.y
	payload["z"] = location.z
	payload["range"] = radius
	window.send_message("audio/playWorldMusic", payload)
	return TRUE

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
