AUTH_CLIENT_VERB(toggletitlemusic)
	set name = "Hear/Silence Lobby Music"
	set category = "Preferences"
	set desc = "Hear Music In Lobby"
	if(!prefs)
		return
	var/hear = !prefs.read_player_preference(/datum/preference/toggle/sound_lobby)
	prefs.update_preference(/datum/preference/toggle/sound_lobby, hear)
	if(hear)
		to_chat(usr, "You will now hear music in the game lobby.")
	else
		to_chat(usr, "You will no longer hear music in the game lobby.")
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Lobby Music", "[hear ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

AUTH_CLIENT_VERB(Toggle_Soundscape)
	set name = "Hear/Silence Ambience"
	set category = "Preferences"
	set desc = "Hear Ambient Sound Effects"
	if(!prefs)
		return
	var/hear = !prefs.read_player_preference(/datum/preference/toggle/sound_ambience)
	prefs.update_preference(/datum/preference/toggle/sound_ambience, hear)
	if(hear)
		to_chat(usr, "You will now hear ambient sounds.")
	else
		to_chat(usr, "You will no longer hear ambient sounds.")
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Ambience", "[hear ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

AUTH_CLIENT_VERB(toggle_ship_ambience)
	set name = "Hear/Silence Ship Ambience"
	set category = "Preferences"
	set desc = "Hear Ship Ambience Roar"
	if(!prefs)
		return
	var/hear = !prefs.read_player_preference(/datum/preference/toggle/sound_ship_ambience)
	prefs.update_preference(/datum/preference/toggle/sound_ship_ambience, hear)
	if(hear)
		to_chat(usr, "You will now hear ship ambience.")
	else
		to_chat(usr, "You will no longer hear ship ambience.")
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Ship Ambience", "[hear ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, I bet you read this comment expecting to see the same thing :^)

AUTH_CLIENT_VERB(stop_client_sounds)
	set name = "Stop Sounds"
	set category = "Preferences"
	set desc = "Stop Current Sounds"
	SEND_SOUND(usr, sound(null))
	tgui_panel?.stop_music()
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Stop Self Sounds")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
