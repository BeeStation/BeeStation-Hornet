#define SET_CHANNEL_VOLUME_FROM_PREF(client, channel, volume) client?.mob?.set_sound_channel_volume(channel, client?.sound_channel_initial_volumes["[channel]"] * (volume / 100))

/datum/preference/numeric/volume
	abstract_type = /datum/preference/numeric/volume
	minimum = 0
	maximum = 100

/datum/preference/numeric/volume/create_default_value()
	return maximum

/datum/preference/toggle/sound_adminhelp
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_adminhelp"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/sound_adminhelp/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	. = ..()
	if (!.)
		return FALSE

	return is_admin(preferences.parent)

/datum/preference/numeric/volume/sound_midi_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_midi_volume"
	preference_type = PREFERENCE_PLAYER

/datum/preference/numeric/volume/sound_ambience_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_ambience_volume"
	preference_type = PREFERENCE_PLAYER

/datum/preference/numeric/volume/sound_ambience_volume/apply_to_client(client/client, value)
	if(value > 0)
		if(client)
			SSambience.add_ambience_client(client)
		SET_CHANNEL_VOLUME_FROM_PREF(client, CHANNEL_AMBIENT_EFFECTS, value)
		SET_CHANNEL_VOLUME_FROM_PREF(client, CHANNEL_AMBIENT_MUSIC, value)
	else
		var/mob/client_mob = client?.mob
		if(client_mob)
			client_mob.stop_sound_channel(CHANNEL_AMBIENT_EFFECTS)
			client_mob.stop_sound_channel(CHANNEL_AMBIENT_MUSIC)

		var/drone_vol = client?.prefs?.read_player_preference(/datum/preference/numeric/volume/sound_ambient_buzz_volume)
		if(drone_vol <= 0)
			SSambience.remove_ambience_client(client)

/datum/preference/numeric/volume/sound_lobby_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_lobby_volume"
	preference_type = PREFERENCE_PLAYER

/datum/preference/numeric/volume/sound_lobby_volume/apply_to_client(client/client, value)
	SET_CHANNEL_VOLUME_FROM_PREF(client, CHANNEL_LOBBYMUSIC, value)

/datum/preference/numeric/volume/sound_instruments_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_instruments_volume"
	preference_type = PREFERENCE_PLAYER

/datum/preference/numeric/volume/sound_ambient_buzz_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_ambient_buzz_volume"
	preference_type = PREFERENCE_PLAYER

/datum/preference/numeric/volume/sound_ambient_buzz_volume/apply_to_client(client/client, value)
	if(value > 0)
		if(client)
			SSambience.add_ambience_client(client)
		SET_CHANNEL_VOLUME_FROM_PREF(client, CHANNEL_BUZZ, value)
	else
		client?.mob?.stop_sound_channel(CHANNEL_BUZZ)
		client?.buzz_playing = null

		var/ambience_vol = client?.prefs?.read_player_preference(/datum/preference/numeric/volume/sound_ambience_volume)
		if(ambience_vol <= 0)
			SSambience.remove_ambience_client(client)

/datum/preference/toggle/sound_prayers
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_prayers"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/sound_adminalert
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_adminalert"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/sound_announcements
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_announcements"
	preference_type = PREFERENCE_PLAYER

/datum/preference/numeric/volume/sound_soundtrack_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_soundtrack_volume"
	preference_type = PREFERENCE_PLAYER

/datum/preference/numeric/volume/sound_soundtrack_volume/apply_to_client(client/client, value)
	SET_CHANNEL_VOLUME_FROM_PREF(client, CHANNEL_SOUNDTRACK, value)

/datum/preference/numeric/volume/sound_ai_vox_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_ai_vox_volume"
	preference_type = PREFERENCE_PLAYER

/datum/preference/numeric/volume/sound_ai_vox_volume/apply_to_client(client/client, value)
	SET_CHANNEL_VOLUME_FROM_PREF(client, CHANNEL_VOX, value)

/// Controls hearing the combat mode toggle sound
/datum/preference/toggle/sound_combatmode
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_combatmode"
	preference_type = PREFERENCE_PLAYER

/// Controls hearing the combat mode toggle sound
/datum/preference/toggle/sound_ghostpoll
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_ghostpoll"
	preference_type = PREFERENCE_PLAYER

/// Controls hearing radio noise
/datum/preference/toggle/radio_noise
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_radio_noise"
	preference_type = PREFERENCE_PLAYER

/datum/preference/numeric/volume/sound_weather_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_weather_volume"
	preference_type = PREFERENCE_PLAYER

/datum/preference/numeric/volume/sound_weather_volume/apply_to_client(client/client, value)
	SET_CHANNEL_VOLUME_FROM_PREF(client, CHANNEL_WEATHER, value)

#undef SET_CHANNEL_VOLUME_FROM_PREF
