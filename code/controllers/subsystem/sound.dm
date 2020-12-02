/*
 * Sound subsystem:
 * Used for things that need constant updating (sound fading in / out)
*/

SUBSYSTEM_DEF(sound_effects)
	name = "Sound"
	wait = 1
	priority = FIRE_PRIORITY_AMBIENCE
	flags = SS_NO_INIT
	//Note: Make sure you update this if you use sound fading pre-game
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/acting_effects = list()	//key = sound, value = datum
	var/list/currentrun = list()

/datum/controller/subsystem/sound_effects/fire(resumed = 0)
	if (!resumed)
		src.currentrun = acting_effects.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(LAZYLEN(currentrun))
		var/datum/sound_effect/sound_effect = currentrun[currentrun[currentrun.len]]
		currentrun.len--

		sound_effect.update_effect()

		if(world.time > sound_effect.end_tick)
			sound_effect.end_effect()
			acting_effects -= sound_effect.effect_id

		if (MC_TICK_CHECK)
			return

// ===== Sound effect procs =====

/proc/sound_fade(sound/S, start_volume = 100, end_volume = 0, time = 10, var/listeners)
	//Check basics
	if(!S)
		CRASH("sound_fade called without a sound file.")
	if(!listeners)
		return
	//Check in list format
	var/listeners_list = listeners
	if(!islist(listeners_list))
		listeners_list = list(listeners)
	//Create datum
	new /datum/sound_effect/fade(S, listeners_list, time, start_volume, end_volume)

// ===== Sound effect datum =====

/datum/sound_effect
	var/name = "null"
	var/sound/sound
	var/list/listeners
	var/start_tick
	var/end_tick
	var/effect_id

/datum/sound_effect/New(S, list/_listeners, time)
	. = ..()
	sound = S
	listeners = _listeners
	start_tick = world.time
	end_tick = world.time + time
	effect_id = generate_id()
	start_sound()

/datum/sound_effect/proc/generate_id()
	var/id = "[name][sound.file]"
	for(var/A in listeners)
		id = "[id][REF(A)]"
	return id

/datum/sound_effect/proc/send_sound()
	for(var/reciever in listeners)
		SEND_SOUND(reciever, sound)

/datum/sound_effect/proc/update_effect()
	return	//Not implemented

/datum/sound_effect/proc/end_effect()
	return	//Not implemented

// Send the sound to the person it's affecting and add it to the sound subsystem.
// Should be overridden to account for if an effect is already playing for that sound.
/datum/sound_effect/proc/start_sound()
	send_sound()
	SSsound_effects.acting_effects[effect_id] = src

//============== Fade =============

/datum/sound_effect/fade
	name = "fade"
	var/in_vol
	var/out_vol
	//Calculated
	var/current_vol

/datum/sound_effect/fade/New(S, list/_listeners, time, start_vol, end_vol)
	in_vol = start_vol
	out_vol = end_vol
	. = ..(S, _listeners, time)

/datum/sound_effect/fade/start_sound()
	//If the sound is already playing, make it fade from the current point
	if(SSsound_effects.acting_effects[effect_id])
		var/datum/sound_effect/fade/old_sound = SSsound_effects.acting_effects[effect_id]
		in_vol = old_sound.current_vol
	else
		send_sound()
	SSsound_effects.acting_effects[effect_id] = src

/datum/sound_effect/fade/update_effect()
	var/time_multiplier = CLAMP((world.time - start_tick) / (end_tick - start_tick), 0, 1)
	current_vol = (time_multiplier * out_vol) + ((1-time_multiplier) * in_vol)
	sound.status = SOUND_UPDATE
	sound.volume = current_vol

	for(var/reciever in listeners)
		SEND_SOUND(reciever, sound)

/datum/sound_effect/fade/end_effect()
	if(!out_vol)
		sound.repeat = FALSE
