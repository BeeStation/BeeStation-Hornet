/// The subsystem used to play ambience to users every now and then, makes them real excited.
SUBSYSTEM_DEF(ambience)
	name = "Ambience"
	flags = SS_BACKGROUND|SS_NO_INIT
	priority = FIRE_PRIORITY_AMBIENCE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 2
	///Assoc list of listening client - next ambience time
	var/list/ambience_listening_clients = list()
	///Cache for sanic speed :D
	var/list/currentrun = list()

/datum/controller/subsystem/ambience/fire(resumed)
	if(!resumed)
		currentrun = ambience_listening_clients.Copy()
	var/list/cached_clients = currentrun

	while(cached_clients.len)
		var/client/client_iterator = cached_clients[cached_clients.len]
		cached_clients.len--
		process_ambience_client(client_iterator)

		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/ambience/proc/process_ambience_client(client/to_process)
	if(isnull(to_process) || isnewplayer(to_process.mob))
		return

	var/area/current_area = get_area(to_process.mob)
	if(!current_area) //Something's gone horribly wrong
		stack_trace("[key_name(to_process)] has somehow ended up in nullspace. WTF did you do -xoxo ambience subsystem")
		ambience_listening_clients -= to_process
		return

	play_buzz(to_process.mob, current_area)

	if(ambience_listening_clients[to_process] > world.time)
		return //Not ready for the next sound

	var/ambi_fx = pick(current_area.ambientsounds)
	var/ambi_music = pick(current_area.ambientmusic)

	play_ambience_music(to_process.mob, ambi_music, current_area)
	play_ambience_effects(to_process.mob, ambi_fx, current_area)

	ambience_listening_clients[to_process] = world.time + rand(current_area.min_ambience_cooldown, current_area.max_ambience_cooldown)

/datum/controller/subsystem/ambience/proc/remove_ambience_client(client/to_remove)
	ambience_listening_clients -= to_remove
	currentrun -= to_remove

/datum/controller/subsystem/ambience/proc/play_buzz(mob/M, area/A)
	if (A.ambient_buzz && (M.client.prefs.toggles & PREFTOGGLE_SOUND_SHIP_AMBIENCE) && M.can_hear_ambience())
		if (!M.client.buzz_playing || (A.ambient_buzz != M.client.buzz_playing))
			SEND_SOUND(M, sound(A.ambient_buzz, repeat = 1, wait = 0, volume = 40, channel = CHANNEL_BUZZ))
			M.client.buzz_playing = A.ambient_buzz // It's done this way so I can tell when the user switches to an area that has a different buzz effect, so we can seamlessly swap over to that one

	else if (M.client.buzz_playing) // If it's playing, and it shouldn't be, stop it
		M.stop_sound_channel(CHANNEL_BUZZ)
		M.client.buzz_playing = null

/datum/controller/subsystem/ambience/proc/play_ambience_music(mob/M, _ambi_music, area/A) // Background music, the more OOC ambience, like eerie space music
	if(A.ambientmusic && !M.client?.channel_in_use(CHANNEL_AMBIENT_MUSIC))
		SEND_SOUND(M, sound(_ambi_music, repeat = 0, wait = 0, volume = 75, channel = CHANNEL_AMBIENT_MUSIC))

/datum/controller/subsystem/ambience/proc/play_ambience_effects(mob/M, _ambi_fx, area/A) // Effect, random sounds that will play at random times, IC (requires the user to be able to hear)
	if (length(A.ambientsounds) && M.can_hear_ambience() && !M.client?.channel_in_use(CHANNEL_AMBIENT_EFFECTS))
		SEND_SOUND(M, sound(_ambi_fx, repeat = 0, wait = 0, volume = 45, channel = CHANNEL_AMBIENT_EFFECTS))
