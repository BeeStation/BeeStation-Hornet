GLOBAL_DATUM_INIT(human_typing_indicator, /mutable_appearance, mutable_appearance('icons/mob/talk.dmi', "typingindicator", -TYPING_LAYER))

/mob/proc/update_typing_indicator()
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

////Wrappers////
//Keybindings were updated to change to use these wrappers. If you ever remove this file, revert those keybind changes
/mob/verb/say_wrapper()
	set name = ".Say"
	set hidden = 1
	set instant = 1

	update_typing_indicator()
	var/message = input("","say (text)") as text|null
	remove_typing_indicator()
	if(message)
		say_verb(message)

/mob/verb/me_wrapper()
	set name = ".Me"
	set hidden = 1
	set instant = 1

	update_typing_indicator(TRUE)
	var/message = input("","me (text)") as text|null
	remove_typing_indicator()
	if(message)
		me_verb(message)

///Human Typing Indicators///
/mob/living/carbon/human/update_typing_indicator(me = FALSE)
	var/mob/living/carbon/human/H = src
	if((HAS_TRAIT(H, TRAIT_MUTE) || H.silent) && !me)
		remove_overlay(TYPING_LAYER)
		return

	if(client)
		if(stat != CONSCIOUS || is_muzzled() || (client.prefs.toggles & TYPING_INDICATOR_SAY) || (me && (client.prefs.toggles & TYPING_INDICATOR_ME)))
			remove_overlay(TYPING_LAYER)
		else if(!overlays_standing[TYPING_LAYER])
			overlays_standing[TYPING_LAYER] = GLOB.human_typing_indicator
			apply_overlay(TYPING_LAYER)
	else
		remove_overlay(TYPING_LAYER)

/mob/living/carbon/human/remove_typing_indicator()
	remove_overlay(TYPING_LAYER)

/client/verb/typing_indicator()
	set name = "Show/Hide Typing Indicator"
	set category = "Preferences"
	set desc = "Toggles showing an indicator when you are typing a message."
	prefs.toggles ^= TYPING_INDICATOR_SAY
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles & TYPING_INDICATOR_SAY) ? "no longer" : "now"] display a typing indicator.")

	// Clear out any existing typing indicator.
	if(prefs.toggles & TYPING_INDICATOR_SAY)
		if(istype(mob))
			mob.update_typing_indicator()

	SSblackbox.record_feedback("tally", "toggle_verbs", 1, list("Toggle Typing Indicator (Speech)", "[usr.client.prefs.toggles & TYPING_INDICATOR_SAY ? "Disabled" : "Enabled"]"))


/client/verb/emote_indicator()
	set name = "Show/Hide Emote Typing Indicator"
	set category = "Preferences"
	set desc = "Toggles showing an indicator when you are typing an emote."
	prefs.toggles ^= TYPING_INDICATOR_ME
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles & TYPING_INDICATOR_ME) ? "no longer" : "now"] display a typing indicator for emotes.")

	// Clear out any existing typing indicator.
	if(prefs.toggles & TYPING_INDICATOR_ME)
		if(istype(mob))
			mob.update_typing_indicator(TRUE)

	SSblackbox.record_feedback("tally", "toggle_verbs", 1, list("Toggle Typing Indicator (Emote)", "[usr.client.prefs.toggles & TYPING_INDICATOR_ME ? "Disabled" : "Enabled"]"))
