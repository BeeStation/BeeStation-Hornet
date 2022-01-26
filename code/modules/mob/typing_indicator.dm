GLOBAL_DATUM_INIT(typing_indicator, /mutable_appearance, mutable_appearance('icons/mob/talk.dmi', "default0", -TYPING_LAYER))

/mob/proc/create_typing_indicator()
	return

/mob/proc/remove_typing_indicator()
	return

/mob/set_stat(new_stat)
	. = ..()
	if(.)
		remove_typing_indicator()

/mob/Logout()
	remove_typing_indicator()
	. = ..()

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

	create_typing_indicator()

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

///Human Typing Indicators///
/mob/living/create_typing_indicator()
	if(!typing_indicator && stat == CONSCIOUS) //Prevents sticky overlays and typing while in any state besides conscious
		add_overlay(GLOB.typing_indicator)
		typing_indicator = TRUE

/mob/living/remove_typing_indicator()
	if(typing_indicator)
		cut_overlay(GLOB.typing_indicator)
		typing_indicator = FALSE
