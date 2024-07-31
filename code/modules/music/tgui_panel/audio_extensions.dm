/**
 * Modularised extensions file for modules/tgui_panel/audio.dm
 */

/**
 * Play music with a given 3D position in the world
 */
/datum/tgui_panel/proc/play_world_music(atom/source, url, radius, priority = 0, extra_data = null)
	if(!is_ready())
		return
	if(!findtext(url, GLOB.is_http_protocol))
		return
	var/list/payload = list()
	if(length(extra_data) > 0)
		for(var/key in extra_data)
			payload[key] = extra_data[key]
	payload["url"] = url
	payload["priority"] = priority
	var/turf/location = get_turf(source)
	if (!location)
		CRASH("Attempting to play world music from a null location which is not allowed.")
	payload["x"] = location.x
	payload["y"] = location.y
	payload["z"] = location.z
	payload["range"] = radius
	window.send_message("audio/playWorldMusic", payload)

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

/client/verb/debug_music()
	set name = "debug music"
	set category = "PowerfulBacon"
	mob.AddComponent(/datum/component/music_listener, tgui_panel)
	tgui_panel.play_world_music(get_turf(mob), tgui_input_text(mob, "give me a song URL"), 15, 5)
