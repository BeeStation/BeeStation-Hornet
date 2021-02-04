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

			if(M?.client)
				if (istype(M, /mob/dead/new_player)) // Don't play ambience to nerds in the lobby
					continue

				src.update_buzz(M) // Update buzz every fire, or every 1/5th second

				if (src.times_fired % 5 == 0) // Only update effects and music every second instead of every 1/5th second
					src.update_effects(M)
					src.update_music(M)

		if (MC_TICK_CHECK)
			return


/datum/controller/subsystem/ambience/proc/update_buzz(mob/M) // Buzz, the growling buzz of the station, etc, IC (requires the user to be able to hear)
	var/area/A = get_area(M)

	if (A.ambient_buzz && (M.client.prefs.toggles & SOUND_SHIP_AMBIENCE) && M.can_hear_ambience())
		if (!M.client.ambient_buzz_playing || (A.ambient_buzz != M.client.ambient_buzz_playing))
			SEND_SOUND(M, sound(A.ambient_buzz, repeat = 1, wait = 0, volume = AMBIENT_BUZZ_VOLUME, channel = CHANNEL_AMBIENT_BUZZ))
			M.client.ambient_buzz_playing = A.ambient_buzz // It's done this way so I can tell when the user switches to an area that has a different buzz effect, so we can seamlessly swap over to that one

	else if (M.client.ambient_buzz_playing) // If it's playing, and it shouldn't be, stop it
		M.stop_sound_channel(CHANNEL_AMBIENT_BUZZ)
		M.client.ambient_buzz_playing = null


/datum/controller/subsystem/ambience/proc/update_music(mob/M) // Background music, the more OOC ambience, like eerie space music
	var/area/A = get_area(M)

	if (A.ambient_music && (M.client.prefs.toggles & SOUND_AMBIENCE) && prob(1.25) && !M.client.channel_in_use(CHANNEL_AMBIENT_MUSIC)) // 1/80 chance to play every second, only play while another one is not playing
		SEND_SOUND(M, sound(pick(A.ambient_music), repeat = 0, wait = 0, volume = AMBIENT_MUSIC_VOLUME, channel = CHANNEL_AMBIENT_MUSIC))


/datum/controller/subsystem/ambience/proc/update_effects(mob/M) // Effect, random sounds that will play at random times, IC (requires the user to be able to hear)
	var/area/A = get_area(M)

	if (A.ambient_effects && (M.client.prefs.toggles & SOUND_AMBIENCE) && M.can_hear_ambience() && (world.time - M.client.ambient_effect_last_played) > AMBIENT_EFFECT_COOLDOWN && prob(5) && !M.client.channel_in_use(CHANNEL_AMBIENT_EFFECTS)) // 1/20 chance to play every second after cooldown
		SEND_SOUND(M, sound(pick(A.ambient_effects), repeat = 0, wait = 0, volume = AMBIENT_EFFECTS_VOLUME, channel = CHANNEL_AMBIENT_EFFECTS))
		M.client.ambient_effect_last_played = world.time
