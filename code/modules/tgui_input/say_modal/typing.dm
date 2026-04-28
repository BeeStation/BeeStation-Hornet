
/// Typing
GLOBAL_DATUM_INIT(blind_typing_indicator, /mutable_appearance, mutable_appearance('icons/mob/talk.dmi', "default0", (-TYPING_LAYER), BLIND_FEATURE_PLANE, appearance_flags = KEEP_TOGETHER))

/** Creates a thinking indicator over the mob. */
/mob/proc/create_thinking_indicator()
	return

/** Removes the thinking indicator over the mob. */
/mob/proc/remove_thinking_indicator()
	return

/** Creates a typing indicator over the mob. */
/mob/proc/create_typing_indicator()
	return

/** Removes the typing indicator over the mob. */
/mob/proc/remove_typing_indicator()
	return

/** Removes any indicators and marks the mob as not speaking IC. */
/mob/proc/remove_all_indicators()
	return

/mob/set_stat(new_stat)
	. = ..()
	if(.)
		remove_all_indicators()

/mob/Logout()
	remove_all_indicators()
	return ..()

/** Sets the mob as "thinking" - with indicator and the TRAIT_THINKING_IN_CHARACTER trait */
/datum/tgui_say/proc/start_thinking()
	if(!window_open)
		return FALSE
	return client.start_thinking()

/** Removes typing/thinking indicators and flags the mob as not thinking */
/datum/tgui_say/proc/stop_thinking()
	if(!istype(client.mob))
		return FALSE
	return client.stop_thinking()

/**
 * Handles the user typing. After a brief period of inactivity,
 * signals the client mob to revert to the "thinking" icon.
 */
/datum/tgui_say/proc/start_typing()
	if(!istype(client.mob))
		return FALSE
	if(!window_open)
		return FALSE
	return client.start_typing()

/**
 * Remove the typing indicator after a brief period of inactivity or during say events.
 * If the user was typing IC, the thinking indicator is shown.
 */
/datum/tgui_say/proc/stop_typing()
	if(!window_open)
		return FALSE
	client.stop_typing()

/// Overrides for overlay creation
/mob/living/create_thinking_indicator()
	if(active_thinking_indicator || active_typing_indicator || stat != CONSCIOUS || !HAS_TRAIT(src, TRAIT_THINKING_IN_CHARACTER))
		return FALSE
	active_thinking_indicator = mutable_appearance('icons/mob/talk.dmi', "[bubble_icon]3", TYPING_LAYER)
	add_overlay(active_thinking_indicator)

/mob/living/remove_thinking_indicator()
	if(!active_thinking_indicator)
		return FALSE
	cut_overlay(active_thinking_indicator)
	active_thinking_indicator = null

/mob/living/create_typing_indicator(override = FALSE)
	if(active_typing_indicator || ((active_thinking_indicator || !HAS_TRAIT(src, TRAIT_THINKING_IN_CHARACTER)) && !override) || stat != CONSCIOUS)
		return FALSE
	active_typing_indicator = mutable_appearance('icons/mob/talk.dmi', "[bubble_icon]0", TYPING_LAYER)
	add_overlay(active_typing_indicator)
	add_overlay(GLOB.blind_typing_indicator)

/mob/living/remove_typing_indicator()
	if(!active_typing_indicator)
		return FALSE
	cut_overlay(active_typing_indicator)
	cut_overlay(GLOB.blind_typing_indicator)
	active_typing_indicator = null

/mob/living/remove_all_indicators()
	REMOVE_TRAIT(src, TRAIT_THINKING_IN_CHARACTER, CURRENTLY_TYPING_TRAIT)
	remove_thinking_indicator()
	remove_typing_indicator()

// ---------------------------
//       LEGACY SUPPORT
// ---------------------------

////Typing verbs////
//Those are used to show the typing indicator for the player without waiting on the client.

/*
Some information on how these work:
The keybindings for say and me have been modified to call start_typing and immediately open the textbox clientside.
Because of this, the client doesn't have to wait for a message from the server before opening the textbox, the server
knows immediately when the user pressed the hotkey, and the clientside textbox can signal success or failure to the server.
When you press the hotkey, the .start_typing verb is called with the source ("say" or "me") to show the typing indicator.
When you send a message from the custom window, the appropriate verb is called, .say or .me
If you close the window without actually sending the message, the .cancel_typing verb is called with the source.
Both the say/me wrappers and cancel_typing remove the typing indicator.
*/

/// Show the typing indicator. The source signifies what action the user is typing for.
/mob/verb/start_typing(source as text) // The source argument is currently unused
	set name = ".start_typing"
	set hidden = 1

	create_typing_indicator(TRUE)

/// Hide the typing indicator. The source signifies what action the user was typing for.
/mob/verb/cancel_typing(source as text)
	set name = ".cancel_typing"
	set hidden = 1

	remove_typing_indicator()

////Wrappers////
//Keybindings were updated to change to use these wrappers. If you ever remove this file, revert those keybind changes

/mob/verb/say_wrapper(message as text)
	set name = ".Say"
	set hidden = 1
	set instant = 1

	remove_typing_indicator()
	if(message)
		say_verb(message)

/mob/verb/me_wrapper(message as text)
	set name = ".Me"
	set hidden = 1
	set instant = 1

	remove_typing_indicator()
	if(message)
		me_verb(message)
