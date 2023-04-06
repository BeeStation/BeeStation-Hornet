/** Assigned say modal of the client */
/client/var/datum/tgui_say/tgui_say

/**
 * Creates a JSON encoded message to open TGUI say modals properly.
 *
 * Arguments:
 * channel - The channel to open the modal in.
 * Returns:
 * string - A JSON encoded message to open the modal.
 */
/client/proc/tgui_say_create_open_command(channel)
	var/message = TGUI_CREATE_MESSAGE("open", list(
		channel = channel,
	))
	return "\".output tgui_say.browser:update [message]\""

/**
 * Creates a JSON encoded message to close TGUI say modals.
 *
 * Returns:
 * string - A JSON encoded message to close the modal.
 */
/client/proc/tgui_say_create_close_command()
	var/message = TGUI_CREATE_MESSAGE_EMPTY("close")
	return "\".output tgui_say.browser:update [message]\""

/**
 * The tgui say modal. This initializes an input window which hides until
 * the user presses one of the speech hotkeys. Once something is entered, it will
 * delegate the speech to the proper channel.
 */
/datum/tgui_say
	/// The user who opened the window
	var/client/client
	/// Injury phrases to blurt out
	var/list/hurt_phrases = list(
		"GACK!",
		"GLORF!",
		"OOF!",
		"AUGH!",
		"OW!",
		"URGH!",
		"HRNK!",
		"ACK!",
	)
	/// Max message length
	var/max_length = MAX_MESSAGE_LEN
	/// The modal window
	var/datum/tgui_window/window
	/// Boolean for whether the tgui_say was opened by the user.
	var/window_open

/** Creates the new input window to exist in the background. */
/datum/tgui_say/New(client/client, id)
	src.client = client
	window = new(client, id)
	window.subscribe(src, PROC_REF(on_message))
	window.is_browser = TRUE

/**
 * After a brief period, injects the scripts into
 * the window to listen for open commands.
 */
/datum/tgui_say/proc/initialize()
	set waitfor = FALSE
	// Sleep to defer initialization to after client constructor
	sleep(3 SECONDS)
	window.initialize(
			strict_mode = TRUE,
			fancy = TRUE,
			// Switch inline to assets for hot-reload in development
			inline_css = file("tgui/public/tgui-say.bundle.css"),
			inline_js = file("tgui/public/tgui-say.bundle.js"),
			//assets = list(
			//	get_asset_datum(/datum/asset/simple/tgui_say),
			//),
	);

/**
 * Ensures nothing funny is going on window load.
 * Minimizes the window, sets max length, closes all
 * typing and thinking indicators. This is triggered
 * as soon as the window sends the "ready" message.
 */
/datum/tgui_say/proc/load()
	window_open = FALSE
	// Width and height are from skin.dmf, no way to not hardcode these unfortunately.
	client.center_window("tgui_say", 231, 30)
	winshow(client, "tgui_say", FALSE)
	window.send_message("props", list(
		lightMode = (client?.prefs?.toggles2 & PREFTOGGLE_2_SAY_LIGHT_THEME),
		showRadioPrefix = (client?.prefs?.toggles2 & PREFTOGGLE_2_SAY_SHOW_PREFIX),
		maxLength = max_length,
	))
	stop_thinking()
	return TRUE

/**
 * Sets the window as "opened" server side, though it is already
 * visible to the user. We do this to set local vars &
 * start typing (if enabled and in an IC channel). Logs the event.
 *
 * Arguments:
 * payload - A list containing the channel the window was opened in.
 */
/datum/tgui_say/proc/open(payload)
	if(!payload?["channel"])
		CRASH("No channel provided to an open TGUI-Say")
	window_open = TRUE
	if(payload["channel"] != OOC_CHANNEL && payload["channel"] != LOOC_CHANNEL)
		start_thinking()
	log_speech_indicators("[key_name(client)] started typing at [loc_name(client.mob)].")
	return TRUE

/**
 * Closes the window serverside. Closes any open chat bubbles
 * regardless of preference. Logs the event.
 */
/datum/tgui_say/proc/close()
	window_open = FALSE
	stop_thinking()
	log_speech_indicators("[key_name(client)] stopped typing at [loc_name(client.mob)].")

/**
 * The equivalent of ui_act, this waits on messages from the window
 * and delegates actions.
 */
/datum/tgui_say/proc/on_message(type, payload)
	if(type == "ready")
		load()
		return TRUE
	if (type == "open")
		open(payload)
		return TRUE
	if (type == "close")
		close()
		return TRUE
	if (type == "thinking")
		if(payload["mode"] == TRUE)
			start_thinking()
			return TRUE
		if(payload["mode"] == FALSE)
			stop_thinking()
			return TRUE
		return FALSE
	if (type == "typing")
		start_typing()
		return TRUE
	if (type == "entry" || type == "force")
		handle_entry(type, payload)
		return TRUE
	return FALSE
