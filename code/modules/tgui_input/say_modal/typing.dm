/// Thinking
GLOBAL_DATUM_INIT(thinking_indicator, /mutable_appearance, mutable_appearance('icons/mob/talk.dmi', "default3", TYPING_LAYER))
/// Typing
GLOBAL_DATUM_INIT(typing_indicator, /mutable_appearance, mutable_appearance('icons/mob/talk.dmi', "default0", TYPING_LAYER))


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

/** Sets the mob as "thinking" - with indicator and variable thinking_IC */
/datum/tgui_say/proc/start_thinking()
	if(!window_open)
		return FALSE
	/// Special exemptions
	if(isabductor(client.mob))
		return FALSE
	client.mob.thinking_IC = TRUE
	client.mob.create_thinking_indicator()

/** Removes typing/thinking indicators and flags the mob as not thinking */
/datum/tgui_say/proc/stop_thinking()
	client.mob.remove_all_indicators()

/**
 * Handles the user typing. After a brief period of inactivity,
 * signals the client mob to revert to the "thinking" icon.
 */
/datum/tgui_say/proc/start_typing()
	client.mob.remove_thinking_indicator()
	if(!window_open || !client.mob.thinking_IC)
		return FALSE
	client.mob.create_typing_indicator()
	addtimer(CALLBACK(src, .proc/stop_typing), 5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)

/**
 * Callback to remove the typing indicator after a brief period of inactivity.
 * If the user was typing IC, the thinking indicator is shown.
 */
/datum/tgui_say/proc/stop_typing()
	if(!client?.mob)
		return FALSE
	client.mob.remove_typing_indicator()
	if(!window_open || !client.mob.thinking_IC)
		return FALSE
	client.mob.create_thinking_indicator()

/// Overrides for overlay creation
/mob/living/create_thinking_indicator()
	if(thinking_indicator || typing_indicator || !thinking_IC || stat != CONSCIOUS )
		return FALSE
	add_overlay(GLOB.thinking_indicator)
	thinking_indicator = TRUE

/mob/living/remove_thinking_indicator()
	if(!thinking_indicator)
		return FALSE
	cut_overlay(GLOB.thinking_indicator)
	thinking_indicator = FALSE

/mob/living/create_typing_indicator(override = FALSE)
	if(typing_indicator || ((thinking_indicator || !thinking_IC) && !override) || stat != CONSCIOUS)
		return FALSE
	add_overlay(GLOB.typing_indicator)
	typing_indicator = TRUE

/mob/living/remove_typing_indicator()
	if(!typing_indicator)
		return FALSE
	cut_overlay(GLOB.typing_indicator)
	typing_indicator = FALSE

/mob/living/remove_all_indicators()
	thinking_IC = FALSE
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
