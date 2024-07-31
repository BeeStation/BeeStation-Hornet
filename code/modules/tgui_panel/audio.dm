/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/// Admin music volume, from 0 to 1.
/client/var/admin_music_volume = 1

/**
 * public
 *
 * Sends music data to the browser.
 *
 * Optional settings:
 * - pitch: the playback rate
 * - start: the start time of the sound
 * - end: when the musics stops playing
 *
 * required url string: Must be an https URL.
 * optional priority number: The priority of this sound, only 1 track can be played at a time so this allows overlapping
 * optional extra_data list: Optional settings.
 */
/datum/tgui_panel/proc/play_music(url, priority = 0, extra_data = null)
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
	window.send_message("audio/playMusic", payload)

/**
 * public
 *
 * Stops playing music through the browser.
 */
/datum/tgui_panel/proc/stop_music()
	if(!is_ready())
		return
	window.send_message("audio/stopMusic")
