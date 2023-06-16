/datum/preference/toggle/sound_adminhelp
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_adminhelp"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/sound_adminhelp/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return is_admin(preferences.parent)

/datum/preference/toggle/sound_midi
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_midi"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/sound_midi/apply_to_client(client/client, value)
	if(!value)
		client.mob.stop_sound_channel(CHANNEL_ADMIN)
		client.tgui_panel?.stop_music()

/datum/preference/toggle/sound_ambience
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_ambience"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/sound_ambience/apply_to_client(client/client, value)
	if(value)
		SSambience.add_ambience_client(src)
	else
		client.mob.stop_sound_channel(CHANNEL_AMBIENT_EFFECTS)
		client.mob.stop_sound_channel(CHANNEL_AMBIENT_MUSIC)
		client.mob.stop_sound_channel(CHANNEL_BUZZ)
		client.buzz_playing = FALSE
		SSambience.remove_ambience_client(src)

/datum/preference/toggle/sound_lobby
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_lobby"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/sound_lobby/apply_to_client(client/client, value)
	if (value && isnewplayer(client.mob))
		client.playtitlemusic()
	else
		client.mob.stop_sound_channel(CHANNEL_LOBBYMUSIC)

/datum/preference/toggle/sound_instruments
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_instruments"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/sound_ship_ambience
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_ship_ambience"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/sound_ship_ambience/apply_to_client(client/client, value)
	if(!value)
		client.mob.stop_sound_channel(CHANNEL_BUZZ)
		client.buzz_playing = FALSE

/datum/preference/toggle/sound_prayers
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_prayers"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/sound_announcements
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_announcements"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/sound_soundtrack
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_soundtrack"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/sound_soundtrack/apply_to_client(client/client, value)
	if (value)
		client.mob.play_current_soundtrack()
	else
		client.mob.stop_sound_channel(CHANNEL_SOUNDTRACK)
