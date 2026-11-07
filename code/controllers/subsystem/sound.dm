/*
 * Sound subsystem:
 * Used for things that need constant updating (sound fading in / out)
*/

SUBSYSTEM_DEF(sound_effects)
	name = "Sound"
	wait = 0.1 SECONDS
	priority = FIRE_PRIORITY_AMBIENCE
	ss_flags = SS_NO_INIT
	//Note: Make sure you update this if you use sound fading pre-game
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	/// Associative list of the currently running sound effects
	/// sound effect id --> sound effect instance
	var/list/acting_effects = list()
	var/list/currentrun = list()

/datum/controller/subsystem/sound_effects/fire(resumed = 0)
	if (!resumed)
		src.currentrun = acting_effects.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(LAZYLEN(currentrun))
		var/datum/sound_effect/sound_effect = currentrun[currentrun[length(currentrun)]]
		currentrun.len--

		sound_effect.update_effect()

		if(world.time > sound_effect.end_tick)
			sound_effect.end_effect()
			acting_effects -= sound_effect.effect_id

		if (MC_TICK_CHECK)
			return

// ===== Sound effect procs =====

/proc/sound_fade(sound/sound_file, list/listeners, time = 1 SECONDS, start_volume = 100, end_volume = 0, volume_preference)
	//Check basics
	if(!istype(sound_file, /sound))
		CRASH("sound_fade() called without a sound instance.")
	if(ismob(listeners) || istype(listeners, /client))
		listeners = list(listeners)
	else if(!length(listeners))
		CRASH("sound_fade() called without a valid listeners list.")
	//Create datum
	new /datum/sound_effect/fade(sound_file, listeners, time, volume_preference, start_volume, end_volume)

// ===== Sound effect datum =====

/datum/sound_effect
	var/name = "null"
	var/sound/sound
	var/list/listeners
	var/start_tick
	var/end_tick
	var/effect_id
	/// Whether or not this sound effect is using a defined channel and not a randomly assigned one
	var/has_custom_channel
	/// The audio preference of this looping sound. Used as a multiplier per player
	var/volume_preference

/datum/sound_effect/New(sound/sound, list/listeners, time, volume_preference)
	. = ..()
	src.sound = sound
	src.listeners = listeners
	src.volume_preference = volume_preference

	// Ensure we have a valid channel
	sound.channel ||= SSsounds.random_available_channel()
	has_custom_channel = HAS_UNIQUE_SOUND_CHANNEL(sound)

	start_tick = world.time
	end_tick = world.time + time
	effect_id = generate_id()
	start_sound()

/datum/sound_effect/proc/generate_id()
	var/id = "[name][sound.file]"
	for(var/datum/listener as anything in listeners)
		id += FAST_REF(listener)
		// I would've made this its own proc, but I don't want to loop through listeners multiple times
		RegisterSignal(listener, COMSIG_QDELETING, PROC_REF(on_listener_deleted))
	return id

/datum/sound_effect/proc/send_sound()
	for(var/receiver in listeners)
		if(has_custom_channel)
			astype(receiver, /mob)?.client?.sound_channel_initial_volumes["[sound.channel]"] = sound.volume
			astype(receiver, /client)?.sound_channel_initial_volumes["[sound.channel]"] = sound.volume

		var/previous_volume = sound.volume
		if(ispath(volume_preference))
			var/client/receiver_client = astype(receiver, /mob)?.client || astype(receiver, /client)
			var/pref_volume = receiver_client?.prefs?.read_player_preference(volume_preference)
			sound.volume *= pref_volume / 100

		SEND_SOUND(receiver, sound)
		sound.volume = previous_volume

/datum/sound_effect/proc/update_effect()
	return

/datum/sound_effect/proc/end_effect()
	return

// Send the sound to the person it's affecting and add it to the sound subsystem.
// Should be overridden to account for if an effect is already playing for that sound.
/datum/sound_effect/proc/start_sound()
	send_sound()
	SSsound_effects.acting_effects[effect_id] = src

/datum/sound_effect/proc/on_listener_deleted(datum/source, force)
	SIGNAL_HANDLER
	listeners -= source
	UnregisterSignal(source, COMSIG_QDELETING)

//============== Fade =============

/datum/sound_effect/fade
	name = "fade"
	/// The volume this sound effect starts at
	var/in_vol
	/// The volume this sound effect ends at
	var/out_vol
	/// Calculated
	var/current_vol

/datum/sound_effect/fade/New(sound/sound, list/listeners, time, volume_preference, start_vol, end_vol)
	. = ..()
	in_vol = start_vol
	out_vol = end_vol

/datum/sound_effect/fade/start_sound()
	//If the sound is already playing, make it fade from the current point
	if(SSsound_effects.acting_effects[effect_id])
		var/datum/sound_effect/fade/old_sound = SSsound_effects.acting_effects[effect_id]
		in_vol = old_sound.current_vol
	else
		send_sound()
	SSsound_effects.acting_effects[effect_id] = src

/datum/sound_effect/fade/update_effect()
	var/time_multiplier = clamp((world.time - start_tick) / (end_tick - start_tick), 0, 1)
	current_vol = (time_multiplier * out_vol) + ((1-time_multiplier) * in_vol)
	sound.status = SOUND_UPDATE
	sound.volume = current_vol

	for(var/receiver in listeners)
		if(has_custom_channel)
			astype(receiver, /mob)?.client?.sound_channel_initial_volumes["[sound.channel]"] = sound.volume
			astype(receiver, /client)?.sound_channel_initial_volumes["[sound.channel]"] = sound.volume

		var/previous_volume = sound.volume
		if(ispath(volume_preference))
			var/client/receiver_client = astype(receiver, /mob)?.client || astype(receiver, /client)
			var/pref_volume = receiver_client?.prefs?.read_player_preference(volume_preference)
			sound.volume *= pref_volume / 100

		SEND_SOUND(receiver, sound)
		sound.volume = previous_volume

/datum/sound_effect/fade/end_effect()
	if(!out_vol)
		sound.repeat = FALSE
