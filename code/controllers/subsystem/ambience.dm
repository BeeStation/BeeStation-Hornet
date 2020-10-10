#define AMBIENT_EFFECT_COOLDOWN 600	// The minimum amount to wait between playing ambient effects (deciseconds)

#define AMBIENT_BUZZ_VOLUME 40
#define AMBIENT_MUSIC_VOLUME 75
#define AMBIENT_EFFECTS_VOLUME 45

// Ambient sounds: buzz, effects, music
SUBSYSTEM_DEF(ambience)
	name = "Ambience"
	wait = 2
	priority = FIRE_PRIORITY_AMBIENCE
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/ambience_killed = FALSE
	var/list/currentrun = list()

/datum/controller/subsystem/ambience/fire(resumed = 0)
	if (!resumed)
		src.currentrun = GLOB.clients.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/client/C = currentrun[currentrun.len]
		currentrun.len--

		if (C)
			var/mob/M = C.mob

			if(M)
				if (istype(M, /mob/dead/new_player)) // Don't play ambience to nerds in the lobby
					return

				src.update_buzz(M) // Update buzz every fire, or every 1/5th second

				if (src.times_fired % 5 == 0) // Only update effects and music every second instead of every 1/5th second
					src.update_effects(M)
					src.update_music(M)

		if (MC_TICK_CHECK)
			return


/datum/controller/subsystem/ambience/proc/update_buzz(mob/M) // Buzz, the growling buzz of the station, etc, IC (requires the user to be able to hear)
	var/area/A = get_area(M)

	//No more buzz
	if(ambience_killed)
		return

	if (A.ambient_buzz && (M.client.prefs.toggles & SOUND_SHIP_AMBIENCE) && M.can_hear_ambience())
		if ((!M.client.ambient_buzz_playing || (A.ambient_buzz != M.client.ambient_buzz_playing)) && world.time > M.client.ambient_fade_end_tick)
			var/sound/fadein = sound(A.ambient_buzz_in, repeat = 0, wait = 0, volume = AMBIENT_BUZZ_VOLUME, channel = CHANNEL_AMBIENT_BUZZ)
			M.client.ambient_fade_end_tick = world.time + (fadein.len * 10)
			SEND_SOUND(M, sound(fadein, repeat = FALSE, wait = FALSE, volume = AMBIENT_BUZZ_VOLUME, channel = CHANNEL_AMBIENT_BUZZ))
			SEND_SOUND(M, sound(A.ambient_buzz, repeat = TRUE, wait = TRUE, volume = AMBIENT_BUZZ_VOLUME, channel = CHANNEL_AMBIENT_BUZZ))
			M.client.ambient_buzz_playing = A.ambient_buzz // It's done this way so I can tell when the user switches to an area that has a different buzz effect, so we can seamlessly swap over to that one

	else if (M.client.ambient_buzz_playing) // If it's playing, and it shouldn't be, stop it
		// If the user uses ambience, the area has a fade out sound and there isn't a fade currently playing, then fade out the thing we are listening to.
		if(world.time > M.client.ambient_fade_end_tick)
			// Don't stop the fading out sound
			M.stop_sound_channel(CHANNEL_AMBIENT_BUZZ)
			var/last_sound_file = M.client.previous_area_fade_out
			if (M.client.prefs.toggles & SOUND_SHIP_AMBIENCE && last_sound_file)
				var/sound/S = sound(last_sound_file, repeat = FALSE, wait = FALSE, volume = AMBIENT_BUZZ_VOLUME, channel = CHANNEL_AMBIENT_BUZZ)
				M.client.ambient_fade_end_tick = world.time + (S.len * 10)
				SEND_SOUND(M, S)
		M.client.ambient_buzz_playing = null

	M.client.previous_area_fade_out = A.ambient_buzz_out

/datum/controller/subsystem/ambience/proc/kill_ambience(final_sound)
	for(var/mob/M in GLOB.player_list)
		if(isnewplayer(M))
			return
		SEND_SOUND(M, sound(null, repeat = FALSE, wait = FALSE, channel = CHANNEL_AMBIENT_BUZZ))
		if(M.client.prefs.toggles & SOUND_SHIP_AMBIENCE && final_sound)
			SEND_SOUND(M, sound(final_sound, repeat = FALSE, wait = FALSE, volume = AMBIENT_BUZZ_VOLUME, channel = CHANNEL_AMBIENT_BUZZ))
	ambience_killed = TRUE

/datum/controller/subsystem/ambience/proc/update_music(mob/M) // Background music, the more OOC ambience, like eerie space music
	var/area/A = get_area(M)

	if (A.ambient_music && (M.client.prefs.toggles & SOUND_AMBIENCE) && prob(1.25) && !M.client.channel_in_use(CHANNEL_AMBIENT_MUSIC)) // 1/80 chance to play every second, only play while another one is not playing
		SEND_SOUND(M, sound(pick(A.ambient_music), repeat = FALSE, wait = FALSE, volume = AMBIENT_MUSIC_VOLUME, channel = CHANNEL_AMBIENT_MUSIC))


/datum/controller/subsystem/ambience/proc/update_effects(mob/M) // Effect, random sounds that will play at random times, IC (requires the user to be able to hear)
	var/area/A = get_area(M)

	if (A.ambient_effects && (M.client.prefs.toggles & SOUND_AMBIENCE) && M.can_hear_ambience() && (world.time - M.client.ambient_effect_last_played) > AMBIENT_EFFECT_COOLDOWN && prob(5) && !M.client.channel_in_use(CHANNEL_AMBIENT_EFFECTS)) // 1/20 chance to play every second after cooldown
		SEND_SOUND(M, sound(pick(A.ambient_effects), repeat = 0, wait = 0, volume = AMBIENT_EFFECTS_VOLUME, channel = CHANNEL_AMBIENT_EFFECTS))
		M.client.ambient_effect_last_played = world.time
