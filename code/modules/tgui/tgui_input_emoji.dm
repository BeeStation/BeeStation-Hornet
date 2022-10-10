/**
 * Creates a TGUI window with a emoji input. Returns the user's response.
 *
 * This proc should be used to create windows for emoji entry that the caller will wait for a response from.
 * If tgui fancy chat is turned off: Will return a normal input. If max_length is specified, will return
 * stripped_multiline_input.
 *
 * Arguments:
 * * user - The user to show the textbox to.
 * * title - The title of the textbox modal, shown on the top of the TGUI window.
 */
/proc/tgui_input_emoji(mob/user, title = "Emoji Input")
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	var/datum/tgui_input_emoji/textbox = new(user, title)
	textbox.ui_interact(user)
	textbox.wait()
	if (textbox)
		. = textbox.entry
		qdel(textbox)

/**
 * Creates an asynchronous TGUI emoji input window with an associated callback.
 *
 * This proc should be used to create textboxes that invoke a callback with the user's entry.
 * Arguments:
 * * user - The user to show the textbox to.
 * * title - The title of the textbox modal, shown on the top of the TGUI window.
 * * callback - The callback to be invoked when a choice is made.
 */
/proc/tgui_input_emoji_async(mob/user, title = "Emoji Input", datum/callback/callback)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	var/datum/tgui_input_emoji/async/textbox = new(user, title, callback)
	textbox.ui_interact(user)

/**
 * # tgui_input_emoji
 *
 * Datum used for instantiating and using a TGUI-controlled textbox that prompts the user with
 * a message and has an input for emoji entry.
 */
/datum/tgui_input_emoji
	/// Boolean field describing if the tgui_input_emoji was closed by the user.
	var/closed
	/// The entry that the user has return_typed in.
	var/entry
	/// The title of the TGUI window
	var/title


/datum/tgui_input_emoji/New(mob/user, title)
	src.title = title

/datum/tgui_input_emoji/Destroy(force, ...)
	SStgui.close_uis(src)
	. = ..()

/**
 * Waits for a user's response to the tgui_input_emoji's prompt before returning. Returns early if
 * the window was closed by the user.
 */
/datum/tgui_input_emoji/proc/wait()
	while (!entry && !closed && !QDELETED(src))
		stoplag(1)

/datum/tgui_input_emoji/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EmojiInputModal")
		ui.open()

/datum/tgui_input_emoji/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_input_emoji/ui_state(mob/user)
	return GLOB.always_state

/datum/tgui_input_emoji/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/emoji)
	)

/datum/tgui_input_emoji/ui_static_data(mob/user)
	return list(
		"all_emojis" = icon_states(icon('icons/emoji.dmi'))
	)

/datum/tgui_input_emoji/ui_data(mob/user)
	return list(
		"title" = title,
	)

/datum/tgui_input_emoji/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("submit")
			set_entry(params["entry"])
			SStgui.close_uis(src)
			return TRUE
		if("cancel")
			set_entry(null)
			SStgui.close_uis(src)
			return TRUE

/datum/tgui_input_emoji/proc/set_entry(entry)
		src.entry = entry

/**
 * # async tgui_input_emoji
 *
 * An asynchronous version of tgui_input_emoji to be used with callbacks instead of waiting on user responses.
 */
/datum/tgui_input_emoji/async
	/// The callback to be invoked by the tgui_input_emoji upon having a choice made.
	var/datum/callback/callback

/datum/tgui_input_emoji/async/New(mob/user, title, callback)
	..(user, title)
	src.callback = callback

/datum/tgui_input_emoji/async/Destroy(force, ...)
	QDEL_NULL(callback)
	. = ..()

/datum/tgui_input_emoji/async/set_entry(entry)
	. = ..()
	if(!isnull(src.entry))
		callback?.InvokeAsync(src.entry)

/datum/tgui_input_emoji/async/wait()
	return
