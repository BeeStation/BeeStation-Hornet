/// The subsystem used to play ambience to users every now and then, makes them real excited.
SUBSYSTEM_DEF(ambience)
	name = "Ambience"
	ss_flags = SS_BACKGROUND | SS_NO_INIT
	priority = FIRE_PRIORITY_AMBIENCE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 1 SECONDS

	/// Assoc list of listening client - next ambience time
	var/list/ambience_listening_clients = list()
	/// Cache for sanic speed :D
	var/list/currentrun = list()

/datum/controller/subsystem/ambience/fire(resumed = FALSE)
	if(!resumed)
		currentrun = ambience_listening_clients.Copy()

	var/list/cached_clients = currentrun
	while(cached_clients.len)
		var/client/client_iterator = cached_clients[cached_clients.len]
		cached_clients.len--

		//Check to see if the client exists and isn't held by a new player
		var/mob/client_mob = client_iterator?.mob
		if(isnull(client_iterator) || isnull(client_mob) || isnewplayer(client_mob))
			continue

		process_ambience_client(client_iterator)

		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/ambience/proc/process_ambience_client(client/to_process)
	var/mob/current_mob = to_process.mob

	var/area/current_area = get_area(current_mob)
	if(!current_area) //Something's gone horribly wrong
		stack_trace("[key_name(to_process)] has somehow ended up in nullspace. WTF did you do -xoxo ambience subsystem")
		ambience_listening_clients -= to_process
		return

	if(current_area.ambient_buzz)
		play_buzz(current_mob, current_area)

	if(ambience_listening_clients[to_process] > world.time)
		return //Not ready for the next sound

	var/ambi_fx
	if(length(current_area.rare_ambient_sounds) && prob(0.5))
		ambi_fx = pick(current_area.rare_ambient_sounds)
	else if(length(current_area.ambientsounds))
		ambi_fx = pick(current_area.ambientsounds)

	if(ambi_fx)
		play_ambience_effects(current_mob, ambi_fx)

	if(length(current_area.ambientmusic))
		var/ambi_music = pick(current_area.ambientmusic)
		play_ambience_music(current_mob, ambi_music)

	ambience_listening_clients[to_process] = world.time + rand(current_area.min_ambience_cooldown, current_area.max_ambience_cooldown)

/datum/controller/subsystem/ambience/proc/add_ambience_client(client/to_add)
	if(SSambience.ambience_listening_clients[to_add] > world.time)
		return // If already properly set we don't want to reset the timer.
	SSambience.ambience_listening_clients[to_add] = world.time + 10 SECONDS //Just wait 10 seconds before the next one aight mate? cheers.

/datum/controller/subsystem/ambience/proc/remove_ambience_client(client/to_remove)
	ambience_listening_clients -= to_remove
	currentrun -= to_remove

/// Buzzing sound, the low ship drone that plays constantly, IC (requires the user to be able to hear)
/datum/controller/subsystem/ambience/proc/play_buzz(mob/ambience_hearer, area/buzz_area)
	if(ambience_hearer.can_hear_ambience())
		var/buzz_info = "[buzz_area.ambient_buzz][buzz_area.ambient_buzz_vol]"
		var/pref_volume = ambience_hearer.client?.prefs.read_player_preference(/datum/preference/numeric/volume/sound_ambient_buzz_volume)
		if (pref_volume > 0 && (!ambience_hearer.client?.buzz_playing || ambience_hearer.client?.buzz_playing != buzz_info))
			SEND_SOUND(ambience_hearer, sound(buzz_area.ambient_buzz, repeat = TRUE, wait = FALSE, volume = buzz_area.ambient_buzz_vol * (pref_volume / 100), channel = CHANNEL_BUZZ))

			ambience_hearer.client?.sound_channel_initial_volumes["[CHANNEL_BUZZ]"] = buzz_area.ambient_buzz_vol
			// It's done this way so I can tell when the user switches to an area that has a different buzz effect, so we can seamlessly swap over to that one
			ambience_hearer.client?.buzz_playing = buzz_info
		return

	if(ambience_hearer.client.buzz_playing) // If it's playing, and it shouldn't be, stop it
		ambience_hearer.stop_sound_channel(CHANNEL_BUZZ)
		ambience_hearer.client.buzz_playing = null

/// Effect, random sounds that will play at random times, IC (requires the user to be able to hear)
/datum/controller/subsystem/ambience/proc/play_ambience_effects(mob/ambience_hearer, sound/effect_to_play)
	if(!ambience_hearer.can_hear_ambience() || !ambience_hearer.client || ambience_hearer.client?.get_playing_channel(CHANNEL_AMBIENT_EFFECTS))
		return

	var/pref_volume = ambience_hearer.client?.prefs.read_player_preference(/datum/preference/numeric/volume/sound_ambience_volume)
	if(pref_volume > 0)
		ambience_hearer.client?.sound_channel_initial_volumes["[CHANNEL_AMBIENT_EFFECTS]"] = 45
		SEND_SOUND(ambience_hearer, sound(effect_to_play, repeat = FALSE, volume = 45 * (pref_volume / 100), channel = CHANNEL_AMBIENT_EFFECTS))

/// Play background music, the more OOC ambience, like eerie space music
/datum/controller/subsystem/ambience/proc/play_ambience_music(mob/ambience_hearer, sound/music_to_play)
	if(!ambience_hearer.client || ambience_hearer.client.get_playing_channel(CHANNEL_AMBIENT_MUSIC))
		return

	var/pref_volume = ambience_hearer.client?.prefs.read_player_preference(/datum/preference/numeric/volume/sound_ambience_volume)
	if(pref_volume > 0)
		ambience_hearer.client?.sound_channel_initial_volumes["[CHANNEL_AMBIENT_MUSIC]"] = 75
		SEND_SOUND(ambience_hearer, sound(music_to_play, repeat = FALSE, volume = 75 * (pref_volume / 100), channel = CHANNEL_AMBIENT_MUSIC))
