/client/verb/toggletitlemusic()
	set name = "Hear/Silence Lobby Music"
	set category = "Preferences"
	set desc = "Hear Music In Lobby"
	var/hear = !prefs.read_player_preference(/datum/preference/toggle/sound_lobby)
	prefs.update_preference(/datum/preference/toggle/sound_lobby, hear)
	if(hear)
		to_chat(usr, "You will now hear music in the game lobby.")
	else
		to_chat(usr, "You will no longer hear music in the game lobby.")
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Lobby Music", "[hear ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/togglemidis()
	set name = "Hear/Silence Midis"
	set category = "Preferences"
	set desc = "Hear Admin Triggered Sounds (Midis)"
	var/hear = !prefs.read_player_preference(/datum/preference/toggle/sound_midi)
	prefs.update_preference(/datum/preference/toggle/sound_midi, hear)
	if(hear)
		to_chat(usr, "You will now hear any sounds uploaded by admins.")
	else
		to_chat(usr, "You will no longer hear sounds uploaded by admins")
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Hearing Midis", "[hear ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_instruments()
	set name = "Hear/Silence Instruments"
	set category = "Preferences"
	set desc = "Hear In-game Instruments"
	var/hear = !prefs.read_player_preference(/datum/preference/toggle/sound_instruments)
	prefs.update_preference(/datum/preference/toggle/sound_instruments, hear)
	if(hear)
		to_chat(usr, "You will now hear people playing musical instruments.")
	else
		to_chat(usr, "You will no longer hear musical instruments.")
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Instruments", "[hear ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/Toggle_Soundscape()
	set name = "Hear/Silence Ambience"
	set category = "Preferences"
	set desc = "Hear Ambient Sound Effects"
	var/hear = !prefs.read_player_preference(/datum/preference/toggle/sound_ambience)
	prefs.update_preference(/datum/preference/toggle/sound_ambience, hear)
	if(hear)
		to_chat(usr, "You will now hear ambient sounds.")
	else
		to_chat(usr, "You will no longer hear ambient sounds.")
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Ambience", "[hear ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ship_ambience()
	set name = "Hear/Silence Ship Ambience"
	set category = "Preferences"
	set desc = "Hear Ship Ambience Roar"
	var/hear = !prefs.read_player_preference(/datum/preference/toggle/sound_ship_ambience)
	prefs.update_preference(/datum/preference/toggle/sound_ship_ambience, hear)
	if(hear)
		to_chat(usr, "You will now hear ship ambience.")
	else
		to_chat(usr, "You will no longer hear ship ambience.")
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Ship Ambience", "[hear ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, I bet you read this comment expecting to see the same thing :^)

/client/verb/toggle_soundtrack()
	set name = "Hear/Silence Soundtrack"
	set category = "Preferences"
	set desc = "Hear Soundtrack Songs"
	var/hear = !prefs.read_player_preference(/datum/preference/toggle/sound_soundtrack)
	prefs.update_preference(/datum/preference/toggle/sound_soundtrack, hear)
	if(hear)
		to_chat(usr, "You will now hear soundtrack songs.")
	else
		to_chat(usr, "You will no longer hear soundtrack songs.")
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Soundtrack", "[hear ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, I bet you read this comment expecting to see the same thing :^)


/client/verb/toggle_announcement_sound()
	set name = "Hear/Silence Announcements"
	set category = "Preferences"
	set desc = "Hear Announcement Sound"
	var/hear = !prefs.read_player_preference(/datum/preference/toggle/sound_lobby)
	prefs.update_preference(/datum/preference/toggle/sound_lobby, hear)
	to_chat(usr, "You will now [hear ? "hear announcement sounds" : "no longer hear announcements"].")
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Announcement Sound", "[hear ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/stop_client_sounds()
	set name = "Stop Sounds"
	set category = "Preferences"
	set desc = "Stop Current Sounds"
	SEND_SOUND(usr, sound(null))
	tgui_panel?.stop_music()
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Stop Self Sounds")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

// TODU tgui-prefs
/*
/client/proc/toggle_hear_radio()
	set name = "Show/Hide Radio Chatter"
	set category = "Prefs - Admin"
	set desc = "Toggle seeing radiochatter from nearby radios and speakers"
	if(!holder)
		return
	prefs.chat_toggles ^= CHAT_RADIO
	prefs.save_preferences()
	to_chat(usr, "You will [(prefs.chat_toggles & CHAT_RADIO) ? "now" : "no longer"] see radio chatter from nearby radios or speakers")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Radio Chatter", "[prefs.chat_toggles & CHAT_RADIO ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/deadchat()
	set name = "Show/Hide Deadchat"
	set category = "Prefs - Admin"
	set desc ="Toggles seeing deadchat"
	if(!holder)
		return
	prefs.chat_toggles ^= CHAT_DEAD
	prefs.save_preferences()
	to_chat(src, "You will [(prefs.chat_toggles & CHAT_DEAD) ? "now" : "no longer"] see deadchat.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Deadchat Visibility", "[prefs.chat_toggles & CHAT_DEAD ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleprayers()
	set name = "Show/Hide Prayers"
	set category = "Prefs - Admin"
	set desc = "Toggles seeing prayers"
	if(!holder)
		return
	prefs.chat_toggles ^= CHAT_PRAYER
	prefs.save_preferences()
	to_chat(src, "You will [(prefs.chat_toggles & CHAT_PRAYER) ? "now" : "no longer"] see prayerchat.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Prayer Visibility", "[prefs.chat_toggles & CHAT_PRAYER ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_prayer_sound()
	set name = "Hear/Silence Prayer Sounds"
	set category = "Prefs - Admin"
	set desc = "Hear Prayer Sounds"
	if(!holder)
		return
	prefs.toggles ^= PREFTOGGLE_SOUND_PRAYERS
	prefs.save_preferences()
	to_chat(usr, "You will [(prefs.toggles & PREFTOGGLE_SOUND_PRAYERS) ? "now" : "no longer"] hear a sound when prayers arrive.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Prayer Sounds", "[prefs.toggles & PREFTOGGLE_SOUND_PRAYERS ? "Enabled" : "Disabled"]"))

/client/proc/colorasay()
	set name = "Set Admin Say Color"
	set category = "Prefs - Admin"
	set desc = "Set the color of your ASAY messages"
	if(!holder)
		return
	if(!CONFIG_GET(flag/allow_admin_asaycolor))
		to_chat(src, "Custom Asay color is currently disabled by the server.")
		return
	var/new_asaycolor = input(src, "Please select your ASAY color.", "ASAY color", prefs.asaycolor) as color|null
	if(new_asaycolor)
		prefs.asaycolor = sanitize_ooccolor(new_asaycolor)
		prefs.save_preferences()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Set ASAY Color")
	return

/client/proc/resetasaycolor()
	set name = "Reset your Admin Say Color"
	set desc = "Returns your ASAY Color to default"
	set category = "Prefs - Admin"
	if(!holder)
		return
	if(!CONFIG_GET(flag/allow_admin_asaycolor))
		to_chat(src, "Custom Asay color is currently disabled by the server.")
		return
	prefs.asaycolor = initial(prefs.asaycolor)
	prefs.save_preferences()
*/
