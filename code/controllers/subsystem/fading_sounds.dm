PROCESSING_SUBSYSTEM_DEF(fading_sounds)
	name = "Fading Sounds"
	wait = 1
	priority = FIRE_PRIORITY_AMBIENCE
	ss_flags = SS_TICKER | SS_BACKGROUND | SS_NO_INIT
	// Note: Make sure you update this if you use sound fading pre-game
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

/**
 * A helper proc to set up a fading sound.
 *
 * Arguments:
 * * sound_instance: The sound which is being faded. Cannot be a file
 * * listeners: The list of mobs which hear this fading sound
 * * time: The time it takes for the sound to fade to its final volume
 * * start_volume: The volume which the sound starts at
 * * end_volume: The volume which the sound fades to
 * * volume_preference: If specified, this sound slider preference is used to modify the sound volume per client
 */
/proc/sound_fade(sound/sound_instance, list/listeners, time = 1 SECONDS, start_volume = 100, end_volume = 0, volume_preference)
	if(!istype(sound_instance, /sound))
		CRASH("sound_fade() was called without a sound instance")

	if(ismob(listeners))
		listeners = list(listeners)
	else if(!islist(listeners))
		CRASH("sound_fade() was called without a valid listeners list")
	else if(!length(listeners))
		CRASH("sound_fade() was called with an empty listeners list")

	new /datum/fading_sound(sound_instance, listeners, time, start_volume, end_volume, volume_preference)

/datum/fading_sound
	/// The instance of the sound that we're playing
	VAR_PRIVATE/sound/sound
	/// The list of mobs which will be listening to us
	VAR_PRIVATE/list/listeners
	/// The world time that we started at
	VAR_PRIVATE/start_tick
	/// The world time that we will end at
	VAR_PRIVATE/end_tick
	/// Whether or not this sound effect is using a defined channel and not a randomly assigned one
	VAR_PRIVATE/has_custom_channel
	/// The audio preference of this looping sound. Used as a multiplier per player
	VAR_PRIVATE/volume_preference
	/// The volume this sound effect starts at
	VAR_PRIVATE/start_volume
	/// The volume this sound effect ends at
	VAR_PRIVATE/end_volume

/datum/fading_sound/New(sound/sound, list/listeners, time, start_volume, end_volume, volume_preference)
	src.sound = sound
	src.listeners = listeners
	src.volume_preference = volume_preference
	src.start_volume = start_volume
	src.end_volume = end_volume

	start_tick = world.time
	end_tick = world.time + time

	// Ensure we have a valid channel
	sound.channel ||= SSsounds.random_available_channel()
	has_custom_channel = HAS_UNIQUE_SOUND_CHANNEL(sound)

	// Manage our refs. I'm trusting you to not have non-mobs in this list
	for(var/mob/listener as anything in listeners)
		RegisterSignal(listener, COMSIG_QDELETING, PROC_REF(on_listener_deleted))

	START_PROCESSING(SSfading_sounds, src)
	send_sound()

/datum/fading_sound/process()
	if(world.time > end_tick)
		return PROCESS_KILL

	var/time_multiplier = clamp((world.time - start_tick) / (end_tick - start_tick), 0, 1)
	sound.status = SOUND_UPDATE
	sound.volume = (time_multiplier * end_volume) + ((1 - time_multiplier) * start_volume)
	send_sound()

/datum/fading_sound/proc/send_sound()
	PRIVATE_PROC(TRUE)

	var/previous_volume = sound.volume
	for(var/mob/receiver as anything in listeners)
		if(has_custom_channel)
			receiver.client?.sound_channel_initial_volumes[sound.channel] = sound.volume

		if(ispath(volume_preference, /datum/preference/numeric/volume))
			var/pref_volume = receiver.client?.prefs?.read_player_preference(volume_preference)
			sound.volume *= pref_volume / 100

		SEND_SOUND(receiver, sound)
		sound.volume = previous_volume

/datum/fading_sound/proc/on_listener_deleted(datum/source, force)
	SIGNAL_HANDLER
	listeners -= source
	if(!length(listeners))
		STOP_PROCESSING(SSfading_sounds, src)
