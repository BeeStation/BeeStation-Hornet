/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

GLOBAL_LIST_EMPTY(tgui_panels)

/**
 * tgui_panel datum
 * Hosts tgchat and other nice features.
 */
/datum/tgui_panel
	var/client/client
	var/datum/tgui_window/window
	var/broken = FALSE
	var/initialized_at
	/// Owner of this tgui panel's CKEY, so it can be looked up later via GLOB.tgui_panels
	var/owner_ckey

/datum/tgui_panel/New(client/client, id)
	src.client = client
	owner_ckey = ckey(client.ckey)
	window = new(client, id)
	window.subscribe(src, PROC_REF(on_message))
	GLOB.tgui_panels += src

/datum/tgui_panel/Del()
	window.unsubscribe(src)
	window.close()
	return ..()

/**
 * public
 *
 * TRUE if panel is initialized and ready to receive messages.
 */
/datum/tgui_panel/proc/is_ready()
	return !broken && window.is_ready()

/**
 * public
 *
 * Initializes tgui panel.
 */
/datum/tgui_panel/proc/Initialize(force = FALSE)
	set waitfor = FALSE
	// Minimal sleep to defer initialization to after client constructor
	sleep(1)
	if(!src.client)
		return
	initialized_at = world.time
	// Perform a clean initialization
	window.initialize(assets = list(
		strict_mode = TRUE,
		get_asset_datum(/datum/asset/simple/tgui_panel),
	))
	window.send_asset(get_asset_datum(/datum/asset/simple/namespaced/fontawesome))
	window.send_asset(get_asset_datum(/datum/asset/simple/namespaced/tgfont))
	window.send_asset(get_asset_datum(/datum/asset/spritesheet_batched/chat))
	// Preload assets for /datum/tgui
	var/datum/asset/asset_tgui = get_asset_datum(/datum/asset/simple/tgui)
	if(!src.client)
		return
	var/flush_queue = asset_tgui.send(src.client)
	if(!src.client)
		return
	if(flush_queue)
		src.client.browse_queue_flush()
	if(!src.client)
		return
	// Other setup
	request_telemetry()
	// Send verbs
	if(client)
		set_verb_infomation(client)
	addtimer(CALLBACK(src, PROC_REF(on_initialize_timed_out)), 5 SECONDS)

/**
 * private
 *
 * Called when initialization has timed out.
 */
/datum/tgui_panel/proc/on_initialize_timed_out()
	if(!client)
		return
	// Currently does nothing but sending a message to old chat.
	SEND_TEXT(client, span_userdanger("Failed to load fancy chat, click <a href='byond://?src=[REF(src)];reload_tguipanel=1'>HERE</a> to attempt to reload it."))
	log_tgui("ERROR: [client?.ckey] failed to load their fancy chat after a 5 second timeout when loading.")
	SEND_TEXT(client, span_warning("If the problem persists after fix-chat, try restarting your game as Byond can get confused if the stylesheet it was expecting has changed. (If you have recently played on a server not using TGchat)."))

/**
 * private
 *
 * Callback for handling incoming tgui messages.
 */
/datum/tgui_panel/proc/on_message(type, payload)
	if(type == "ready")
		broken = FALSE
		window.send_message("update", list(
			"config" = list(
				"client" = list(
					"ckey" = client.ckey,
					"address" = client.address,
					"computer_id" = client.computer_id,
				),
				"window" = list(
					"fancy" = FALSE,
					"locked" = FALSE,
				),
			),
		))
		return TRUE
	if(type == "audio/setAdminMusicVolume")
		client.admin_music_volume = payload["volume"]
		return TRUE
	if(type == "telemetry")
		analyze_telemetry(payload)
		return TRUE
	if(cmptext(copytext(type, 1, 5), "stat"))
		return handle_stat_message(type, payload)

/**
 * public
 *
 * Sends a round restart notification.
 */
/datum/tgui_panel/proc/send_roundrestart()
	window.send_message("roundrestart")
