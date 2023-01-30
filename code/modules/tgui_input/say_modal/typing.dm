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

/mob/living/create_typing_indicator()
	if(typing_indicator || thinking_indicator || !thinking_IC || stat != CONSCIOUS)
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

